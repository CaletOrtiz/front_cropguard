import 'package:flutter/material.dart';
import 'package:cropguard/core/constants/app_colors.dart';

/// Indicador visual de confianza del diagnóstico.
class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge({super.key, required this.confidence});

  final int confidence; // 0-100

  Color get _color {
    if (confidence >= 80) return AppColors.primary;
    if (confidence >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$confidence% confianza',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}
