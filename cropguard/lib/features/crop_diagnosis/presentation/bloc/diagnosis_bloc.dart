import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/features/my_crops/data/datasources/my_crops_remote_data_source.dart';

import '../../domain/usecases/analyze_crop_image_usecase.dart';
import 'diagnosis_event.dart';
import 'diagnosis_state.dart';

class DiagnosisBloc extends Bloc<DiagnosisEvent, DiagnosisState> {
  final AnalyzeCropImageUsecase analyzeCropImageUseCase;
  final MyCropsRemoteDataSource sampleSource;

  DiagnosisBloc({
    required this.analyzeCropImageUseCase,
    required this.sampleSource,
  }) : super(DiagnosisInitialState()) {
    on<AnalyzeImageSubmittedEvent>(_onAnalyzeImageSubmitted);
  }

  /// Un diagnóstico suelto se registra como un muestreo de 1 planta del lote
  /// elegido: el backend no acepta diagnósticos sin muestreo.
  Future<void> _onAnalyzeImageSubmitted(
    AnalyzeImageSubmittedEvent event,
    Emitter<DiagnosisState> emit,
  ) async {
    emit(DiagnosisLoadingState());

    String? sampleId;
    try {
      sampleId = await sampleSource.startSample(
        event.plotId,
        plantsEvaluated: 1,
      );
      final result = await analyzeCropImageUseCase(
        imageFile: event.imageFile,
        userId: event.userId,
        prompt: event.prompt,
        plotSamplesId: sampleId,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      if (result.isDiseased) {
        await sampleSource.finishSample(
          sampleId,
          plantsEvaluated: 1,
          plantsAffected: 1,
        );
      }
      emit(DiagnosisSuccessState(result: result));
    } catch (e) {
      if (sampleId != null) {
        // Sin diagnóstico válido el muestreo de 1 planta no debe quedar.
        await sampleSource.discardSample(sampleId).catchError((_) {});
      }
      emit(DiagnosisErrorState(message: e.toString()));
    }
  }
}
