import 'package:flutter/material.dart';
import 'package:cropguard/core/constants/app_colors.dart';
import 'package:cropguard/core/constants/app_spacing.dart';
import 'package:cropguard/core/constants/app_strings.dart';
import 'package:cropguard/presentation/common/kroppi_logo.dart';
import 'package:cropguard/presentation/screens/auth/widgets/auth_background.dart';
import 'package:cropguard/presentation/screens/auth/widgets/auth_buttons.dart';
import 'package:cropguard/presentation/screens/auth/widgets/auth_switch_prompt.dart';

/// Layout compartido por Login y Registro: fondo con paisaje, logo,
/// tarjeta blanca con formulario, botón principal, enlace de cambio

class AuthScreenLayout extends StatelessWidget {
  const AuthScreenLayout({
    super.key,
    required this.formKey,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.submitLabel,
    required this.onSubmit,
    required this.switchPrompt,
    required this.switchActionLabel,
    required this.onSwitchPressed,
    this.onGooglePressed,
    this.isGoogleLoading = false,
    this.onBack,
  });

  final GlobalKey<FormState> formKey;
  final String title;
  final String subtitle;

  /// Campos del formulario (el layout agrega la separación entre ellos).
  final List<Widget> fields;

  final String submitLabel;
  final VoidCallback onSubmit;

  final String switchPrompt;
  final String switchActionLabel;
  final VoidCallback onSwitchPressed;

  final VoidCallback? onGooglePressed;
  final bool isGoogleLoading;

  /// Si es null, no se muestra el botón de volver.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 170),
        child: Column(
          children: [
            // Reserva el mismo alto aunque no haya botón de volver,
            // para que el logo quede en la misma posición en ambas pantallas.
            SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: onBack == null
                    ? null
                    : _BackCircleButton(onPressed: onBack!),
              ),
            ),
            const SizedBox(height: 4),
            const KroppiWordmark(
              fontSize: 40,
              textColor: AppColors.splashOnColor,
              leafColor: AppColors.splashOnColor,
            ),
            const SizedBox(height: 2),
            Text(
              AppStrings.slogan,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.splashOnColor.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 24),
            _buildCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.splashOnColor.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.splashOnColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ..._withSpacing(fields),
            const SizedBox(height: AppSpacing.lg),
            AuthSubmitButton(label: submitLabel, onPressed: onSubmit),
            const SizedBox(height: AppSpacing.sm),
            AuthSwitchPrompt(
              prompt: switchPrompt,
              actionLabel: switchActionLabel,
              onPressed: onSwitchPressed,
            ),
            const SizedBox(height: AppSpacing.xs),
            const _OrDivider(),
            const SizedBox(height: AppSpacing.md),
            GoogleAuthButton(
              label: AppStrings.continueGoogle,
              onPressed: onGooglePressed,
              isLoading: isGoogleLoading,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> children) {
    return [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) const SizedBox(height: AppSpacing.md),
        children[i],
      ],
    ];
  }
}

class _BackCircleButton extends StatelessWidget {
  const _BackCircleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_rounded,
            color: AppColors.splashOnColor,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
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
    );
  }
}
