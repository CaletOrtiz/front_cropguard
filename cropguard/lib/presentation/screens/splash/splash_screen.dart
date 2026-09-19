import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cropguard/core/constants/app_assets.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/navigation/app_routes.dart';
import 'package:cropguard/presentation/common/primary_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.splashBackground,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) =>
                const ColoredBox(color: AppColors.primaryDark),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryDark.withValues(alpha: 0.6),
                  AppColors.primaryDark.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      size: 44,
                      color: AppColors.mint,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    AppStrings.slogan,
                    style: TextStyle(color: AppColors.mint, fontSize: 16),
                  ),
                  const Spacer(flex: 3),
                  const Wrap(
                    spacing: 10,
                    children: [
                      _FeatureChip(AppStrings.detect),
                      _FeatureChip(AppStrings.prevent),
                      _FeatureChip(AppStrings.protect),
                    ],
                  ),
                  const Spacer(flex: 4),
                  PrimaryButton(
                    label: AppStrings.start,
                    colors: const [AppColors.primary, Color(0xFF3DBB63)],
                    onPressed: () => context.go(AppRoutes.register),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.poweredByAi,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
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

class _FeatureChip extends StatelessWidget {
  const _FeatureChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.mint,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
