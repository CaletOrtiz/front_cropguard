import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/features/history/domain/entities/diagnosis_record.dart';
import 'package:kroppi/features/home/presentation/widgets/recent_diagnoses_section.dart';

void main() {
  testWidgets('shows recent diagnoses without overflow on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final record = DiagnosisRecord(
      id: 'diagnosis-1',
      cropId: 'cafe',
      cropName: 'Café',
      pathogen: 'Hemileia vastatrix',
      pathogenType: 'Hongo',
      date: DateTime(2026, 11, 8),
      confidence: 84,
      symptoms: const [],
      recommendations: const [],
      plotName: 'Lote La Esperanza',
    );
    DiagnosisRecord? openedRecord;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: RecentDiagnosesSection(
              records: [record],
              isLoading: false,
              errorMessage: null,
              onRetry: () {},
              onOpenHistory: () {},
              onOpenDiagnosis: (value) => openedRecord = value,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Hemileia vastatrix'), findsOneWidget);
    await tester.tap(find.text('Hemileia vastatrix'));
    expect(openedRecord, record);
    expect(tester.takeException(), isNull);
  });
}
