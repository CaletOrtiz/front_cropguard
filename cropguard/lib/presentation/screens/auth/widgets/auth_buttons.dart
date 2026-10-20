import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_spacing.dart';

/// Botón principal verde oscuro con flecha a la derecha.

class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.splashOnColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonHeight / 2),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.arrow_forward_rounded, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón "Continuar con Google" con borde verde y logo "G" multicolor.
class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.splashOnColor, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonHeight / 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _GoogleG(),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// "G" con los colores de Google. Si tienes el logo oficial como asset
/// (por ejemplo en AppAssets), reemplaza este widget por un Image.asset.
class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => const SweepGradient(
        colors: [
          Color(0xFF4285F4), // azul
          Color(0xFF34A853), // verde
          Color(0xFFFBBC05), // amarillo
          Color(0xFFEA4335), // rojo
          Color(0xFF4285F4),
        ],
        stops: [0.0, 0.3, 0.5, 0.75, 1.0],
      ).createShader(rect),
      child: const Text(
        'G',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1),
      ),
    );
  }
}
