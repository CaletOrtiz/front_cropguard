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

  /// Solo para la app; la decisión real la toma el backend.
  static const conclusiveThreshold = 0.7;

  /// Nombres que el backend usa para "sin enfermedad".
  static const healthyNames = {'Hoja sana', 'Planta sana'};

  bool get isConclusive => confidence >= conclusiveThreshold;

  bool get isHealthy => healthyNames.contains(diseaseName);

  /// Cuenta como planta afectada en un muestreo.
  bool get isDiseased => isConclusive && !isHealthy;

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
