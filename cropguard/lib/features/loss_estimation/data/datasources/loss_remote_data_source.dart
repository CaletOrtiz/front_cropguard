import 'package:dio/dio.dart';
import 'package:kroppi/core/network/api/api_endpoints.dart';
import 'package:kroppi/core/network/api/fastapi_client.dart';

import '../../domain/entities/loss_estimation.dart';

class LossRemoteDataSource {
  LossRemoteDataSource([Dio? dio]) : _dio = dio ?? FastApiClient.client;

  final Dio _dio;

  Map<String, dynamic> _map(Response response) =>
      response.data as Map<String, dynamic>;

  Future<LossDefaults> defaults(String plotId) async => LossDefaults.fromJson(
    _map(await _dio.get(ApiEndpoints.plotLossDefaults(plotId))),
  );

  /// [excludeId]: estimación en edición, para que no choque consigo misma en
  /// la validación de traslape de periodos.
  Future<LossEstimation> preview(
    String plotId,
    LossInput input, {
    String? excludeId,
  }) async => LossEstimation.fromJson(
    _map(
      await _dio.post(
        ApiEndpoints.plotLossPreview(plotId),
        data: input.toJson(),
        queryParameters: {'exclude_id': ?excludeId},
      ),
    ),
  );

  Future<LossEstimation> create(String plotId, LossInput input) async =>
      LossEstimation.fromJson(
        _map(
          await _dio.post(
            ApiEndpoints.plotLossEstimations(plotId),
            data: input.toJson(),
          ),
        ),
      );

  Future<LossPage> list(
    String plotId, {
    int limit = 20,
    int offset = 0,
  }) async => LossPage.fromJson(
    _map(
      await _dio.get(
        ApiEndpoints.plotLossEstimations(plotId),
        queryParameters: {'limit': limit, 'offset': offset},
      ),
    ),
  );

  Future<LossEstimation> get(String id) async => LossEstimation.fromJson(
    _map(await _dio.get(ApiEndpoints.lossEstimation(id))),
  );

  Future<LossEstimation> update(String id, LossInput input) async =>
      LossEstimation.fromJson(
        _map(
          await _dio.patch(
            ApiEndpoints.lossEstimation(id),
            data: input.toJson(),
          ),
        ),
      );

  Future<void> delete(String id) async {
    await _dio.delete(ApiEndpoints.lossEstimation(id));
  }
}
