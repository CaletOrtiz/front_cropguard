import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:kroppi/core/widgets/app_dropdown_field.dart';
import 'package:kroppi/features/crop_diagnosis/presentation/services/image_picker_service.dart';
import 'package:kroppi/features/farms/data/datasources/farm_remote_data_source.dart';
import '../bloc/diagnosis_bloc.dart';
import '../bloc/diagnosis_event.dart';
import '../bloc/diagnosis_state.dart';

/// Lote elegible para un diagnóstico suelto.
class _PlotOption {
  const _PlotOption({required this.id, required this.label});

  final String id;
  final String label;
}

class DiagnosisScreen extends StatefulWidget {
  final String userId;

  const DiagnosisScreen({super.key, required this.userId});

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  // Cada diagnóstico debe pertenecer a un lote (se registra como un muestreo
  // de 1 planta), así que primero se elige el lote.
  List<_PlotOption>? _plots;
  String? _plotId;
  String? _loadError;

  String get userId => widget.userId;

  @override
  void initState() {
    super.initState();
    _loadPlots();
  }

  Future<void> _loadPlots() async {
    setState(() {
      _plots = null;
      _loadError = null;
    });
    try {
      final source = context.read<FarmRemoteDataSource>();
      final farms = await source.getFarms();
      final details = await Future.wait(
        farms.map((farm) => source.getFarmDetails(farm.id)),
      );
      final plots = [
        for (var i = 0; i < farms.length; i++)
          for (final crop in details[i].crops)
            if (crop.isActive)
              for (final plot in crop.plots)
                _PlotOption(
                  id: plot.id,
                  label: '${farms[i].name} · ${crop.name} · ${plot.name}',
                ),
      ];
      if (!mounted) return;
      setState(() {
        _plots = plots;
        if (plots.length == 1) _plotId = plots.first.id;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = 'No se pudieron cargar tus lotes: $error');
    }
  }

  void _showImageSourceModal(BuildContext context) {
    final plotId = _plotId;
    if (plotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero elige el lote de la planta.')),
      );
      return;
    }
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
                    final XFile? image = await imagePickerService
                        .pickImageFromCamera();

                    if (image != null && context.mounted) {
                      context.read<DiagnosisBloc>().add(
                        AnalyzeImageSubmittedEvent(
                          imageFile: image,
                          userId: userId,
                          plotId: plotId,
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
                    final XFile? image = await imagePickerService
                        .pickImageFromGallery();

                    if (image != null && context.mounted) {
                      context.read<DiagnosisBloc>().add(
                        AnalyzeImageSubmittedEvent(
                          imageFile: image,
                          userId: userId,
                          plotId: plotId,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _buildPlotPicker(),
          ),
          Expanded(child: Center(child: _buildResult())),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImageSourceModal(context),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildPlotPicker() {
    if (_loadError != null) {
      return Row(
        children: [
          Expanded(
            child: Text(_loadError!, style: const TextStyle(color: Colors.red)),
          ),
          TextButton(onPressed: _loadPlots, child: const Text('Reintentar')),
        ],
      );
    }
    final plots = _plots;
    if (plots == null) return const LinearProgressIndicator();
    if (plots.isEmpty) {
      return const Text(
        'Necesitas al menos un lote en un cultivo activo para diagnosticar.',
      );
    }
    return AppDropdownField<String>(
      label: 'Lote de la planta',
      hint: 'Elige un lote',
      value: _plotId,
      items: [
        for (final plot in plots)
          DropdownMenuItem(
            value: plot.id,
            child: Text(plot.label, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (value) => setState(() => _plotId = value),
    );
  }

  Widget _buildResult() {
    return BlocBuilder<DiagnosisBloc, DiagnosisState>(
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
                  if (state.result.scientificName.isNotEmpty &&
                      state.result.scientificName != 'No especificado') ...[
                    const SizedBox(height: 4),
                    Text(
                      'Nombre científico: ${state.result.scientificName}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.teal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Confianza: ${(state.result.confidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Recomendaciones de Gemini:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.result.geminiRecommendations.isNotEmpty
                        ? state.result.geminiRecommendations
                        : 'No se generaron recomendaciones adicionales.',
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
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
    );
  }
}
