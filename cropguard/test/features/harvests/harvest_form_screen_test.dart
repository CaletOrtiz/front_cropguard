import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kroppi/core/widgets/primary_button.dart';
import 'package:kroppi/features/harvests/domain/entities/harvest.dart';
import 'package:kroppi/features/harvests/domain/repositories/harvest_repository.dart';
import 'package:kroppi/features/harvests/presentation/cubit/harvest_form_cubit.dart';
import 'package:kroppi/features/harvests/presentation/screens/harvest_form_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements HarvestRepository {}

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  Future<void> pump(WidgetTester tester) async {
    final repository = _MockRepository();
    when(() => repository.list(any(), limit: any(named: 'limit'))).thenAnswer(
      (_) async => const HarvestPage(items: [], totals: HarvestTotals()),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => HarvestFormCubit(repository, plotId: 'p1'),
          child: const HarvestFormScreen(plotId: 'p1'),
        ),
      ),
    );
    await tester.pump();
  }

  PrimaryButton saveButton(WidgetTester tester) =>
      tester.widget<PrimaryButton>(find.byKey(const Key('harvest_save')));

  testWidgets('Guardar está deshabilitado con datos inválidos', (tester) async {
    await pump(tester);
    expect(saveButton(tester).onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cantidad (kg)*'),
      '0',
    );
    await tester.pump();
    expect(saveButton(tester).onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cantidad (kg)*'),
      '850',
    );
    await tester.pump();
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('el valor estimado se actualiza al escribir', (tester) async {
    await pump(tester);
    expect(find.byKey(const Key('harvest_value_preview')), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Cantidad (kg)*'),
      '850',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Precio por kg'),
      '9000',
    );
    await tester.pump();

    final preview = tester.widget<Text>(
      find.byKey(const Key('harvest_value_preview')),
    );
    expect(preview.data, contains('7.650.000'));
  });
}
