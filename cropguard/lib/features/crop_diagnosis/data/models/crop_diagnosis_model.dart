import '../../domain/entities/crop_diagnosis.dart';

class CropDiagnosisModel extends CropDiagnosis {
  const CropDiagnosisModel({
    required super.id,
    required super.userId,
    required super.imageUrl,
    required super.diseaseName,
    super.scientificName,
    required super.confidence,
    required super.geminiRecommendations,
    required super.createdAt,
  });

  factory CropDiagnosisModel.fromJson(Map<String, dynamic> json) {
    // 1. Nombre común de la enfermedad
    String diseaseName = 'Planta sana';
    if (json['ai_prediction'] is Map && json['ai_prediction']['disease_name'] != null) {
      diseaseName = json['ai_prediction']['disease_name'].toString();
    } else if (json['disease'] is Map && json['disease']['name'] != null) {
      diseaseName = json['disease']['name'].toString();
    } else if (json['disease_name'] != null) {
      diseaseName = json['disease_name'].toString();
    }

    // 2. Nombre científico de la enfermedad (extraído de ai_prediction o disease)
    String scientificName = 'No especificado';
    if (json['ai_prediction'] is Map && json['ai_prediction']['scientific_name'] != null) {
      scientificName = json['ai_prediction']['scientific_name'].toString();
    } else if (json['disease'] is Map && json['disease']['scientific_name'] != null) {
      scientificName = json['disease']['scientific_name'].toString();
    } else if (json['scientific_name'] != null) {
      scientificName = json['scientific_name'].toString();
    }

    // 3. Nivel de confianza
    double confidence = 0.0;
    if (json['ai_prediction'] is Map && json['ai_prediction']['confidence'] != null) {
      confidence = (json['ai_prediction']['confidence'] as num).toDouble();
    } else if (json['confidence'] != null) {
      confidence = (json['confidence'] as num).toDouble();
    }

    // 4. Recomendaciones de Gemini
    String recommendations = '';
    final dynamic rawRec = (json['ai_prediction'] is Map)
        ? json['ai_prediction']['recommendations']
        : json['recommendations'];

    if (rawRec is List && rawRec.isNotEmpty) {
      recommendations = rawRec.join('\n\n');
    } else if (rawRec != null && rawRec.toString().trim().isNotEmpty && rawRec != '[]') {
      recommendations = rawRec.toString();
    } else if (json['disease'] is Map && json['disease']['general_recommendations'] != null) {
      final genRec = json['disease']['general_recommendations'];
      if (genRec is List) {
        recommendations = genRec.join('\n\n');
      } else {
        recommendations = genRec.toString();
      }
    }

    // 5. Fecha de creación
    DateTime createdAt = DateTime.now();
    if (json['created_at'] != null) {
      createdAt = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    return CropDiagnosisModel(
      id: (json['id'] ?? json['diagnostico_id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      diseaseName: diseaseName,
      scientificName: scientificName,
      confidence: confidence,
      geminiRecommendations: recommendations,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'disease_name': diseaseName,
      'scientific_name': scientificName,
      'confidence': confidence,
      'recommendations': geminiRecommendations,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
