import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/core/utils/number_format.dart';

/// Umbrales del chip de severidad del % de pérdida.
const lossLowThresholdPct = 0.0;
const lossHighThresholdPct = 15.0;

enum LossSeverity { none, low, high }

LossSeverity lossSeverity(double pct) {
  if (pct <= lossLowThresholdPct) return LossSeverity.none;
  if (pct < lossHighThresholdPct) return LossSeverity.low;
  return LossSeverity.high;
}

Color lossSeverityColor(LossSeverity severity) => switch (severity) {
  LossSeverity.none => AppColors.primary,
  LossSeverity.low => AppColors.warning,
  LossSeverity.high => AppColors.error,
};

/// Validación del periodo (null si es válido).
String? validateLossPeriod(DateTime? from, DateTime? to) {
  if (from == null || to == null) return 'Elige el periodo';
  if (to.isBefore(from)) {
    return 'La fecha final debe ser igual o posterior a la inicial';
  }
  final limit = DateTime(from.year + 2, from.month, from.day);
  if (to.isAfter(limit)) return 'El periodo no puede superar 2 años';
  return null;
}

/// Aviso (no bloquea) si el periodo termina en el futuro.
String? futurePeriodWarning(DateTime? to, {DateTime? now}) {
  if (to == null) return null;
  return to.isAfter(now ?? today())
      ? 'El periodo termina en el futuro: la estimación cambiará al registrar más cosechas'
      : null;
}

String? validateExpectedKg(String text) {
  final value = parseDecimal(text);
  if (value == null) return 'Ingresa los kilos que esperas producir';
  if (value <= 0) return 'Debe ser mayor que 0';
  return null;
}

String? validateRequiredPrice(String text) {
  final value = parseDecimal(text);
  if (value == null) return 'Ingresa el precio por kg';
  if (value < 0) return 'El precio no puede ser negativo';
  return null;
}
