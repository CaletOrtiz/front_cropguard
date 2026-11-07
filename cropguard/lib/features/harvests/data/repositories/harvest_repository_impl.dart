import 'package:kroppi/core/network/api/dio_guard.dart';

import '../../domain/entities/harvest.dart';
import '../../domain/repositories/harvest_repository.dart';
import '../datasources/harvest_remote_data_source.dart';

class HarvestRepositoryImpl implements HarvestRepository {
  HarvestRepositoryImpl([HarvestRemoteDataSource? source])
    : _source = source ?? HarvestRemoteDataSource();

  final HarvestRemoteDataSource _source;

  @override
  Future<HarvestPage> list(
    String plotId, {
    DateTime? from,
    DateTime? to,
    int limit = 20,
    int offset = 0,
  }) => dioGuard(
    () =>
        _source.list(plotId, from: from, to: to, limit: limit, offset: offset),
  );

  @override
  Future<Harvest> get(String id) => dioGuard(() => _source.get(id));

  @override
  Future<HarvestSaveResult> create(String plotId, HarvestInput input) =>
      dioGuard(() => _source.create(plotId, input));

  @override
  Future<HarvestSaveResult> update(String id, HarvestInput input) =>
      dioGuard(() => _source.update(id, input));

  @override
  Future<void> delete(String id) => dioGuard(() => _source.delete(id));
}
