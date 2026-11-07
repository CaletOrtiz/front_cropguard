import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/core/errors/failures.dart';

import '../../domain/entities/harvest.dart';
import '../../domain/repositories/harvest_repository.dart';

enum HarvestFormStatus { loading, ready, saving, saved, deleted, failure }

class HarvestFormState extends Equatable {
  const HarvestFormState({
    required this.status,
    this.harvest,
    this.result,
    this.failure,
    this.lastCurrency = 'COP',
  });

  final HarvestFormStatus status;

  /// Cosecha en edición (null al crear).
  final Harvest? harvest;
  final HarvestSaveResult? result;
  final Failure? failure;

  /// Moneda sugerida para una cosecha nueva (la de la última cosecha).
  final String lastCurrency;

  bool get isSaving => status == HarvestFormStatus.saving;

  @override
  List<Object?> get props => [status, harvest, result, failure, lastCurrency];
}

class HarvestFormCubit extends Cubit<HarvestFormState> {
  HarvestFormCubit(this._repository, {required this.plotId, this.harvestId})
    : super(
        HarvestFormState(
          status: harvestId == null
              ? HarvestFormStatus.ready
              : HarvestFormStatus.loading,
        ),
      );

  final HarvestRepository _repository;
  final String plotId;
  final String? harvestId;

  bool get isEditing => harvestId != null;

  Future<void> load() async {
    final id = harvestId;
    try {
      if (id == null) {
        // Solo para sugerir la moneda; si falla, se queda en COP.
        final page = await _repository.list(plotId, limit: 1);
        if (isClosed || page.items.isEmpty) return;
        emit(
          HarvestFormState(
            status: state.status,
            lastCurrency: page.items.first.currency,
          ),
        );
        return;
      }
      emit(const HarvestFormState(status: HarvestFormStatus.loading));
      final harvest = await _repository.get(id);
      if (isClosed) return;
      emit(HarvestFormState(status: HarvestFormStatus.ready, harvest: harvest));
    } on Failure catch (failure) {
      if (isClosed || id == null) return;
      emit(
        HarvestFormState(status: HarvestFormStatus.failure, failure: failure),
      );
    }
  }

  Future<void> save(HarvestInput input) async {
    if (state.isSaving) return;
    final previous = state;
    emit(
      HarvestFormState(
        status: HarvestFormStatus.saving,
        harvest: previous.harvest,
        lastCurrency: previous.lastCurrency,
      ),
    );
    try {
      final id = harvestId;
      final result = id == null
          ? await _repository.create(plotId, input)
          : await _repository.update(id, input);
      if (isClosed) return;
      emit(
        HarvestFormState(
          status: HarvestFormStatus.saved,
          harvest: result.harvest,
          result: result,
        ),
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        HarvestFormState(
          status: HarvestFormStatus.ready,
          harvest: previous.harvest,
          failure: failure,
          lastCurrency: previous.lastCurrency,
        ),
      );
    }
  }

  Future<void> delete() async {
    final id = harvestId;
    if (id == null || state.isSaving) return;
    final previous = state;
    emit(
      HarvestFormState(
        status: HarvestFormStatus.saving,
        harvest: previous.harvest,
      ),
    );
    try {
      await _repository.delete(id);
      if (isClosed) return;
      emit(const HarvestFormState(status: HarvestFormStatus.deleted));
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        HarvestFormState(
          status: HarvestFormStatus.ready,
          harvest: previous.harvest,
          failure: failure,
        ),
      );
    }
  }
}
