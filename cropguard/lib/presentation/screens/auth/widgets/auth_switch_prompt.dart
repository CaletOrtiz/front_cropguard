import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';

/// "¿No tienes cuenta? Regístrate" / "¿Ya tienes cuenta? Inicia sesión"
class AuthSwitchPrompt extends StatelessWidget {
  const AuthSwitchPrompt({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prompt, style: const TextStyle(color: AppColors.textSecondary)),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 44),
          ),
          child: Text(
            actionLabel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
