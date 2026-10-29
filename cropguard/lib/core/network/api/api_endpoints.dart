import 'package:flutter/foundation.dart';

/// Define los endpoints y la URL base para conectar con FastAPI.
class ApiEndpoints {
  ApiEndpoints._();

  static const int port = 8000;

  /// IP de tu PC en la red Wi-Fi (usar solo si desconectas el cable USB).
  static const String localNetworkIp = '192.168.1.185';

  /// URL base por defecto.
  /// Con el cable USB conectado y `adb reverse tcp:8000 tcp:8000`,
  /// `http://127.0.0.1:8000` conecta inmediatamente tanto en celular físico
  /// como en la web o Linux desktop.
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:$port';
    }
    // Con 'adb reverse tcp:8000 tcp:8000' activo en tu celular,
    // 127.0.0.1 se redirige directamente a tu computadora por USB.
    return 'http://127.0.0.1:$port';
  }

  /// **GET /health** (Público)
  /// Estado de la API y versión del modelo de IA.
  static const String health = '/health';

  /// **POST /diagnoses** (Requiere token)
  /// Recibe una imagen y crea un diagnóstico ejecutando el pipeline de IA.
  ///
  /// **GET /diagnoses** (Requiere token)
  /// Lista los diagnósticos del usuario autenticado (soporta `limit` y `offset`).
  static const String diagnoses = '/diagnoses';

  /// **GET /diagnoses/{diagnostico_id}** (Requiere token)
  /// Obtiene un diagnóstico propio por su UUID.
  static String diagnosisById(String diagnosticoId) => '/diagnoses/$diagnosticoId';
}
