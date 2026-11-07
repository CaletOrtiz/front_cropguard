import 'package:kroppi/core/network/api/dio_guard.dart';

import '../../domain/entities/loss_estimation.dart';
import '../../domain/repositories/loss_repository.dart';
import '../datasources/loss_remote_data_source.dart';

class LossRepositoryImpl implements LossRepository {
  LossRepositoryImpl([LossRemoteDataSource? source])
    : _source = source ?? LossRemoteDataSource();

  final LossRemoteDataSource _source;

  @override
  Future<LossDefaults> defaults(String plotId) =>
      dioGuard(() => _source.defaults(plotId));

  @override
  Future<LossEstimation> preview(
    String plotId,
    LossInput input, {
    String? excludeId,
  }) => dioGuard(() => _source.preview(plotId, input, excludeId: excludeId));

  @override
  Future<LossEstimation> create(String plotId, LossInput input) =>
      dioGuard(() => _source.create(plotId, input));

  @override
  Future<LossPage> list(String plotId, {int limit = 20, int offset = 0}) =>
      dioGuard(() => _source.list(plotId, limit: limit, offset: offset));

  @override
  Future<LossEstimation> get(String id) => dioGuard(() => _source.get(id));

  @override
  Future<LossEstimation> update(String id, LossInput input) =>
      dioGuard(() => _source.update(id, input));

  @override
  Future<void> delete(String id) => dioGuard(() => _source.delete(id));
}
