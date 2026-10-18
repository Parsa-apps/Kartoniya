import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';

/// حالت‌های احساسی ماسکٔ رابط «فِلَک».
enum MascotMood { happy, sleepy, confused, cheering }

/// نسخهٔ برداریِ «فِلَک» برای حالت‌های رابط (خالی، خطا، موفقیت و اسپلش).
///
/// هویت بصری از تصویر پیش‌رندرشدهٔ برند گرفته شده است: بدن ابریِ کرم،
/// کاکل فیروزه‌ای، چشم‌های درشت آبی، شال مرجانی و ستارهٔ طلایی. این یک
/// نقاشی دوبعدی با سایه‌پردازی شبه‌سه‌بعدی است و **مدل سه‌بعدی یا رندر
/// بلادرنگ نیست**؛ تصویر `flak_3d.webp` همان نسخهٔ از پیش‌رندرشده است.
///
/// انیمیشن‌ها محدود و هدفمندند: پلک‌زدن نامنظم، شناوری آرام و واکنش کوتاه
/// به لمس. با «کاهش حرکت» همهٔ Tickerها می‌ایستند و تصویر ثابت می‌ماند؛
/// هر Timer/Controller در dispose آزاد می‌شود.
class KartoniyaMascot extends StatefulWidget {
  const KartoniyaMascot({
    super.key,
    this.mood = MascotMood.happy,
    this.size = 96,
    this.accent = AppColors.sky,
    this.float = true,
    this.onTap,
    this.semanticLabel = 'شخصیت کارتونی فِلَک',
    this.interactive = true,
  });

  final MascotMood mood;
  final double size;
  final Color accent;

  /// شناور شدن عمودی آرام؛ در بنرها بهتر است روشن باشد.
  final bool float;

  /// اختیاری؛ شخصیت همیشه یک واکنش بصری کوتاه دارد، این callback برای
  /// اتصال واکنش به رفتار صفحه استفاده می‌شود.
  final VoidCallback? onTap;

  final String semanticLabel;

  /// اگر false باشد، لمس و semantics دکمه حذف می‌شوند (برای تصویر تزئینی).
  final bool interactive;

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
      duration: const Duration(milliseconds: 560),
    );
    _bobAnimation = Tween<double>(begin: 0, end: -widget.size * .04).animate(
      CurvedAnimation(parent: _bob, curve: Curves.easeInOut),
    );
    // در initState دسترسی به MediaQuery مجاز نیست؛ فقط snapshot ایستای
    // کاهش حرکت خوانده می‌شود و didChangeDependencies آن را به‌روز می‌کند.
    _motionEnabled = context.motionEnabledAtInit;
    if (_motionEnabled && widget.float) {
      _bob.repeat(reverse: true);
    }
    if (_motionEnabled) _scheduleBlink();
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
    _motionEnabled = context.motion.enabled;
    if (_motionEnabled) {
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
    if (_motionEnabled) _reaction.forward(from: 0);
    HapticFeedback.selectionClick();
    widget.onTap?.call();
  }

  final _blinkRandom = math.Random();

  Timer? _blinkTimer;
  bool _motionEnabled = true;

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
    final character = AnimatedBuilder(
      animation: Listenable.merge([_blink, _bob, _reaction]),
      builder: (context, _) {
        final bounce = math.sin(_reaction.value * math.pi);
        final tilt = math.sin(_reaction.value * math.pi * 2) * .035;
        return Transform.translate(
          offset: Offset(0, _bobAnimation.value - bounce * widget.size * .06),
          child: Transform.rotate(
            angle: tilt,
            child: Transform.scale(
              scale: 1 + bounce * .085,
              child: RepaintBoundary(
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
                      reaction: _reaction.value,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!widget.interactive) {
      return Semantics(
        image: true,
        label: widget.semanticLabel,
        child: ExcludeSemantics(child: character),
      );
    }

    return Semantics(
      // `container` keeps the character in its own accessibility node so a
      // screen reader announces it as one tappable item instead of merging it
      // into the surrounding content.
      container: true,
      button: true,
      label: widget.semanticLabel,
      hint: 'برای دیدن واکنش فِلَک ضربه بزن',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _reactToTap,
        child: character,
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  const _MascotPainter({
    required this.mood,
    required this.accent,
    required this.blink,
    required this.reaction,
  });

  final MascotMood mood;
  final Color accent;
  final double blink;
  final double reaction;

  static const _ink = Color(0xFF23324D);
  static const _cream = Color(0xFFFFF8EA);
  static const _creamShade = Color(0xFFF3E2C6);
  static const _hair = Color(0xFF63C7D6);
  static const _hairDeep = Color(0xFF2E9FB5);
  static const _scarf = Color(0xFFFF8063);
  static const _scarfDeep = Color(0xFFE05B43);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // شخصیت در کادر ۱x۱ با حاشیهٔ امن ۴٪ رسم می‌شود.
    final s = math.min(w, h) * .92;
    final dx = (w - s) / 2;
    final dy = (h - s) / 2;
    canvas.save();
    canvas.translate(dx, dy);

    // هالهٔ رنگ برند پشت شخصیت؛ accent را به سطح صفحه وصل می‌کند.
    final auraRect = Rect.fromCenter(
      center: Offset(s * .5, s * .55),
      width: s * .98,
      height: s * .98,
    );
    canvas.drawCircle(
      auraRect.center,
      auraRect.width / 2,
      Paint()
        ..shader = RadialGradient(
          colors: [
            accent.withOpacity(.16),
            accent.withOpacity(0),
          ],
          stops: const [.55, 1],
        ).createShader(auraRect),
    );

    // هالهٔ رنگ برند پشت شخصیت؛ accent را به سطح صفحه وصل می‌کند.
    final aura = Rect.fromCenter(
      center: Offset(s * .5, s * .56),
      width: s * 1.02,
      height: s * 1.02,
    );
    canvas.drawCircle(
      aura.center,
      aura.width / 2,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withOpacity(.16), accent.withOpacity(0)],
          stops: const [.5, 1],
        ).createShader(aura),
    );

    // ——— سایهٔ زمین (بسیار نرم، بدون blur سنگین) ———
    final groundRect = Rect.fromCenter(
      center: Offset(s * .5, s * .95),
      width: s * .52,
      height: s * .07,
    );
    canvas.drawOval(
      groundRect,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.black.withOpacity(.16), Colors.transparent],
        ).createShader(groundRect),
    );

    final cloud = _cloudPath(s);
    // بدنهٔ زیرین برای حس اسباب‌بازی، سپس بدنهٔ اصلی.
    canvas.drawPath(
      cloud.shift(Offset(0, s * .035)),
      Paint()..color = Color.lerp(_creamShade, const Color(0xFF17233B), .22)!,
    );
    canvas.drawShadow(cloud, Colors.black.withOpacity(.14), s * .06, false);
    final bodyRect = Rect.fromLTWH(0, 0, s, s);
    canvas.drawPath(
      cloud,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_cream, Color(0xFFFFF1DA), _creamShade],
          stops: [0, .55, 1],
        ).createShader(bodyRect),
    );

    // لایه‌های حجم: سایهٔ پایین و درخشش بالا.
    canvas.save();
    canvas.clipPath(cloud);
    final lower = Rect.fromLTWH(0, s * .55, s, s * .45);
    canvas.drawRect(
      lower,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFFCBB08B).withOpacity(.26)
          ],
        ).createShader(lower),
    );
    final gloss = Rect.fromLTWH(s * .18, s * .16, s * .48, s * .3);
    canvas.drawOval(
      gloss,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withOpacity(.72), Colors.white.withOpacity(0)],
        ).createShader(gloss),
    );
    // بافت کُرکی: چند نقطهٔ نرم.
    final speck = Paint()..color = Colors.white.withOpacity(.45);
    for (final p in const [
      Offset(.22, .30),
      Offset(.31, .25),
      Offset(.70, .31),
      Offset(.78, .44),
      Offset(.38, .78),
      Offset(.62, .82),
      Offset(.50, .72),
    ]) {
      canvas.drawCircle(Offset(p.dx * s, p.dy * s), s * .022, speck);
    }
    canvas.restore();
    canvas.drawPath(
      cloud,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .011
        ..color = Colors.white.withOpacity(.55),
    );

    // ——— دست‌ها و پاها ———
    _drawLimb(canvas, s, const Offset(.14, .60), const Offset(.075, .15), -.55);
    _drawLimb(canvas, s, const Offset(.86, .60), const Offset(.075, .15), .55);
    _drawLimb(canvas, s, const Offset(.40, .91), const Offset(.085, .13), 0);
    _drawLimb(canvas, s, const Offset(.60, .91), const Offset(.085, .13), 0);

    // ——— شال مرجانی ———
    _drawScarf(canvas, s);

    // ——— کاکل فیروزه‌ای ———
    _drawHair(canvas, s);

    // ——— چهره ———
    final eyeY = s * .48;
    final leftEye = Offset(s * .385, eyeY);
    final rightEye = Offset(s * .615, eyeY);
    final squish = 1 - blink * .9;

    _drawBrow(canvas, s, leftEye, mood == MascotMood.confused ? -.10 : 0);
    _drawBrow(canvas, s, rightEye, mood == MascotMood.confused ? .02 : 0);
    _drawEye(
      canvas,
      s,
      leftEye,
      squish: squish,
      mood: mood,
      lookRight: mood == MascotMood.cheering,
    );
    _drawEye(
      canvas,
      s,
      rightEye,
      squish: squish,
      mood: mood,
      lookRight: mood == MascotMood.cheering,
    );

    // بینی و دهان.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * .5, s * .585),
        width: s * .052,
        height: s * .038,
      ),
      Paint()..color = _scarfDeep,
    );
    _drawMouth(canvas, s, mood);
    _drawCheeks(canvas, s);

    // ——— ستاره‌های تشویق ———
    if (mood == MascotMood.cheering) {
      final energy = .65 + math.sin(reaction * math.pi) * .35;
      _drawStar(
          canvas, Offset(s * .13, s * .16), s * .055 * energy, AppColors.gold);
      _drawStar(
          canvas, Offset(s * .88, s * .12), s * .038 * energy, Colors.white);
      _drawStar(canvas, Offset(s * .9, s * .34), s * .028 * energy,
          AppColors.coralLight);
    }

    canvas.restore();
  }

  Path _cloudPath(double s) {
    final path = Path();
    // بدنهٔ مرکزی.
    final body = Rect.fromLTWH(s * .10, s * .30, s * .80, s * .55);
    // برجستگی‌های دور بدنه برای silhouette ابری.
    const bumps = <(double x, double y, double rx, double ry)>[
      (.16, .38, .085, .085),
      (.25, .27, .10, .095),
      (.40, .24, .115, .105),
      (.57, .24, .105, .10),
      (.72, .29, .10, .095),
      (.83, .40, .09, .09),
      (.20, .56, .09, .085),
      (.80, .56, .09, .085),
      (.26, .72, .095, .09),
      (.48, .76, .12, .10),
      (.70, .72, .10, .09),
    ];
    for (final bump in bumps) {
      path.addOval(
        Rect.fromCenter(
          center: Offset(s * bump.$1, s * bump.$2),
          width: s * bump.$3 * 2,
          height: s * bump.$4 * 2,
        ),
      );
    }
    path.addOval(body);
    return path;
  }

  void _drawLimb(
    Canvas canvas,
    double s,
    Offset position,
    Offset radius,
    double angle,
  ) {
    canvas.save();
    canvas.translate(position.dx * s, position.dy * s);
    canvas.rotate(angle);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: radius.dx * 2 * s,
      height: radius.dy * 2 * s,
    );
    canvas.drawOval(rect, Paint()..color = _cream);
    canvas.drawOval(
      rect.deflate(s * .012),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withOpacity(.5), Colors.transparent],
        ).createShader(rect),
    );
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .008
        ..color = _creamShade,
    );
    canvas.restore();
  }

  void _drawScarf(Canvas canvas, double s) {
    final band = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * .16, s * .615, s * .68, s * .105),
      Radius.circular(s * .055),
    );
    canvas.drawRRect(
      band.shift(Offset(0, s * .012)),
      Paint()..color = _scarfDeep.withOpacity(.55),
    );
    canvas.drawRRect(
      band,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFA189), _scarf, _scarfDeep],
        ).createShader(band.outerRect),
    );
    // بافت بافتنی ظریف.
    final knit = Paint()
      ..color = Colors.white.withOpacity(.20)
      ..strokeWidth = s * .007
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 9; i++) {
      final x = s * (.21 + i * .072);
      canvas.drawLine(
        Offset(x, s * .625),
        Offset(x - s * .018, s * .705),
        knit,
      );
    }
    // دنبالهٔ شال و ستاره.
    final tail = Path()
      ..moveTo(s * .24, s * .70)
      ..lineTo(s * .36, s * .70)
      ..lineTo(s * .34, s * .82)
      ..quadraticBezierTo(s * .30, s * .855, s * .265, s * .82)
      ..close();
    canvas.drawPath(tail, Paint()..color = _scarf);
    canvas.drawPath(
      tail,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .008
        ..color = _scarfDeep.withOpacity(.45),
    );
    _drawStar(canvas, Offset(s * .30, s * .765), s * .045, AppColors.gold);
    _drawStar(
        canvas, Offset(s * .295, s * .758), s * .022, AppColors.goldLight);
  }

  void _drawHair(Canvas canvas, double s) {
    // پایهٔ کاکل: دو برجستگی فیروزه‌ای بالای سر.
    final base = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(s * .55, s * .24),
          width: s * .30,
          height: s * .22,
        ),
      )
      ..addOval(
        Rect.fromCenter(
          center: Offset(s * .64, s * .20),
          width: s * .22,
          height: s * .18,
        ),
      );
    canvas.drawPath(
      base.shift(Offset(0, s * .012)),
      Paint()..color = _hairDeep.withOpacity(.45),
    );
    canvas.drawPath(
      base,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_hair, Color(0xFF8ADCE5), _hairDeep],
        ).createShader(Rect.fromLTWH(s * .35, s * .08, s * .38, s * .28)),
    );

    // مارپیچ امضای فِلَک.
    final spiral = Path()
      ..moveTo(s * .60, s * .22)
      ..cubicTo(s * .70, s * .17, s * .74, s * .27, s * .66, s * .30)
      ..cubicTo(s * .57, s * .34, s * .52, s * .24, s * .60, s * .20)
      ..cubicTo(s * .70, s * .15, s * .78, s * .25, s * .69, s * .31);
    canvas.drawPath(
      spiral,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .038
        ..strokeCap = StrokeCap.round
        ..color = _hairDeep.withOpacity(.72),
    );
    final spiralLight = Path()
      ..moveTo(s * .565, s * .235)
      ..cubicTo(s * .63, s * .185, s * .69, s * .235, s * .655, s * .275);
    canvas.drawPath(
      spiralLight,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .018
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withOpacity(.55),
    );
    // چند تار موی بیرون‌زده.
    final strand = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .016
      ..strokeCap = StrokeCap.round
      ..color = _hairDeep.withOpacity(.65);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(s * .40, s * .245),
        width: s * .16,
        height: s * .13,
      ),
      math.pi * .8,
      math.pi * .7,
      false,
      strand,
    );
  }

  void _drawBrow(Canvas canvas, double s, Offset eye, double lift) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * .024
      ..strokeCap = StrokeCap.round
      ..color = _hairDeep.withOpacity(.9);
    final rect = Rect.fromCenter(
      center: eye + Offset(0, -s * .095 + lift * s),
      width: s * .11,
      height: s * .035,
    );
    canvas.drawArc(rect, math.pi * 1.15, math.pi * .7, false, paint);
  }

  void _drawEye(
    Canvas canvas,
    double s,
    Offset center, {
    required double squish,
    required MascotMood mood,
    required bool lookRight,
  }) {
    final radius = s * .052;
    if (mood == MascotMood.sleepy) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .018
        ..strokeCap = StrokeCap.round
        ..color = _ink;
      canvas.drawArc(
        Rect.fromCenter(
          center: center + Offset(0, s * .008),
          width: radius * 2.1,
          height: radius * 1.35,
        ),
        math.pi * 1.08,
        math.pi * .84,
        false,
        paint,
      );
      return;
    }

    final clamped = squish.clamp(.06, 1.0).toDouble();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1, clamped);
    canvas.drawCircle(
      Offset.zero,
      radius * 1.08,
      Paint()..color = const Color(0xFFF7FBFF),
    );
    final irisShift = Offset(lookRight ? radius * .22 : 0, 0);
    canvas.drawCircle(
      irisShift,
      radius,
      Paint()..color = _ink,
    );
    canvas.drawCircle(
      irisShift + Offset(0, radius * .12),
      radius * .82,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF4C9FDD), Color(0xFF1F4E86)],
          stops: [.1, 1],
        ).createShader(
          Rect.fromCircle(center: irisShift, radius: radius),
        ),
    );
    // مردمک.
    canvas.drawCircle(
      irisShift,
      radius * .40,
      Paint()..color = const Color(0xFF101B30),
    );
    // دو هایلایت، مثل تصویر برند.
    canvas.drawCircle(
      irisShift + Offset(radius * .34, -radius * .38),
      radius * .30,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      irisShift + Offset(-radius * .30, radius * .20),
      radius * .14,
      Paint()..color = Colors.white.withOpacity(.8),
    );
    canvas.restore();
    canvas.drawCircle(
      center,
      radius * 1.12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .006
        ..color = _ink.withOpacity(.16),
    );
  }

  void _drawMouth(Canvas canvas, double s, MascotMood mood) {
    final ink = Paint()..color = _ink;
    final mouthY = s * .655;
    switch (mood) {
      case MascotMood.happy:
        final stroke = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * .018
          ..strokeCap = StrokeCap.round
          ..color = _ink;
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(s * .52, mouthY - s * .012),
            width: s * .10,
            height: s * .07,
          ),
          .2 * math.pi,
          .62 * math.pi,
          false,
          stroke,
        );
      case MascotMood.cheering:
        final mouth = Path()
          ..moveTo(s * .45, mouthY - s * .012)
          ..quadraticBezierTo(
              s * .52, mouthY + s * .065, s * .59, mouthY - s * .012)
          ..close();
        canvas.drawPath(mouth, ink);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(s * .525, mouthY + s * .028),
            width: s * .062,
            height: s * .026,
          ),
          Paint()..color = AppColors.coral,
        );
      case MascotMood.sleepy:
        final stroke = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * .016
          ..strokeCap = StrokeCap.round
          ..color = _ink.withOpacity(.85);
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(s * .53, mouthY + s * .004),
            width: s * .055,
            height: s * .04,
          ),
          1.1 * math.pi,
          .8 * math.pi,
          false,
          stroke,
        );
      case MascotMood.confused:
        final stroke = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * .016
          ..strokeCap = StrokeCap.round
          ..color = _ink;
        final path = Path()
          ..moveTo(s * .46, mouthY)
          ..quadraticBezierTo(
            s * .50,
            mouthY - s * .028,
            s * .54,
            mouthY,
          )
          ..quadraticBezierTo(
            s * .57,
            mouthY + s * .024,
            s * .60,
            mouthY - s * .004,
          );
        canvas.drawPath(path, stroke);
    }
  }

  void _drawCheeks(Canvas canvas, double s) {
    final blush = Paint()..color = AppColors.coral.withOpacity(.30);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * .30, s * .60),
        width: s * .09,
        height: s * .055,
      ),
      blush,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * .70, s * .60),
        width: s * .09,
        height: s * .055,
      ),
      blush,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var point = 0; point < 10; point++) {
      final angle = point * math.pi / 5 - math.pi / 2;
      final r = point.isEven ? radius : radius * .44;
      final offset = Offset(
        center.dx + r * math.cos(angle),
        center.dy + r * math.sin(angle),
      );
      if (point == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    path.close();
    canvas.drawPath(
      path.shift(Offset(0, radius * .12)),
      Paint()..color = Colors.black.withOpacity(.14),
    );
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: [Color.lerp(color, Colors.white, .45)!, color],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_MascotPainter oldDelegate) =>
      oldDelegate.blink != blink ||
      oldDelegate.mood != mood ||
      oldDelegate.accent != accent ||
      oldDelegate.reaction != reaction;
}
