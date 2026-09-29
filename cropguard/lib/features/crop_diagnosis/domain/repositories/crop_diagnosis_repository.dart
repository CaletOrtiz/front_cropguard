import 'dart:io';

import '../entities/crop_diagnosis.dart';

abstract class CropDiagnosisRepository {
  Future<CropDiagnosis> analyzeCropImage({
    required File imageFile,
    required String userId,
    String? prompt,
  });

  Future<List<CropDiagnosis>> getDiagnosisHistory({required String userId});
}
