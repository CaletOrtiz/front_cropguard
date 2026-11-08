import 'package:flutter_test/flutter_test.dart';
import 'package:kroppi/features/history/domain/entities/diagnosis_record.dart';
import 'package:kroppi/features/history/domain/usecases/get_diagnosis_history_usecase.dart';
import 'package:kroppi/features/history/presentation/cubit/history_cubit.dart';

void main() {
  test('loads every page before marking history successful', () async {
    final usecase = _PagedHistoryUsecase();
    final cubit = HistoryCubit(usecase);
    addTearDown(cubit.close);

    await cubit.load();

    expect(usecase.offsets, [0, 100]);
    expect(cubit.state.status, HistoryStatus.success);
    expect(cubit.state.records, hasLength(101));
  });
}

class _PagedHistoryUsecase implements GetDiagnosisHistoryUsecase {
  final offsets = <int>[];

  @override
  Future<List<DiagnosisRecord>> call({int from = 0, int pageSize = 20}) async {
    offsets.add(from);
    final count = from == 0 ? pageSize : 1;
    return List.generate(
      count,
      (index) => DiagnosisRecord(
        id: '${from + index}',
        cropId: 'cafe',
        cropName: 'Café',
        pathogen: 'Roya',
        pathogenType: 'Hongo',
        date: DateTime(2026, 11, 8),
        confidence: 90,
        symptoms: const [],
        recommendations: const [],
      ),
    );
  }
}
