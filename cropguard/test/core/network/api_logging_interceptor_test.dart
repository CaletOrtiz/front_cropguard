import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/core/network/api/api_interceptors.dart';

// Synthetic sentinel only; no real credentials are used by these tests.
const _sensitive = 'SYNTHETIC_PRIVATE_DATA';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.fail);
  final bool fail;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (fail) {
      throw DioException(
        requestOptions: options,
        message: _sensitive,
        response: Response(
          requestOptions: options,
          statusCode: 400,
          data: {'detail': _sensitive},
        ),
      );
    }
    return ResponseBody.fromString(_sensitive, 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  for (final fail in [false, true]) {
    test(
      'network logs exclude private URLs, bodies and errors (fail=$fail)',
      () async {
        final logs = <String>[];
        final original = debugPrint;
        debugPrint = (String? message, {int? wrapWidth}) {
          if (message != null) logs.add(message);
        };
        addTearDown(() => debugPrint = original);
        final dio = Dio(BaseOptions(baseUrl: 'https://example.invalid'))
          ..httpClientAdapter = _Adapter(fail)
          ..interceptors.add(ApiLoggingInterceptor());
        final request = dio.post<void>(
          '/$_sensitive?token=$_sensitive',
          data: {'password': _sensitive},
          options: Options(headers: {'Authorization': 'Bearer $_sensitive'}),
        );
        if (fail) {
          await expectLater(request, throwsA(isA<DioException>()));
        } else {
          await request;
        }
        expect(logs, isNotEmpty);
        expect(logs.join('\n'), isNot(contains(_sensitive)));
      },
    );
  }
}
