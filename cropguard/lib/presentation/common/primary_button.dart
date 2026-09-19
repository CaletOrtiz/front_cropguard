import 'package:flutter/material.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_spacing.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.colors,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final radius = BorderRadius.circular(AppSpacing.radius);

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Container(
        height: AppSpacing.buttonHeight,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            colors: colors ?? const [AppColors.primaryDark, AppColors.primary],
          ),
          boxShadow: [
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
