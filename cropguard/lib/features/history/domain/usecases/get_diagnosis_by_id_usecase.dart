import '../entities/diagnosis_record.dart';
import '../repositories/history_repository.dart';

class GetDiagnosisByIdUsecase {
  const GetDiagnosisByIdUsecase(this._repository);

  final HistoryRepository _repository;

  Future<DiagnosisRecord?> call(String id) => _repository.getById(id);
}
