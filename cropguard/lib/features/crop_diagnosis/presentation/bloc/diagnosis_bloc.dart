import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/analyze_crop_image_usecase.dart';
import 'diagnosis_event.dart';
import 'diagnosis_state.dart';

class DiagnosisBloc extends Bloc<DiagnosisEvent, DiagnosisState> {
  final AnalyzeCropImageUsecase analyzeCropImageUseCase;

  DiagnosisBloc({required this.analyzeCropImageUseCase})
    : super(DiagnosisInitialState()) {
    on<AnalyzeImageSubmittedEvent>(_onAnalyzeImageSubmitted);
  }

  Future<void> _onAnalyzeImageSubmitted(
    AnalyzeImageSubmittedEvent event,
    Emitter<DiagnosisState> emit,
  ) async {
    emit(DiagnosisLoadingState());

    try {
      final result = await analyzeCropImageUseCase(
        imageFile: event.imageFile,
        userId: event.userId,
        prompt: event.prompt,
        cropSlug: event.cropSlug,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(DiagnosisSuccessState(result: result));
    } catch (e) {
      emit(DiagnosisErrorState(message: e.toString()));
    }
  }
}
