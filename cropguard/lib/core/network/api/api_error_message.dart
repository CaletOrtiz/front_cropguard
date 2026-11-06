import 'package:dio/dio.dart';

String apiErrorMessage(Object error) {
  if (error is DioException) {
    final response = error.response?.data;
    if (response is Map && response['detail'] is String) {
      return response['detail'] as String;
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Sin conexión. Revisa tu internet e inténtalo de nuevo.';
    }
  }
  return error.toString();
}
