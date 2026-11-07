import 'package:image_picker/image_picker.dart';

import '../entities/crop_diagnosis.dart';

abstract class CropDiagnosisRepository {
  Future<CropDiagnosis> analyzeCropImage({
    required XFile imageFile,
    required String userId,
    String? prompt,
    required String plotSamplesId,
    double? latitude,
    double? longitude,
  });
}
