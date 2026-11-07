import 'package:image_picker/image_picker.dart';

abstract class DiagnosisEvent {}

class AnalyzeImageSubmittedEvent extends DiagnosisEvent {
  final XFile imageFile;
  final String userId;
  final String? prompt;
  final String plotId;
  final double? latitude;
  final double? longitude;

  AnalyzeImageSubmittedEvent({
    required this.imageFile,
    required this.userId,
    this.prompt,
    required this.plotId,
    this.latitude,
    this.longitude,
  });
}
