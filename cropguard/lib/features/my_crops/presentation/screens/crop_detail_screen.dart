import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/widgets/empty_state.dart';
import 'package:kroppi/features/history/presentation/utils/date_formatter.dart';
import 'package:kroppi/features/my_crops/data/datasources/my_crops_remote_data_source.dart';
import 'package:kroppi/features/my_crops/domain/entities/my_crop.dart';
import 'package:kroppi/features/my_crops/domain/entities/plot.dart';
import 'package:kroppi/features/my_crops/presentation/widgets/plot_status_chip.dart';
import 'package:kroppi/navigation/app_routes.dart';

class CropDetailScreen extends StatefulWidget {
  const CropDetailScreen({super.key, required this.cropId});

  final String cropId;

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  MyCrop? _crop;
  List<Plot> _plots = [];
  bool _loading = true;
  String? _error;

  MyCropsRemoteDataSource get _source =>
      context.read<MyCropsRemoteDataSource>();

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
      final crops = await _source.getCrops();
      final plots = await _source.getPlots(widget.cropId);
      if (!mounted) return;
      setState(() {
        _crop = crops.where((c) => c.id == widget.cropId).firstOrNull;
        _plots = plots;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _open(String path) async {
    await context.push(path);
    if (mounted) _load();
  }

  Future<void> _archive() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Archivar cultivo?'),
        content: const Text(
          'Dejará de aparecer en tu lista. El historial se conserva.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Archivar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await _source.archiveCrop(widget.cropId);
      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo archivar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_crop?.name ?? 'Cultivo'),
        actions: [
          if (_crop != null)
            IconButton(
              tooltip: 'Archivar',
              onPressed: _archive,
              icon: const Icon(Icons.archive_outlined),
            ),
        ],
      ),
      floatingActionButton: _crop == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () => _open(AppRoutes.plotNewPath(widget.cropId)),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar lote'),
            ),
      body: SafeArea(
        child: _loading
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
            : _plots.isEmpty
            ? const EmptyState(
                icon: Icons.landscape_rounded,
                title: 'Sin lotes',
                subtitle:
                    'Divide tu cultivo en lotes para llevar el control de cada zona.',
              )
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                  itemCount: _plots.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final p = _plots[i];
                    return _PlotTile(
                      plot: p,
                      onTap: () => _open(AppRoutes.plotDetailPath(p.id)),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _PlotTile extends StatelessWidget {
  const _PlotTile({required this.plot, required this.onTap});

  final Plot plot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 5, color: plot.status.color),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plot.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${plot.areaHa} ha'
                                  '${plot.plantCount != null ? ' · ${plot.plantCount} plantas' : ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  plot.lastSampledAt == null
                                      ? 'Sin muestreos'
                                      : 'Último muestreo: ${DateFormatter.short(plot.lastSampledAt!)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PlotStatusChip(status: plot.status),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
