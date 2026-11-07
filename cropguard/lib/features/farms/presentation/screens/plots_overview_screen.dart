import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/features/farms/data/datasources/farm_remote_data_source.dart';
import 'package:kroppi/features/farms/domain/entities/farm.dart';
import 'package:kroppi/features/farms/domain/entities/farm_details.dart';
import 'package:kroppi/navigation/app_routes.dart';

enum PlotsOverviewFilter { all, alert, danger }

class PlotsOverviewScreen extends StatefulWidget {
  const PlotsOverviewScreen({super.key, this.filter = PlotsOverviewFilter.all});

  final PlotsOverviewFilter filter;

  @override
  State<PlotsOverviewScreen> createState() => _PlotsOverviewScreenState();
}

class _PlotsOverviewScreenState extends State<PlotsOverviewScreen> {
  static const _pageSize = 10;
  List<_PlotEntry> _entries = const [];
  bool _loading = true;
  String? _error;
  int _page = 0;

  String get _title => switch (widget.filter) {
    PlotsOverviewFilter.all => 'Todos los lotes',
    PlotsOverviewFilter.alert => 'Lotes en alerta',
    PlotsOverviewFilter.danger => 'Lotes en peligro',
  };

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
      final source = context.read<FarmRemoteDataSource>();
      final farms = await source.getFarms();
      final details = await Future.wait(
        farms.map((farm) => source.getFarmDetails(farm.id)),
      );
      final entries = [
        for (var index = 0; index < farms.length; index++)
          for (final crop in details[index].crops)
            if (crop.isActive)
              for (final plot in crop.plots)
                _PlotEntry(farm: farms[index], crop: crop, plot: plot),
      ];
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _page = 0;
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
    final visible = _entries.where((entry) {
      return switch (widget.filter) {
        PlotsOverviewFilter.all => true,
        PlotsOverviewFilter.alert => entry.plot.health == FarmPlotHealth.alert,
        PlotsOverviewFilter.danger =>
          entry.plot.health == FarmPlotHealth.danger,
      };
    }).toList();
    final pageCount = (visible.length / _pageSize).ceil();
    final safePage = pageCount == 0 ? 0 : _page.clamp(0, pageCount - 1);
    final start = safePage * _pageSize;
    final pageItems = visible.skip(start).take(_pageSize).toList();

    return Scaffold(
      appBar: AppBar(title: Text(_title)),
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
          : visible.isEmpty
          ? Center(
              child: Text(switch (widget.filter) {
                PlotsOverviewFilter.all => 'Aún no tienes lotes registrados.',
                PlotsOverviewFilter.alert =>
                  'No hay lotes en estado de alerta.',
                PlotsOverviewFilter.danger =>
                  'No hay lotes en estado de peligro.',
              }, textAlign: TextAlign.center),
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      itemCount: pageItems.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final entry = pageItems[index];
                        return _PlotCard(
                          entry: entry,
                          onTap: () => context.push(
                            AppRoutes.farmPlotDetailPath(
                              entry.farm.id,
                              entry.crop.id,
                              entry.plot.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        style: _pagerStyle,
                        onPressed: safePage == 0
                            ? null
                            : () => setState(() => _page = safePage - 1),
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Anterior'),
                      ),
                      Text('Página ${safePage + 1} de $pageCount'),
                      OutlinedButton.icon(
                        style: _pagerStyle,
                        onPressed: safePage + 1 >= pageCount
                            ? null
                            : () => setState(() => _page = safePage + 1),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Siguiente'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// El tema usa ancho infinito para OutlinedButton; dentro de un Row hay que acotarlo.
final _pagerStyle = OutlinedButton.styleFrom(minimumSize: const Size(0, 40));

class _PlotEntry {
  const _PlotEntry({
    required this.farm,
    required this.crop,
    required this.plot,
  });

  final Farm farm;
  final FarmCrop crop;
  final FarmPlot plot;
}

class _PlotCard extends StatelessWidget {
  const _PlotCard({required this.entry, required this.onTap});

  final _PlotEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final health = entry.plot.health;
    final color = switch (health) {
      FarmPlotHealth.healthy => AppColors.primary,
      FarmPlotHealth.alert => AppColors.warning,
      FarmPlotHealth.danger => AppColors.error,
    };
    final label = switch (health) {
      FarmPlotHealth.healthy => 'Sano',
      FarmPlotHealth.alert => 'Alerta',
      FarmPlotHealth.danger => 'Peligro',
    };

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Icon(Icons.grid_view_rounded, color: color),
        title: Text(entry.plot.name),
        subtitle: Text(
          '${entry.farm.name} · ${entry.crop.name}\n'
          '${entry.plot.areaHa} ha'
          '${entry.plot.plantCount == null ? '' : ' · ${entry.plot.plantCount} plantas'}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: color)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
