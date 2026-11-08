import 'package:flutter/material.dart';
import 'package:kroppi/core/utils/number_format.dart';

/// Campo numérico decimal: teclado numérico, separador de miles mientras se
/// escribe y coma o punto decimal. Leer el valor con [parseDecimal].
class DecimalField extends StatelessWidget {
  const DecimalField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.helperText,
    this.suffixText,
    this.onChanged,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String text)? validator;
  final String? helperText;
  final String? suffixText;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    enabled: enabled,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: const [DecimalInputFormatter()],
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: validator == null ? null : (value) => validator!(value ?? ''),
    onChanged: onChanged,
    decoration: InputDecoration(
      labelText: label,
      helperText: helperText,
      helperMaxLines: 2,
      suffixText: suffixText,
    ),
  );
}

/// Selector de fecha con el estilo de campo del tema.
class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      child: Text(
        value == null ? 'Elegir fecha' : formatDay(value!),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

/// Selector COP / USD.
class CurrencySelector extends StatelessWidget {
  const CurrencySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;

  /// Null deshabilita el selector.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<String>(
    segments: const [
      ButtonSegment(value: 'COP', label: Text('COP')),
      ButtonSegment(value: 'USD', label: Text('USD')),
    ],
    selected: {value},
    onSelectionChanged: onChanged == null
        ? null
        : (selection) => onChanged!(selection.first),
  );
}
