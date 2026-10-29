import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/diagnosis_record.dart';
import '../../domain/usecases/get_diagnosis_history_usecase.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.records = const [],
    this.message,
  });

  final HistoryStatus status;

  /// Diagnósticos cargados.
  final List<DiagnosisRecord> records;

  /// Mensaje de error (solo en `failure`).
  final String? message;

  bool get isLoading => status == HistoryStatus.loading;
  bool get isEmpty => status == HistoryStatus.success && records.isEmpty;

  @override
  List<Object?> get props => [status, records, message];
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._getHistory) : super(const HistoryState());

  final GetDiagnosisHistoryUsecase _getHistory;

  Future<void> load() async {
    if (state.isLoading) return;
    emit(HistoryState(status: HistoryStatus.loading, records: state.records));
    try {
      final records = await _getHistory();
      emit(HistoryState(status: HistoryStatus.success, records: records));
    } catch (error) {
      emit(
        HistoryState(
          status: HistoryStatus.failure,
          records: state.records,
          message: error.toString(),
        ),
      );
    }
  }
}
