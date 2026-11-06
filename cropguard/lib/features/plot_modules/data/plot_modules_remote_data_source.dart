import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kroppi/core/network/api/api_endpoints.dart';
import 'package:kroppi/core/network/api/fastapi_client.dart';

class PlotModulesRemoteDataSource {
  PlotModulesRemoteDataSource([Dio? dio]) : _dio = dio ?? FastApiClient.client;

  final Dio _dio;

  String _day(DateTime date) => date.toIso8601String().split('T').first;

  Future<List<Map<String, dynamic>>> getCare(
    String plotId, {
    String? type,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.careActivities(plotId),
      queryParameters: {'limit': 50, 'offset': offset, 'type': ?type},
    );
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getCareById(String id) async =>
      (await _dio.get(ApiEndpoints.careActivity(id))).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> saveCare(
    String plotId,
    Map<String, dynamic> body, {
    String? id,
  }) async =>
      (await _dio.request(
        id == null
            ? ApiEndpoints.careActivities(plotId)
            : ApiEndpoints.careActivity(id),
        data: body,
        options: Options(method: id == null ? 'POST' : 'PATCH'),
      )).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> uploadCareEvidence(String id, String path) async {
    final extension = path.split('.').last.toLowerCase();
    final mime = switch (extension) {
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      _ => MediaType('image', 'jpeg'),
    };
    final data = FormData.fromMap({
      'file': await MultipartFile.fromFile(path, contentType: mime),
    });
    return (await _dio.put(ApiEndpoints.careEvidence(id), data: data)).data
        as Map<String, dynamic>;
  }

  Future<void> deleteCare(String id) async {
    await _dio.delete(ApiEndpoints.careActivity(id));
  }

  Future<void> deleteCareEvidence(String id) async {
    await _dio.delete(ApiEndpoints.careEvidence(id));
  }

  Future<Map<String, dynamic>> getStats(
    String plotId, {
    required DateTime from,
    required DateTime to,
    String granularity = 'month',
  }) async =>
      (await _dio.get(
        ApiEndpoints.plotStats(plotId),
        queryParameters: {
          'from': _day(from),
          'to': _day(to),
          'granularity': granularity,
        },
      )).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> getTimeline(
    String plotId, {
    String? before,
    List<String>? types,
    int limit = 50,
  }) async =>
      (await _dio.get(
        ApiEndpoints.plotTimeline(plotId),
        queryParameters: {
          'limit': limit,
          'before': ?before,
          'types': ?(types == null || types.isEmpty ? null : types.join(',')),
        },
      )).data as Map<String, dynamic>;

  Future<Map<String, dynamic>> getReportData(
    String plotId, {
    required DateTime from,
    required DateTime to,
  }) async =>
      (await _dio.get(
        ApiEndpoints.plotReportData(plotId),
        queryParameters: {'from': _day(from), 'to': _day(to)},
      )).data as Map<String, dynamic>;

  Future<List<Map<String, dynamic>>> getReports(String plotId) async {
    final response = await _dio.get(ApiEndpoints.plotReports(plotId));
    return (response.data as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getReport(String id) async =>
      (await _dio.get(ApiEndpoints.report(id))).data as Map<String, dynamic>;

  Future<Uint8List> downloadFile(String url) async {
    final response = await Dio().get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    if (response.data == null) {
      throw StateError('El servidor no devolvió el archivo solicitado.');
    }
    return Uint8List.fromList(response.data!);
  }

  Future<void> deleteReport(String id) async {
    await _dio.delete(ApiEndpoints.report(id));
  }

  Future<Map<String, dynamic>> uploadReport({
    required String plotId,
    required DateTime from,
    required DateTime to,
    required Uint8List bytes,
    required String filename,
  }) async {
    final body = FormData.fromMap({
      'period_from': _day(from),
      'period_to': _day(to),
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: MediaType('application', 'pdf'),
      ),
    });
    return (await _dio.post(ApiEndpoints.plotReports(plotId), data: body)).data
        as Map<String, dynamic>;
  }
}
