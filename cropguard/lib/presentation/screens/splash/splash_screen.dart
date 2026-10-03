import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/navigation/app_routes.dart';
import 'package:cropguard/presentation/common/kroppi_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 5),
              KroppiIntroAnimation(
                fontSize: 48,
                textColor: AppColors.splashOnColor,
                leafColor: AppColors.splashOnColor,
                slogan: AppStrings.slogan,
                sloganStyle: TextStyle(
                  color: AppColors.splashOnColor.withValues(alpha: 0.75),
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
                  color: AppColors.splashOnColor.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkPillButton extends StatelessWidget {
  const _DarkPillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.splashOnColor,
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
