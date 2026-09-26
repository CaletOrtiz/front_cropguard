import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/core/models/crop.dart';
import 'package:cropguard/navigation/app_routes.dart';
import 'package:cropguard/presentation/screens/crops/widgets/crop_card.dart';

class CropsScreen extends StatelessWidget {
  const CropsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            const Text(
              AppStrings.cropsTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              AppStrings.cropsSubtitle,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ...AppCrops.all.map(
              (crop) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CropCard(
                  crop: crop,
                  onTap: () => context.push(AppRoutes.cropDetailPath(crop.id)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
