import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/navigation/app_routes.dart';
import 'package:cropguard/presentation/common/aura_background.dart';
import 'package:cropguard/presentation/common/kroppi_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuraBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  const KroppiWordmark(
                    fontSize: 48,
                    textColor: AppColors.primaryDark,
                    leafColor: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.slogan,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(flex: 5),
                  _DarkPillButton(
                    label: AppStrings.start,
                    onPressed: () => context.go(AppRoutes.register),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.poweredByAi,
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón tipo píldora, oscuro, de ancho ajustado al contenido.
class _DarkPillButton extends StatelessWidget {
  const _DarkPillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
