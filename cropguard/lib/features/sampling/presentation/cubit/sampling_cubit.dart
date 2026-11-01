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

  /// Máximo de plantas a muestrear por defecto.
  static const int maxTarget = 20;

  /// Meta de plantas: nunca más que las que tiene el lote (mínimo 1, máximo 20).
  int get target {
    final n = plantCount;
    if (n == null) return maxTarget;
    return n < 1 ? 1 : (n > maxTarget ? maxTarget : n);
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

  /// Ids de todos los diagnósticos de esta sesión (el backend descarta
  /// los no concluyentes al cerrar).
  List<String> get ids => scans.map((s) => s.id).toList();

  /// Fotos concluyentes: son las que realmente cuentan como plantas evaluadas.
  int get evaluated =>
      scans.where((s) => s.outcome != ScanOutcome.inconclusive).length;

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

  /// Meta de plantas a escanear (min(plantas del lote, 20)).
  final int target;

  /// Tope duro: plantas que tiene el lote. Null = sin tope.
  final int? maxPlants;

  final AnalyzeCropImageUsecase _analyze;
  final MyCropsRemoteDataSource _source;

  /// Solo para avisar en pantalla; la decisión real la toma el backend.
  static const _umbral = 0.7;

  /// Nombres que el backend usa para "sin enfermedad".
  static const _sanos = {'Hoja sana', 'Planta sana'};

  /// ¿Se pueden seguir escaneando plantas? (no pasar de las que tiene el lote)
  bool get canScan {
    if (state.isBusy) return false;
    final m = maxPlants;
    return m == null || state.evaluated < m;
  }

  Future<void> scan(XFile image) async {
    if (!canScan) return;
    emit(state.copyWith(status: SamplingStatus.scanning));
    try {
      final d = await _analyze(
        imageFile: image,
        userId: userId,
        cropSlug: cropSlug,
        plotId: plotId,
      );
      final outcome = d.confidence < _umbral
          ? ScanOutcome.inconclusive
          : (_sanos.contains(d.diseaseName)
                ? ScanOutcome.healthy
                : ScanOutcome.diseased);
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
  void remove(int index) {
    if (state.isBusy || index < 0 || index >= state.scans.length) return;
    final copy = [...state.scans]..removeAt(index);
    emit(state.copyWith(status: SamplingStatus.idle, scans: copy));
  }

  Future<void> finish() async {
    if (state.isBusy || state.evaluated == 0) return;
    emit(state.copyWith(status: SamplingStatus.closing));
    try {
      final r = await _source.closeSample(plotId, state.ids);
      if (isClosed) return;
      emit(state.copyWith(status: SamplingStatus.done, result: r));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(status: SamplingStatus.failure, message: e.toString()),
      );
    }
  }
}
