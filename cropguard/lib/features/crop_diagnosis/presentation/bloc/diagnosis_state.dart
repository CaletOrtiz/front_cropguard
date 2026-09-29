import '../../domain/entities/crop_diagnosis.dart';

abstract class DiagnosisState {}

class DiagnosisInitialState extends DiagnosisState {}

class DiagnosisLoadingState extends DiagnosisState {}

class DiagnosisSuccessState extends DiagnosisState {
  final CropDiagnosis result;

  DiagnosisSuccessState({required this.result});
}

class DiagnosisErrorState extends DiagnosisState {
  final String message;

  DiagnosisErrorState({required this.message});
}
