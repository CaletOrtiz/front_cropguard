import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/navigation/app_routes.dart';
import 'package:cropguard/presentation/screens/auth/widgets/diagnose_card.dart';
import 'package:cropguard/presentation/screens/auth/widgets/quick_access_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // TODO: reemplazar por el nombre real del usuario autenticado
  static const _userName = 'Agricultor';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.greeting,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => context.push(AppRoutes.notifications),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryLight.withValues(
                        alpha: 0.7,
                      ),
                      foregroundColor: AppColors.primaryDark,
                      minimumSize: const Size(48, 48),
                    ),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.whatToday,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              DiagnoseCard(onTap: () => context.push(AppRoutes.diagnose)),
              const SizedBox(height: 28),
              const Text(
                AppStrings.quickAccess,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.25,
                children: [
                  QuickAccessTile(
                    icon: Icons.history_rounded,
                    label: AppStrings.myDiagnoses,
                    onTap: () => context.go(AppRoutes.history),
                  ),
                  QuickAccessTile(
                    icon: Icons.grass_rounded,
                    label: AppStrings.cropGuide,
                    onTap: () => context.go(AppRoutes.crops),
                  ),
                  QuickAccessTile(
                    icon: Icons.lightbulb_outline_rounded,
                    label: AppStrings.recommendations,
                    onTap: () => context.push(AppRoutes.recommendations),
                  ),
                  QuickAccessTile(
                    icon: Icons.person_outline_rounded,
                    label: AppStrings.profile,
                    onTap: () => context.go(AppRoutes.profile),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
