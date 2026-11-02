import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/features/farms/data/datasources/farm_remote_data_source.dart';
import 'package:kroppi/features/farms/domain/entities/farm_details.dart';
import 'package:kroppi/features/history/presentation/utils/date_formatter.dart';

class FarmPlotDetailScreen extends StatefulWidget {
  const FarmPlotDetailScreen({super.key, required this.plotId});

  final String plotId;

  @override
  State<FarmPlotDetailScreen> createState() => _FarmPlotDetailScreenState();
}

class _FarmPlotDetailScreenState extends State<FarmPlotDetailScreen> {
  FarmPlot? _plot;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final plot = await context
          .read<FarmRemoteDataSource>()
          .getFarmPlot(widget.plotId);
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

  @override
  Widget build(BuildContext context) {
    final plot = _plot;
    return Scaffold(
      appBar: AppBar(title: Text(plot?.name ?? 'Detalle del lote')),
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
