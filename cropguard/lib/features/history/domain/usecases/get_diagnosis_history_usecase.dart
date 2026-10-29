import '../entities/diagnosis_record.dart';
import '../repositories/history_repository.dart';

class GetDiagnosisHistoryUsecase {
  const GetDiagnosisHistoryUsecase(this._repository);

  final HistoryRepository _repository;

  Future<List<DiagnosisRecord>> call({int from = 0, int pageSize = 20}) {
    return _repository.getHistory(from: from, pageSize: pageSize);
  }
}
