import 'package:flutter/material.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_crop_visuals.dart';
import 'package:cropguard/core/models/crop.dart';

/// Tarjeta vertical de un cultivo: foto arriba, insignia circular con el
/// ícono del cultivo, nombre, enfermedades comunes y flecha.
///
/// Ubicación: presentation/screens/crops/widgets/crop_card.dart
class CropCard extends StatelessWidget {
  const CropCard({super.key, required this.crop, required this.onTap});

  final Crop crop;
  final VoidCallback onTap;

  static const _photoHeight = 96.0;
  static const _badgeSize = 44.0;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    final color = AppCropVisuals.colorFor(crop.id);
    final icon = AppCropVisuals.iconFor(crop.id);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.splashOnColor.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              SizedBox(
                height: _photoHeight + _badgeSize / 2,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: _photoHeight,
                      child: _CropPhoto(
                        assetPath: crop.imageAsset,
                        color: color,
                        icon: icon,
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: _photoHeight - _badgeSize / 2,
                      child: Container(
                        width: _badgeSize,
                        height: _badgeSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 21),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 10, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crop.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.splashOnColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              crop.commonDiseases.take(2).join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryLight,
                        ),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppColors.splashOnColor.withValues(
                            alpha: 0.75,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Foto del cultivo. Si el archivo no existe todavía, muestra una cabecera
/// de color con el ícono del cultivo.
class _CropPhoto extends StatelessWidget {
  const _CropPhoto({
    required this.assetPath,
    required this.color,
    required this.icon,
  });

  final String assetPath;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.38),
              color.withValues(alpha: 0.16),
            ],
          ),
        ),
        child: Center(
          child: Icon(icon, size: 46, color: color.withValues(alpha: 0.55)),
        ),
      ),
    );
  }
}
