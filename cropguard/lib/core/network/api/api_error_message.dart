import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';

String apiErrorMessage(Object error) {
  if (error is PostgrestException) return error.message;
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status == 401) return 'Tu sesión expiró. Inicia sesión de nuevo.';
    final response = error.response?.data;
    if (response is Map && response['detail'] is String) {
      return response['detail'] as String;
    }
    if (status == 403) return 'Tu cuenta no tiene permiso para esta acción.';
    if (status == 409) {
      return 'La acción entra en conflicto con el estado actual.';
    }
    if (status == 429) return 'Alcanzaste la cuota disponible.';
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Sin conexión. Revisa tu internet e inténtalo de nuevo.';
    }
  }
  return error.toString();
}
