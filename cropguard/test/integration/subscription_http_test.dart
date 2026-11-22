import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/core/network/api/api_endpoints.dart';
import 'package:kroppi/features/profile/domain/entities/subscription_access.dart';
import 'package:kroppi/features/profile/presentation/cubit/subscription_cubit.dart';

void main() {
  final environment = Platform.environment;
  final url = environment['KROPPI_QA_URL'];

  test(
    'reconciles subscription state across real HTTP requests',
    () async {
      final address = Uri.parse(url!);
      expect(address.host, '127.0.0.1');
      final client = Dio(
        BaseOptions(
          baseUrl: url,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      addTearDown(() => client.close(force: true));

      Future<Map<String, dynamic>> fetch(String? token) async {
        final response = await client.get<Map<String, dynamic>>(
          ApiEndpoints.subscription,
          options: Options(
            headers: {if (token != null) 'Authorization': 'Bearer $token'},
          ),
        );
        expect(response.statusCode, 200);
        return response.data!;
      }

      var token = environment['KROPPI_QA_FREE_JWT'];
      final cubit = SubscriptionCubit(
        () async => SubscriptionAccess.fromJson(await fetch(token)),
      );
      addTearDown(cubit.close);

      await cubit.setAccount('free');
      final free = cubit.state.access!;
      expect(free.plan, 'free');
      expect(free.premiumFeatures, isFalse);
      expect(free.quotas.values.map((quota) => quota.limit), [1, 2, 5, 3]);
      expect(free.quota(PlanResource.farms).used, 1);
      expect(free.quota(PlanResource.farms).exhausted, isTrue);
      expect(cubit.state.canDiagnose, isFalse);

      token = environment['KROPPI_QA_PREMIUM_JWT'];
      await cubit.setAccount('premium');
      final premium = cubit.state.access!;
      expect(premium.plan, 'premium');
      expect(premium.premiumFeatures, isTrue);
      expect(premium.quotas.values.map((quota) => quota.limit), [
        null,
        null,
        null,
        30,
      ]);
      expect(premium.quota(PlanResource.farms).used, 2);
      expect(cubit.state.canDiagnose, isTrue);

      token = environment['KROPPI_QA_DOWNGRADED_JWT'];
      await cubit.setAccount('downgraded');
      final downgraded = cubit.state.access!;
      expect(downgraded.plan, 'free');
      expect(downgraded.premiumFeatures, isFalse);
      expect(downgraded.quotas.values.map((quota) => quota.used), [
        10,
        8,
        12,
        4,
      ]);
      expect(
        downgraded.quotas.values.every((quota) => quota.exhausted),
        isTrue,
      );
      expect(cubit.state.canDiagnose, isFalse);

      for (final rejected in [
        null,
        'invalid',
        environment['KROPPI_QA_EXPIRED_JWT'],
      ]) {
        await expectLater(
          fetch(rejected),
          throwsA(
            isA<DioException>().having(
              (error) => error.response?.statusCode,
              'status',
              401,
            ),
          ),
        );
      }

      token = environment['KROPPI_QA_EXPIRED_JWT'];
      await cubit.refresh();
      expect(cubit.state.access, isNull);
      expect(cubit.state.error, isNotNull);
      expect(cubit.state.canDiagnose, isFalse);
      await cubit.setAccount(null);
      expect(cubit.state.access, isNull);
      expect(cubit.state.error, isNull);
    },
    skip: url == null ? 'Run from test_subscription_flutter_http.py' : false,
  );
}
