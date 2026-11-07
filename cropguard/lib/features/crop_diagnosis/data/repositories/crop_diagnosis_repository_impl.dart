import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/crop_diagnosis.dart';
import '../../domain/repositories/crop_diagnosis_repository.dart';
import '../datasources/crop_diagnosis_remote_data_source.dart';

class CropDiagnosisRepositoryImpl implements CropDiagnosisRepository {
  final CropDiagnosisRemoteDataSource remoteDataSource;

  CropDiagnosisRepositoryImpl({
    CropDiagnosisRemoteDataSource? remoteDataSource,
    Dio? dioClient,
  }) : remoteDataSource =
           remoteDataSource ??
           CropDiagnosisRemoteDataSource(dioClient: dioClient);

  @override
  Future<CropDiagnosis> analyzeCropImage({
    required XFile imageFile,
    required String userId,
    String? prompt,
    required String plotSamplesId,
    double? latitude,
    double? longitude,
  }) async {
    return await remoteDataSource.analyzeCropImage(
      imageFile: imageFile,
      userId: userId,
      prompt: prompt,
      plotSamplesId: plotSamplesId,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
