import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/core/widgets/app_search_bar.dart';
import 'package:kroppi/core/widgets/empty_state.dart';
import 'package:kroppi/core/widgets/filter_chip_button.dart';
import 'package:kroppi/features/history/domain/entities/diagnosis_record.dart';
import 'package:kroppi/features/history/presentation/cubit/history_cubit.dart';
import 'package:kroppi/features/history/presentation/widgets/diagnosis_history_card.dart';
import 'package:kroppi/navigation/app_routes.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedCrop = AppStrings.filterAll;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _cropFilters(List<DiagnosisRecord> records) {
    final crops = records.map((e) => e.cropName).toSet().toList();
    return [AppStrings.filterAll, ...crops];
  }

  List<DiagnosisRecord> _filtered(
    List<DiagnosisRecord> records,
    String selectedCrop,
  ) {
    return records.where((record) {
      final matchesCrop =
          selectedCrop == AppStrings.filterAll ||
          record.cropName == selectedCrop;
      final matchesQuery =
          _query.isEmpty ||
          record.pathogen.toLowerCase().contains(_query) ||
          record.cropName.toLowerCase().contains(_query) ||
          (record.farmName?.toLowerCase().contains(_query) ?? false) ||
          (record.farmCropName?.toLowerCase().contains(_query) ?? false) ||
          (record.plotName?.toLowerCase().contains(_query) ?? false);
      return matchesCrop && matchesQuery;
    }).toList();
  }

  List<_FarmHistoryGroup> _groupByFarmAndCrop(List<DiagnosisRecord> records) {
    final farms = <String, _FarmHistoryGroup>{};

    for (final record in records) {
      final farmKey = record.farmId ?? 'unassigned-farm';
      final farm = farms.putIfAbsent(
        farmKey,
        () => _FarmHistoryGroup(
          name: record.farmName?.trim().isNotEmpty == true
              ? record.farmName!
              : 'Finca sin identificar',
        ),
      );

      final cropKey = record.farmCropId ?? 'unassigned-crop';
      final crop = farm.crops.putIfAbsent(
        cropKey,
        () => _CropHistoryGroup(
          name: record.farmCropName?.trim().isNotEmpty == true
              ? record.farmCropName!
              : record.cropName,
          typeName: record.cropName,
        ),
      );

      final plotKey = record.plotId ?? 'unassigned-plot';
      final plot = crop.plots.putIfAbsent(
        plotKey,
        () => _PlotHistoryGroup(
          name: record.plotName?.trim().isNotEmpty == true
              ? record.plotName!
              : 'Lote sin identificar',
        ),
      );
      plot.records.add(record);
    }

    return farms.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: BlocBuilder<HistoryCubit, HistoryState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.historyTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildBody(context, state)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HistoryState state) {
    if (state.status == HistoryStatus.failure) {
      return _ErrorView(
        message: state.message ?? 'No se pudo cargar el historial.',
        onRetry: () => context.read<HistoryCubit>().load(),
      );
    }

    if (state.records.isEmpty && state.status != HistoryStatus.success) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<HistoryCubit>().load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            EmptyState(
              icon: Icons.history_rounded,
              title: AppStrings.emptyHistoryTitle,
              subtitle: AppStrings.emptyHistorySubtitle,
            ),
          ],
        ),
      );
    }

    final filters = _cropFilters(state.records);
    final selected = filters.contains(_selectedCrop)
        ? _selectedCrop
        : AppStrings.filterAll;
    final results = _filtered(state.records, selected);
    final farmGroups = _groupByFarmAndCrop(results);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSearchBar(
          controller: _searchController,
          hint: AppStrings.searchHint,
          onChanged: (value) => setState(() => _query = value.toLowerCase()),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final crop = filters[index];
              return FilterChipButton(
                label: crop,
                selected: selected == crop,
                onTap: () => setState(() => _selectedCrop = crop),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<HistoryCubit>().load(),
            child: results.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'Sin resultados',
                        subtitle: 'Prueba con otra búsqueda o filtro.',
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: farmGroups.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final farm = farmGroups[index];
                      return Card(
                        margin: EdgeInsets.zero,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          childrenPadding: const EdgeInsets.only(bottom: 8),
                          visualDensity: VisualDensity.compact,
                          leading: const Icon(
                            Icons.agriculture_outlined,
                            color: AppColors.primary,
                          ),
                          title: Text(
                            farm.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          subtitle: Text(
                            '${farm.diagnosisCount} diagnósticos · '
                            '${farm.crops.length} cultivos',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          children: [
                            for (final crop in farm.crops.values)
                              ExpansionTile(
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                childrenPadding: const EdgeInsets.only(
                                  bottom: 8,
                                ),
                                visualDensity: VisualDensity.compact,
                                leading: const Icon(
                                  Icons.eco_outlined,
                                  color: AppColors.primary,
                                ),
                                title: Text(
                                  crop.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${crop.typeName} · '
                                  '${crop.diagnosisCount} diagnósticos',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                children: [
                                  for (final plot in crop.plots.values)
                                    ExpansionTile(
                                      tilePadding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      childrenPadding: const EdgeInsets.only(
                                        bottom: 8,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      leading: const Icon(
                                        Icons.grid_view_rounded,
                                        color: AppColors.textSecondary,
                                      ),
                                      title: Text(
                                        plot.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        '${plot.records.length} diagnósticos',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      children: [
                                        for (final record in plot.records)
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              8,
                                            ),
                                            child: DiagnosisHistoryCard(
                                              record: record,
                                              onTap: () => context.push(
                                                AppRoutes.diagnosisDetailPath(
                                                  record.id,
                                                ),
                                                extra: record,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _FarmHistoryGroup {
  _FarmHistoryGroup({required this.name});

  final String name;
  final Map<String, _CropHistoryGroup> crops = {};

  int get diagnosisCount =>
      crops.values.fold(0, (total, crop) => total + crop.diagnosisCount);
}

class _CropHistoryGroup {
  _CropHistoryGroup({required this.name, required this.typeName});

  final String name;
  final String typeName;
  final Map<String, _PlotHistoryGroup> plots = {};

  int get diagnosisCount =>
      plots.values.fold(0, (total, plot) => total + plot.records.length);
}

class _PlotHistoryGroup {
  _PlotHistoryGroup({required this.name});

  final String name;
  final List<DiagnosisRecord> records = [];
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.error),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
