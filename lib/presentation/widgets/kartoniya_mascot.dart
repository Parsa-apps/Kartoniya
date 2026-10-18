import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';

/// حالت‌های احساسی ماسکٔ رابط «فِلَک».
enum MascotMood { happy, sleepy, confused, cheering }

/// ماسکٔ رابط کارتونیا: ابر کوچولوی «فِلَک» با پلک‌زدن و شناور شدن آرام.
///
/// برای نقاط حساس (خالی، خطا، موفقیت و اسپلش) استفاده می‌شود. همهٔ
/// انیمیشن‌ها با «کاهش حرکت» خاموش‌اند و Ticker در dispose آزاد می‌شود.
class KartoniyaMascot extends StatefulWidget {
  const KartoniyaMascot({
    super.key,
    this.mood = MascotMood.happy,
    this.size = 96,
    this.accent = AppColors.sky,
    this.float = true,
    this.onTap,
  });

  final MascotMood mood;
  final double size;
  final Color accent;

  /// شناور شدن عمودی آرام؛ در بنرها بهتر است روشن باشد.
  final bool float;

  /// اختیاری؛ شخصیت همیشه یک واکنش بصری کوتاه دارد، این callback برای
  /// اتصال واکنش به رفتار صفحه استفاده می‌شود.
  final VoidCallback? onTap;

  @override
  State<KartoniyaMascot> createState() => _KartoniyaMascotState();
}

class _KartoniyaMascotState extends State<KartoniyaMascot>
    with TickerProviderStateMixin {
  late final AnimationController _blink;
  late final AnimationController _bob;
  late final AnimationController _reaction;
  late final Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    _reaction = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _bobAnimation = Tween<double>(begin: 0, end: -widget.size * .045).animate(
      CurvedAnimation(parent: _bob, curve: Curves.easeInOut),
    );
    if (context.motionEnabledAtInit && widget.float) {
      _bob.repeat(reverse: true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant KartoniyaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.float != widget.float) _syncMotion();
  }

  void _syncMotion() {
    if (context.motion.enabled) {
      if (widget.float && !_bob.isAnimating) _bob.repeat(reverse: true);
      if (_blinkTimer == null) _scheduleBlink();
      return;
    }
    _bob.stop(canceled: false);
    _reaction.stop(canceled: false);
    _reaction.value = 0;
    _blinkTimer?.cancel();
    _blinkTimer = null;
    _blink.stop(canceled: false);
    _blink.value = 0;
  }

  void _reactToTap() {
    if (context.motion.enabled) _reaction.forward(from: 0);
    HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  final _blinkRandom = math.Random();

  Timer? _blinkTimer;

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    if (!mounted || !context.motion.enabled) return;
    _blinkTimer = Timer(
      Duration(milliseconds: 1600 + _blinkRandom.nextInt(2600)),
      () async {
        if (!mounted || !context.motion.enabled) return;
        try {
          await _blink.forward().orCancel;
          await _blink.reverse().orCancel;
        } catch (_) {
          // Disposing the controller cancels an in-flight blink.
          return;
        }
        if (mounted) _scheduleBlink();
      },
    );
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _blink.dispose();
    _bob.dispose();
    _reaction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'شخصیت کارتونی فِلَک',
      hint: 'برای دیدن واکنش فِلَک ضربه بزن',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _reactToTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_blink, _bob, _reaction]),
          builder: (context, _) {
            final bounce = math.sin(_reaction.value * math.pi);
            final tilt = math.sin(_reaction.value * math.pi * 2) * .035;
            return Transform.translate(
              offset: Offset(0, _bobAnimation.value - bounce * widget.size * .055),
              child: Transform.rotate(
                angle: tilt,
                child: Transform.scale(
                  scale: 1 + bounce * .085,
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: CustomPaint(
                      painter: _MascotPainter(
                        mood: _reaction.isAnimating
                            ? MascotMood.cheering
                            : widget.mood,
                        accent: widget.accent,
                        blink: _blink.value,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  const _MascotPainter({
    required this.mood,
    required this.accent,
    required this.blink,
  });

  final MascotMood mood;
  final Color accent;
  final double blink;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color.lerp(accent, Colors.white, .55)!,
          accent,
          Color.lerp(accent, const Color(0xFF101627), .2)!,
        ],
      ).createShader(Offset.zero & size);

    // ابر: بدنهٔ پهن + برجستگی‌های گرد.
    final cloud = Path();
    cloud
      ..addOval(Rect.fromLTWH(w * .12, h * .34, w * .76, h * .5))
      ..addOval(Rect.fromLTWH(w * .06, h * .44, w * .34, h * .3))
      ..addOval(Rect.fromLTWH(w * .6, h * .42, w * .35, h * .32))
      ..addOval(Rect.fromLTWH(w * .3, h * .2, w * .42, h * .36));
    // A small offset under-shell creates a soft toy-like extrusion without
    // pretending this vector artwork is a real-time 3D model.
    canvas.drawPath(
      cloud.shift(Offset(0, h * .035)),
      Paint()..color = Color.lerp(accent, const Color(0xFF17233B), .28)!,
    );
    canvas.drawShadow(cloud, Colors.black.withOpacity(.16), w * .09, false);
    canvas.drawPath(cloud, bodyPaint);

    canvas.save();
    canvas.clipPath(cloud);
    final surface = Offset.zero & size;
    canvas.drawRect(
      surface,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Color.lerp(accent, const Color(0xFF17233B), .34)!
                .withOpacity(.20),
          ],
          stops: const [.48, 1],
        ).createShader(surface),
    );
    final gloss = Rect.fromLTWH(w * .16, h * .24, w * .56, h * .22);
    canvas.drawOval(
      gloss,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withOpacity(.50), Colors.white.withOpacity(0)],
        ).createShader(gloss),
    );
    canvas.restore();
    canvas.drawPath(
      cloud,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .012
        ..color = Colors.white.withOpacity(.38),
    );

    final faceCenter = Offset(w * .5, h * .58);
    final eyeGap = w * .14;
    final eyeY = faceCenter.dy - h * .02;
    final eyePaint = Paint()..color = const Color(0xFF22304A);
    final eyeRadius = w * .045;

    void drawEye(Offset center) {
      if (mood == MascotMood.sleepy) {
        final line = Paint()
          ..color = const Color(0xFF22304A)
          ..strokeWidth = w * .022
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          center - Offset(eyeRadius, 0),
          center + Offset(eyeRadius, 0),
          line,
        );
        return;
      }
      final squish = 1 - blink * .92;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(1, squish.clamp(.08, 1).toDouble());
      canvas.drawCircle(Offset.zero, eyeRadius, eyePaint);
      canvas.restore();
      // هایلایت کوچک چشم.
      if (squish > .5) {
        canvas.drawCircle(
          center + Offset(eyeRadius * .35, -eyeRadius * .35),
          eyeRadius * .3,
          Paint()..color = Colors.white.withOpacity(.9),
        );
      }
    }

    drawEye(Offset(faceCenter.dx - eyeGap, eyeY));
    drawEye(Offset(faceCenter.dx + eyeGap, eyeY));

    // گونه‌ها.
    final blush = Paint()
      ..color = AppColors.pink.withOpacity(.4);
    canvas.drawCircle(
      Offset(faceCenter.dx - eyeGap * 2.05, eyeY + h * .05),
      w * .04,
      blush,
    );
    canvas.drawCircle(
      Offset(faceCenter.dx + eyeGap * 2.05, eyeY + h * .05),
      w * .04,
      blush,
    );

    // دهان بر اساس حال‌وهوا.
    final mouthPaint = Paint()
      ..color = const Color(0xFF22304A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .024
      ..strokeCap = StrokeCap.round;
    final mouthY = eyeY + h * .08;
    switch (mood) {
      case MascotMood.happy:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(faceCenter.dx, mouthY - h * .01),
            width: w * .16,
            height: h * .1,
          ),
          .15 * math.pi,
          .7 * math.pi,
          false,
          mouthPaint,
        );
      case MascotMood.cheering:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(faceCenter.dx, mouthY),
            width: w * .18,
            height: h * .12,
          ),
          0,
          math.pi,
          true,
          Paint()..color = const Color(0xFF22304A),
        );
      case MascotMood.sleepy:
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(faceCenter.dx + w * .03, mouthY),
            width: w * .1,
            height: h * .05,
          ),
          1.1 * math.pi,
          .8 * math.pi,
          false,
          mouthPaint,
        );
      case MascotMood.confused:
        final path = Path()
          ..moveTo(faceCenter.dx - w * .07, mouthY)
          ..quadraticBezierTo(
            faceCenter.dx - w * .02,
            mouthY - h * .035,
            faceCenter.dx + w * .03,
            mouthY,
          )
          ..quadraticBezierTo(
            faceCenter.dx + w * .06,
            mouthY + h * .03,
            faceCenter.dx + w * .08,
            mouthY - h * .005,
          );
        canvas.drawPath(path, mouthPaint);
    }

    // ستارهٔ کوچک کنار سر برای حالت تشویق.
    if (mood == MascotMood.cheering) {
      final star = Paint()..color = AppColors.gold;
      for (final offset in [
        Offset(w * .12, h * .2),
        Offset(w * .86, h * .16),
      ]) {
        final path = Path();
        for (var point = 0; point < 10; point++) {
          final angle = point * math.pi / 5 - math.pi / 2;
          final radius = point.isEven ? w * .05 : w * .02;
          final position = offset +
              Offset(radius * math.cos(angle), radius * math.sin(angle));
          if (point == 0) {
            path.moveTo(position.dx, position.dy);
          } else {
            path.lineTo(position.dx, position.dy);
          }
        }
        path.close();
        canvas.drawPath(path, star);
      }
    }
  }

  @override
  bool shouldRepaint(_MascotPainter oldDelegate) =>
      oldDelegate.blink != blink ||
      oldDelegate.mood != mood ||
      oldDelegate.accent != accent;
}
