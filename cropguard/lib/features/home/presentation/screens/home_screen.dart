import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_state.dart';
import 'package:kroppi/features/home/domain/entities/home_dashboard.dart';
import 'package:kroppi/features/home/presentation/cubit/home_cubit.dart';
import 'package:kroppi/features/home/presentation/widgets/home_summary.dart';
import 'package:kroppi/features/home/presentation/widgets/pending_sampling_card.dart';
import 'package:kroppi/features/home/presentation/widgets/quick_access_header.dart';
import 'package:kroppi/features/home/presentation/widgets/quick_access_tile.dart';
import 'package:kroppi/features/sampling/presentation/cubit/sampling_cubit.dart';
import 'package:kroppi/navigation/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, homeState) {
        return BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (_, current) => current is AuthAuthenticated,
          builder: (context, authState) {
            final user = authState is AuthAuthenticated ? authState.user : null;
            final fullName = user?.fullName.trim() ?? '';
            final displayName = fullName.isEmpty
                ? 'Agricultor'
                : fullName.split(RegExp(r'\s+')).first;
            final dashboard = homeState.dashboard;

            return Scaffold(
              body: SafeArea(
                child: RefreshIndicator(
                  onRefresh: context.read<HomeCubit>().load,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HomeHeader(
                          displayName: displayName,
                          onNotifications: () =>
                              context.push(AppRoutes.notifications),
                        ),
                        const SizedBox(height: 20),
                        if (homeState.status == HomeStatus.loading ||
                            homeState.status == HomeStatus.initial)
                          const _HomeLoadingState()
                        else if (homeState.status == HomeStatus.failure)
                          _HomeErrorState(
                            message:
                                homeState.message ??
                                'No se pudo cargar Inicio.',
                            onRetry: context.read<HomeCubit>().load,
                          )
                        else if (dashboard != null)
                          _DashboardContent(dashboard: dashboard),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.displayName, required this.onNotifications});

  final String displayName;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                AppStrings.greeting,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onNotifications,
          tooltip: AppStrings.notificationsMenu,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.7),
            foregroundColor: AppColors.primaryDark,
            minimumSize: const Size(48, 48),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.dashboard});

  final HomeDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeSummary(
          dashboard: dashboard,
          onOpenFarms: () => context.go(AppRoutes.farms),
          onOpenPlots: () => context.push(AppRoutes.plotOverview),
          onOpenAlerts: () => context.push(AppRoutes.plotAlerts),
          onOpenDanger: () => context.push(AppRoutes.plotDanger),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 28),
        const Text(
          AppStrings.pendingMonitoring,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (dashboard.pendingSamplings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No tienes monitoreos pendientes.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          for (final sampling in dashboard.pendingSamplings) ...[
            PendingSamplingCard(
              sampling: sampling,
              onStartSampling: () => context.push(
                AppRoutes.samplingPath(sampling.plotId),
                extra: SamplingArgs(
                  cropSlug: sampling.cropSlug,
                  plantCount: sampling.plantCount,
                ),
              ),
            ),
            if (sampling != dashboard.pendingSamplings.last)
              const SizedBox(height: 12),
          ],
        const SizedBox(height: 28),
        const QuickAccessHeader(),
        const SizedBox(height: 12),
        QuickAccessTile(
          icon: Icons.receipt_long_rounded,
          label: AppStrings.reports,
          subtitle: AppStrings.reportsHint,
          tone: QuickAccessTone.mint,
          onTap: () => context.go(AppRoutes.history),
        ),
        const SizedBox(height: 12),
        QuickAccessTile(
          icon: Icons.menu_book_rounded,
          label: AppStrings.cropGuide,
          subtitle: AppStrings.cropGuideHint,
          tone: QuickAccessTone.lime,
          onTap: () => context.go(AppRoutes.guide),
        ),
        const SizedBox(height: 12),
        QuickAccessTile(
          icon: Icons.person_outline_rounded,
          label: AppStrings.profile,
          subtitle: AppStrings.profileHint,
          tone: QuickAccessTone.sky,
          onTap: () => context.go(AppRoutes.profile),
        ),
      ],
    );
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 72),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  const _HomeErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: AppColors.error,
            ),
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
      ),
    );
  }
}
