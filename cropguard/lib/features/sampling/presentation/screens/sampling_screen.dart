import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/features/crop_diagnosis/presentation/services/image_picker_service.dart';
import 'package:kroppi/features/my_crops/domain/entities/plot_sample.dart';
import 'package:kroppi/features/my_crops/presentation/widgets/plot_status_chip.dart';
import 'package:kroppi/features/sampling/presentation/cubit/sampling_cubit.dart';
import 'package:kroppi/features/my_crops/domain/entities/plot.dart';

Color _outcomeColor(ScanOutcome o) => switch (o) {
  ScanOutcome.healthy => AppColors.primary,
  ScanOutcome.diseased => AppColors.error,
  ScanOutcome.inconclusive => AppColors.warning,
};

IconData _outcomeIcon(ScanOutcome o) => switch (o) {
  ScanOutcome.healthy => Icons.check_circle_rounded,
  ScanOutcome.diseased => Icons.coronavirus_rounded,
  ScanOutcome.inconclusive => Icons.help_outline_rounded,
};

String _outcomeText(ScanItem s) =>
    s.outcome == ScanOutcome.inconclusive ? 'No concluyente' : s.label;

String _pct(double confidence) => '${(confidence * 100).toStringAsFixed(0)} %';

class SamplingScreen extends StatelessWidget {
  const SamplingScreen({super.key, required this.plotId});

  final String plotId;

  Future<void> _capture(BuildContext context, {required bool camera}) async {
    final picker = ImagePickerService();
    final XFile? file = camera
        ? await picker.pickImageFromCamera()
        : await picker.pickImageFromGallery();
    if (file != null && context.mounted) {
      context.read<SamplingCubit>().scan(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SamplingCubit, SamplingState>(
      listenWhen: (_, s) => s.status == SamplingStatus.failure,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(state.message ?? 'Ocurrió un error.')),
          );
      },
      builder: (context, state) {
        if (state.status == SamplingStatus.done && state.result != null) {
          return _Summary(result: state.result!, scans: state.scans);
        }

        final cubit = context.read<SamplingCubit>();
        final evaluated = state.evaluated; // solo fotos concluyentes
        final target = cubit.target;
        final maxPlants = cubit.maxPlants;
        final hasRoom = maxPlants == null || evaluated < maxPlants;
        final reachedTarget = evaluated >= target;
        final scanning = state.status == SamplingStatus.scanning;
        final closing = state.status == SamplingStatus.closing;

        final title = !reachedTarget
            ? 'Planta ${evaluated + 1} de $target'
            : (hasRoom
                  ? '$evaluated plantas escaneadas'
                  : 'Muestreo completo ($evaluated de $target)');

        return Scaffold(
          appBar: AppBar(title: const Text('Muestreo del lote')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 10,
                      value: (evaluated / target).clamp(0, 1).toDouble(),
                      backgroundColor: AppColors.primaryLight,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Toma una foto clara de una hoja de cada planta, '
                    'recorriendo el lote en zigzag.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  if (state.inconclusive > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.warning,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${state.inconclusive} foto(s) no fueron concluyentes y '
                              'no cuentan en el resultado. Mejora la luz y el enfoque.',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Resultado de cada foto, en vivo (la más reciente arriba)
                  Expanded(
                    child: state.scans.isEmpty
                        ? const SizedBox.shrink()
                        : ListView.separated(
                            itemCount: state.scans.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final index = state.scans.length - 1 - i;
                              return _ScanTile(
                                number: index + 1,
                                item: state.scans[index],
                                onRemove: state.isBusy
                                    ? null
                                    : () => cubit.remove(index),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  if (scanning || closing)
                    Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        Text(
                          scanning
                              ? 'Analizando imagen…'
                              : 'Calculando resultado…',
                        ),
                      ],
                    )
                  else if (hasRoom) ...[
                    GestureDetector(
                      onTap: () => _capture(context, camera: true),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.photo_camera_rounded,
                          size: 44,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => _capture(context, camera: false),
                      child: const Text('Elegir de la galería'),
                    ),
                  ] else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Ya escaneaste todas las plantas del lote. '
                        'Toca «Terminar muestreo».',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (state.isBusy || evaluated == 0)
                          ? null
                          : cubit.finish,
                      child: Text(
                        evaluated == 0
                            ? 'Escanea al menos una planta'
                            : 'Terminar muestreo ($evaluated)',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScanTile extends StatelessWidget {
  const _ScanTile({
    required this.number,
    required this.item,
    required this.onRemove,
  });

  final int number;
  final ScanItem item;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final color = _outcomeColor(item.outcome);
    final inconclusive = item.outcome == ScanOutcome.inconclusive;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(_outcomeIcon(item.outcome), color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Foto $number · ${_outcomeText(item)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  inconclusive
                      ? 'Confianza ${_pct(item.confidence)} · no cuenta'
                      : 'Confianza ${_pct(item.confidence)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Quitar foto',
            visualDensity: VisualDensity.compact,
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.result, required this.scans});

  final SampleResult result;
  final List<ScanItem> scans;

  @override
  Widget build(BuildContext context) {
    final color = result.status.color;
    final message = switch (result.status) {
      PlotStatus.healthy => 'La incidencia está bajo el nivel de alerta.',
      PlotStatus.alert =>
        'Hay presencia de enfermedad. Vigila el lote y consulta a un técnico.',
      PlotStatus.danger =>
        'Incidencia alta. Consulta a un agrónomo cuanto antes.',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado del muestreo'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                  border: Border.all(color: color, width: 4),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${result.incidencePct.toStringAsFixed(1)} %',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PlotStatusChip(status: result.status),
              const SizedBox(height: 16),
              Text(
                '${result.affected} de ${result.evaluated} plantas afectadas',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (result.discarded > 0) ...[
                const SizedBox(height: 6),
                Text(
                  '${result.discarded} foto(s) descartadas por no ser concluyentes',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              if (result.evaluated < 10) ...[
                const SizedBox(height: 10),
                Text(
                  'Muestra pequeña (${result.evaluated} '
                  '${result.evaluated == 1 ? 'planta' : 'plantas'}): '
                  'con pocas plantas el porcentaje es muy sensible. '
                  'Mientras más plantas evalúes, más confiable es el resultado.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (scans.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < scans.length; i++)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _outcomeColor(
                            scans[i].outcome,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _outcomeColor(
                              scans[i].outcome,
                            ).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          '${i + 1}. ${_outcomeText(scans[i])} '
                          '${_pct(scans[i].confidence)}',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                  ],
                ),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Volver al lote'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
