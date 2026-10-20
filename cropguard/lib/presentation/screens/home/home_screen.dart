import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/navigation/app_routes.dart';
import 'package:cropguard/presentation/screens/auth/widgets/diagnose_card.dart';
import 'package:cropguard/presentation/screens/home/widgets/quick_access_tile.dart';
import 'package:cropguard/presentation/screens/home/widgets/quick_access_header.dart';

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
              // Para mostrar el enlace "Ver todos >", pasa onSeeAll: () {...}
              const QuickAccessHeader(),
              const SizedBox(height: 12),
              Column(
                children: [
                  QuickAccessTile(
                    icon: Icons.history_rounded,
                    label: AppStrings.myDiagnoses,
                    subtitle: AppStrings.myDiagnosesHint,
                    tone: QuickAccessTone.mint,
                    onTap: () => context.go(AppRoutes.history),
                  ),
                  const SizedBox(height: 12),
                  QuickAccessTile(
                    icon: Icons.grass_rounded,
                    label: AppStrings.cropGuide,
                    subtitle: AppStrings.cropGuideHint,
                    tone: QuickAccessTone.lime,
                    onTap: () => context.go(AppRoutes.crops),
                  ),
                  const SizedBox(height: 12),
                  QuickAccessTile(
                    icon: Icons.person_outline_rounded,
                    label: AppStrings.profile,
                    subtitle: AppStrings.profileHint,
                    tone: QuickAccessTone.sky,
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
