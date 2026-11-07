import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/core/errors/failures.dart';

import '../../domain/entities/loss_estimation.dart';
import '../../domain/repositories/loss_repository.dart';

enum LossFormStatus { loading, ready, loadFailure, saving, saved, deleted }

class LossFormState extends Equatable {
  const LossFormState({
    required this.status,
    this.defaults,
    this.estimation,
    this.preview,
    this.previewLoading = false,
    this.previewFailure,
    this.saveFailure,
    this.periodConflict = false,
    this.loadFailure,
  });

  final LossFormStatus status;

  /// Valores sugeridos (solo al crear).
  final LossDefaults? defaults;

  /// Estimación guardada (al editar, o tras guardar).
  final LossEstimation? estimation;

  /// Último resultado calculado por el backend sin guardar.
  final LossEstimation? preview;
  final bool previewLoading;
  final Failure? previewFailure;
  final Failure? saveFailure;

  /// El backend rechazó el periodo por traslape: resaltar las fechas.
  final bool periodConflict;
  final Failure? loadFailure;

  bool get isSaving => status == LossFormStatus.saving;

  LossFormState copyWith({
    LossFormStatus? status,
    LossDefaults? defaults,
    LossEstimation? estimation,
    LossEstimation? Function()? preview,
    bool? previewLoading,
    Failure? Function()? previewFailure,
    Failure? Function()? saveFailure,
    bool? periodConflict,
    Failure? Function()? loadFailure,
  }) => LossFormState(
    status: status ?? this.status,
    defaults: defaults ?? this.defaults,
    estimation: estimation ?? this.estimation,
    preview: preview != null ? preview() : this.preview,
    previewLoading: previewLoading ?? this.previewLoading,
    previewFailure: previewFailure != null
        ? previewFailure()
        : this.previewFailure,
    saveFailure: saveFailure != null ? saveFailure() : this.saveFailure,
    periodConflict: periodConflict ?? this.periodConflict,
    loadFailure: loadFailure != null ? loadFailure() : this.loadFailure,
  );

  @override
  List<Object?> get props => [
    status,
    defaults,
    estimation,
    preview,
    previewLoading,
    previewFailure,
    saveFailure,
    periodConflict,
    loadFailure,
  ];
}

/// Formulario de estimación: prellenado con defaults, preview en vivo con
/// debounce y guardado. Las cifras siempre las calcula el backend.
class LossFormCubit extends Cubit<LossFormState> {
  LossFormCubit(
    this._repository, {
    required this.plotId,
    this.estimationId,
    this.debounce = const Duration(milliseconds: 500),
  }) : super(const LossFormState(status: LossFormStatus.loading));

  final LossRepository _repository;
  final String plotId;
  final String? estimationId;
  final Duration debounce;

  Timer? _timer;
  LossInput? _lastInput;
  int _previewRequest = 0;

  bool get isEditing => estimationId != null;

  Future<void> load() async {
    emit(const LossFormState(status: LossFormStatus.loading));
    try {
      final id = estimationId;
      if (id == null) {
        final defaults = await _repository.defaults(plotId);
        if (isClosed) return;
        emit(LossFormState(status: LossFormStatus.ready, defaults: defaults));
      } else {
        final estimation = await _repository.get(id);
        if (isClosed) return;
        emit(
          LossFormState(
            status: LossFormStatus.ready,
            estimation: estimation,
            preview: estimation,
          ),
        );
      }
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        LossFormState(status: LossFormStatus.loadFailure, loadFailure: failure),
      );
    }
  }

  /// La pantalla llama a esto en cada cambio. `null` = datos inválidos (no se
  /// pide preview). Varios cambios seguidos producen una sola llamada.
  void inputChanged(LossInput? input) {
    _timer?.cancel();
    _lastInput = input;
    if (state.periodConflict) emit(state.copyWith(periodConflict: false));
    if (input == null) return;
    _timer = Timer(debounce, () => _runPreview(input));
  }

  /// Reintenta el último preview sin perder lo escrito.
  Future<void> retryPreview() async {
    final input = _lastInput;
    if (input != null) await _runPreview(input);
  }

  Future<void> _runPreview(LossInput input) async {
    final request = ++_previewRequest;
    emit(state.copyWith(previewLoading: true, previewFailure: () => null));
    try {
      final preview = await _repository.preview(
        plotId,
        input,
        excludeId: estimationId,
      );
      // Ignora respuestas viejas si ya hubo otro cambio.
      if (isClosed || request != _previewRequest) return;
      emit(state.copyWith(preview: () => preview, previewLoading: false));
    } on Failure catch (failure) {
      if (isClosed || request != _previewRequest) return;
      emit(
        state.copyWith(previewLoading: false, previewFailure: () => failure),
      );
    }
  }

  Future<void> save(LossInput input) async {
    if (state.isSaving) return;
    _timer?.cancel();
    emit(
      state.copyWith(
        status: LossFormStatus.saving,
        saveFailure: () => null,
        periodConflict: false,
      ),
    );
    try {
      final id = estimationId;
      final saved = id == null
          ? await _repository.create(plotId, input)
          : await _repository.update(id, input);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LossFormStatus.saved,
          estimation: saved,
          preview: () => saved,
        ),
      );
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LossFormStatus.ready,
          saveFailure: () => failure,
          periodConflict: failure is ValidationFailure && _isOverlap(failure),
        ),
      );
    }
  }

  Future<void> delete() async {
    final id = estimationId;
    if (id == null || state.isSaving) return;
    emit(state.copyWith(status: LossFormStatus.saving));
    try {
      await _repository.delete(id);
      if (isClosed) return;
      emit(state.copyWith(status: LossFormStatus.deleted));
    } on Failure catch (failure) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LossFormStatus.ready,
          saveFailure: () => failure,
        ),
      );
    }
  }

  static bool _isOverlap(Failure failure) {
    final message = failure.message.toLowerCase();
    return message.contains('cruza') || message.contains('periodo');
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
