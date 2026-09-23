import 'dart:io';

abstract class DiagnosisEvent {}

class AnalyzeImageSubmittedEvent extends DiagnosisEvent {
  final File imageFile;
  final String userId;
  final String? prompt;

  AnalyzeImageSubmittedEvent({
    required this.imageFile,
    required this.userId,
    this.prompt,
  });
}
