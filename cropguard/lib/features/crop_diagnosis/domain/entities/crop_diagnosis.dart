import 'package:equatable/equatable.dart';

class CropDiagnosis extends Equatable {
  final String id;
  final String user_id;
  final String imageUrl;
  final String diseaseName;
  final double confidence;
  final String geminiRecommendations;
  final DateTime createdAt;

  const CropDiagnosis({
    required this.id,
    required this.user_id,
    required this.imageUrl,
    required this.diseaseName,
    required this.confidence,
    required this.geminiRecommendations,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    imageUrl,
    diseaseName,
    confidence,
    geminiRecommendations,
    createdAt,
  ];
}
