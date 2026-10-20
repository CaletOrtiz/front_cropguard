import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/models/diagnosis_record.dart';
import 'package:kroppi/core/utils/date_formatter.dart';
import 'package:kroppi/presentation/common/confidence_badge.dart';
import 'package:kroppi/presentation/common/crop_visual.dart';

class DiagnosisHistoryCard extends StatelessWidget {
  const DiagnosisHistoryCard({
    super.key,
    required this.record,
    required this.onTap,
  });

  final DiagnosisRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CropVisual(
                cropId: record.cropId,
                width: 64,
                height: 64,
                borderRadius: BorderRadius.circular(12),
                iconSize: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.cropName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      record.pathogen,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ConfidenceBadge(confidence: record.confidence),
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.short(record.date),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
