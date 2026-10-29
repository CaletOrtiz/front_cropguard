import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kroppi/core/network/supabase/supabase_client.dart' as app_supabase;

/// Interceptor que inyecta automáticamente el token JWT de Supabase
/// si el usuario ha iniciado sesión.
class ApiAuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    try {
      final session = app_supabase.SupabaseClient.client.auth.currentSession;
      if (session != null && session.accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer ${session.accessToken}';
      }
    } catch (_) {
      // Si Supabase aún no está inicializado o falla, continúa la petición sin token
    }
    handler.next(options);
  }
}

/// Interceptor para registrar peticiones y respuestas en consola durante desarrollo.
class ApiLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> [FASTAPI REQUEST] ${options.method} ${options.uri}');
      if (options.data != null && options.data is! FormData) {
        debugPrint('    Data: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- [FASTAPI RESPONSE ${response.statusCode}] ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- [FASTAPI ERROR ${err.response?.statusCode}] ${err.requestOptions.uri}');
      debugPrint('    Message: ${err.message}');
      if (err.response?.data != null) {
        debugPrint('    Response Body: ${err.response?.data}');
      }
    }
    handler.next(err);
  }
}

