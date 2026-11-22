import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/core/network/api/api_error_message.dart';
import 'package:kroppi/features/profile/domain/entities/subscription_access.dart';
import 'package:kroppi/features/profile/presentation/cubit/subscription_cubit.dart';
import 'package:kroppi/features/profile/presentation/widgets/subscription_access.dart';

Map<String, dynamic> status({bool premium = false, int used = 3}) {
  final now = DateTime.now().toUtc();
  return {
    'plan_type': premium ? 'premium' : 'free',
    'premium_until': premium
        ? now.add(const Duration(days: 30)).toIso8601String()
        : null,
    'premium_features_available': premium,
    'limits': {
      'farms': premium ? null : 1,
      'crops': premium ? null : 2,
      'plots': premium ? null : 5,
      'diagnoses': premium ? 30 : 3,
    },
    'usage': {'farms': 2, 'crops': 2, 'plots': 5, 'diagnoses': used},
    'remaining': {
      'farms': premium ? null : 0,
      'crops': premium ? null : 0,
      'plots': premium ? null : 0,
      'diagnoses': premium ? 30 - used : (3 - used).clamp(0, 3),
    },
    'diagnosis_period': {
      'starts_at': now.subtract(const Duration(days: 2)).toIso8601String(),
      'renews_at': now.add(const Duration(days: 10)).toIso8601String(),
      'timezone': 'America/Bogota',
    },
  };
}

void main() {
  test('Free conserva los registros por encima del límite', () {
    final free = SubscriptionAccess.fromJson(status(used: 8));
    expect(free.isPremium, isFalse);
    expect(free.quota(PlanResource.farms).used, 2);
    expect(free.quota(PlanResource.farms).exhausted, isTrue);
    expect(free.quota(PlanResource.diagnoses).left, 0);
    expect(
      free.allowsDiagnosisHistoryAt(
        free.startsAt.subtract(const Duration(seconds: 1)),
      ),
      isFalse,
    );
  });

  test('Premium usa límites nulos y conserva el período de la IA', () {
    final premium = SubscriptionAccess.fromJson(status(premium: true));
    expect(premium.premiumFeatures, isTrue);
    expect(premium.quota(PlanResource.farms).limit, isNull);
    expect(premium.quota(PlanResource.farms).exhausted, isFalse);
    expect(premium.quota(PlanResource.diagnoses).left, 27);
    expect(premium.allowsDiagnosisHistoryAt(DateTime.utc(2000)), isTrue);
  });

  test('actualiza plan y consumo y permite reintentar ante un error', () async {
    bool premium = false;
    bool fail = false;
    final cubit = SubscriptionCubit(() async {
      if (fail) throw const FormatException('Respuesta inválida');
      return SubscriptionAccess.fromJson(status(premium: premium));
    });
    addTearDown(cubit.close);

    await cubit.setAccount('account');
    expect(cubit.state.canDiagnose, isFalse);
    premium = true;
    await cubit.refresh();
    expect(cubit.state.canDiagnose, isTrue);
    fail = true;
    await cubit.refresh();
    expect(cubit.state.access, isNull);
    expect(cubit.state.error, contains('Respuesta inválida'));
    fail = false;
    premium = false;
    await cubit.refresh();
    expect(cubit.state.access?.isPremium, isFalse);
  });

  test('descarta respuestas de una sesión anterior', () async {
    final previous = Completer<SubscriptionAccess>();
    final started = Completer<void>();
    var calls = 0;
    final cubit = SubscriptionCubit(() {
      if (calls++ == 0) {
        started.complete();
        return previous.future;
      }
      return Future.value(SubscriptionAccess.fromJson(status()));
    });
    addTearDown(cubit.close);

    final oldRequest = cubit.setAccount('previous');
    await started.future;
    await cubit.setAccount('current');
    previous.complete(SubscriptionAccess.fromJson(status(premium: true)));
    await oldRequest;
    expect(cubit.state.access?.isPremium, isFalse);
    await cubit.setAccount(null);
    expect(cubit.state.access, isNull);
  });

  test('conserva el mensaje de denegación enviado por FastAPI', () {
    final request = RequestOptions(path: '/diagnoses');
    for (final code in [403, 409, 429]) {
      final error = DioException.badResponse(
        statusCode: code,
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: code,
          data: {'detail': 'Denegación del servidor'},
        ),
      );
      expect(apiErrorMessage(error), 'Denegación del servidor');
    }
  });

  testWidgets('el formulario solo se abre cuando el servidor da cupo', (
    tester,
  ) async {
    var premium = false;
    final cubit = SubscriptionCubit(
      () async => SubscriptionAccess.fromJson(status(premium: premium)),
    );
    await cubit.setAccount('account');
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          home: SubscriptionGate(
            resource: PlanResource.farms,
            builder: (_) => const Text('Formulario'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Alcanzaste el límite de fincas'),
      findsOneWidget,
    );
    expect(find.text('Consultar planes'), findsOneWidget);
    expect(find.text('Formulario'), findsNothing);

    premium = true;
    await cubit.refresh();
    await tester.pumpAndSettle();
    expect(find.text('Formulario'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await cubit.close();
  });

  testWidgets('Premium habilita el módulo y Free mantiene el registro', (
    tester,
  ) async {
    var premium = true;
    final cubit = SubscriptionCubit(
      () async => SubscriptionAccess.fromJson(status(premium: premium)),
    );
    await cubit.setAccount('account');
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          home: SubscriptionGate(
            premium: true,
            freeAction: const Text('Registrar cosecha'),
            builder: (_) => const Text('Historial de cosechas'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Historial de cosechas'), findsOneWidget);

    premium = false;
    await cubit.refresh();
    await tester.pumpAndSettle();
    expect(find.text('Historial de cosechas'), findsNothing);
    expect(find.text('Registrar cosecha'), findsOneWidget);
    expect(find.text('Consultar planes'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await cubit.close();
  });
}
