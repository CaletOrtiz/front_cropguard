import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/constants/app_strings.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_event.dart';
import 'package:kroppi/features/auth/presentation/bloc/auth_state.dart';
import 'package:kroppi/navigation/app_routes.dart';
import 'package:kroppi/features/profile/presentation/widgets/profile_menu_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.logoutConfirmTitle),
        content: const Text(AppStrings.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthSignOutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.splash);
        } else if (state case AuthFailure(:final message)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('No se pudo cerrar sesión: $message')),
            );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            children: [
              // Solo se reconstruye con AuthAuthenticated, así el nombre no
              // parpadea mientras se cierra la sesión (AuthLoading).
              BlocBuilder<AuthBloc, AuthState>(
                buildWhen: (_, current) => current is AuthAuthenticated,
                builder: (context, state) {
                  final user = state is AuthAuthenticated ? state.user : null;
                  final name = user?.fullName ?? 'Agricultor';
                  final email = user?.email ?? '';

                  return Center(
                    child: Column(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 44,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        if (user != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            [
                              user.roleLabel,
                              user.locationLabel,
                            ].whereType<String>().join(' · '),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          if (user.phoneNumber != null)
                            Text(
                              user.phoneNumber!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              ProfileMenuTile(
                icon: Icons.grass_rounded,
                label: AppStrings.myCrops,
                onTap: () => context.go(AppRoutes.crops),
              ),
              const SizedBox(height: 10),
              ProfileMenuTile(
                icon: Icons.notifications_none_rounded,
                label: AppStrings.notificationsMenu,
                onTap: () => context.push(AppRoutes.notifications),
              ),
              const SizedBox(height: 10),
              ProfileMenuTile(
                icon: Icons.help_outline_rounded,
                label: AppStrings.helpSupport,
                onTap: () => context.push(AppRoutes.help),
              ),
              const SizedBox(height: 24),
              ProfileMenuTile(
                icon: Icons.logout_rounded,
                label: AppStrings.logout,
                destructive: true,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
