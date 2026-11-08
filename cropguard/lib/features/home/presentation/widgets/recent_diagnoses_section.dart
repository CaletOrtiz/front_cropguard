import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/widgets/confidence_badge.dart';
import 'package:kroppi/features/history/domain/entities/diagnosis_record.dart';
import 'package:kroppi/features/history/presentation/utils/date_formatter.dart';
import 'package:kroppi/features/history/presentation/widgets/diagnosis_photo.dart';

class RecentDiagnosesSection extends StatelessWidget {
  const RecentDiagnosesSection({
    super.key,
    required this.records,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onOpenHistory,
    required this.onOpenDiagnosis,
  });

  final List<DiagnosisRecord> records;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onOpenHistory;
  final ValueChanged<DiagnosisRecord> onOpenDiagnosis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.medical_services_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Últimos diagnósticos',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: onOpenHistory,
              child: const Text('Ver historial'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (errorMessage != null)
          _MessageCard(
            message: 'No se pudieron cargar los diagnósticos recientes.',
            actionLabel: 'Reintentar',
            onAction: onRetry,
          )
        else if (records.isEmpty)
          const _MessageCard(
            message: 'Tus diagnósticos recientes aparecerán aquí.',
          )
        else
          for (var index = 0; index < records.length; index++) ...[
            _RecentDiagnosisCard(
              record: records[index],
              onTap: () => onOpenDiagnosis(records[index]),
            ),
            if (index < records.length - 1) const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _RecentDiagnosisCard extends StatelessWidget {
  const _RecentDiagnosisCard({required this.record, required this.onTap});

  final DiagnosisRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final contextLabel = [
      if (record.plotName != null && record.plotName!.isNotEmpty)
        record.plotName!,
      record.cropName,
    ].join(' · ');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              DiagnosisPhoto(
                imageUrl: record.imageUrl,
                cropId: record.cropId,
                width: 58,
                height: 58,
                borderRadius: BorderRadius.circular(12),
                iconSize: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contextLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      record.pathogen,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        ConfidenceBadge(confidence: record.confidence),
                        Text(
                          DateFormatter.short(record.date),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
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

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          if (actionLabel != null && onAction != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ),
        ],
      ),
    );
  }
}
