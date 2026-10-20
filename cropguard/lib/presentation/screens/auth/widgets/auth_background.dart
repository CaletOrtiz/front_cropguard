import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';

/// Fondo de las pantallas de autenticación: degradado lima, hojas que se
/// mecen suavemente y paisaje con tractor al pie.
class AuthBackground extends StatefulWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AuthBackground> createState() => _AuthBackgroundState();
}

class _AuthBackgroundState extends State<AuthBackground>
    with SingleTickerProviderStateMixin {
  /// Duración de un balanceo completo de las hojas (se repite en bucle).
  static const _cycle = Duration(seconds: 6);

  /// Balanceos completos por ciclo. Debe ser un entero para que el bucle
  /// no tenga saltos.
  static const _swayCycles = 1;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _cycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respeta el ajuste de accesibilidad "reducir movimiento".
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.4;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _leaf({
    required double width,
    required double height,
    required double angle,
    required Color color,
    double phase = 0,
    double sway = 0.06,
  }) {
    return _Leaf(
      animation: _controller,
      swayCycles: _swayCycles,
      width: width,
      height: height,
      angle: angle,
      color: color,
      phase: phase,
      sway: sway,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Stack(
        children: [
          // Degradado
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFB9EF7C), AppColors.splashBackground],
                ),
              ),
            ),
          ),

          // Hojas arriba a la derecha
          Positioned(
            top: -6,
            right: -34,
            child: _leaf(
              width: 140,
              height: 62,
              angle: 2.25,
              color: const Color(0xFF3F7D1F),
              phase: 0.0,
            ),
          ),
          Positioned(
            top: 34,
            right: -28,
            child: _leaf(
              width: 110,
              height: 50,
              angle: 1.55,
              color: AppColors.splashOnColor,
              phase: 0.35,
            ),
          ),
          Positioned(
            top: 6,
            right: 48,
            child: _leaf(
              width: 70,
              height: 32,
              angle: 2.7,
              color: const Color(0xFFD2F5A8),
              phase: 0.7,
              sway: 0.09,
            ),
          ),

          // Paisaje al pie
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 170,
            child: CustomPaint(painter: _LandscapePainter()),
          ),

          // Tractor (estático)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 74,
            child: Center(
              child: Icon(
                Icons.agriculture_rounded,
                size: 36,
                color: AppColors.splashOnColor,
              ),
            ),
          ),

          // Hojas de las esquinas inferiores
          Positioned(
            bottom: -14,
            left: -34,
            child: _leaf(
              width: 150,
              height: 72,
              angle: -0.85,
              color: AppColors.splashOnColor,
              phase: 0.15,
            ),
          ),
          Positioned(
            bottom: 8,
            left: -20,
            child: _leaf(
              width: 90,
              height: 42,
              angle: -1.5,
              color: const Color(0xFF3F7D1F),
              phase: 0.55,
              sway: 0.08,
            ),
          ),
          Positioned(
            bottom: -14,
            right: -34,
            child: _leaf(
              width: 150,
              height: 72,
              angle: -2.3,
              color: AppColors.splashOnColor,
              phase: 0.45,
            ),
          ),
          Positioned(
            bottom: 14,
            right: -16,
            child: _leaf(
              width: 80,
              height: 38,
              angle: -1.7,
              color: const Color(0xFF5E9E2E),
              phase: 0.85,
              sway: 0.08,
            ),
          ),

          SafeArea(child: widget.child),
        ],
      ),
    );
  }
}

/// Hoja que oscila alrededor de su base (el tallo), no de su centro.
class _Leaf extends StatelessWidget {
  const _Leaf({
    required this.animation,
    required this.swayCycles,
    required this.width,
    required this.height,
    required this.angle,
    required this.color,
    required this.phase,
    required this.sway,
  });

  final Animation<double> animation;
  final int swayCycles;
  final double width;
  final double height;

  /// Ángulo base (posición de reposo) de la hoja.
  final double angle;
  final Color color;

  /// Desfase del balanceo (0..1) para que no se muevan todas a la vez.
  final double phase;

  /// Amplitud del balanceo en radianes.
  final double sway;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final t = animation.value;
          final a = math.sin(2 * math.pi * (t * swayCycles + phase)) * sway;
          return Transform.rotate(
            angle: a,
            alignment: Alignment.centerLeft,
            child: child,
          );
        },
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(painter: _LeafPainter(color)),
        ),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  const _LeafPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, h * 0.5)
      ..cubicTo(w * 0.25, -h * 0.15, w * 0.75, -h * 0.05, w, h * 0.5)
      ..cubicTo(w * 0.75, h * 1.05, w * 0.25, h * 1.15, 0, h * 0.5)
      ..close();

    canvas.drawPath(path, Paint()..color = color);

    // Nervadura central
    canvas.drawLine(
      Offset(w * 0.04, h * 0.5),
      Offset(w * 0.92, h * 0.5),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = math.max(1.2, h * 0.04)
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LeafPainter old) => old.color != color;
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter();

  @override
  void paint(Canvas canvas, Size s) {
    // Colina del fondo
    final back = Path()
      ..moveTo(0, s.height * 0.50)
      ..quadraticBezierTo(
        s.width * 0.22,
        s.height * 0.18,
        s.width * 0.48,
        s.height * 0.42,
      )
      ..quadraticBezierTo(
        s.width * 0.75,
        s.height * 0.62,
        s.width,
        s.height * 0.28,
      )
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFF94D14E));

    // Colina intermedia
    final mid = Path()
      ..moveTo(0, s.height * 0.62)
      ..quadraticBezierTo(
        s.width * 0.30,
        s.height * 0.40,
        s.width * 0.62,
        s.height * 0.58,
      )
      ..quadraticBezierTo(
        s.width * 0.85,
        s.height * 0.70,
        s.width,
        s.height * 0.52,
      )
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    canvas.drawPath(mid, Paint()..color = const Color(0xFF7DBA3D));

    // Campo frontal
    final front = Path()
      ..moveTo(0, s.height * 0.78)
      ..quadraticBezierTo(
        s.width * 0.50,
        s.height * 0.52,
        s.width,
        s.height * 0.76,
      )
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    canvas.drawPath(front, Paint()..color = const Color(0xFF649F2E));

    // Surcos del campo
    final furrow = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 1; i <= 3; i++) {
      final y = s.height * (0.74 + i * 0.065);
      final p = Path()
        ..moveTo(0, y + 6)
        ..quadraticBezierTo(s.width * 0.5, y - 14, s.width, y + 6);
      canvas.drawPath(p, furrow);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
