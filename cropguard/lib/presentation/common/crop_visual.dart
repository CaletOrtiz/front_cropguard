import 'package:flutter/material.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_crop_visuals.dart';

/// Representación visual genérica de un cultivo: gradiente + ícono.
/// Reemplaza a una fotografía mientras no se agreguen imágenes reales.
class CropVisual extends StatelessWidget {
  const CropVisual({
    super.key,
    required this.cropId,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.iconSize = 32,
  });

  final String cropId;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          AppCropVisuals.iconFor(cropId),
          size: iconSize,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
