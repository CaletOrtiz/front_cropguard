import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/features/home/domain/entities/home_dashboard.dart';

class PendingSamplingCard extends StatelessWidget {
  const PendingSamplingCard({
    super.key,
    required this.sampling,
    required this.onStartSampling,
  });

  final HomePendingSampling sampling;
  final VoidCallback onStartSampling;

  @override
  Widget build(BuildContext context) {
    final days = sampling.daysSinceLastSample;
    final status = sampling.hasNeverBeenSampled
        ? AppStrings.neverSampled
        : AppStrings.daysSinceSample(days!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF8E3B0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.schedule_rounded,
                color: AppColors.warning,
                size: 21,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sampling.plotName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      sampling.farmName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onStartSampling,
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text(AppStrings.startSampling),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryDark,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
