import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';

/// نوار پیشرفت با انیمیشن نرمِ تغییر مقدار؛ وقتی درصد ادامهٔ تماشا از player
/// آپدیت می‌شود، جابه‌جایی مقدار محسوس و دوستانه است نه پرش ناگهانی.
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    required this.value,
    required this.color,
    super.key,
    this.height = 6,
    this.background,
  });

  final double value;
  final Color color;
  final double height;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final track = background ?? color.withOpacity(.16);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: context.motion.dur(AppMotion.soft),
        curve: AppMotion.curveStandard,
        builder: (context, animated, _) => SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: track),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FractionallySizedBox(
                  widthFactor: animated,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.lerp(color, Colors.white, .35)!,
                          color,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// حلقهٔ پیشرفت (برای کارت‌های «ادامهٔ تماشا» و شمارش معکوس قسمت بعد).
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.value,
    required this.color,
    super.key,
    this.size = 44,
    this.strokeWidth = 4.5,
    this.child,
    this.trackColor,
  });

  final double value;
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget? child;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: context.motion.dur(AppMotion.entrance),
        curve: AppMotion.curveEntrance,
        builder: (context, animated, inner) => CustomPaint(
          painter: _RingPainter(
            value: animated,
            color: color,
            track: trackColor ?? color.withOpacity(.18),
            strokeWidth: strokeWidth,
          ),
          foregroundPainter: null,
          child: inner,
        ),
        child: child,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.strokeWidth,
  });

  final double value;
  final Color color;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = track,
    );
    if (value <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.color != color ||
      oldDelegate.track != track ||
      oldDelegate.strokeWidth != strokeWidth;
}
