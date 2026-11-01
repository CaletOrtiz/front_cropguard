import '../../domain/entities/diagnosis_record.dart';

class DiagnosisRecordModel extends DiagnosisRecord {
  const DiagnosisRecordModel({
    required super.id,
    required super.cropId,
    required super.cropName,
    required super.pathogen,
    required super.pathogenType,
    required super.date,
    required super.confidence,
    required super.symptoms,
    required super.recommendations,
    this.imageUrl,
  });

  final String? imageUrl;

  factory DiagnosisRecordModel.fromJson(Map<String, dynamic> json) {
    final crop = json['crop_type'] as Map<String, dynamic>? ?? {};
    final ai = json['ai_prediction'] as Map<String, dynamic>? ?? {};

    List<String> strings(dynamic v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? const [];

    final sci = ai['scientific_name']?.toString();
    final pathogen = (sci != null && sci != 'No especificado')
        ? sci
        : (ai['disease_name']?.toString() ?? 'No identificado');

    final recs = strings(json['recommendations']);

    return DiagnosisRecordModel(
      id: json['id'].toString(),
      cropId: crop['slug']?.toString() ?? 'otros',
      cropName: crop['name']?.toString() ?? 'Cultivo',
      pathogen: pathogen,
      pathogenType: ai['pathogen_type']?.toString() ?? '',
      date:
          DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      confidence:
          ((((json['confidence'] ?? ai['confidence']) as num?) ?? 0) * 100)
              .round(),
      symptoms: strings(ai['symptoms']),
      recommendations: recs,
      imageUrl: json['image_url']?.toString(),
    );
  }
}
