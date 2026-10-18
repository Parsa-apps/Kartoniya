import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cartoon_model.dart';

/// پوستر برداری زایا برای کاتالوگ.
///
/// این راهکار از دریافت تصویر تصادفی و نامناسب برای کودک جلوگیری می‌کند،
/// با هر اندازهٔ نمایش مقیاس می‌گیرد، صفر بایت asset شبکه دارد و صحنهٔ
/// تزئینی آن بر اساس شناسهٔ کارتون به‌صورت قطعی (deterministic) تولید می‌شود.
class CartoonArtwork extends StatelessWidget {
  const CartoonArtwork({
    super.key,
    required this.cartoon,
    this.borderRadius = AppTheme.radiusLarge,
    this.showPlayAffordance = true,
    this.showTitle = false,
    this.showAgeBadge = false,
    this.emphasis = false,
  });

  final CartoonModel cartoon;
  final double borderRadius;
  final bool showPlayAffordance;
  final bool showTitle;

  /// ردهٔ سنی روی پوستر؛ فقط وقتی دادهٔ معتبر سن وجود دارد نمایش داده شود.
  final bool showAgeBadge;

  /// برای بنرهای بزرگ: مدالیون و جزئیات درشت‌تر.
  final bool emphasis;

  /// تگ Hero مشترک بین کارت انتخاب‌شده و صفحهٔ جزئیات.
  static String heroTagFor(CartoonModel cartoon) => AppMotion.heroTag(cartoon.id);

  @override
  Widget build(BuildContext context) {
    final baseColor = cartoon.artworkColor;
    final isDark = context.isDarkMode;

    return Semantics(
      image: true,
      label: 'تصویرسازی ${cartoon.title}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: PosterScenePainter(
                baseColor: baseColor,
                seed: cartoon.id.hashCode.abs(),
                isDark: isDark,
              ),
            ),
            // مدالیون شخصیت با هالهٔ نرم.
            Center(
              child: Transform.rotate(
                angle: cartoon.id.hashCode.isEven ? -.05 : .05,
                child: Container(
                  width: emphasis ? 128 : 96,
                  height: emphasis ? 128 : 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(.34),
                        Colors.white.withOpacity(.14),
                      ],
                      stops: const [.55, 1],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(.38), width: 1.6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.16),
                        blurRadius: emphasis ? 26 : 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    cartoon.artworkEmoji,
                    style: TextStyle(
                      fontSize: emphasis ? 66 : 52,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
            if (cartoon.isNew)
              PositionedDirectional(
                top: 12,
                start: 12,
                child: _ArtworkBadge(
                  label: 'جدید',
                  color: baseColor,
                  icon: Icons.auto_awesome_rounded,
                ),
              ),
            if (showAgeBadge && cartoon.ageRange.trim().isNotEmpty)
              PositionedDirectional(
                top: 12,
                end: 12,
                child: _ArtworkBadge(
                  label: 'سن ${cartoon.ageRange}',
                  color: Colors.black54,
                  icon: Icons.child_care_rounded,
                  lightOnDark: true,
                ),
              ),
            if (showPlayAffordance)
              PositionedDirectional(
                bottom: 12,
                start: 12,
                child: Container(
                  width: emphasis ? 42 : 34,
                  height: emphasis ? 42 : 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.94),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: baseColor,
                    size: emphasis ? 28 : 23,
                  ),
                ),
              ),
            if (showTitle)
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(.48),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 22, 14, 12),
                      child: Text(
                        cartoon.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(color: Colors.black38, blurRadius: 5),
                                  ],
                                ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ArtworkBadge extends StatelessWidget {
  const _ArtworkBadge({
    required this.label,
    required this.color,
    required this.icon,
    this.lightOnDark = false,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool lightOnDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: lightOnDark
            ? Colors.black.withOpacity(.45)
            : Colors.white.withOpacity(.94),
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
        border: lightOnDark
            ? Border.all(color: Colors.white.withOpacity(.25))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: lightOnDark ? AppColors.goldLight : color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: lightOnDark ? Colors.white : color,
                  fontSize: 10.5,
                ),
          ),
        ],
      ),
    );
  }
}

/// نقاش صحنهٔ پوستر: گرادیان آسمانی + تپه، ابر، ستاره و پرتوهای نور؛
/// ترکیب عناصر از seed شناسهٔ کارتون می‌آید تا هر پوستر امضای خودش را داشته
/// باشد. نقاشی کاملاً سبک است (چند path، بدون blur گران).
class PosterScenePainter extends CustomPainter {
  const PosterScenePainter({
    required this.baseColor,
    required this.seed,
    required this.isDark,
  });

  final Color baseColor;
  final int seed;
  final bool isDark;

  double _rand(int index) {
    // LCG قطعی برای جایابی عناصر تزئینی.
    final value = (seed * 1103515245 + 12345 + index * 2654435761) & 0x7FFFFFFF;
    return (value % 1000) / 1000;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final light = Color.lerp(baseColor, Colors.white, .42)!;
    final deep = Color.lerp(
      baseColor,
      isDark ? const Color(0xFF0B1122) : const Color(0xFF17223B),
      .28,
    )!;

    final background = Paint()
      ..shader = LinearGradient(
        colors: [light, baseColor, deep],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    // پرتوهای نور ملایم از گوشهٔ بالا.
    final rays = Paint()
      ..color = Colors.white.withOpacity(.08)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 3; i++) {
      final dx = size.width * (.1 + .28 * i + _rand(i) * .1);
      final path = Path()
        ..moveTo(dx, 0)
        ..lineTo(dx + size.width * .14, 0)
        ..lineTo(size.width * .2 + dx * .6, size.height)
        ..lineTo(size.width * .04 + dx * .6, size.height)
        ..closePath();
      canvas.save();
      canvas.clipRect(Offset.zero & size);
      canvas.drawPath(path, rays);
      canvas.restore();
    }

    // تپه‌های نرم پایین.
    final hillPaint = Paint()
      ..color = Colors.white.withOpacity(.13);
    final hillPath = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * .3,
        size.height * (.62 + _rand(7) * .12),
        size.width * .62,
        size.height * .82,
      )
      ..quadraticBezierTo(
        size.width * .84,
        size.height * .94,
        size.width,
        size.height * (.78 + _rand(8) * .1),
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    final hillPaint2 = Paint()..color = Colors.black.withOpacity(.07);
    final hillPath2 = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * .24,
        size.height * (.78 + _rand(9) * .08),
        size.width * .58,
        size.height * .92,
      )
      ..quadraticBezierTo(size.width * .8, size.height, size.width, size.height * .9)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(hillPath2, hillPaint2);

    // حباب‌های نور.
    final bubblePaint = Paint()..color = Colors.white.withOpacity(.15);
    final bubbleCount = 2 + (seed % 3);
    for (var i = 0; i < bubbleCount; i++) {
      canvas.drawCircle(
        Offset(
          size.width * (.12 + _rand(20 + i) * .76),
          size.height * (.1 + _rand(40 + i) * .5),
        ),
        size.shortestSide * (.06 + _rand(60 + i) * .07),
        bubblePaint,
      );
    }

    // ستاره‌های درخشش‌دار.
    final sparklePaint = Paint()
      ..color = Colors.white.withOpacity(.75)
      ..style = PaintingStyle.fill;
    final starCount = 3 + (seed % 3);
    for (var i = 0; i < starCount; i++) {
      final x = size.width * (.08 + _rand(80 + i) * .84);
      final y = size.height * (.08 + _rand(120 + i) * .5);
      final r = size.shortestSide * (.012 + _rand(160 + i) * .012);
      _drawSparkle(canvas, Offset(x, y), r, sparklePaint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var point = 0; point < 8; point++) {
      final angle = point * math.pi / 4;
      final r = point.isEven ? radius * 2.2 : radius * .8;
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
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PosterScenePainter oldDelegate) =>
      oldDelegate.baseColor != baseColor ||
      oldDelegate.seed != seed ||
      oldDelegate.isDark != isDark;
}
