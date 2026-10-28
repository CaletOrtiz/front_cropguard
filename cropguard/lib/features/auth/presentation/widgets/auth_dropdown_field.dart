import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';

/// Lista desplegable con el mismo diseño que [AuthInputField]: etiqueta
/// arriba, fondo verde suave e ícono a la izquierda.
class AuthDropdownField<T> extends StatelessWidget {
  const AuthDropdownField({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.validator,
  });

  final String label;
  final IconData icon;
  final T? value;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  static const _fill = Color(0xFFF1FADF);

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
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.splashOnColor,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          borderRadius: BorderRadius.circular(18),
          dropdownColor: Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: _fill,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            prefixIcon: Icon(icon, color: AppColors.splashOnColor),
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
