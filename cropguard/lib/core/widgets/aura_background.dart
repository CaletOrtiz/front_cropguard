import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Fondo tipo "aura" con un amplio recorrido dinámico por la pantalla.
class AuraBackground extends StatefulWidget {
  const AuraBackground({
    super.key,
    this.backgroundColor = const Color(0xFFF7F6F2),
  });

  final Color backgroundColor;

  @override
  State<AuraBackground> createState() => _AuraBackgroundState();
}

class _AuraBackgroundState extends State<AuraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _blobs = [
    _BlobSpec(
      size: 280,
      color: Color(0xFFF3D77B), // amarillo cálido
      speedX: 1.0,
      speedY: 0.7,
      phaseX: 0.0,
      phaseY: 1.2,
    ),
    _BlobSpec(
      size: 250,
      color: Color(0xFFB7E4C7), // verde menta
      speedX: 0.6,
      speedY: 1.1,
      phaseX: 2.1,
      phaseY: 0.5,
    ),
    _BlobSpec(
      size: 260,
      color: Color(0xFFE7BEE0), // rosa suave
      speedX: 0.8,
      speedY: 0.5,
      phaseX: 4.0,
      phaseY: 3.1,
    ),
    _BlobSpec(
      size: 230,
      color: Color(0xFFA9D8C2), // verde claro
      speedX: 1.2,
      speedY: 0.9,
      phaseX: 1.5,
      phaseY: 4.8,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Se aumentó a 12 segundos para un recorrido amplio pero suave
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: widget.backgroundColor),
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 75, sigmaY: 75),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value * 2 * math.pi;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight;

                    return Stack(
                      children: _blobs.map((blob) {
                        // Cálculo de posición normalizada en pantalla [0.0, 1.0]
                        final normalizedX =
                            0.5 +
                            0.45 * math.sin(t * blob.speedX + blob.phaseX);
                        final normalizedY =
                            0.5 +
                            0.45 * math.cos(t * blob.speedY + blob.phaseY);

                        // Mapeo a los píxeles reales restando el centro de cada blob
                        final posX = (normalizedX * width) - (blob.size / 2);
                        final posY = (normalizedY * height) - (blob.size / 2);

                        return Positioned(
                          left: posX,
                          top: posY,
                          child: Container(
                            width: blob.size,
                            height: blob.size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: blob.color,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _BlobSpec {
  const _BlobSpec({
    required this.size,
    required this.color,
    required this.speedX,
    required this.speedY,
    required this.phaseX,
    required this.phaseY,
  });

  final double size;
  final Color color;
  final double speedX; // velocidad horizontal
  final double speedY; // velocidad vertical
  final double phaseX; // desfase inicial horizontal
  final double phaseY; // desfase inicial vertical
}
