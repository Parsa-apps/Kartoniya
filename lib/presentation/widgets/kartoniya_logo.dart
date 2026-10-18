import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';

/// نشان برند کارتونیا؛ کاملاً برداری تا در اسپلش، هدر و دربارهٔ ما بدون
/// asset و با هر تراکم پیکسلی تیز بماند.
class KartoniyaLogoMark extends StatelessWidget {
  const KartoniyaLogoMark({
    super.key,
    this.size = 56,
    this.gradient,
    this.showOrbit = false,
  });

  final double size;
  final Gradient? gradient;

  /// دو نقطهٔ در حال چرخش دور لوگو؛ فقط در اسپلش/هالهٔ برند استفاده شود.
  final bool showOrbit;

  @override
  Widget build(BuildContext context) {
    final paintGradient = gradient ?? AppColors.skyGradient;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showOrbit) _LogoOrbits(size: size),
          CustomPaint(
            size: Size.square(size),
            painter: _LogoPainter(gradient: paintGradient, corner: size * .3),
          ),
        ],
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter({required this.gradient, required this.corner});

  final Gradient gradient;
  final double corner;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(corner));
    canvas.drawRRect(
      rrect.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withOpacity(.14),
    );
    canvas.drawRRect(
      rrect,
      Paint()..shader = gradient.createShader(rect),
    );

    // هایلایت شیشه‌ای بالای نشان.
    final highlight = Path.combine(
      PathOperation.intersect,
      Path()..addRRect(rrect),
      Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(size.width / 2, -size.height * .1),
            width: size.width * 1.4,
            height: size.height * .8,
          ),
        ),
    );
    canvas.drawPath(highlight, Paint()..color = Colors.white.withOpacity(.16));

    // دایرهٔ مرکزی + مثلث پخش.
    final center = rect.center;
    canvas.drawCircle(
      center,
      size.width * .27,
      Paint()..color = Colors.white.withOpacity(.95),
    );
    final play = Path()
      ..moveTo(center.dx + size.width * .105, center.dy)
      ..lineTo(center.dx - size.width * .05, center.dy - size.width * .1)
      ..lineTo(center.dx - size.width * .05, center.dy + size.width * .1)
      ..close();
    canvas.drawPath(
      play,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.coral, AppColors.coralDeep],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) =>
      oldDelegate.gradient != gradient || oldDelegate.corner != corner;
}

class _LogoOrbits extends StatefulWidget {
  const _LogoOrbits({required this.size});

  final double size;

  @override
  State<_LogoOrbits> createState() => _LogoOrbitsState();
}

class _LogoOrbitsState extends State<_LogoOrbits>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
    if (context.motionEnabledFallback) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        Widget dot(double phase, double radius, Color color, double dotSize) {
          final angle = (t + phase) * 2 * math.pi;
          return Positioned(
            left: widget.size / 2 + radius * math.cos(angle) - dotSize / 2,
            top: widget.size / 2 + radius * math.sin(angle) * .82 - dotSize / 2,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          );
        }

        return Stack(
          children: [
            dot(0, widget.size * .58, AppColors.gold, widget.size * .085),
            dot(.5, widget.size * .62, AppColors.pink, widget.size * .07),
          ],
        );
      },
    );
  }
}

extension on BuildContext {
  /// در initState نمی‌توان از InheritedWidget خواند؛ flag ایستای MotionScope
  /// توسط ریشهٔ برنامه نگه‌داشته می‌شود.
  bool get motionEnabledFallback => !MotionScope.reducedGlobally;
}
