import 'package:kroppi/core/utils/number_format.dart';

/// Validadores del formulario de cosecha. Devuelven el mensaje de error o null.
String? validateHarvestDate(DateTime? date, {DateTime? now}) {
  if (date == null) return 'Elige la fecha de cosecha';
  final limit = now ?? today();
  final day = DateTime(date.year, date.month, date.day);
  if (day.isAfter(limit)) return 'La fecha no puede ser futura';
  return null;
}

String? validateHarvestQuantity(String text) {
  final value = parseDecimal(text);
  if (value == null) return 'Ingresa la cantidad en kg';
  if (value <= 0) return 'La cantidad debe ser mayor que 0';
  return null;
}

String? validateOptionalPrice(String text) {
  if (text.trim().isEmpty) return null;
  final value = parseDecimal(text);
  if (value == null) return 'Ingresa un precio válido';
  if (value < 0) return 'El precio no puede ser negativo';
  return null;
}
