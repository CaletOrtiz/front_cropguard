import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';
import 'package:kroppi/features/my_crops/domain/entities/plot_sample.dart';

/// Barras de incidencia por muestreo.
/// - Altura de la barra = % de plantas afectadas.
/// - Color = estado (sano / alerta / peligro) según los umbrales del cultivo.
/// - Sobre cada barra: el % y "afectadas/evaluadas" (cuántas plantas se analizaron).
/// - Bajo cada barra: fecha y hora del muestreo.
/// Las líneas punteadas marcan el umbral de alerta (amarillo) y de peligro (rojo).
class IncidenceChart extends StatelessWidget {
  const IncidenceChart({
    super.key,
    required this.samples,
    required this.alertPct,
    required this.dangerPct,
    this.maxBars = 8,
  });

  final List<PlotSample> samples;
  final double alertPct;
  final double dangerPct;

  /// Cuántos muestreos recientes se dibujan como máximo.
  final int maxBars;

  @override
  Widget build(BuildContext context) {
    final shown = samples.length > maxBars
        ? samples.sublist(samples.length - maxBars)
        : samples;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: CustomPaint(
            painter: _ChartPainter(shown, alertPct, dangerPct),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          runSpacing: 4,
          children: const [
            _LegendDot(color: AppColors.primary, text: 'Sano'),
            _LegendDot(color: AppColors.warning, text: 'Alerta'),
            _LegendDot(color: AppColors.error, text: 'Peligro'),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Sobre cada barra: % de incidencia y plantas afectadas / evaluadas.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        if (samples.length > maxBars)
          Text(
            'Se muestran los últimos $maxBars muestreos.',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.text});

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.samples, this.alertPct, this.dangerPct);

  final List<PlotSample> samples;
  final double alertPct;
  final double dangerPct;

  static String _two(int n) => n.toString().padLeft(2, '0');

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  Color _colorOf(double pct) {
    if (pct >= dangerPct) return AppColors.error;
    if (pct >= alertPct) return AppColors.warning;
    return AppColors.primary;
  }

  @override
  void paint(Canvas canvas, Size size) {
    const left = 36.0, top = 34.0, bottom = 34.0;
    final w = size.width - left;
    final h = size.height - top - bottom;

    // Escala vertical: un tope "redondo" para que las barras se lean bien.
    final maxData = samples.fold<double>(
      0,
      (m, s) => s.incidencePct > m ? s.incidencePct : m,
    );
    final wanted = [
      maxData * 1.1,
      dangerPct * 1.6,
      10.0,
    ].reduce((a, b) => a > b ? a : b);
    final maxY = [
      20.0,
      30.0,
      50.0,
      100.0,
    ].firstWhere((v) => v >= wanted, orElse: () => 100.0);

    double yOf(double v) =>
        top + h - (math.min(math.max(v, 0.0), maxY) / maxY) * h;

    void text(
      String t,
      double cx,
      double y, {
      double fontSize = 10,
      FontWeight weight = FontWeight.w400,
      Color color = AppColors.textSecondary,
    }) {
      final tp = TextPainter(
        text: TextSpan(
          text: t,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: weight,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, y));
    }

    void axisLabel(String t, double y) {
      final tp = TextPainter(
        text: TextSpan(
          text: t,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(left - 6 - tp.width, y - tp.height / 2));
    }

    // Base (0 %) y tope de la escala
    final grid = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    canvas.drawLine(Offset(left, yOf(0)), Offset(size.width, yOf(0)), grid);
    canvas.drawLine(
      Offset(left, yOf(maxY)),
      Offset(size.width, yOf(maxY)),
      grid,
    );
    axisLabel('0 %', yOf(0));
    axisLabel('${maxY.toStringAsFixed(0)} %', yOf(maxY));

    // Líneas punteadas de alerta y peligro
    void dashed(double v, Color c) {
      final y = yOf(v);
      final p = Paint()
        ..color = c.withValues(alpha: 0.7)
        ..strokeWidth = 1.2;
      for (var x = left; x < size.width; x += 8) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + 4, size.width), y),
          p,
        );
      }
    }

    if (alertPct <= maxY) dashed(alertPct, AppColors.warning);
    if (dangerPct <= maxY) dashed(dangerPct, AppColors.error);

    if (samples.isEmpty) return;

    // Barras
    final slot = w / samples.length;
    final barW = math.min(slot * 0.55, 34.0);
    for (var i = 0; i < samples.length; i++) {
      final s = samples[i];
      final cx = left + slot * (i + 0.5);
      final color = _colorOf(s.incidencePct);
      final yTop = yOf(s.incidencePct);
      final barH = math.max(yOf(0) - yTop, 2.0);

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(cx - barW / 2, yOf(0) - barH, barW, barH),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        ),
        Paint()..color = color,
      );

      final barTop = yOf(0) - barH;
      // % (arriba) y afectadas/evaluadas (debajo del %)
      text(
        '${_num(s.incidencePct)}%',
        cx,
        barTop - 28,
        fontSize: 11,
        weight: FontWeight.w800,
        color: color,
      );
      text('${s.affected}/${s.evaluated}', cx, barTop - 14, fontSize: 10);

      // Fecha y hora del muestreo
      final d = s.sampledAt;
      text('${_two(d.day)}/${_two(d.month)}', cx, yOf(0) + 5);
      text('${_two(d.hour)}:${_two(d.minute)}', cx, yOf(0) + 18, fontSize: 9);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) =>
      old.samples != samples ||
      old.alertPct != alertPct ||
      old.dangerPct != dangerPct;
}
