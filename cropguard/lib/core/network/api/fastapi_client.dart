import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'api_interceptors.dart';

/// Cliente HTTP centralizado para el backend de FastAPI (IA Local + Gemini).
///
/// Sigue el mismo patrón de inicialización y acceso que [SupabaseClient].
class FastApiClient {
  FastApiClient._();

  static Dio? _instance;
  static String _baseUrl = ApiEndpoints.defaultBaseUrl;

  /// Inicializa el cliente Dio con opciones optimizadas para modelos de IA
  /// y agrega los interceptores correspondientes.
  static void init({
    String? baseUrl,
    Map<String, dynamic>? customHeaders,
  }) {
    if (baseUrl != null && baseUrl.isNotEmpty) {
      _baseUrl = baseUrl;
    } else {
      _baseUrl = ApiEndpoints.defaultBaseUrl;
    }

    final options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 45), // Tiempo amplio para inferencia de IA
      sendTimeout: const Duration(seconds: 30), // Tiempo para subir imágenes
      headers: {
        'Accept': 'application/json',
        ...?customHeaders,
      },
    );

    _instance = Dio(options)
      ..interceptors.addAll([
        ApiAuthInterceptor(),
        ApiLoggingInterceptor(),
      ]);
  }

  /// Retorna la instancia configurada de [Dio].
  ///
  /// Si aún no se llamó a `init()`, se inicializa automáticamente con valores por defecto.
  static Dio get client {
    if (_instance == null) {
      init();
    }
    return _instance!;
  }

  /// Permite actualizar la URL base en tiempo de ejecución (ej. desde configuración).
  static void setBaseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
    if (_instance != null) {
      _instance!.options.baseUrl = newBaseUrl;
    }
  }

  /// URL base actual configurada en el cliente.
  static String get baseUrl => _baseUrl;
}

