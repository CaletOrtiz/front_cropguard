import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/features/history/data/models/diagnosis_record_model.dart';

void main() {
  group('DiagnosisRecordModel.fromJson', () {
    test('reads crop type from plot sample relationships', () {
      final record = DiagnosisRecordModel.fromJson({
        'id': 'diagnosis-1',
        'image_url': 'https://storage.example.test/diagnosis/photo.jpg',
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
              'farm_id': 'farm-1',
              'name': 'Café de la parcela norte',
              'farms': {'id': 'farm-1', 'name': 'Finca El Roble'},
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
      expect(record.farmId, 'farm-1');
      expect(record.farmName, 'Finca El Roble');
      expect(record.farmCropId, 'crop-1');
      expect(record.farmCropName, 'Café de la parcela norte');
      expect(record.plotId, 'plot-1');
      expect(record.plotName, 'Lote norte');
      expect(
        record.imageUrl,
        'https://storage.example.test/diagnosis/photo.jpg',
      );
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
