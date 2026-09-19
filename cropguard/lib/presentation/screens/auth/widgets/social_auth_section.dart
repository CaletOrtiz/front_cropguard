import 'package:flutter/material.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/presentation/common/social_button.dart';

class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                AppStrings.orContinueWith,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 16),
        SocialButton(
          label: AppStrings.continueGoogle,
          icon: Icons.g_mobiledata_rounded,
          onPressed: () {
            // TODO: autenticación con Google
          },
        ),
        const SizedBox(height: 12),
        SocialButton(
          label: AppStrings.continueApple,
          icon: Icons.apple,
          onPressed: () {
            // TODO: autenticación con Apple
          },
        ),
      ],
    );
  }
}
