import 'dart:io';

abstract class DiagnosisEvent {}

class AnalyzeImageSubmittedEvent extends DiagnosisEvent {
  final File imageFile;
  final String userId;
  final String? prompt;
  final String cropSlug;
  final double? latitude;
  final double? longitude;

  AnalyzeImageSubmittedEvent({
    required this.imageFile,
    required this.userId,
    this.prompt,
    this.cropSlug = 'cafe',
    this.latitude,
    this.longitude,
  });
}
