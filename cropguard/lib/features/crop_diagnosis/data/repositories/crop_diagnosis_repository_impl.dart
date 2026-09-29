import '../../domain/entities/crop_diagnosis.dart';
import '../../domain/repositories/crop_diagnosis_repository.dart';
import 'dart:io';
import 'package:dio/dio.dart';

import '../model/crop_diagnosis_model.dart';

class CropDiagnosisRepositoryImpl implements CropDiagnosisRepository {
  final Dio dioClient;

  CropDiagnosisRepositoryImpl({required this.dioClient});

  @override
  Future<CropDiagnosis> analyzeCropImage({
    required File imageFile,
    required String userId,
    String? prompt,
  }) async {
    try {
      final String fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'user_id': userId,
        'prompt': prompt ?? '',
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await dioClient.post(
        '/api/v1/diagnosis/analyze',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parseamos la respuesta con el Model y lo retornamos como Entity
        return CropDiagnosisModel.fromJson(response.data);
      } else {
        throw Exception('Error en el servidor: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error de red al analizar la imagen: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<List<CropDiagnosis>> getDiagnosisHistory({
    required String userId,
  }) async {
    try {
      final response = await dioClient.get('/api/v1/diagnosis/history/$userId');

      if (response.statusCode == 200) {
        final List<dynamic> listJson = response.data;
        return listJson
            .map((json) => CropDiagnosisModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Error al obtener el historial');
      }
    } catch (e) {
      throw Exception('Error al conectar con la base de datos: $e');
    }
  }
}
