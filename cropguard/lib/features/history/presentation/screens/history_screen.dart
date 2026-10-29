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
          record.cropName.toLowerCase().contains(_query);
      return matchesCrop && matchesQuery;
    }).toList();
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
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final record = results[index];
                      return DiagnosisHistoryCard(
                        record: record,
                        onTap: () => context.push(
                          AppRoutes.diagnosisDetailPath(record.id),
                          extra: record,
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
