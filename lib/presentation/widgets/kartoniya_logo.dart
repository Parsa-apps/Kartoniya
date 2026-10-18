import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';

/// نشان برند کارتونیا؛ کاملاً برداری تا در اسپلش، هدر و دربارهٔ ما بدون
/// asset و با هر تراکم پیکسلی تیز بماند.
///
/// نشان از سه عنصر هویت می‌سازد: ابرِ فِلَک (سفید نرم)، مثلث پخش (مرجانی) و
/// دو ستارهٔ طلایی. پس‌زمینهٔ نشان یک squircle آسمانی با هایلایت شیشه‌ای است؛
/// همان زبان بصری در آیکون اپ و بنرها تکرار می‌شود.
class KartoniyaLogoMark extends StatelessWidget {
  const KartoniyaLogoMark({
    super.key,
    this.size = 56,
    this.gradient,
    this.showOrbit = false,
    this.semanticLabel = 'نشان کارتونیا',
  });

  final double size;
  final Gradient? gradient;

  /// دو نقطهٔ در حال چرخش دور لوگو؛ فقط در اسپلش/هالهٔ برند استفاده شود.
  final bool showOrbit;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final paintGradient = gradient ?? AppColors.skyGradient;
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (showOrbit) _LogoOrbits(size: size),
              CustomPaint(
                size: Size.square(size),
                painter: _LogoPainter(
                  gradient: paintGradient,
                  corner: size * .3,
                  detail: size >= 44,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter({
    required this.gradient,
    required this.corner,
    required this.detail,
  });

  final Gradient gradient;
  final double corner;

  /// ستاره‌ها و هایلایت‌های ریز فقط در اندازه‌های خوانا رسم می‌شوند.
  final bool detail;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final w = size.width;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(corner));

    // سایهٔ نرم پایین نشان.
    canvas.drawRRect(
      rrect.shift(Offset(0, w * .035)),
      Paint()..color = Colors.black.withOpacity(.16),
    );
    canvas.drawRRect(
      rrect,
      Paint()..shader = gradient.createShader(rect),
    );

    canvas.save();
    canvas.clipRRect(rrect);
    // هایلایت شیشه‌ای بالای نشان.
    final sheen = Path()
      ..moveTo(-w * .1, -w * .1)
      ..lineTo(w * 1.1, -w * .1)
      ..lineTo(w * 1.1, w * .38)
      ..quadraticBezierTo(w * .5, w * .58, -w * .1, w * .30)
      ..close();
    canvas.drawPath(sheen, Paint()..color = Colors.white.withOpacity(.18));
    // عمق نرم پایین.
    canvas.drawRect(
      Rect.fromLTRB(0, w * .70, w, w),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(.14)],
        ).createShader(Rect.fromLTRB(0, w * .70, w, w)),
    );
    canvas.restore();

    // قاب نازک داخلی؛ نشان را از پس‌زمینه جدا می‌کند.
    canvas.drawRRect(
      rrect.deflate(w * .012),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .018
        ..color = Colors.white.withOpacity(.20),
    );

    // ——— ابر فِلَک ———
    final cloud = Path()
      ..addOval(Rect.fromLTWH(w * .22, w * .42, w * .40, w * .30))
      ..addOval(Rect.fromLTWH(w * .34, w * .30, w * .40, w * .38))
      ..addOval(Rect.fromLTWH(w * .50, w * .42, w * .30, w * .28))
      ..addOval(Rect.fromLTWH(w * .28, w * .48, w * .46, w * .23));
    final cloudRect = Rect.fromLTWH(w * .18, w * .27, w * .66, w * .48);
    canvas.save();
    canvas.translate(0, w * .02);
    canvas.drawShadow(cloud, Colors.black.withOpacity(.18), w * .05, false);
    canvas.restore();
    canvas.drawPath(
      cloud,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFFFF4E4)],
        ).createShader(cloudRect),
    );

    // ——— مثلث پخش مرجانی ———
    final center = Offset(w * .53, w * .54);
    final play = Path()
      ..moveTo(center.dx + w * .115, center.dy)
      ..lineTo(center.dx - w * .068, center.dy - w * .105)
      ..lineTo(center.dx - w * .068, center.dy + w * .105)
      ..close();
    canvas.drawShadow(play, AppColors.coralDeep.withOpacity(.45), w * .025, true);
    canvas.drawPath(
      play,
      Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.coralLight, AppColors.coral, AppColors.coralDeep],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ).createShader(cloudRect),
    );

    if (!detail) return;

    // ——— دو ستارهٔ هویت ———
    _drawStar(
      canvas,
      Offset(w * .255, w * .255),
      w * .062,
      AppColors.goldLight,
    );
    _drawStar(
      canvas,
      Offset(w * .79, w * .755),
      w * .042,
      Colors.white.withOpacity(.9),
    );
    // نقطهٔ نور روی ابر.
    canvas.drawCircle(
      Offset(w * .34, w * .37),
      w * .035,
      Paint()..color = Colors.white.withOpacity(.55),
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var point = 0; point < 8; point++) {
      final angle = point * math.pi / 4 - math.pi / 2;
      final r = point.isEven ? radius : radius * .34;
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
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) =>
      oldDelegate.gradient != gradient ||
      oldDelegate.corner != corner ||
      oldDelegate.detail != detail;
}

/// نشان + نام برند + شعار؛ برای اسپلش و سطوح برندی استفاده می‌شود.
///
/// رنگ متن را فراخوان تعیین می‌کند تا روی پس‌زمینهٔ روشن و شبانه هر دو
/// خوانا بماند. تایپوگرافی از تم می‌آید و فونت Vazirmatn حفظ می‌شود.
class KartoniyaWordmark extends StatelessWidget {
  const KartoniyaWordmark({
    super.key,
    this.markSize = 92,
    this.titleColor,
    this.taglineColor,
    this.tagline = 'دنیای شاد و امن کودکان',
    this.showTagline = true,
    this.showOrbit = false,
    this.spacing = 18,
  });

  final double markSize;
  final Color? titleColor;
  final Color? taglineColor;
  final String tagline;
  final bool showTagline;
  final bool showOrbit;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        KartoniyaLogoMark(size: markSize, showOrbit: showOrbit),
        SizedBox(height: spacing),
        Text(
          'کارتونیا',
          textAlign: TextAlign.center,
          style: theme.textTheme.displayMedium?.copyWith(
            color: titleColor,
            letterSpacing: -.4,
            shadows: titleColor == Colors.white
                ? const [Shadow(color: Color(0x66000000), blurRadius: 14)]
                : null,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            tagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: taglineColor,
              fontWeight: FontWeight.w500,
              letterSpacing: .2,
            ),
          ),
        ],
      ],
    );
  }
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  void _syncMotion() {
    if (context.motion.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!context.motion.enabled) {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        // جعبهٔ مدار بزرگ‌تر از نشان است تا نقطه‌ها بدون بریده‌شدن دور آن
        // بچرخند؛ لایهٔ والد (Stack نشان) اجازهٔ ترسیم بیرون از bounds را دارد.
        final box = widget.size * 1.46;
        final center = box / 2;
        Widget dot(double phase, double radius, Color color, double dotSize) {
          final angle = (t + phase) * 2 * math.pi;
          return Positioned(
            left: center + radius * math.cos(angle) - dotSize / 2,
            top: center + radius * math.sin(angle) * .82 - dotSize / 2,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(.55),
                    blurRadius: dotSize * .9,
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          width: box,
          height: box,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              dot(0, widget.size * .62, AppColors.goldLight, widget.size * .075),
              dot(.5, widget.size * .66, Colors.white, widget.size * .06),
            ],
          ),
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
