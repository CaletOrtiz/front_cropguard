import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/core/errors/failures.dart';

import '../../domain/entities/harvest.dart';
import '../../domain/repositories/harvest_repository.dart';

enum HarvestListStatus { loading, success, failure }

class HarvestListState extends Equatable {
  const HarvestListState({
    this.status = HarvestListStatus.loading,
    this.items = const [],
    this.totals = const HarvestTotals(),
    this.nextOffset,
    this.loadingMore = false,
    this.from,
    this.to,
    this.failure,
  });

  final HarvestListStatus status;
  final List<Harvest> items;
  final HarvestTotals totals;
  final int? nextOffset;
  final bool loadingMore;
  final DateTime? from;
  final DateTime? to;
  final Failure? failure;

  bool get isEmpty => status == HarvestListStatus.success && items.isEmpty;

  HarvestListState copyWith({
    HarvestListStatus? status,
    List<Harvest>? items,
    HarvestTotals? totals,
    int? Function()? nextOffset,
    bool? loadingMore,
    DateTime? Function()? from,
    DateTime? Function()? to,
    Failure? Function()? failure,
  }) => HarvestListState(
    status: status ?? this.status,
    items: items ?? this.items,
    totals: totals ?? this.totals,
    nextOffset: nextOffset != null ? nextOffset() : this.nextOffset,
    loadingMore: loadingMore ?? this.loadingMore,
    from: from != null ? from() : this.from,
    to: to != null ? to() : this.to,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    status,
    items,
    totals,
    nextOffset,
    loadingMore,
    from,
    to,
    failure,
  ];
}

class HarvestListCubit extends Cubit<HarvestListState> {
  HarvestListCubit(this._repository, this.plotId)
    : super(const HarvestListState());

  final HarvestRepository _repository;
  final String plotId;
  static const pageSize = 20;

  Future<void> load() async {
    emit(
      state.copyWith(status: HarvestListStatus.loading, failure: () => null),
    );
    try {
      final page = await _repository.list(
        plotId,
        from: state.from,
        to: state.to,
        limit: pageSize,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: HarvestListStatus.success,
          items: page.items,
          totals: page.totals,
          nextOffset: () => page.nextOffset,
        ),
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: HarvestListStatus.failure,
          failure: () => failure,
        ),
      );
    }
  }

  Future<void> setRange(DateTime? from, DateTime? to) {
    emit(state.copyWith(from: () => from, to: () => to));
    return load();
  }

  /// Scroll infinito: trae la siguiente página si existe.
  Future<void> loadMore() async {
    final offset = state.nextOffset;
    if (offset == null || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    try {
      final page = await _repository.list(
        plotId,
        from: state.from,
        to: state.to,
        limit: pageSize,
        offset: offset,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          items: [...state.items, ...page.items],
          totals: page.totals,
          nextOffset: () => page.nextOffset,
          loadingMore: false,
        ),
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(state.copyWith(loadingMore: false, failure: () => failure));
    }
  }

  /// Borra y recarga (los totales los recalcula el backend).
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
