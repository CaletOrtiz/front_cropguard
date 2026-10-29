import '../entities/diagnosis_record.dart';

abstract interface class HistoryRepository {
  Future<List<DiagnosisRecord>> getHistory({int from = 0, int pageSize = 20});

  Future<DiagnosisRecord?> getById(String id);
}
