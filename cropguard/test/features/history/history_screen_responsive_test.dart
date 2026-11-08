import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/features/history/domain/entities/diagnosis_record.dart';
import 'package:kroppi/features/history/domain/usecases/get_diagnosis_history_usecase.dart';
import 'package:kroppi/features/history/presentation/cubit/history_cubit.dart';
import 'package:kroppi/features/history/presentation/screens/history_screen.dart';

void main() {
  testWidgets('nested history groups fit a narrow mobile viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => HistoryCubit(_HistoryUsecase())..load(),
          child: const HistoryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Finca estrecha'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Cultivo largo de café para prueba'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Lote norte con nombre largo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  });
}

class _HistoryUsecase implements GetDiagnosisHistoryUsecase {
  @override
  Future<List<DiagnosisRecord>> call({int from = 0, int pageSize = 20}) async {
    if (from > 0) return const [];
    return [
      DiagnosisRecord(
        id: 'diagnosis-1',
        cropId: 'cafe',
        cropName: 'Café',
        pathogen:
            'Nombre del patógeno con longitud suficiente para probar el ajuste',
        pathogenType: 'Hongo',
        date: DateTime(2026, 11, 8),
        confidence: 90,
        symptoms: [],
        recommendations: [],
        farmId: 'farm-1',
        farmName: 'Finca estrecha',
        farmCropId: 'crop-1',
        farmCropName: 'Cultivo largo de café para prueba',
        plotId: 'plot-1',
        plotName: 'Lote norte con nombre largo',
      ),
    ];
  }
}
