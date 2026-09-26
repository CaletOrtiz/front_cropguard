import 'package:flutter/material.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/presentation/common/aura_background.dart';
import 'package:cropguard/presentation/common/kroppi_logo.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.height = 220});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const AuraBackground(),
            SafeArea(
              bottom: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const KroppiWordmark(
                      fontSize: 30,
                      textColor: AppColors.primaryDark,
                      leafColor: AppColors.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.slogan,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
