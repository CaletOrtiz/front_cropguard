import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/features/history/presentation/utils/date_formatter.dart';
import 'package:kroppi/features/my_crops/domain/entities/plot.dart';
import 'package:kroppi/features/my_crops/domain/entities/plot_sample.dart';
import 'package:kroppi/features/my_crops/presentation/cubit/plot_detail_cubit.dart';
import 'package:kroppi/features/my_crops/presentation/widgets/incidence_chart.dart';
import 'package:kroppi/features/my_crops/presentation/widgets/plot_status_chip.dart';
import 'package:kroppi/features/sampling/presentation/cubit/sampling_cubit.dart';
import 'package:kroppi/navigation/app_routes.dart';

class PlotDetailScreen extends StatelessWidget {
  const PlotDetailScreen({super.key, required this.plotId});

  final String plotId;

  Future<void> _startSampling(BuildContext context, PlotDetail d) async {
    await context.push(
      AppRoutes.samplingPath(plotId),
      extra: SamplingArgs(cropSlug: d.cropSlug, plantCount: d.plot.plantCount),
    );
    if (context.mounted) context.read<PlotDetailCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlotDetailCubit, PlotDetailState>(
      builder: (context, state) {
        final d = state.detail;
        return Scaffold(
          appBar: AppBar(title: Text(d?.plot.name ?? 'Lote')),
          body: SafeArea(
            child: d == null
                ? (state.status == PlotDetailStatus.failure
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.message ?? 'No se pudo cargar.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: () =>
                                      context.read<PlotDetailCubit>().load(),
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()))
                : RefreshIndicator(
                    onRefresh: () => context.read<PlotDetailCubit>().load(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      children: [
                        _Header(
                          detail: d,
                          lastSample: state.samples.isEmpty
                              ? null
                              : state.samples.last,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () => _startSampling(context, d),
                            icon: const Icon(Icons.photo_camera_rounded),
                            label: const Text('Nuevo muestreo'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ModuleLink(
                              icon: Icons.medication_outlined,
                              label: 'Cuidados',
                              onTap: () => context.push(AppRoutes.careListPath(plotId)),
                            ),
                            _ModuleLink(
                              icon: Icons.insights_outlined,
                              label: 'Estadísticas',
                              onTap: () => context.push(AppRoutes.plotStatsPath(plotId)),
                            ),
                            _ModuleLink(
                              icon: Icons.history,
                              label: 'Historial',
                              onTap: () => context.push(AppRoutes.plotTimelinePath(plotId)),
                            ),
                            _ModuleLink(
                              icon: Icons.picture_as_pdf_outlined,
                              label: 'Informes',
                              onTap: () => context.push(AppRoutes.reportsPath(plotId)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Evolución de la incidencia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Alerta desde ${d.alertPct.toStringAsFixed(0)} % · '
                          'peligro desde ${d.dangerPct.toStringAsFixed(0)} %',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (state.samples.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Aún no hay muestreos. Haz el primero para saber qué tan sano está este lote.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        else
                          IncidenceChart(
                            samples: state.samples,
                            alertPct: d.alertPct,
                            dangerPct: d.dangerPct,
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

class _ModuleLink extends StatelessWidget {
  const _ModuleLink({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 18),
    label: Text(label),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.detail, this.lastSample});

  final PlotDetail detail;
  final PlotSample? lastSample;

  @override
  Widget build(BuildContext context) {
    final p = detail.plot;
    final last = detail.lastIncidencePct;
    final sample = lastSample;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.status.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.status.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  detail.cropName,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
              PlotStatusChip(status: p.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            last == null
                ? 'Sin datos de incidencia'
                : '${last.toStringAsFixed(1)} %',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: p.status.color,
            ),
          ),
          Text(
            last == null
                ? 'Haz un muestreo para calcularla'
                : (sample == null
                      ? 'de plantas afectadas en el último muestreo'
                      : '${sample.affected} de ${sample.evaluated} plantas '
                            'afectadas en el último muestreo'),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const Divider(height: 28),
          Wrap(
            spacing: 18,
            runSpacing: 6,
            children: [
              _Info(Icons.straighten_rounded, '${p.areaHa} ha'),
              if (p.plantCount != null)
                _Info(Icons.grass_rounded, '${p.plantCount} plantas'),
              if (p.variety != null)
                _Info(Icons.local_florist_rounded, p.variety!),
              if (p.lastSampledAt != null)
                _Info(
                  Icons.event_rounded,
                  DateFormatter.short(p.lastSampledAt!),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}
