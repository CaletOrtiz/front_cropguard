import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/refresh/plot_data_refresh.dart';
import 'package:kroppi/features/farms/data/datasources/farm_remote_data_source.dart';
import 'package:kroppi/features/farms/domain/entities/farm_details.dart';
import 'package:kroppi/features/history/presentation/utils/date_formatter.dart';
import 'package:kroppi/navigation/app_routes.dart';

class FarmPlotDetailScreen extends StatefulWidget {
  const FarmPlotDetailScreen({
    super.key,
    required this.farmId,
    required this.cropId,
    required this.plotId,
  });

  final String farmId;
  final String cropId;
  final String plotId;

  @override
  State<FarmPlotDetailScreen> createState() => _FarmPlotDetailScreenState();
}

class _FarmPlotDetailScreenState extends State<FarmPlotDetailScreen> {
  FarmPlot? _plot;
  String? _error;
  bool _loading = true;

  final _refresh = PlotDataRefreshNotifier.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    _refresh.addListener(_onPlotChanged);
  }

  @override
  void dispose() {
    _refresh.removeListener(_onPlotChanged);
    super.dispose();
  }

  void _onPlotChanged() {
    if (_refresh.lastPlotId == widget.plotId && mounted) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plot = await context.read<FarmRemoteDataSource>().getFarmPlot(
        widget.plotId,
      );
      if (!mounted) return;
      setState(() {
        _plot = plot;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _edit() async {
    final changed = await context.push<bool>(
      AppRoutes.farmPlotEditPath(widget.farmId, widget.cropId, widget.plotId),
      extra: _plot,
    );
    if (changed == true && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final plot = _plot;
    return Scaffold(
      appBar: AppBar(
        title: Text(plot?.name ?? 'Detalle del lote'),
        actions: [
          if (plot != null)
            IconButton(
              tooltip: 'Editar lote',
              onPressed: _edit,
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: _loading && plot == null
          ? const Center(child: CircularProgressIndicator())
          : plot == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error ?? 'No se encontró el lote.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _load,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          size: 30,
                          color: _statusColor(plot.health),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          plot.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusLabel(plot.health),
                          style: TextStyle(
                            color: _statusColor(plot.health),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _PlotFact(
                    icon: Icons.landscape_outlined,
                    label: 'Área',
                    value: '${_formatArea(plot.areaHa)} ha',
                  ),
                  if (plot.variety?.trim().isNotEmpty ?? false)
                    _PlotFact(
                      icon: Icons.eco_outlined,
                      label: 'Variedad',
                      value: plot.variety!,
                    ),
                  if (plot.plantCount != null)
                    _PlotFact(
                      icon: Icons.nature_outlined,
                      label: 'Cantidad de plantas',
                      value: '${plot.plantCount}',
                    ),
                  if (plot.lastSampledAt != null)
                    _PlotFact(
                      icon: Icons.event_available_outlined,
                      label: 'Último muestreo',
                      value: DateFormatter.short(plot.lastSampledAt!.toLocal()),
                    ),
                  const SizedBox(height: 10),
                  const Text(
                    'Módulos del lote',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _ModuleButton(
                        label: 'Cuidados',
                        icon: Icons.medication_outlined,
                        onTap: () =>
                            context.push(AppRoutes.careListPath(widget.plotId)),
                      ),
                      _ModuleButton(
                        label: 'Cosechas',
                        icon: Icons.agriculture,
                        onTap: () =>
                            context.push(AppRoutes.harvestsPath(widget.plotId)),
                      ),
                      _ModuleButton(
                        label: 'Pérdida estimada',
                        icon: Icons.trending_down,
                        onTap: () =>
                            context.push(AppRoutes.lossPath(widget.plotId)),
                      ),
                      _ModuleButton(
                        label: 'Estadísticas',
                        icon: Icons.insights_outlined,
                        onTap: () => context.push(
                          AppRoutes.plotStatsPath(widget.plotId),
                        ),
                      ),
                      _ModuleButton(
                        label: 'Historial',
                        icon: Icons.history,
                        onTap: () => context.push(
                          AppRoutes.plotTimelinePath(widget.plotId),
                        ),
                      ),
                      _ModuleButton(
                        label: 'Informes',
                        icon: Icons.picture_as_pdf_outlined,
                        onTap: () =>
                            context.push(AppRoutes.reportsPath(widget.plotId)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _PlotFact extends StatelessWidget {
  const _PlotFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ModuleButton extends StatelessWidget {
  const _ModuleButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon, size: 18),
    label: Text(label),
  );
}

Color _statusColor(FarmPlotHealth health) => switch (health) {
  FarmPlotHealth.healthy => AppColors.mint,
  FarmPlotHealth.alert => AppColors.warning,
  FarmPlotHealth.danger => AppColors.error,
};

String _statusLabel(FarmPlotHealth health) => switch (health) {
  FarmPlotHealth.healthy => 'Estado: Sano',
  FarmPlotHealth.alert => 'Estado: Alerta',
  FarmPlotHealth.danger => 'Estado: Peligro',
};

String _formatArea(double area) =>
    area.toStringAsFixed(area.truncateToDouble() == area ? 0 : 1);
