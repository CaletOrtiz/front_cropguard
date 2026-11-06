import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/features/home/domain/entities/home_dashboard.dart';

class HomeSummary extends StatelessWidget {
  const HomeSummary({
    super.key,
    required this.dashboard,
    required this.onOpenFarms,
    required this.onOpenPlots,
    required this.onOpenAlerts,
    required this.onOpenDanger,
  });

  final HomeDashboard dashboard;
  final VoidCallback onOpenFarms;
  final VoidCallback onOpenPlots;
  final VoidCallback onOpenAlerts;
  final VoidCallback onOpenDanger;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _HomeMetric(
        label: AppStrings.farms,
        value: dashboard.totalFarms,
        icon: Icons.agriculture_rounded,
        color: AppColors.primary,
        background: AppColors.primaryLight,
        onTap: onOpenFarms,
      ),
      _HomeMetric(
        label: AppStrings.plots,
        value: dashboard.totalPlots,
        icon: Icons.grid_view_rounded,
        color: AppColors.primaryDark,
        background: const Color(0xFFEAF2E8),
        onTap: onOpenPlots,
      ),
      _HomeMetric(
        label: AppStrings.alertPlots,
        value: dashboard.alertPlots,
        icon: Icons.warning_amber_rounded,
        color: AppColors.warning,
        background: const Color(0xFFFFF6DC),
        onTap: onOpenAlerts,
      ),
      _HomeMetric(
        label: AppStrings.dangerPlots,
        value: dashboard.dangerPlots,
        icon: Icons.error_outline_rounded,
        color: AppColors.error,
        background: const Color(0xFFFEECEC),
        onTap: onOpenDanger,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.homeSummary,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final metric in metrics)
                  SizedBox(
                    width: itemWidth,
                    child: _MetricCard(metric: metric),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HomeMetric {
  const _HomeMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final _HomeMetric metric;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: metric.background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: metric.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(metric.icon, color: metric.color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${metric.value}',
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.1,
                        fontWeight: FontWeight.w800,
                        color: metric.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metric.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
