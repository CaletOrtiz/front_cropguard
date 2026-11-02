import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/features/farms/domain/entities/farm.dart';

class FarmCard extends StatelessWidget {
  const FarmCard({
    super.key,
    required this.farm,
    required this.onTap,
    required this.onEdit,
  });

  final Farm farm;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final location = [
      farm.municipality,
      farm.department,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');
    final area = farm.areaHa;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.agriculture_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farm.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Editar finca',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    color: AppColors.primaryDark,
                  ),
                ],
              ),
              if (farm.description?.trim().isNotEmpty ?? false) ...[
                const SizedBox(height: 12),
                Text(
                  farm.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (area != null)
                    _FarmFact(
                      icon: Icons.landscape_outlined,
                      label: '${_formatArea(area)} ha',
                    ),
                  _FarmFact(
                    icon: Icons.grass_rounded,
                    label: '${farm.cropCount} ${AppStrings.crops.toLowerCase()}',
                  ),
                  _FarmFact(
                    icon: Icons.grid_view_rounded,
                    label: '${farm.plotCount} ${AppStrings.plots.toLowerCase()}',
                  ),
                  if (farm.alertPlots > 0)
                    _FarmFact(
                      icon: Icons.warning_amber_rounded,
                      label:
                          '${farm.alertPlots} ${AppStrings.alertPlots.toLowerCase()}',
                      color: AppColors.warning,
                    ),
                  if (farm.dangerPlots > 0)
                    _FarmFact(
                      icon: Icons.error_outline_rounded,
                      label:
                          '${farm.dangerPlots} ${AppStrings.dangerPlots.toLowerCase()}',
                      color: AppColors.error,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatArea(double area) =>
      area.toStringAsFixed(area.truncateToDouble() == area ? 0 : 1);
}

class _FarmFact extends StatelessWidget {
  const _FarmFact({
    required this.icon,
    required this.label,
    this.color = AppColors.textSecondary,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
