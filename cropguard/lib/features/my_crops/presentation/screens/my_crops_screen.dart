import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/widgets/empty_state.dart';
import 'package:kroppi/features/my_crops/domain/entities/my_crop.dart';
import 'package:kroppi/features/my_crops/presentation/cubit/my_crops_cubit.dart';
import 'package:kroppi/navigation/app_routes.dart';

class MyCropsScreen extends StatelessWidget {
  const MyCropsScreen({super.key});

  Future<void> _open(BuildContext context, String path) async {
    await context.push(path);
    if (context.mounted) context.read<MyCropsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Mis cultivos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    tooltip: 'Registrar cultivo',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: () => _open(context, AppRoutes.cropNew),
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: AppColors.primaryDark,
                ),
                onPressed: () => context.push(AppRoutes.guide),
                icon: const Icon(Icons.menu_book_rounded, size: 18),
                label: const Text('Guía de enfermedades'),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<MyCropsCubit, MyCropsState>(
                  builder: (context, state) {
                    if (state.status == MyCropsStatus.failure &&
                        state.crops.isEmpty) {
                      return _ErrorView(
                        message: state.message ?? 'No se pudo cargar.',
                        onRetry: () => context.read<MyCropsCubit>().load(),
                      );
                    }
                    if (state.crops.isEmpty &&
                        state.status != MyCropsStatus.success) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.isEmpty) {
                      return const EmptyState(
                        icon: Icons.grass_rounded,
                        title: 'Aún no tienes cultivos',
                        subtitle: 'Registra tu primer cultivo con el botón +.',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () => context.read<MyCropsCubit>().load(),
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 120),
                        itemCount: state.crops.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => _CropTile(
                          crop: state.crops[i],
                          onTap: () => _open(
                            context,
                            AppRoutes.cropDetailPath(state.crops[i].id),
                          ),
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

class _CropTile extends StatelessWidget {
  const _CropTile({required this.crop, required this.onTap});

  final MyCrop crop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final problems = crop.alertPlots + crop.dangerPlots;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.grass_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crop.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${crop.typeName} · ${crop.totalAreaHa} ha',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      crop.totalPlots == 0
                          ? 'Sin lotes todavía'
                          : '${crop.totalPlots} lotes'
                                '${problems > 0 ? ' · $problems con problemas' : ' · todos sanos'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: crop.dangerPlots > 0
                            ? AppColors.error
                            : crop.alertPlots > 0
                            ? AppColors.warning
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
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
