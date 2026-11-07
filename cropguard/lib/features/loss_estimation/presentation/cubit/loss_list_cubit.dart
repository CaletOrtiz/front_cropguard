import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/core/errors/failures.dart';

import '../../domain/entities/loss_estimation.dart';
import '../../domain/repositories/loss_repository.dart';

enum LossListStatus { loading, success, failure }

class LossListState extends Equatable {
  const LossListState({
    this.status = LossListStatus.loading,
    this.items = const [],
    this.nextOffset,
    this.loadingMore = false,
    this.failure,
  });

  final LossListStatus status;
  final List<LossEstimation> items;
  final int? nextOffset;
  final bool loadingMore;
  final Failure? failure;

  bool get isEmpty => status == LossListStatus.success && items.isEmpty;

  @override
  List<Object?> get props => [status, items, nextOffset, loadingMore, failure];
}

class LossListCubit extends Cubit<LossListState> {
  LossListCubit(this._repository, this.plotId) : super(const LossListState());

  final LossRepository _repository;
  final String plotId;
  static const pageSize = 20;

  Future<void> load() async {
    emit(LossListState(items: state.items));
    try {
      final page = await _repository.list(plotId, limit: pageSize);
      if (isClosed) return;
      emit(
        LossListState(
          status: LossListStatus.success,
          items: page.items,
          nextOffset: page.nextOffset,
        ),
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        LossListState(
          status: LossListStatus.failure,
          items: state.items,
          failure: failure,
        ),
      );
    }
  }

  Future<void> loadMore() async {
    final offset = state.nextOffset;
    if (offset == null || state.loadingMore) return;
    emit(
      LossListState(
        status: state.status,
        items: state.items,
        nextOffset: offset,
        loadingMore: true,
      ),
    );
    try {
      final page = await _repository.list(
        plotId,
        limit: pageSize,
        offset: offset,
      );
      if (isClosed) return;
      emit(
        LossListState(
          status: LossListStatus.success,
          items: [...state.items, ...page.items],
          nextOffset: page.nextOffset,
        ),
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        LossListState(
          status: LossListStatus.success,
          items: state.items,
          nextOffset: offset,
          failure: failure,
        ),
      );
    }
  }

  Future<Failure?> delete(String id) async {
    try {
      await _repository.delete(id);
      await load();
      return null;
    } on Failure catch (failure) {
      return failure;
    }
  }
}
