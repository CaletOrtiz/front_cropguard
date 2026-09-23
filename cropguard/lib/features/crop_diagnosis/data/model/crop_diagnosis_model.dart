import '../../domain/entities/crop_diagnosis.dart';

class CropDiagnosisModel extends CropDiagnosis {
  const CropDiagnosisModel({
    required super.id,
    required super.user_id,
    required super.imageUrl,
    required super.diseaseName,
    required super.confidence,
    required super.geminiRecommendations,
    required super.createdAt,
  });

  factory CropDiagnosisModel.fromJson(Map<String, dynamic> json) {
    return CropDiagnosisModel(
      id: json['_id'] ?? json['id'] ?? '',
      user_id: json['user_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      diseaseName: json['disease_name'] ?? 'No identificado',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      geminiRecommendations: json['recommendations'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'image_url': imageUrl,
      'disease_name': diseaseName,
      'confidence': confidence,
      'recommendations': geminiRecommendations,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
