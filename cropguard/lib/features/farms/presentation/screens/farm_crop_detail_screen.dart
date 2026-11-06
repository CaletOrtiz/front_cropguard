import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/features/farms/data/datasources/farm_remote_data_source.dart';
import 'package:kroppi/features/farms/domain/entities/farm_details.dart';
import 'package:kroppi/features/history/presentation/utils/date_formatter.dart';
import 'package:kroppi/features/sampling/presentation/cubit/sampling_cubit.dart';
import 'package:kroppi/navigation/app_routes.dart';

class FarmCropDetailScreen extends StatefulWidget {
  const FarmCropDetailScreen({
    super.key,
    required this.farmId,
    required this.cropId,
  });

  final String farmId;
  final String cropId;

  @override
  State<FarmCropDetailScreen> createState() => _FarmCropDetailScreenState();
}

class _FarmCropDetailScreenState extends State<FarmCropDetailScreen> {
  FarmCrop? _crop;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final crop = await context.read<FarmRemoteDataSource>().getFarmCrop(
        widget.cropId,
      );
      if (crop.farmId != widget.farmId) {
        throw StateError('El cultivo no pertenece a esta finca.');
      }
      if (!mounted) return;
      setState(() {
        _crop = crop;
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

  @override
  Widget build(BuildContext context) {
    final crop = _crop;
    return Scaffold(
      appBar: AppBar(
        title: Text(crop?.name ?? 'Cultivo'),
        actions: [
          if (crop != null)
            IconButton(
              tooltip: 'Editar cultivo',
              onPressed: () =>
                  _openForm(AppRoutes.farmCropEditPath(widget.farmId, crop.id)),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      floatingActionButton: crop == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () =>
                  _openForm(AppRoutes.farmPlotNewPath(widget.farmId, crop.id)),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar lote'),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: _load,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : crop == null
          ? const Center(child: Text('No se encontró el cultivo.'))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.typeName,
                          style: const TextStyle(color: AppColors.mint),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          crop.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${crop.plots.length} lotes · '
                          '${crop.totalPlotAreaHa.toStringAsFixed(2)} ha',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (crop.plantedAt != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Siembra: ${DateFormatter.short(crop.plantedAt!.toLocal())}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Lotes del cultivo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (crop.plots.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('Este cultivo aún no tiene lotes.'),
                    )
                  else
                    for (final plot in crop.plots)
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(plot.name),
                              subtitle: Text(
                                '${plot.areaHa} ha'
                                '${plot.plantCount == null ? '' : ' · ${plot.plantCount} plantas'}'
                                '${plot.lastSampledAt == null ? '' : ' · Muestreo: ${DateFormatter.short(plot.lastSampledAt!.toLocal())}'}',
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => context.push(
                                AppRoutes.farmPlotDetailPath(
                                  widget.farmId,
                                  crop.id,
                                  plot.id,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => context.push(
                                  AppRoutes.samplingPath(plot.id),
                                  extra: SamplingArgs(
                                    cropSlug: crop.typeSlug ?? 'cafe',
                                    plantCount: plot.plantCount,
                                  ),
                                ),
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Iniciar muestreo'),
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              ),
            ),
    );
  }
}
