import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kroppi/core/network/supabase/supabase_client.dart'
    as app_supabase;

/// Interceptor que inyecta automáticamente el token JWT de Supabase
/// si el usuario ha iniciado sesión.
class ApiAuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = app_supabase.SupabaseClient.client.auth.currentSession;
    if (session != null && session.accessToken.isNotEmpty) {
      options.headers['Authorization'] = [
        'Bearer',
        session.accessToken,
      ].join(' ');
    }
    handler.next(options);
  }
}

/// Solo metadatos en debug: las URLs, cuerpos y errores pueden contener secretos.
class ApiLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> [FASTAPI REQUEST] ${options.method}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- [FASTAPI RESPONSE ${response.statusCode}]');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- [FASTAPI ERROR ${err.response?.statusCode}]');
    }
    handler.next(err);
  }
}
