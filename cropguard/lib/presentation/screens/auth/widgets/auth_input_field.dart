import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';

/// Campo de texto del diseño de autenticación: etiqueta arriba,
/// fondo verde suave, ícono a la izquierda y ojo para contraseñas.

class AuthInputField extends StatefulWidget {
  const AuthInputField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.onSubmitted,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool isPassword;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  static const _fill = Color(0xFFF1FADF);

  late bool _obscure = widget.isPassword;

  OutlineInputBorder _border([Color? color]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: color == null
        ? BorderSide.none
        : BorderSide(color: color, width: 1.4),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.splashOnColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscure,
          onFieldSubmitted: widget.onSubmitted,
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.label,
            hintStyle: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: _fill,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            prefixIcon: Icon(widget.icon, color: AppColors.splashOnColor),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(AppColors.splashOnColor),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error),
          ),
        ),
      ],
    );
  }
}
