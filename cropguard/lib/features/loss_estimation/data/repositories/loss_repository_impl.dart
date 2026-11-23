import 'package:kroppi/core/errors/failures.dart';
import 'package:kroppi/core/network/api/dio_guard.dart';
import 'package:kroppi/features/profile/data/datasources/plan_access_remote_data_source.dart';

import '../../domain/entities/loss_estimation.dart';
import '../../domain/repositories/loss_repository.dart';
import '../datasources/loss_remote_data_source.dart';

class LossRepositoryImpl implements LossRepository {
  LossRepositoryImpl({required this.planAccess, LossRemoteDataSource? source})
    : _source = source ?? LossRemoteDataSource();

  final PlanAccessRemoteDataSource planAccess;
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
      dioGuard(() async {
        await _ensureCanRecord();
        return _source.create(plotId, input);
      });

  @override
  Future<LossPage> list(String plotId, {int limit = 20, int offset = 0}) =>
      dioGuard(() => _source.list(plotId, limit: limit, offset: offset));

  @override
  Future<LossEstimation> get(String id) => dioGuard(() => _source.get(id));

  @override
  Future<LossEstimation> update(String id, LossInput input) =>
      dioGuard(() async {
        await _ensureCanRecord();
        return _source.update(id, input);
      });

  @override
  Future<void> delete(String id) => dioGuard(() => _source.delete(id));

  Future<void> _ensureCanRecord() async {
    try {
      await planAccess.ensureCanRecordLossEstimation();
    } on Failure {
      rethrow;
    } catch (error) {
      throw ServerFailure('No se pudo validar tu plan: $error');
    }
  }
}
