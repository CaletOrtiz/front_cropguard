import 'package:image_picker/image_picker.dart';

import '../entities/crop_diagnosis.dart';
import '../repositories/crop_diagnosis_repository.dart';

class AnalyzeCropImageUsecase {
  final CropDiagnosisRepository repository;

  AnalyzeCropImageUsecase({required this.repository});

  Future<CropDiagnosis> call({
    required XFile imageFile,
    required String userId,
    String? prompt,
    required String plotSamplesId,
    double? latitude,
    double? longitude,
  }) async {
    return await repository.analyzeCropImage(
      imageFile: imageFile,
      userId: userId,
      prompt: prompt,
      plotSamplesId: plotSamplesId,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
