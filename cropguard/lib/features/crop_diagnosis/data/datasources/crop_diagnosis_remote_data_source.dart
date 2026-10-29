import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kroppi/core/network/api/fastapi_client.dart';
import 'package:kroppi/core/network/api/services/ai_backend_service.dart';
import '../models/crop_diagnosis_model.dart';

/// Fuente de datos remota para el diagnóstico de cultivos conectada a FastAPI:
/// - POST /diagnoses                   -> Crea diagnóstico con campo 'file' y orquesta las IAs
/// - GET  /diagnoses                   -> Lista diagnósticos del usuario
/// - GET  /diagnoses/{diagnostico_id}  -> Detalle por UUID
class CropDiagnosisRemoteDataSource {
  final AiBackendService _backendService;

  CropDiagnosisRemoteDataSource({
    AiBackendService? backendService,
    Dio? dioClient,
  }) : _backendService = backendService ??
            AiBackendService(dio: dioClient ?? FastApiClient.client);

  /// Envía la imagen a `POST /diagnoses` en el campo `file` (requiere token).
  Future<CropDiagnosisModel> analyzeCropImage({
    required File imageFile,
    required String userId,
    String? prompt,
    String cropSlug = 'cafe',
    double? latitude,
    double? longitude,
  }) async {
    final responseMap = await _backendService.createDiagnosis(
      imageFile: imageFile,
      cropSlug: cropSlug,
      latitude: latitude,
      longitude: longitude,
    );

    return CropDiagnosisModel.fromJson(responseMap);
  }

  /// Obtiene un diagnóstico por su UUID desde `GET /diagnoses/{diagnostico_id}`.
  Future<CropDiagnosisModel> getDiagnosisById(String diagnosticoId) async {
    final responseMap = await _backendService.getDiagnosisById(diagnosticoId);
    return CropDiagnosisModel.fromJson(responseMap);
  }

  /// Obtiene la lista de diagnósticos paginados desde `GET /diagnoses`.
  Future<List<CropDiagnosisModel>> getDiagnoses({
    int limit = 20,
    int offset = 0,
  }) async {
    final list = await _backendService.getDiagnoses(limit: limit, offset: offset);
    return list.map(CropDiagnosisModel.fromJson).toList();
  }
}
