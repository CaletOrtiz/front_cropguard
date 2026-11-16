import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/core/network/api/api_transport_policy.dart';

class RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString('', 200);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const secure = ApiTransportPolicy(allowHttp: false);

  test(
    'release/profile reject HTTP and malformed or credential-bearing URLs',
    () {
      for (final url in [
        'http://127.0.0.1:8000',
        'http://api.example.test',
        '',
        '/relative',
        'ftp://api.example.test',
        'https://',
        'https://user:password@api.example.test',
      ]) {
        expect(() => secure.validate(url), throwsStateError);
      }
      expect(
        secure.validate('https://api.example.test'),
        'https://api.example.test',
      );
    },
  );

  test('debug retains USB, emulator and LAN HTTP access', () {
    const debug = ApiTransportPolicy(allowHttp: true);
    for (final host in [
      '127.0.0.1',
      'localhost',
      '10.0.2.2',
      '192.168.1.185',
    ]) {
      expect(debug.validate('http://$host:8000'), 'http://$host:8000');
    }
  });

  test(
    'HTTP never reaches adapter, including absolute URLs and changed base URL',
    () async {
      final adapter = RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
        ..httpClientAdapter = adapter
        ..interceptors.add(secure);
      await expectLater(
        dio.get('http://api.example.test/private'),
        throwsA(isA<DioException>()),
      );
      dio.options.baseUrl = 'http://127.0.0.1:8000';
      await expectLater(dio.get('/private'), throwsA(isA<DioException>()));
      expect(adapter.requests, isEmpty);
    },
  );

  test('HTTPS reaches adapter with automatic redirects disabled', () async {
    final adapter = RecordingAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(secure);
    await dio.get('/health', options: Options(followRedirects: true));
    expect(adapter.requests.single.followRedirects, isFalse);
  });
}
