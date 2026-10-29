import 'package:equatable/equatable.dart';

class CropDiagnosis extends Equatable {
  final String id;
  final String userId;
  final String imageUrl;
  final String diseaseName;
  final String scientificName;
  final double confidence;
  final String geminiRecommendations;
  final DateTime createdAt;

  const CropDiagnosis({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.diseaseName,
    this.scientificName = 'No especificado',
    required this.confidence,
    required this.geminiRecommendations,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    imageUrl,
    diseaseName,
    scientificName,
    confidence,
    geminiRecommendations,
    createdAt,
  ];
}
