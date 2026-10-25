import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/features/history/domain/entities/diagnosis_record.dart';
import 'package:kroppi/core/widgets/app_search_bar.dart';
import 'package:kroppi/core/widgets/empty_state.dart';
import 'package:kroppi/core/widgets/filter_chip_button.dart';
import 'package:kroppi/features/history/presentation/widgets/diagnosis_history_card.dart';
import 'package:go_router/go_router.dart';
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

  List<String> get _cropFilters {
    final crops = SampleDiagnoses.all.map((e) => e.cropName).toSet().toList();
    return [AppStrings.filterAll, ...crops];
  }

  List<DiagnosisRecord> get _filtered {
    return SampleDiagnoses.all.where((record) {
      final matchesCrop =
          _selectedCrop == AppStrings.filterAll ||
          record.cropName == _selectedCrop;
      final matchesQuery =
          _query.isEmpty ||
          record.pathogen.toLowerCase().contains(_query) ||
          record.cropName.toLowerCase().contains(_query);
      return matchesCrop && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
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
              AppSearchBar(
                controller: _searchController,
                hint: AppStrings.searchHint,
                onChanged: (value) =>
                    setState(() => _query = value.toLowerCase()),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cropFilters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final crop = _cropFilters[index];
                    return FilterChipButton(
                      label: crop,
                      selected: _selectedCrop == crop,
                      onTap: () => setState(() => _selectedCrop = crop),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: results.isEmpty
                    ? const SingleChildScrollView(
                        child: EmptyState(
                          icon: Icons.history_rounded,
                          title: AppStrings.emptyHistoryTitle,
                          subtitle: AppStrings.emptyHistorySubtitle,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final record = results[index];
                          return DiagnosisHistoryCard(
                            record: record,
                            onTap: () => context.push(
                              AppRoutes.diagnosisDetailPath(record.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
