import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formato de dinero, kilos y fechas de los módulos de cosechas y pérdidas.
/// La app solo formatea: las cifras las calcula el backend.
String formatMoney(num? value, String currency) {
  final format = currency == 'USD'
      ? NumberFormat.currency(locale: 'en_US', symbol: r'US$', decimalDigits: 2)
      // es_CO pone el símbolo al final por defecto; en Colombia se escribe $2.700.000.
      : NumberFormat.currency(
          locale: 'es_CO',
          symbol: r'$',
          decimalDigits: 0,
          customPattern: '¤#,##0',
        );
  return format.format(value ?? 0);
}

String formatKg(num? value) =>
    '${NumberFormat('#,##0.##', 'es_CO').format(value ?? 0)} kg';

String formatPct(num? value) =>
    '${NumberFormat('#,##0.##', 'es_CO').format(value ?? 0)} %';

String formatDay(DateTime date) => DateFormat('d MMM y', 'es').format(date);

String formatPeriod(DateTime from, DateTime to) =>
    '${DateFormat('dd MMM', 'es').format(from)} – ${DateFormat('dd MMM y', 'es').format(to)}';

/// Fecha `yyyy-MM-dd` para el backend.
String apiDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

/// Lee un `yyyy-MM-dd` (o ISO) como fecha local sin hora.
DateTime parseApiDate(String value) {
  final parsed = DateTime.parse(value);
  return DateTime(parsed.year, parsed.month, parsed.day);
}

DateTime today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

double? toDouble(Object? value) => (value as num?)?.toDouble();

/// Separa lo que escribe el usuario en (parte entera, decimales). Acepta coma
/// o punto decimal y puntos de miles. Decimales null = no hay separador.
///
/// Con [dotsAreGrouping] todos los puntos se tratan como separador de miles
/// (texto que ya formateó el propio campo, en es_CO).
(String, String?) _split(String raw, {bool dotsAreGrouping = false}) {
  final text = raw.replaceAll(RegExp(r'[^0-9.,]'), '');
  final comma = text.lastIndexOf(',');
  if (comma >= 0) {
    return (
      text.substring(0, comma).replaceAll(RegExp(r'[^0-9]'), ''),
      text.substring(comma + 1).replaceAll(RegExp(r'[^0-9]'), ''),
    );
  }
  final dot = dotsAreGrouping ? -1 : text.lastIndexOf('.');
  // Con máximo 2 decimales, un punto seguido de 3 dígitos es separador de miles.
  if (dot >= 0 && text.length - dot - 1 != 3) {
    return (
      text.substring(0, dot).replaceAll('.', ''),
      text.substring(dot + 1),
    );
  }
  return (text.replaceAll('.', ''), null);
}

/// Convierte el texto de un campo numérico a double (null si está vacío).
double? parseDecimal(String raw) {
  final (integer, decimals) = _split(raw.trim());
  if (integer.isEmpty && (decimals == null || decimals.isEmpty)) return null;
  final fraction = decimals == null || decimals.isEmpty ? '0' : decimals;
  return double.tryParse('${integer.isEmpty ? '0' : integer}.$fraction');
}

/// Muestra separador de miles mientras se escribe (formato es_CO: `1.234,5`)
/// y no admite letras ni más de [decimalDigits] decimales.
class DecimalInputFormatter extends TextInputFormatter {
  const DecimalInputFormatter({this.decimalDigits = 2});

  final int decimalDigits;

  static String format(
    String raw, {
    int decimalDigits = 2,
    bool dotsAreGrouping = false,
  }) {
    final (integer, decimals) = _split(raw, dotsAreGrouping: dotsAreGrouping);
    final clean = integer.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final grouped = clean.isEmpty
        ? (decimals == null ? '' : '0')
        : NumberFormat('#,##0', 'es_CO').format(int.parse(clean));
    if (decimals == null || decimalDigits == 0) return grouped;
    final cut = decimals.length > decimalDigits
        ? decimals.substring(0, decimalDigits)
        : decimals;
    return '$grouped,$cut';
  }

  /// Texto inicial de un campo a partir de un número.
  static String fromNumber(num? value) =>
      value == null ? '' : NumberFormat('#,##0.##', 'es_CO').format(value);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final old = oldValue.text;
    var raw = newValue.text;
    final singleKeystroke = (raw.length - old.length).abs() <= 1;
    // Un punto tecleado al final, sin coma previa, es el separador decimal.
    final typedDecimalDot = raw.length == old.length + 1 &&
        raw.endsWith('.') &&
        !old.contains(',');
    if (typedDecimalDot) raw = '${raw.substring(0, raw.length - 1)},';
    // Al teclear o borrar un carácter, los puntos del campo son los de miles que
    // puso este mismo formateador: no se pueden reinterpretar como decimales
    // ("1.000" + "0" debe dar "10.000", no "1,00"). Al pegar se adivina.
    final text = format(
      raw,
      decimalDigits: decimalDigits,
      dotsAreGrouping: singleKeystroke,
    );
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
