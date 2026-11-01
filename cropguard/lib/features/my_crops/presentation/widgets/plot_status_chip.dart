import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/features/my_crops/domain/entities/plot.dart';

extension PlotStatusX on PlotStatus {
  String get label => switch (this) {
    PlotStatus.healthy => 'Sano',
    PlotStatus.alert => 'En alerta',
    PlotStatus.danger => 'En peligro',
  };

  Color get color => switch (this) {
    PlotStatus.healthy => AppColors.primary,
    PlotStatus.alert => AppColors.warning,
    PlotStatus.danger => AppColors.error,
  };
}

class PlotStatusChip extends StatelessWidget {
  const PlotStatusChip({super.key, required this.status});

  final PlotStatus status;

  @override
  Widget build(BuildContext context) {
    final c = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: c),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
