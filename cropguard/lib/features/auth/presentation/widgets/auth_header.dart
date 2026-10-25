import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/core/widgets/kroppi_logo.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, this.height = 200});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      child: Container(
        height: height,
        width: double.infinity,
        color: AppColors.splashBackground,
        child: SafeArea(
          bottom: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const KroppiWordmark(
                  fontSize: 30,
                  textColor: AppColors.splashOnColor,
                  leafColor: AppColors.splashOnColor,
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.slogan,
                  style: TextStyle(
                    color: AppColors.splashOnColor.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
