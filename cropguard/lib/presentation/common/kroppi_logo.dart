import 'package:flutter/material.dart';
import 'package:cropguard/core/constants/app_colors.dart';

/// Wordmark de Kroppi: texto "Kropp" + una "i" personalizada,
/// donde el punto se reemplaza por una hoja.
class KroppiWordmark extends StatelessWidget {
  const KroppiWordmark({
    super.key,
    this.fontSize = 32,
    this.textColor = AppColors.primaryDark,
    this.leafColor = AppColors.primary,
  });

  final double fontSize;
  final Color textColor;
  final Color leafColor;

  @override
  Widget build(BuildContext context) {
    final stemHeight = fontSize * 0.5;
    final stemWidth = fontSize * 0.1;
    final leafSize = fontSize * 0.42;
    final gap = fontSize * 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Kropp',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: textColor,
            height: 1,
          ),
        ),
        SizedBox(width: gap),
        // "i" personalizada: barra + hoja en vez del punto
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: -0.5,
              child: Icon(Icons.eco_rounded, size: leafSize, color: leafColor),
            ),
            SizedBox(height: fontSize * 0.04),
            Container(
              width: stemWidth,
              height: stemHeight,
              decoration: BoxDecoration(
                color: textColor,
                borderRadius: BorderRadius.circular(stemWidth),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
