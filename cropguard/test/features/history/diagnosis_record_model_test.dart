import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/features/history/data/models/diagnosis_record_model.dart';

void main() {
  group('DiagnosisRecordModel.fromJson', () {
    test('reads crop type from plot sample relationships', () {
      final record = DiagnosisRecordModel.fromJson({
        'id': 'diagnosis-1',
        'created_at': '2026-11-08T12:00:00Z',
        'predicted_label': 'Roya',
        'confidence': 0.9,
        'recommendations': ['Monitorear el cultivo'],
        'plot_samples': {
          'id': 'sample-1',
          'incidence_pct': 12.5,
          'plots': {
            'id': 'plot-1',
            'name': 'Lote norte',
            'crops': {
              'id': 'crop-1',
              'name': 'Cultivo de café',
              'crop_types': {
                'id': 'type-1',
                'name': 'Café',
                'slug': 'cafe',
                'icon_url': 'https://example.test/cafe.png',
              },
            },
          },
        },
      });

      expect(record.cropId, 'cafe');
      expect(record.cropName, 'Café');
      expect(record.pathogen, 'Roya');
      expect(record.confidence, 90);
    });

    test('accepts array-shaped nested relationships', () {
      final record = DiagnosisRecordModel.fromJson({
        'id': 'diagnosis-2',
        'plot_samples': [
          {
            'plots': [
              {
                'crops': [
                  {
                    'crop_types': [
                      {'name': 'Maíz', 'slug': 'maiz'},
                    ],
                  },
                ],
              },
            ],
          },
        ],
      });

      expect(record.cropId, 'maiz');
      expect(record.cropName, 'Maíz');
    });
  });
}
