import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';

/// حالت‌های احساسی ماسکٔ رابط «فِلَک».
enum MascotMood { happy, sleepy, confused, cheering }

/// ماسکٔ برداریِ دوبعدی با سایه‌روشن شبه‌سه‌بعدی؛ مدل mesh یا رندر واقعی 3D نیست.
/// فِلَک پلک می‌زند، آرام شناور می‌شود و در نقاط منتخب به لمس واکنش کوتاه دارد.
/// با «کاهش حرکت» انیمیشن‌ها متوقف و همهٔ Tickerها در dispose آزاد می‌شوند.
class KartoniyaMascot extends StatefulWidget {
  const KartoniyaMascot({
    super.key,
    this.mood = MascotMood.happy,
    this.size = 96,
    this.accent = AppColors.sky,
    this.float = true,
    this.reactToTouch = false,
  });

  final MascotMood mood;
  final double size;
  final Color accent;

  /// شناور شدن عمودی آرام؛ در بنرها بهتر است روشن باشد.
  final bool float;

  /// واکنش لمسِ تزئینی و کوتاه؛ بدون تغییر مسیر یا وضعیت محتوای برنامه.
  final bool reactToTouch;

  @override
  State<KartoniyaMascot> createState() => _KartoniyaMascotState();
}

class _KartoniyaMascotState extends State<KartoniyaMascot>
    with TickerProviderStateMixin {
  late final AnimationController _blink;
  late final AnimationController _bob;
  late final AnimationController _tap;
  late final Animation<double> _tapScale;
  late Animation<double> _bobAnimation;
  late bool _motionEnabled;

  @override
  void initState() {
    super.initState();
    _motionEnabled = !MotionScope.reducedGlobally;
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _bob = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    _tap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _tapScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: .92).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: .92, end: 1.06).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.06, end: 1.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 40,
      ),
    ]).animate(_tap);
    _bobAnimation = _createBobAnimation();
    if (_motionEnabled) _startMotion();
  }

  Animation<double> _createBobAnimation() =>
      Tween<double>(begin: 0, end: -widget.size * .045).animate(
        CurvedAnimation(parent: _bob, curve: Curves.easeInOut),
      );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = context.motion.enabled && TickerMode.of(context);
    if (enabled == _motionEnabled) return;
    _motionEnabled = enabled;
    if (enabled) {
      _startMotion();
    } else {
      _stopMotion();
    }
  }

  @override
  void didUpdateWidget(covariant KartoniyaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) _bobAnimation = _createBobAnimation();
    if (oldWidget.float != widget.float && _motionEnabled) {
      if (widget.float) {
        _bob.repeat(reverse: true);
      } else {
        _bob.stop();
        _bob.value = 0;
      }
    }
  }

  final _blinkRandom = math.Random();

  Timer? _blinkTimer;

  void _startMotion() {
    _scheduleBlink();
    if (widget.float && !_bob.isAnimating) _bob.repeat(reverse: true);
  }

  void _stopMotion() {
    _blinkTimer?.cancel();
    _blink.stop();
    _blink.value = 0;
    _bob.stop();
    _bob.value = 0;
    _tap.stop();
    _tap.value = 0;
  }

  void _reactToTouch() {
    if (!widget.reactToTouch) return;
    HapticFeedback.selectionClick();
    if (context.motion.enabled) _tap.forward(from: 0);
  }

  void _scheduleBlink() {
    _blinkTimer?.cancel();
    if (!mounted || !_motionEnabled) return;
    _blinkTimer = Timer(
      Duration(milliseconds: 1600 + _blinkRandom.nextInt(2600)),
      () async {
        if (!mounted || !_motionEnabled) return;
        try {
          await _blink.forward().orCancel;
          await _blink.reverse().orCancel;
        } catch (_) {
          // Disposing the controller or enabling reduced motion cancels a blink.
          return;
        }
        if (mounted && _motionEnabled) _scheduleBlink();
      },
    );
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _blink.dispose();
    _bob.dispose();
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // هر انیمیشن فقط لایهٔ خودش را rebuild می‌کند: bob و touch بارها در
    // فریم‌های حرکت به CustomPainter چشم/بدنه را دوباره نمی‌کشانند.
    final face = AnimatedBuilder(
      animation: _blink,
      builder: (context, _) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _MascotPainter(
            mood: widget.mood,
            accent: widget.accent,
            blink: _blink.value,
          ),
        ),
      ),
    );
    final tapVisual = AnimatedBuilder(
      animation: _tap,
      builder: (context, child) => Transform.scale(
        scale: _tapScale.value,
        child: child,
      ),
      child: face,
    );
    final visual = AnimatedBuilder(
      animation: _bob,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _bobAnimation.value),
        child: child,
      ),
      child: tapVisual,
    );

    return Semantics(
      label: widget.reactToTouch
          ? 'فِلَک؛ برای دیدن واکنش لمس کن'
          : 'شخصیت کارتونی فِلَک',
      image: !widget.reactToTouch,
      button: widget.reactToTouch,
      child: widget.reactToTouch
          ? GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _reactToTouch,
              child: visual,
            )
          : visual,
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
      ..shader = RadialGradient(
        center: const Alignment(-.38, -.52),
        radius: 1.18,
        colors: [
          Color.lerp(accent, Colors.white, .84)!,
          Color.lerp(accent, Colors.white, .4)!,
          accent,
          Color.lerp(accent, const Color(0xFF101627), .24)!,
        ],
        stops: const [0, .24, .7, 1],
      ).createShader(Offset.zero & size);

    // ابر: بدنهٔ پهن + برجستگی‌های گرد.
    final cloud = Path();
    cloud
      ..addOval(Rect.fromLTWH(w * .12, h * .34, w * .76, h * .5))
      ..addOval(Rect.fromLTWH(w * .06, h * .44, w * .34, h * .3))
      ..addOval(Rect.fromLTWH(w * .6, h * .42, w * .35, h * .32))
      ..addOval(Rect.fromLTWH(w * .3, h * .2, w * .42, h * .36));
    canvas.drawShadow(cloud, Colors.black.withOpacity(.16), 8, false);
    canvas.drawPath(cloud, bodyPaint);

    // نور شیشه‌ایِ لبهٔ بالا و سایهٔ نرم زیر بدنه، بدون bitmap یا blur اضافی.
    canvas.save();
    canvas.clipPath(cloud);
    final glossRect = Rect.fromLTWH(w * .16, h * .23, w * .66, h * .26);
    canvas.drawOval(
      glossRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(.38),
            Colors.white.withOpacity(.03),
          ],
        ).createShader(glossRect),
    );
    final shadeRect = Rect.fromLTWH(0, h * .47, w, h * .4);
    canvas.drawRect(
      shadeRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(.12),
          ],
        ).createShader(shadeRect),
    );
    canvas.drawOval(
      Rect.fromLTWH(w * .22, h * .31, w * .22, h * .045),
      Paint()..color = Colors.white.withOpacity(.32),
    );
    canvas.restore();

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
    final blush = Paint()..color = AppColors.pink.withOpacity(.4);
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
