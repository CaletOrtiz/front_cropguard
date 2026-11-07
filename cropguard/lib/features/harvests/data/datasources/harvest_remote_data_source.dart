import 'package:dio/dio.dart';
import 'package:kroppi/core/network/api/api_endpoints.dart';
import 'package:kroppi/core/network/api/fastapi_client.dart';
import 'package:kroppi/core/utils/number_format.dart';

import '../../domain/entities/harvest.dart';

class HarvestRemoteDataSource {
  HarvestRemoteDataSource([Dio? dio]) : _dio = dio ?? FastApiClient.client;

  final Dio _dio;

  Future<HarvestPage> list(
    String plotId, {
    DateTime? from,
    DateTime? to,
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.plotHarvests(plotId),
      queryParameters: {
        'limit': limit,
        'offset': offset,
        'from': ?(from == null ? null : apiDate(from)),
        'to': ?(to == null ? null : apiDate(to)),
      },
    );
    return HarvestPage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Harvest> get(String id) async {
    final response = await _dio.get(ApiEndpoints.harvest(id));
    return Harvest.fromJson(response.data as Map<String, dynamic>);
  }

  Future<HarvestSaveResult> create(String plotId, HarvestInput input) async {
    final response = await _dio.post(
      ApiEndpoints.plotHarvests(plotId),
      data: input.toJson(),
    );
    return HarvestSaveResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<HarvestSaveResult> update(String id, HarvestInput input) async {
    final response = await _dio.patch(
      ApiEndpoints.harvest(id),
      data: input.toJson(),
    );
    return HarvestSaveResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete(ApiEndpoints.harvest(id));
  }
}
