import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';

/// پس‌زمینهٔ چندلایهٔ کارتونیا: هاله‌های رنگی نرم که بسیار آهسته شناورند.
///
/// یک Ticker مشترک دارد، هنگام خروج از صفحه (route غیرفعال) توسط TickerMode
/// متوقف می‌شود و با «کاهش حرکت» کاملاً ثابت می‌ماند. blur واقعی انجام
/// نمی‌دهد تا روی گوشی‌های ضعیف هم روان باشد.
class AuroraBackground extends StatefulWidget {
  const AuroraBackground({
    required this.child,
    super.key,
    this.tint,
  });

  final Widget child;
  final Color? tint;

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    );
    if (context.motionEnabledAtInit) _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  void _syncMotion() {
    if (context.motion.enabled) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop(canceled: false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? const [
                      Color(0xFF121B31),
                      AppColors.darkBackground,
                      Color(0xFF0C1322),
                    ]
                  : const [
                      Color(0xFFEAF5FF),
                      AppColors.lightBackground,
                      Color(0xFFF6FBFF),
                    ],
            ),
          ),
        ),
        IgnorePointer(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _AuroraPainter(
                  t: _controller.value,
                  isDark: isDark,
                  tint: widget.tint,
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _AuroraBlob {
  const _AuroraBlob({
    required this.color,
    required this.baseX,
    required this.baseY,
    required this.radius,
    required this.phase,
    required this.driftX,
    required this.driftY,
  });

  final Color color;
  final double baseX;
  final double baseY;
  final double radius;
  final double phase;
  final double driftX;
  final double driftY;
}

class _AuroraPainter extends CustomPainter {
  const _AuroraPainter({
    required this.t,
    required this.isDark,
    required this.tint,
  });

  final double t;
  final bool isDark;
  final Color? tint;

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = isDark ? .11 : .16;
    final blobs = <_AuroraBlob>[
      _AuroraBlob(
        color: (tint ?? AppColors.skyLight).withOpacity(alpha),
        baseX: .82,
        baseY: .1,
        radius: .62,
        phase: 0,
        driftX: .05,
        driftY: .04,
      ),
      _AuroraBlob(
        color: AppColors.tealLight.withOpacity(alpha * .9),
        baseX: .1,
        baseY: .32,
        radius: .5,
        phase: 2.1,
        driftX: .06,
        driftY: .05,
      ),
      _AuroraBlob(
        color: AppColors.violetLight.withOpacity(alpha * .8),
        baseX: .9,
        baseY: .78,
        radius: .58,
        phase: 4.2,
        driftX: .045,
        driftY: .05,
      ),
      _AuroraBlob(
        color: AppColors.coralLight.withOpacity(alpha * .65),
        baseX: .22,
        baseY: .96,
        radius: .44,
        phase: 1.2,
        driftX: .05,
        driftY: .035,
      ),
    ];

    final angle = t * 2 * math.pi;
    for (final blob in blobs) {
      final dx = (blob.baseX + math.sin(angle + blob.phase) * blob.driftX) *
          size.width;
      final dy = (blob.baseY + math.cos(angle + blob.phase) * blob.driftY) *
          size.height;
      final r = blob.radius * size.shortestSide;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [blob.color, blob.color.withOpacity(0)],
          stops: const [0, 1],
        ).createShader(Rect.fromCircle(center: Offset(dx, dy), radius: r));
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.isDark != isDark ||
      oldDelegate.tint != tint;
}
