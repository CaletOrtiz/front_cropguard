import 'package:flutter/material.dart';
import 'package:cropguard/core/constants/app_colors.dart';

/// Wordmark de Kroppi: texto "Kropp" + una "i" personalizada,
/// donde el punto se reemplaza por una hoja.
class KroppiWordmark extends StatelessWidget {
  const KroppiWordmark({
    super.key,
    this.fontSize = 32,
    this.textColor = AppColors.primaryDark,
    this.leafColor = AppColors.primary,
  });

  final double fontSize;
  final Color textColor;
  final Color leafColor;

  @override
  Widget build(BuildContext context) {
    final stemHeight = fontSize * 0.5;
    final stemWidth = fontSize * 0.1;
    final leafSize = fontSize * 0.42;
    final gap = fontSize * 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Kropp',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: textColor,
            height: 1,
          ),
        ),
        SizedBox(width: gap),
        // "i" personalizada: barra + hoja en vez del punto
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: -0.5,
              child: Icon(Icons.eco_rounded, size: leafSize, color: leafColor),
            ),
            SizedBox(height: fontSize * 0.04),
            Container(
              width: stemWidth,
              height: stemHeight,
              decoration: BoxDecoration(
                color: textColor,
                borderRadius: BorderRadius.circular(stemWidth),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Reproduce una animación de "escritura" (reveal de izquierda a derecha)
/// sobre KroppiWordmark, una sola vez al construirse.
class AnimatedKroppiWordmark extends StatefulWidget {
  const AnimatedKroppiWordmark({
    super.key,
    this.fontSize = 32,
    this.textColor = AppColors.primaryDark,
    this.leafColor = AppColors.primary,
    this.duration = const Duration(milliseconds: 900),
    this.delay = Duration.zero,
    this.onComplete,
  });

  final double fontSize;
  final Color textColor;
  final Color leafColor;
  final Duration duration;
  final Duration delay;
  final VoidCallback? onComplete;

  @override
  State<AnimatedKroppiWordmark> createState() => _AnimatedKroppiWordmarkState();
}

class _AnimatedKroppiWordmarkState extends State<AnimatedKroppiWordmark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _reveal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _reveal = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    if (widget.onComplete != null) {
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onComplete!();
      });
    }

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _reveal,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: _reveal.value,
            child: child,
          ),
        );
      },
      child: KroppiWordmark(
        fontSize: widget.fontSize,
        textColor: widget.textColor,
        leafColor: widget.leafColor,
      ),
    );
  }
}
