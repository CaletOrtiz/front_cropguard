import 'package:flutter/material.dart';
import 'package:kroppi/core/constants/app_colors.dart';

/// Solo la marca: hoja + barra (la "i" de Kroppi), sin el resto del texto.
class KroppiMark extends StatelessWidget {
  const KroppiMark({
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
    final stemWidth = fontSize * 0.09;
    final leafSize = fontSize * 0.42;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(stemWidth * 0.3, fontSize * 0.06),
          child: Transform.rotate(
            angle: -0.5,
            child: Icon(Icons.eco_rounded, size: leafSize, color: leafColor),
          ),
        ),
        SizedBox(height: fontSize * 0.01),
        Container(
          width: stemWidth,
          height: stemHeight,
          decoration: BoxDecoration(
            color: textColor,
            borderRadius: BorderRadius.circular(stemWidth),
          ),
        ),
      ],
    );
  }
}

/// Wordmark completo: "Kropp" + KroppiMark, estático (sin animación).
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
    final gap = fontSize * 0.02;

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
        KroppiMark(
          fontSize: fontSize,
          textColor: textColor,
          leafColor: leafColor,
        ),
      ],
    );
  }
}

/// Secuencia de intro: 1) solo la marca, grande y centrada; 2) un
/// crossfade con leve escala hacia el wordmark completo; 3) el eslogan
/// aparece debajo. Todo se centra de forma natural (sin medir anchos).
class KroppiIntroAnimation extends StatefulWidget {
  const KroppiIntroAnimation({
    super.key,
    this.fontSize = 48,
    this.textColor = AppColors.primaryDark,
    this.leafColor = AppColors.primary,
    this.iconOnlyScale = 2.2,
    this.slogan,
    this.sloganStyle,
    this.holdDuration = const Duration(milliseconds: 600),
    this.writeDuration = const Duration(milliseconds: 500),
    this.sloganDuration = const Duration(milliseconds: 400),
    this.startDelay = const Duration(milliseconds: 150),
  });

  final double fontSize;
  final Color textColor;
  final Color leafColor;
  final double iconOnlyScale;
  final String? slogan;
  final TextStyle? sloganStyle;
  final Duration holdDuration;
  final Duration writeDuration;
  final Duration sloganDuration;
  final Duration startDelay;

  @override
  State<KroppiIntroAnimation> createState() => _KroppiIntroAnimationState();
}

class _KroppiIntroAnimationState extends State<KroppiIntroAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _markOpacity;
  late final Animation<double> _markScale;
  late final Animation<double> _wordOpacity;
  late final Animation<double> _wordScale;
  late final Animation<double> _sloganOpacity;

  @override
  void initState() {
    super.initState();

    final holdMs = widget.holdDuration.inMilliseconds;
    final writeMs = widget.writeDuration.inMilliseconds;
    final sloganMs = widget.sloganDuration.inMilliseconds;
    final totalMs = holdMs + writeMs + sloganMs;
    final safeTotal = totalMs == 0 ? 1 : totalMs;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: safeTotal),
    );

    final holdEnd = holdMs / safeTotal;
    final writeEnd = (holdMs + writeMs) / safeTotal;

    final crossfade = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        holdEnd,
        writeEnd.clamp(holdEnd, 1.0),
        curve: Curves.easeInOutCubic,
      ),
    );

    _markOpacity = Tween(begin: 1.0, end: 0.0).animate(crossfade);
    _markScale = Tween(begin: widget.iconOnlyScale, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          holdEnd,
          writeEnd.clamp(holdEnd, 1.0),
          curve: Curves.easeInOutCubic,
        ),
      ),
    );

    _wordOpacity = Tween(begin: 0.0, end: 1.0).animate(crossfade);
    _wordScale = Tween(begin: 0.92, end: 1.0).animate(crossfade);

    _sloganOpacity = CurvedAnimation(
      parent: _controller,
      curve: Interval(writeEnd.clamp(0.0, 1.0), 1.0, curve: Curves.easeOut),
    );

    Future.delayed(widget.startDelay, () {
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
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Wordmark completo
                    Opacity(
                      opacity: _wordOpacity.value,
                      child: Transform.scale(
                        scale: _wordScale.value,
                        child: KroppiWordmark(
                          fontSize: widget.fontSize,
                          textColor: widget.textColor,
                          leafColor: widget.leafColor,
                        ),
                      ),
                    ),

                    // Marca sola (hoja + barra)
                    Opacity(
                      opacity: _markOpacity.value,
                      child: Transform.scale(
                        scale: _markScale.value,
                        child: KroppiMark(
                          fontSize: widget.fontSize,
                          textColor: widget.textColor,
                          leafColor: widget.leafColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          if (widget.slogan != null) ...[
            const SizedBox(height: 8),

            FadeTransition(
              opacity: _sloganOpacity,
              child: Text(
                widget.slogan!,
                textAlign: TextAlign.center,
                style: widget.sloganStyle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
