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
    final crop = json['crop'] as Map<String, dynamic>? ?? {};
    final disease = json['disease'] as Map<String, dynamic>?;
    final ai = json['ai_prediction'] as Map<String, dynamic>? ?? {};

    List<String> strings(dynamic v) =>
        (v as List?)?.map((e) => e.toString()).toList() ?? const [];

    // Recomendaciones: primero las de la IA; si vienen vacías, las de la enfermedad.
    final aiRecs = strings(ai['recommendations']);

    return DiagnosisRecordModel(
      id: json['id'].toString(),
      cropId: crop['slug']?.toString() ?? 'otros',
      cropName: crop['name']?.toString() ?? 'Cultivo',
      pathogen:
          disease?['scientific_name']?.toString() ??
          disease?['name']?.toString() ??
          'No identificado',
      pathogenType: disease?['pathogen_type']?.toString() ?? '',
      date:
          DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      confidence: (((ai['confidence'] as num?) ?? 0) * 100).round(),
      symptoms: strings(disease?['symptoms']),
      recommendations: aiRecs.isNotEmpty
          ? aiRecs
          : strings(disease?['general_recommendations']),
      imageUrl: json['image_url']?.toString(),
    );
  }
}
