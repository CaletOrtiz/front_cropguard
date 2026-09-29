import 'dart:io';

import '../entities/crop_diagnosis.dart';
import '../repositories/crop_diagnosis_repository.dart';

class AnalyzeCropImageUsecase {
  final CropDiagnosisRepository repository;

  AnalyzeCropImageUsecase({required this.repository});

  Future<CropDiagnosis> call({
    required File imageFile,
    required String userId,
    String? prompt,
  }) async {
    return await repository.analyzeCropImage(
      imageFile: imageFile,
      userId: userId,
      prompt: prompt,
    );
  }
}
