import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_spacing.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.colors,
    this.dark = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color>? colors;

  /// Si es true, usa una píldora negra en vez del degradado verde.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final radius = BorderRadius.circular(dark ? 999 : AppSpacing.radius);

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Container(
        height: AppSpacing.buttonHeight,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: dark ? const Color(0xFF1A1A1A) : null,
          gradient: dark
              ? null
              : LinearGradient(
                  colors:
                      colors ??
                      const [AppColors.primaryDark, AppColors.primary],
                ),
          boxShadow: dark
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: enabled ? onPressed : null,
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
