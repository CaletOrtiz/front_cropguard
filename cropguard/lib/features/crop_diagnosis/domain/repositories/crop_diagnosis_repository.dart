import 'dart:io';

import '../entities/crop_diagnosis.dart';

/// Contrato del repositorio para el análisis fitosanitario con FastAPI.
abstract class CropDiagnosisRepository {
  Future<CropDiagnosis> analyzeCropImage({
    required File imageFile,
    required String userId,
    String? prompt,
    String cropSlug = 'cafe',
    double? latitude,
    double? longitude,
  });
}
