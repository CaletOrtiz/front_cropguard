import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/core/widgets/empty_state.dart';
import 'package:kroppi/features/farms/presentation/cubit/farms_cubit.dart';
import 'package:kroppi/features/farms/presentation/widgets/farm_card.dart';
import 'package:kroppi/navigation/app_routes.dart';

class FarmsScreen extends StatelessWidget {
  const FarmsScreen({super.key});

  Future<void> _openCreateForm(BuildContext context) async {
    await context.push(AppRoutes.farmNew);
    if (context.mounted) context.read<FarmsCubit>().load();
  }

  Future<void> _openFarm(BuildContext context, String farmId) async {
    await context.push(AppRoutes.farmDetailPath(farmId));
    if (context.mounted) context.read<FarmsCubit>().load();
  }

  Future<void> _editFarm(BuildContext context, String farmId) async {
    await context.push(AppRoutes.farmEditPath(farmId));
    if (context.mounted) context.read<FarmsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 88),
        child: FloatingActionButton.extended(
          tooltip: AppStrings.createFarm,
          onPressed: () => _openCreateForm(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text(AppStrings.createFarm),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.myFarms,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.primaryDark,
                ),
                onPressed: () => context.push(AppRoutes.guide),
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: const Text('Guía de cultivos'),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<FarmsCubit, FarmsState>(
                  builder: (context, state) {
                    if (state.status == FarmsStatus.failure &&
                        state.farms.isEmpty) {
                      return _ErrorView(
                        message:
                            state.message ??
                            'No se pudieron cargar las fincas.',
                        onRetry: () => context.read<FarmsCubit>().load(),
                      );
                    }
                    if (state.status == FarmsStatus.loading &&
                        state.farms.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.isEmpty) {
                      return const EmptyState(
                        icon: Icons.agriculture_rounded,
                        title: 'Aún no tienes fincas',
                        subtitle:
                            'Registra tu primera finca con el botón flotante.',
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => context.read<FarmsCubit>().load(),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 140),
                        itemCount: state.farms.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => FarmCard(
                          farm: state.farms[index],
                          onTap: () =>
                              _openFarm(context, state.farms[index].id),
                          onEdit: () =>
                              _editFarm(context, state.farms[index].id),
                        ),
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
