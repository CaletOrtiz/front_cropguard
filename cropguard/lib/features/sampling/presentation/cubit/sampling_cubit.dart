import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kroppi/features/crop_diagnosis/domain/usecases/analyze_crop_image_usecase.dart';
import 'package:kroppi/features/my_crops/data/datasources/my_crops_remote_data_source.dart';
import 'package:kroppi/features/my_crops/domain/entities/plot_sample.dart';

enum SamplingStatus { idle, scanning, closing, done, failure }

/// Qué dijo el modelo sobre una foto.
enum ScanOutcome { healthy, diseased, inconclusive }

/// Datos que PlotDetailScreen le pasa al muestreo (vía `extra` de la ruta).
class SamplingArgs {
  const SamplingArgs({this.cropSlug = 'cafe', this.plantCount});

  final String cropSlug;

  /// Plantas registradas en el lote (puede ser null si no se indicó).
  final int? plantCount;

  /// Sugerencia para la cantidad inicial del muestreo.
  static const int maxTarget = 20;

  /// Sugerencia inicial, limitada a la cantidad registrada cuando existe.
  int get target {
    final n = plantCount;
    if (n == null) return maxTarget;
    if (n < 1) return maxTarget;
    return n > maxTarget ? maxTarget : n;
  }
}

/// Resultado de UNA foto del muestreo (para mostrarlo en pantalla).
class ScanItem extends Equatable {
  const ScanItem({
    required this.id,
    required this.label,
    required this.confidence,
    required this.outcome,
  });

  final String id; // id del diagnóstico en el backend
  final String label; // "Roya del café", "Hoja sana"...
  final double confidence; // 0..1
  final ScanOutcome outcome;

  @override
  List<Object?> get props => [id, label, confidence, outcome];
}

class SamplingState extends Equatable {
  const SamplingState({
    this.status = SamplingStatus.idle,
    this.scans = const [],
    this.result,
    this.message,
  });

  final SamplingStatus status;
  final List<ScanItem> scans; // una por foto, en orden
  final SampleResult? result;
  final String? message;

  /// Fotos concluyentes: son las que realmente cuentan como plantas evaluadas.
  int get evaluated =>
      scans.where((s) => s.outcome != ScanOutcome.inconclusive).length;

  /// Fotos concluyentes con enfermedad: plantas afectadas.
  int get affected =>
      scans.where((s) => s.outcome == ScanOutcome.diseased).length;

  /// Fotos con confianza baja (no cuentan en el resultado).
  int get inconclusive =>
      scans.where((s) => s.outcome == ScanOutcome.inconclusive).length;

  bool get isBusy =>
      status == SamplingStatus.scanning || status == SamplingStatus.closing;

  SamplingState copyWith({
    SamplingStatus? status,
    List<ScanItem>? scans,
    SampleResult? result,
    String? message,
  }) => SamplingState(
    status: status ?? this.status,
    scans: scans ?? this.scans,
    result: result ?? this.result,
    message: message, // se limpia en cada emisión
  );

  @override
  List<Object?> get props => [status, scans, result, message];
}

class SamplingCubit extends Cubit<SamplingState> {
  SamplingCubit({
    required this.plotId,
    required this.cropSlug,
    required this.userId,
    required this._analyze, // Usando initializing formal
    required this._source, // Usando initializing formal
    this.target = 20,
    this.maxPlants,
  }) : super(const SamplingState());

  final String plotId;
  final String cropSlug;
  final String userId;

  /// Cantidad elegida por el usuario para esta sesión.
  int target;

  /// Tope duro: plantas que tiene el lote. Null = sin tope.
  final int? maxPlants;

  final AnalyzeCropImageUsecase _analyze;
  final MyCropsRemoteDataSource _source;

  /// Muestreo creado en el backend con la primera foto (las fotos deben
  /// pertenecer a un muestreo existente). Null hasta entonces.
  String? _sampleId;

  /// ¿Se pueden seguir escaneando plantas? (no pasar de las que tiene el lote)
  bool get canScan {
    if (state.isBusy) return false;
    final m = maxPlants;
    return state.evaluated < target && (m == null || state.evaluated < m);
  }

  bool configureTarget(int plants) {
    if (plants < 1 || (maxPlants != null && plants > maxPlants!)) return false;
    target = plants;
    emit(state.copyWith(status: SamplingStatus.idle));
    return true;
  }

  Future<void> scan(XFile image) async {
    if (!canScan) return;
    emit(state.copyWith(status: SamplingStatus.scanning));
    try {
      // Cantidades provisionales; finish() guarda las reales.
      final sampleId = _sampleId ??= await _source.startSample(
        plotId,
        plantsEvaluated: target,
      );
      final d = await _analyze(
        imageFile: image,
        userId: userId,
        plotSamplesId: sampleId,
      );
      final outcome = !d.isConclusive
          ? ScanOutcome.inconclusive
          : (d.isHealthy ? ScanOutcome.healthy : ScanOutcome.diseased);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: SamplingStatus.idle,
          scans: [
            ...state.scans,
            ScanItem(
              id: d.id,
              label: d.diseaseName,
              confidence: d.confidence,
              outcome: outcome,
            ),
          ],
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(status: SamplingStatus.failure, message: e.toString()),
      );
    }
  }

  /// Quita una foto del muestreo (por ejemplo si salió mal o se tomó por error).
  /// También borra el diagnóstico en el backend para que no cuente en el muestreo.
  Future<void> remove(int index) async {
    if (state.isBusy || index < 0 || index >= state.scans.length) return;
    final scan = state.scans[index];
    emit(state.copyWith(status: SamplingStatus.scanning));
    try {
      await _source.deleteDiagnosis(scan.id);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: SamplingStatus.idle,
          scans: [...state.scans]..remove(scan),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(status: SamplingStatus.failure, message: e.toString()),
      );
    }
  }

  Future<void> finish() async {
    final sampleId = _sampleId;
    if (state.isBusy || state.evaluated == 0 || sampleId == null) return;
    emit(state.copyWith(status: SamplingStatus.closing));
    try {
      final r = await _source.finishSample(
        sampleId,
        plantsEvaluated: state.evaluated,
        plantsAffected: state.affected,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: SamplingStatus.done,
          result: r.copyWith(discarded: state.inconclusive),
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(status: SamplingStatus.failure, message: e.toString()),
      );
    }
  }

  /// Si se sale sin finalizar, el muestreo provisional se borra (con sus fotos)
  /// para no dejar cantidades falsas en el lote.
  @override
  Future<void> close() {
    final sampleId = _sampleId;
    if (sampleId != null && state.status != SamplingStatus.done) {
      unawaited(_source.discardSample(sampleId).catchError((_) {}));
    }
    return super.close();
  }
}
