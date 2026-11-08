import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/features/farms/data/datasources/farm_remote_data_source.dart';
import 'package:kroppi/features/farms/domain/entities/farm.dart';
import 'package:kroppi/features/farms/domain/entities/farm_details.dart';
import 'package:kroppi/features/history/presentation/utils/date_formatter.dart';
import 'package:kroppi/features/sampling/presentation/cubit/sampling_cubit.dart';
import 'package:kroppi/navigation/app_routes.dart';

class FarmDetailScreen extends StatefulWidget {
  const FarmDetailScreen({super.key, required this.farmId});

  final String farmId;

  @override
  State<FarmDetailScreen> createState() => _FarmDetailScreenState();
}

class _FarmDetailScreenState extends State<FarmDetailScreen> {
  FarmDetails? _details;
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
      final details = await context.read<FarmRemoteDataSource>().getFarmDetails(
        widget.farmId,
      );
      if (!mounted) return;
      setState(() {
        _details = details;
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

  Future<void> _openForm(String path, {Object? extra}) async {
    await context.push(path, extra: extra);
    if (mounted) await _load();
  }

  Future<void> _addPlot(FarmDetails details) async {
    if (details.crops.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Primero agrega un cultivo a la finca.'),
          ),
        );
      return;
    }

    final crop = await showModalBottomSheet<FarmCrop>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                'Selecciona el cultivo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            for (final crop in details.crops)
              ListTile(
                leading: const Icon(Icons.grass_rounded),
                title: Text(crop.name),
                subtitle: Text(crop.typeName),
                onTap: () => Navigator.pop(context, crop),
              ),
          ],
        ),
      ),
    );
    if (crop == null || !mounted) return;
    await _openForm(AppRoutes.farmPlotNewPath(widget.farmId, crop.id));
  }

  @override
  Widget build(BuildContext context) {
    final details = _details;
    return Scaffold(
      appBar: AppBar(title: Text(details?.farm.name ?? 'Detalle de finca')),
      body: _loading && details == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null && details == null
          ? _LoadError(message: _error!, onRetry: _load)
          : details == null
          ? _LoadError(message: 'No se encontró la finca.', onRetry: _load)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  if (_error != null) _RefreshError(message: _error!),
                  _FarmHeader(farm: details.farm),
                  const SizedBox(height: 18),
                  _FarmSummary(details: details),
                  const SizedBox(height: 28),
                  const Text(
                    'Cultivos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Wrap(
                    spacing: 4,
                    children: [
                      TextButton.icon(
                        onPressed: () => _addPlot(details),
                        icon: const Icon(Icons.grid_view_rounded, size: 18),
                        label: const Text('Agregar lote'),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            _openForm(AppRoutes.farmCropNewPath(widget.farmId)),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Agregar cultivo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (details.crops.isEmpty)
                    _NoCrops(
                      onAdd: () =>
                          _openForm(AppRoutes.farmCropNewPath(widget.farmId)),
                    )
                  else
                    for (final crop in details.crops) ...[
                      _CropCard(
                        key: ValueKey(crop.id),
                        crop: crop,
                        initiallyExpanded: details.crops.length == 1,
                        onEdit: () => _openForm(
                          AppRoutes.farmCropEditPath(widget.farmId, crop.id),
                        ),
                        onOpenCrop: () => context.push(
                          AppRoutes.farmCropDetailPath(widget.farmId, crop.id),
                        ),
                        onAddPlot: () => _openForm(
                          AppRoutes.farmPlotNewPath(widget.farmId, crop.id),
                        ),
                        onOpenPlot: (plot) => context.push(
                          AppRoutes.farmPlotDetailPath(
                            widget.farmId,
                            crop.id,
                            plot.id,
                          ),
                        ),
                        onEditPlot: (plot) => _openForm(
                          AppRoutes.farmPlotEditPath(
                            widget.farmId,
                            crop.id,
                            plot.id,
                          ),
                          extra: plot,
                        ),
                        onStartSampling: (plot) => context.push(
                          AppRoutes.samplingPath(plot.id),
                          extra: SamplingArgs(
                            cropSlug: crop.typeSlug ?? 'cafe',
                            plantCount: plot.plantCount,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
    );
  }
}

class _FarmHeader extends StatelessWidget {
  const _FarmHeader({required this.farm});

  final Farm farm;

  @override
  Widget build(BuildContext context) {
    final location = [
      farm.municipality,
      farm.department,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(', ');
    final description = farm.description;
    final area = farm.areaHa;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Icon(
                  Icons.agriculture_rounded,
                  size: 32,
                  color: AppColors.mint,
                ),
              ),
              if (area != null) _HeaderArea(areaHa: area),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            farm.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.mint,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .85),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (description != null && description.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(color: Colors.white.withValues(alpha: .85)),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderArea extends StatelessWidget {
  const _HeaderArea({required this.areaHa});

  final double areaHa;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      '${_formatArea(areaHa)} ha',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    ),
  );
}

class _FarmSummary extends StatelessWidget {
  const _FarmSummary({required this.details});

  final FarmDetails details;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _SummaryMetric(
        icon: Icons.grass_rounded,
        value: '${details.crops.length}',
        label: 'Cultivos',
      ),
      _SummaryMetric(
        icon: Icons.grid_view_rounded,
        value: '${details.totalPlots}',
        label: 'Lotes',
      ),
      _SummaryMetric(
        icon: Icons.landscape_outlined,
        value: '${_formatArea(details.totalPlotAreaHa)} ha',
        label: 'Área en lotes',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 360 ? 2 : 3;
        final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
        return Wrap(
          spacing: 8,
          runSpacing: 12,
          children: [
            for (final metric in metrics) SizedBox(width: width, child: metric),
          ],
        );
      },
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, size: 20, color: AppColors.primary),
      const SizedBox(height: 5),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
    ],
  );
}

class _CropCard extends StatefulWidget {
  const _CropCard({
    required this.crop,
    required this.initiallyExpanded,
    required this.onEdit,
    required this.onOpenCrop,
    required this.onAddPlot,
    required this.onOpenPlot,
    required this.onEditPlot,
    required this.onStartSampling,
    super.key,
  });

  final FarmCrop crop;
  final bool initiallyExpanded;
  final VoidCallback onEdit;
  final VoidCallback onOpenCrop;
  final VoidCallback onAddPlot;
  final ValueChanged<FarmPlot> onOpenPlot;
  final ValueChanged<FarmPlot> onEditPlot;
  final ValueChanged<FarmPlot> onStartSampling;

  @override
  State<_CropCard> createState() => _CropCardState();
}

class _CropCardState extends State<_CropCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final crop = widget.crop;
    // Material (en vez de Container con color) para que los ListTile e InkWell
    // internos pinten sus efectos sobre la tarjeta.
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: widget.onOpenCrop,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            crop.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            crop.typeName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          if (crop.plantedAt != null) ...[
                            const SizedBox(height: 5),
                            Text(
                              'Siembra: ${DateFormatter.short(crop.plantedAt!.toLocal())}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 5),
                          Text(
                            '${crop.plots.length} ${crop.plots.length == 1 ? 'lote' : 'lotes'}'
                            ' · ${_formatArea(crop.totalPlotAreaHa)} ha',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _StatusPill(
                      label: crop.isActive ? 'Activo' : 'Inactivo',
                      color: crop.isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
                IconButton(
                  tooltip: 'Editar cultivo',
                  onPressed: widget.onEdit,
                  color: AppColors.primaryDark,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: _expanded ? 'Contraer lotes' : 'Expandir lotes',
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ),
              ],
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            if (crop.plots.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Este cultivo aún no tiene lotes.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              for (var index = 0; index < crop.plots.length; index++) ...[
                _PlotRow(
                  plot: crop.plots[index],
                  onTap: () => widget.onOpenPlot(crop.plots[index]),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: 4,
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      TextButton.icon(
                        onPressed: () => widget.onEditPlot(crop.plots[index]),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Editar lote'),
                      ),
                      OutlinedButton.icon(
                        // El tema usa ancho infinito; dentro de un Row hay que acotarlo.
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 40),
                        ),
                        onPressed: () =>
                            widget.onStartSampling(crop.plots[index]),
                        icon: const Icon(Icons.play_arrow_rounded, size: 17),
                        label: const Text('Iniciar muestreo'),
                      ),
                    ],
                  ),
                ),
                if (index < crop.plots.length - 1)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: widget.onAddPlot,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Agregar lote'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlotRow extends StatelessWidget {
  const _PlotRow({required this.plot, required this.onTap});

  final FarmPlot plot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final health = _healthStyle(plot.health);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        plot.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        [
          '${_formatArea(plot.areaHa)} ha',
          if (plot.lastSampledAt != null)
            'Último muestreo: ${DateFormatter.short(plot.lastSampledAt!.toLocal())}',
        ].join(' · '),
        maxLines: 2,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 9, color: health.color),
          const SizedBox(width: 6),
          Text(
            health.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: health.color),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}

class _NoCrops extends StatelessWidget {
  const _NoCrops({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: AppColors.primaryLight.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        const Icon(Icons.grass_rounded, size: 38, color: AppColors.primaryDark),
        const SizedBox(height: 12),
        const Text(
          'Aún no tienes cultivos en esta finca',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Registra el primer cultivo para organizar sus lotes y seguimiento.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Agregar cultivo'),
        ),
      ],
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    ),
  );
}

class _RefreshError extends StatelessWidget {
  const _RefreshError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.error.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      'No se pudieron actualizar los datos: $message',
      style: const TextStyle(color: AppColors.error),
    ),
  );
}

({String label, Color color}) _healthStyle(FarmPlotHealth health) =>
    switch (health) {
      FarmPlotHealth.healthy => (label: 'Sano', color: AppColors.primary),
      FarmPlotHealth.alert => (label: 'Alerta', color: AppColors.warning),
      FarmPlotHealth.danger => (label: 'Peligro', color: AppColors.error),
    };

String _formatArea(double area) =>
    area.toStringAsFixed(area.truncateToDouble() == area ? 0 : 1);
