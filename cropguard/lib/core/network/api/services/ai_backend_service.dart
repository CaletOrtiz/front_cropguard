import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kroppi/core/errors/failures.dart';
import '../api_endpoints.dart';
import '../fastapi_client.dart';

/// Servicio de red para la integración con los endpoints de FastAPI:
/// 1. GET  /health                     (Público - Estado y versión de modelo)
/// 2. POST /diagnoses                  (Token - Envía imagen en campo `file` y orquesta diagnóstico)
/// 3. GET  /diagnoses                  (Token - Lista diagnósticos con limit/offset)
/// 4. GET  /diagnoses/{diagnostico_id} (Token - Consulta diagnóstico por UUID)
/// 5. send(...)                        (Genérico - cultivos, lotes y muestreos)
class AiBackendService {
  final Dio _dio;

  AiBackendService({Dio? dio}) : _dio = dio ?? FastApiClient.client;

  MediaType _resolveMediaType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'webp':
        return MediaType('image', 'webp');
      case 'jpg':
      case 'jpeg':
      default:
        return MediaType('image', 'jpeg');
    }
  }

  Never _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw const NetworkFailure();
    }

    final statusCode = e.response?.statusCode;
    if (statusCode == 401 || statusCode == 403) {
      throw const AuthFailure(
        'No autorizado. Tu sesión expiró o el token es inválido.',
      );
    }

    if (statusCode == 404) {
      final d = e.response?.data;
      final msg = (d is Map && d['detail'] is String)
          ? d['detail'] as String
          : 'No se encontró lo que buscas.';
      throw NotFoundFailure(msg);
    }

    final responseData = e.response?.data;
    if (responseData is Map && responseData.containsKey('detail')) {
      final detail = responseData['detail'];
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first.containsKey('msg')) {
          throw ServerFailure('${first['msg']} (${first['loc']?.last ?? ''})');
        }
      }
      throw ServerFailure(detail.toString());
    }

    throw ServerFailure(
      statusCode != null
          ? 'Error del servidor backend ($statusCode)'
          : (e.message ?? 'Error de conexión con FastAPI'),
    );
  }

  // =========================================================================
  // 1. GET /health (Público)
  // =========================================================================

  /// Consulta el estado del servicio y la versión del modelo de IA cargado.
  Future<Map<String, dynamic>> getHealth() async {
    try {
      final response = await _dio.get(ApiEndpoints.health);
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al consultar /health: $e');
    }
  }

  // =========================================================================
  // 2. POST /diagnoses (Requiere Token)
  // =========================================================================

  /// Envía la imagen mediante multipart/form-data según el contrato:
  /// - `file`: obligatorio (JPG, PNG o WEBP de hasta 10 MB).
  /// - `crop_slug`: opcional (por defecto 'cafe').
  /// - `plot_id`: opcional (UUID del lote si se escanea desde un muestreo).
  /// - `latitude` y `longitude`: opcionales (ambos o ninguno).
  Future<Map<String, dynamic>> createDiagnosis({
    required XFile imageFile,
    String cropSlug = 'cafe',
    String? plotId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Se leen los bytes con XFile: funciona en web, Android e iOS
      // (dart:io File NO funciona en Flutter web).
      final bytes = await imageFile.readAsBytes();

      // Validar tamaño máximo de 10 MB antes de subir
      if (bytes.length > 10 * 1024 * 1024) {
        throw const ServerFailure('La imagen supera los 10 MB permitidos.');
      }

      final fileName = imageFile.name.isNotEmpty ? imageFile.name : 'foto.jpg';
      final mime = imageFile.mimeType;
      final mediaType = (mime != null && mime.startsWith('image/'))
          ? MediaType.parse(mime)
          : _resolveMediaType(fileName);

      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: fileName,
        contentType: mediaType,
      );

      final formMap = <String, dynamic>{
        'file': multipartFile,
        'crop_slug': cropSlug,
      };

      // Asocia la foto a un lote (sesión de muestreo)
      if (plotId != null) {
        formMap['plot_id'] = plotId;
      }

      // Latitud y longitud deben enviarse ambos o ninguno
      if (latitude != null && longitude != null) {
        formMap['latitude'] = latitude;
        formMap['longitude'] = longitude;
      }

      final formData = FormData.fromMap(formMap);

      final response = await _dio.post(ApiEndpoints.diagnoses, data: formData);

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al procesar el diagnóstico en FastAPI: $e');
    }
  }

  // =========================================================================
  // 3. GET /diagnoses (Requiere Token)
  // =========================================================================

  /// Lista los diagnósticos del usuario autenticado con paginación.
  Future<List<Map<String, dynamic>>> getDiagnoses({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.diagnoses,
        queryParameters: {'limit': limit, 'offset': offset},
      );

      final dynamic data = response.data;
      if (data is List) {
        return data
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      } else if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      _handleDioError(e);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al obtener la lista de diagnósticos: $e');
    }
  }

  // =========================================================================
  // 4. GET /diagnoses/{diagnostico_id} (Requiere Token)
  // =========================================================================

  /// Obtiene un diagnóstico específico por su UUID.
  Future<Map<String, dynamic>> getDiagnosisById(String diagnosticoId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.diagnosisById(diagnosticoId),
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error al obtener el diagnóstico $diagnosticoId: $e');
    }
  }

  // =========================================================================
  // 5. Método genérico (cultivos, lotes, muestreos)
  // =========================================================================

  /// Llamada HTTP genérica con el mismo manejo de errores y token.
  /// Devuelve `response.data` tal cual (Map o List según el endpoint).
  Future<dynamic> send(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.request(
        path,
        data: data,
        queryParameters: query,
        options: Options(method: method),
      );
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
    } on Failure {
      rethrow;
    } catch (e) {
      throw ServerFailure('Error de comunicación con el servidor: $e');
    }
  }
}
