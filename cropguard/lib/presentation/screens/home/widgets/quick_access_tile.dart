import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';

/// Paleta de cada tarjeta de acceso rápido.
enum QuickAccessTone { mint, lime, sun, sky }

class _ToneStyle {
  const _ToneStyle({
    required this.start,
    required this.end,
    required this.badge,
  });

  final Color start; // inicio del degradado de fondo
  final Color end; // fin del degradado de fondo
  final Color badge; // círculo del ícono
}

const _tones = <QuickAccessTone, _ToneStyle>{
  QuickAccessTone.mint: _ToneStyle(
    start: Color(0xFFE6F5E7),
    end: Color(0xFFD3ECD6),
    badge: Color(0xFF2E7D4F),
  ),
  QuickAccessTone.lime: _ToneStyle(
    start: Color(0xFFECF6DF),
    end: Color(0xFFDDEFC6),
    badge: Color(0xFF3F9B3A),
  ),
  QuickAccessTone.sun: _ToneStyle(
    start: Color(0xFFFFF6DC),
    end: Color(0xFFFFEBBA),
    badge: Color(0xFFF2B01E),
  ),
  QuickAccessTone.sky: _ToneStyle(
    start: Color(0xFFE6EFF9),
    end: Color(0xFFD3E4F4),
    badge: Color(0xFF2F6FA3),
  ),
};

/// Tarjeta de acceso rápido del dashboard.
///
/// Ubicación: presentation/screens/home/widgets/quick_access_tile.dart
///
/// Mantiene los parámetros anteriores (`icon`, `label`, `onTap`), así que
/// las llamadas existentes siguen compilando; `subtitle` y `tone` son nuevos.
class QuickAccessTile extends StatelessWidget {
  const QuickAccessTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.tone = QuickAccessTone.mint,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;
  final QuickAccessTone tone;

  @override
  Widget build(BuildContext context) {
    final style = _tones[tone]!;
    final radius = BorderRadius.circular(22);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [style.start, style.end],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                width: 84,
                height: 72,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.35,
                    child: CustomPaint(painter: _DecorPainter(tone)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: style.badge,
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.splashOnColor,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.25,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.splashOnColor.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decoración de la esquina superior derecha, dibujada con código.
class _DecorPainter extends CustomPainter {
  const _DecorPainter(this.tone);

  final QuickAccessTone tone;

  void _leaf(
    Canvas canvas,
    Offset base,
    double len,
    double wid,
    double angle,
    Color color,
  ) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(len * 0.25, -wid * 0.7, len * 0.75, -wid * 0.55, len, 0)
      ..cubicTo(len * 0.75, wid * 0.55, len * 0.25, wid * 0.7, 0, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);

    canvas.drawLine(
      Offset(len * 0.05, 0),
      Offset(len * 0.9, 0),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    switch (tone) {
      case QuickAccessTone.mint:
        _leaf(
          canvas,
          Offset(w * 0.92, h * 0.95),
          58,
          26,
          -2.35,
          const Color(0xFF2E7D4F),
        );
        _leaf(
          canvas,
          Offset(w * 0.80, h * 1.0),
          50,
          22,
          -1.85,
          const Color(0xFF5FAE63),
        );
        _leaf(
          canvas,
          Offset(w * 1.0, h * 0.80),
          40,
          18,
          -2.9,
          const Color(0xFFA5D6A7),
        );

      case QuickAccessTone.lime:
        final stem = Offset(w * 0.78, h * 1.0);
        canvas.drawLine(
          stem,
          Offset(w * 0.78, h * 0.42),
          Paint()
            ..color = const Color(0xFF4C9A2A)
            ..strokeWidth = 2.5
            ..strokeCap = StrokeCap.round,
        );
        _leaf(
          canvas,
          Offset(w * 0.78, h * 0.66),
          38,
          17,
          -2.5,
          const Color(0xFF4C9A2A),
        );
        _leaf(
          canvas,
          Offset(w * 0.78, h * 0.50),
          44,
          19,
          -0.65,
          const Color(0xFF6DBE45),
        );
        _leaf(
          canvas,
          Offset(w * 0.78, h * 0.86),
          30,
          14,
          -0.35,
          const Color(0xFF8CD06A),
        );

      case QuickAccessTone.sun:
        canvas.drawCircle(
          Offset(w * 0.85, h * 0.42),
          34,
          Paint()..color = const Color(0xFFFFE08A).withValues(alpha: 0.65),
        );
        _leaf(
          canvas,
          Offset(w * 0.95, h * 0.95),
          56,
          26,
          -2.2,
          const Color(0xFF4C9A2A),
        );

      case QuickAccessTone.sky:
        final far = Path()
          ..moveTo(0, h * 0.80)
          ..quadraticBezierTo(w * 0.30, h * 0.35, w * 0.62, h * 0.62)
          ..quadraticBezierTo(w * 0.85, h * 0.78, w, h * 0.45)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close();
        canvas.drawPath(
          far,
          Paint()..color = const Color(0xFF9CC3E4).withValues(alpha: 0.8),
        );
        final near = Path()
          ..moveTo(w * 0.15, h)
          ..quadraticBezierTo(w * 0.50, h * 0.55, w, h * 0.75)
          ..lineTo(w, h)
          ..close();
        canvas.drawPath(
          near,
          Paint()..color = const Color(0xFFBBD7EE).withValues(alpha: 0.9),
        );
        canvas.drawCircle(
          Offset(w * 0.30, h * 0.28),
          8,
          Paint()..color = Colors.white.withValues(alpha: 0.7),
        );
    }
  }

  @override
  bool shouldRepaint(covariant _DecorPainter old) => old.tone != tone;
}
