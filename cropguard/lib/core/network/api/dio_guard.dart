import 'package:dio/dio.dart';
import 'package:kroppi/core/errors/failures.dart';
import 'package:kroppi/core/network/api/api_error_message.dart';

/// Traduce los errores de Dio contra FastAPI a [Failure] con mensaje en
/// español (el `detail` del backend se muestra tal cual).
Future<T> dioGuard<T>(Future<T> Function() run) async {
  try {
    return await run();
  } on Failure {
    rethrow;
  } on DioException catch (error) {
    throw failureFromDio(error);
  }
}

Failure failureFromDio(DioException error) {
  final status = error.response?.statusCode;
  final message = apiErrorMessage(error);
  if (status == null) {
    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout => const NetworkFailure(),
      _ => ServerFailure(message),
    };
  }
  if (status == 401) {
    return const AuthFailure('Tu sesión expiró. Inicia sesión de nuevo.');
  }
  if (status == 404) return const NotFoundFailure('Este registro ya no existe');
  if (status == 400 || status == 422) {
    final data = error.response?.data;
    if (data is Map && data['detail'] is List) {
      final first = (data['detail'] as List).firstOrNull;
      if (first is Map && first['msg'] != null) {
        return ValidationFailure(first['msg'].toString());
      }
    }
    return ValidationFailure(message);
  }
  return ServerFailure(message);
}
