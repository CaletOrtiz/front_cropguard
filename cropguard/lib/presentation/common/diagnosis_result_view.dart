import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/core/utils/date_formatter.dart';
import 'package:kroppi/presentation/common/bullet_list.dart';
import 'package:kroppi/presentation/common/confidence_badge.dart';
import 'package:kroppi/presentation/common/crop_visual.dart';

/// Contenido de un resultado de diagnóstico. Se usa tanto en el detalle
/// del historial como, más adelante, en la pantalla de resultado en vivo.
class DiagnosisResultView extends StatelessWidget {
  const DiagnosisResultView({
    super.key,
    required this.cropId,
    required this.cropName,
    required this.pathogen,
    required this.pathogenType,
    required this.confidence,
    required this.symptoms,
    required this.recommendations,
    this.date,
  });

  final String cropId;
  final String cropName;
  final String pathogen;
  final String pathogenType;
  final int confidence;
  final List<String> symptoms;
  final List<String> recommendations;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CropVisual(
            cropId: cropId,
            width: 180,
            height: 180,
            borderRadius: BorderRadius.circular(24),
            iconSize: 72,
          ),
        ),
        const SizedBox(height: 24),
        Text(cropName, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        const Text(
          AppStrings.possiblePathogen,
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          pathogen,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(
              label: Text(pathogenType, style: const TextStyle(fontSize: 12)),
              backgroundColor: AppColors.primaryLight,
              side: BorderSide.none,
            ),
            ConfidenceBadge(confidence: confidence),
            if (date != null)
              Text(
                DateFormatter.short(date!),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          AppStrings.symptomsObserved,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        BulletList(items: symptoms),
        const SizedBox(height: 24),
        const Text(
          AppStrings.recommendationsTitle,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        BulletList(items: recommendations, icon: Icons.shield_rounded),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppStrings.diagnosisDisclaimer,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
