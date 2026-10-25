import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kroppi/features/crop_diagnosis/presentation/services/image_picker_service.dart';
import '../bloc/diagnosis_bloc.dart';
import '../bloc/diagnosis_event.dart';
import '../bloc/diagnosis_state.dart';

class DiagnosisScreen extends StatelessWidget {
  final String userId;

  const DiagnosisScreen({super.key, required this.userId});

  void _showImageSourceModal(BuildContext context) {
    final imagePickerService = ImagePickerService();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: Colors.green),
                  title: const Text('Tomar foto con la cámara'),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    final File? image = await imagePickerService
                        .pickImageFromCamera();

                    if (image != null && context.mounted) {
                      context.read<DiagnosisBloc>().add(
                        AnalyzeImageSubmittedEvent(
                          imageFile: image,
                          userId: userId,
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.green),
                  title: const Text('Seleccionar de la galería'),
                  onTap: () async {
                    Navigator.pop(bottomSheetContext);
                    final File? image = await imagePickerService
                        .pickImageFromGallery();

                    if (image != null && context.mounted) {
                      context.read<DiagnosisBloc>().add(
                        AnalyzeImageSubmittedEvent(
                          imageFile: image,
                          userId: userId,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico de Cultivo')),
      body: Center(
        child: BlocBuilder<DiagnosisBloc, DiagnosisState>(
          builder: (context, state) {
            if (state is DiagnosisLoadingState) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analizando imagen con IA...'),
                ],
              );
            } else if (state is DiagnosisSuccessState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enfermedad: ${state.result.diseaseName}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Confianza: ${(state.result.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Recomendaciones de Gemini:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(state.result.geminiRecommendations),
                    ],
                  ),
                ),
              );
            } else if (state is DiagnosisErrorState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return const Text('Toma o selecciona una foto para comenzar');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceModal(context),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
