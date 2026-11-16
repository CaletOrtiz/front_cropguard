import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Transport policy shared by URL selection and the final request boundary.
class ApiTransportPolicy extends Interceptor {
  const ApiTransportPolicy({this.allowHttp = kDebugMode});

  final bool allowHttp;

  String validate(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        !(uri.scheme == 'https' || (allowHttp && uri.scheme == 'http'))) {
      // Never include the supplied URL: it may contain credentials.
      throw StateError('FastAPI requires a valid HTTPS URL outside debug.');
    }
    return value;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      validate(options.uri.toString());
      // Automatic redirects happen inside the adapter and bypass interceptors.
      if (!allowHttp) options.followRedirects = false;
      handler.next(options);
    } on StateError catch (error) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: error,
          message: 'Blocked by FastAPI transport policy.',
        ),
      );
    }
  }
}
