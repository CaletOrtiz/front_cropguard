import 'package:kroppi/core/errors/guard.dart';

import '../../domain/entities/diagnosis_record.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._remoteDataSource);

  final HistoryRemoteDataSource _remoteDataSource;

  @override
  Future<List<DiagnosisRecord>> getHistory({int from = 0, int pageSize = 20}) {
    return guardCall<List<DiagnosisRecord>>(
      () => _remoteDataSource.getHistory(from: from, pageSize: pageSize),
    );
  }

  @override
  Future<DiagnosisRecord?> getById(String id) {
    return guardCall<DiagnosisRecord?>(() => _remoteDataSource.getById(id));
  }
}
