import 'dart:io';
import 'package:dio/dio.dart';
import '../../domain/entities/crop_diagnosis.dart';
import '../../domain/repositories/crop_diagnosis_repository.dart';
import '../datasources/crop_diagnosis_remote_data_source.dart';

class CropDiagnosisRepositoryImpl implements CropDiagnosisRepository {
  final CropDiagnosisRemoteDataSource remoteDataSource;

  CropDiagnosisRepositoryImpl({
    CropDiagnosisRemoteDataSource? remoteDataSource,
    Dio? dioClient,
  }) : remoteDataSource = remoteDataSource ??
            CropDiagnosisRemoteDataSource(dioClient: dioClient);

  @override
  Future<CropDiagnosis> analyzeCropImage({
    required File imageFile,
    required String userId,
    String? prompt,
    String cropSlug = 'cafe',
    double? latitude,
    double? longitude,
  }) async {
    return await remoteDataSource.analyzeCropImage(
      imageFile: imageFile,
      userId: userId,
      prompt: prompt,
      cropSlug: cropSlug,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
