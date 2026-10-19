import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/child_profile_model.dart';

/// آواتار اختصاصی کودک با نقاشی برداری؛ به emoji یا فایل تصویری وابسته نیست.
class ChildAvatar extends StatelessWidget {
  const ChildAvatar({
    required this.index,
    this.size = 64,
    super.key,
  });

  final int index;
  final double size;

  @override
  Widget build(BuildContext context) {
    final safeIndex =
        index.clamp(0, ChildProfileModel.avatars.length - 1).toInt();
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ChildAvatarPainter(
          avatarIndex: safeIndex,
          avatar: ChildProfileModel.avatars[safeIndex],
        ),
      ),
    );
  }
}

class _ChildAvatarPainter extends CustomPainter {
  const _ChildAvatarPainter({
    required this.avatarIndex,
    required this.avatar,
  });

  final int avatarIndex;
  final ChildAvatarSpec avatar;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 100;
    canvas.save();
    canvas.scale(scale, scale);

    final color = Color(avatar.colorValue);
    final accent = Color(avatar.accentValue);
    final background = Color(avatar.backgroundValue);
    final dark = Color.lerp(color, const Color(0xFF27354A), .48)!;
    final whiteStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(const Offset(50, 50), 48, Paint()..color = background);
    canvas.drawCircle(const Offset(50, 50), 47, whiteStroke);

    if (avatar.style == ChildAvatarStyle.butterfly) {
      _drawButterflyWings(canvas, color, accent, whiteStroke);
    }
    if (avatar.style == ChildAvatarStyle.bee) {
      _drawBeeWings(canvas, whiteStroke);
    }
    if (avatar.style == ChildAvatarStyle.lion) {
      _drawLionMane(canvas, color, accent, whiteStroke);
    }
    if (avatar.style == ChildAvatarStyle.frog) {
      _drawFrogEyeBumps(canvas, color, whiteStroke);
    }
    if (avatar.style == ChildAvatarStyle.deer) {
      _drawAntlers(canvas, dark, whiteStroke);
    }
    if (avatar.style == ChildAvatarStyle.dinosaur ||
        avatar.style == ChildAvatarStyle.dragon) {
      _drawBackSpines(canvas, color, whiteStroke);
    }
    if (avatar.style == ChildAvatarStyle.unicorn ||
        avatar.style == ChildAvatarStyle.dragon) {
      _drawHorn(canvas, accent, whiteStroke);
    }

    _drawEars(canvas, avatar.style, color, accent, whiteStroke);

    final headRect = avatar.style == ChildAvatarStyle.penguin
        ? const Rect.fromLTRB(24, 25, 76, 80)
        : const Rect.fromLTRB(23, 28, 77, 79);
    final headPath = Path()..addOval(headRect);
    canvas.drawShadow(headPath, Colors.black.withOpacity(.14), 2.5, false);
    canvas.drawPath(headPath, Paint()..color = color);
    canvas.drawPath(headPath, whiteStroke);

    if (avatar.style == ChildAvatarStyle.penguin) {
      canvas.drawOval(
        const Rect.fromLTRB(32, 43, 68, 76),
        Paint()..color = accent,
      );
    }
    if (avatar.style == ChildAvatarStyle.monkey) {
      canvas.drawOval(
        const Rect.fromLTRB(31, 43, 69, 73),
        Paint()..color = accent,
      );
    }
    if (avatar.style == ChildAvatarStyle.elephant) {
      _drawElephantTrunk(canvas, accent, dark);
    }
    if (avatar.style == ChildAvatarStyle.duck) {
      _drawDuckBill(canvas, accent, dark, whiteStroke);
    }
    if (avatar.style == ChildAvatarStyle.bee) {
      _drawBeeStripes(canvas, dark, headPath);
    }
    if (avatar.style == ChildAvatarStyle.panda) {
      _drawPandaPatches(canvas, dark);
    }
    if (avatar.style == ChildAvatarStyle.tiger) {
      _drawTigerStripes(canvas, dark);
    }
    if (avatar.style == ChildAvatarStyle.fox ||
        avatar.style == ChildAvatarStyle.rabbit ||
        avatar.style == ChildAvatarStyle.cat) {
      _drawFaceMask(canvas, accent);
    }

    final eyeY = avatar.style == ChildAvatarStyle.frog ? 48.5 : 52.5;
    final eyeRadius = avatar.style == ChildAvatarStyle.owl ? 5.2 : 3.7;
    _drawEye(canvas, Offset(40, eyeY), eyeRadius, dark);
    _drawEye(canvas, Offset(60, eyeY), eyeRadius, dark);

    if (avatar.style == ChildAvatarStyle.owl) {
      _drawOwlEyeRings(canvas, accent);
    }

    final cheekPaint = Paint()..color = const Color(0xFFFF8EA0).withOpacity(.68);
    canvas.drawOval(const Rect.fromLTRB(29, 59, 39, 65), cheekPaint);
    canvas.drawOval(const Rect.fromLTRB(61, 59, 71, 65), cheekPaint);

    if (avatar.style != ChildAvatarStyle.duck &&
        avatar.style != ChildAvatarStyle.elephant &&
        avatar.style != ChildAvatarStyle.bee) {
      _drawSmile(canvas, dark);
    }
    if (avatar.style == ChildAvatarStyle.deer) {
      canvas.drawCircle(const Offset(50, 36), 3.2, Paint()..color = accent);
    }
    if (avatar.style == ChildAvatarStyle.unicorn) {
      _drawForeheadStar(canvas, accent, dark);
    }
    if (avatar.style == ChildAvatarStyle.dragon) {
      _drawDragonNostrils(canvas, dark);
    }

    canvas.restore();
  }

  void _drawEars(
    Canvas canvas,
    ChildAvatarStyle style,
    Color color,
    Color accent,
    Paint outline,
  ) {
    switch (style) {
      case ChildAvatarStyle.fox:
      case ChildAvatarStyle.cat:
      case ChildAvatarStyle.tiger:
        _drawPointyEars(canvas, color, accent, outline);
        break;
      case ChildAvatarStyle.rabbit:
        _drawLongEars(canvas, color, accent, outline);
        break;
      case ChildAvatarStyle.bear:
      case ChildAvatarStyle.panda:
        _drawRoundEars(canvas, color, accent, outline);
        break;
      case ChildAvatarStyle.puppy:
        _drawFloppyEars(canvas, color, accent, outline);
        break;
      case ChildAvatarStyle.monkey:
        _drawRoundEars(canvas, color, accent, outline);
        break;
      case ChildAvatarStyle.koala:
        _drawKoalaEars(canvas, color, accent, outline);
        break;
      case ChildAvatarStyle.elephant:
        _drawElephantEars(canvas, color, accent, outline);
        break;
      case ChildAvatarStyle.owl:
        _drawTufts(canvas, color, outline);
        break;
      case ChildAvatarStyle.penguin:
      case ChildAvatarStyle.duck:
      case ChildAvatarStyle.bee:
      case ChildAvatarStyle.butterfly:
      case ChildAvatarStyle.frog:
      case ChildAvatarStyle.lion:
      case ChildAvatarStyle.deer:
      case ChildAvatarStyle.dinosaur:
      case ChildAvatarStyle.unicorn:
      case ChildAvatarStyle.dragon:
        break;
    }
  }

  void _drawRoundEars(Canvas canvas, Color color, Color accent, Paint outline) {
    _outlinedOval(canvas, const Rect.fromLTRB(22, 22, 42, 43), color, outline);
    _outlinedOval(canvas, const Rect.fromLTRB(58, 22, 78, 43), color, outline);
    canvas.drawOval(const Rect.fromLTRB(27, 27, 39, 39), Paint()..color = accent);
    canvas.drawOval(const Rect.fromLTRB(61, 27, 73, 39), Paint()..color = accent);
  }

  void _drawFloppyEars(Canvas canvas, Color color, Color accent, Paint outline) {
    _rotatedOval(canvas, const Offset(28, 49), 10, 21, -.45, color, outline);
    _rotatedOval(canvas, const Offset(72, 49), 10, 21, .45, color, outline);
    _rotatedOval(canvas, const Offset(28, 50), 4, 13, -.45, accent, null);
    _rotatedOval(canvas, const Offset(72, 50), 4, 13, .45, accent, null);
  }

  void _drawElephantEars(
    Canvas canvas,
    Color color,
    Color accent,
    Paint outline,
  ) {
    _rotatedOval(canvas, const Offset(25, 53), 14, 23, -.25, color, outline);
    _rotatedOval(canvas, const Offset(75, 53), 14, 23, .25, color, outline);
    _rotatedOval(canvas, const Offset(25, 53), 7, 15, -.25, accent, null);
    _rotatedOval(canvas, const Offset(75, 53), 7, 15, .25, accent, null);
  }

  void _drawKoalaEars(Canvas canvas, Color color, Color accent, Paint outline) {
    _outlinedOval(canvas, const Rect.fromLTRB(12, 31, 39, 58), color, outline);
    _outlinedOval(canvas, const Rect.fromLTRB(61, 31, 88, 58), color, outline);
    canvas.drawOval(const Rect.fromLTRB(19, 37, 34, 52), Paint()..color = accent);
    canvas.drawOval(const Rect.fromLTRB(66, 37, 81, 52), Paint()..color = accent);
  }

  void _drawPointyEars(Canvas canvas, Color color, Color accent, Paint outline) {
    final left = Path()
      ..moveTo(25, 45)
      ..lineTo(27, 19)
      ..quadraticBezierTo(28, 15, 32, 20)
      ..lineTo(46, 36)
      ..close();
    final right = Path()
      ..moveTo(54, 36)
      ..lineTo(68, 20)
      ..quadraticBezierTo(72, 15, 73, 20)
      ..lineTo(75, 45)
      ..close();
    for (final path in [left, right]) {
      canvas.drawPath(path, Paint()..color = color);
      canvas.drawPath(path, outline);
    }
    final innerLeft = Path()
      ..moveTo(30, 37)
      ..lineTo(31, 26)
      ..lineTo(40, 37)
      ..close();
    final innerRight = Path()
      ..moveTo(60, 37)
      ..lineTo(69, 26)
      ..lineTo(70, 37)
      ..close();
    canvas.drawPath(innerLeft, Paint()..color = accent);
    canvas.drawPath(innerRight, Paint()..color = accent);
  }

  void _drawLongEars(Canvas canvas, Color color, Color accent, Paint outline) {
    _rotatedOval(canvas, const Offset(34, 31), 8, 22, -.18, color, outline);
    _rotatedOval(canvas, const Offset(66, 31), 8, 22, .18, color, outline);
    _rotatedOval(canvas, const Offset(34, 30), 3.6, 15, -.18, accent, null);
    _rotatedOval(canvas, const Offset(66, 30), 3.6, 15, .18, accent, null);
  }

  void _drawTufts(Canvas canvas, Color color, Paint outline) {
    for (final (x, y) in [(31.0, 34.0), (50.0, 25.0), (69.0, 34.0)]) {
      final tuft = Path()
        ..moveTo(x - 6, y + 7)
        ..lineTo(x, y - 9)
        ..lineTo(x + 7, y + 7)
        ..close();
      canvas.drawPath(tuft, Paint()..color = color);
      canvas.drawPath(tuft, outline);
    }
  }

  void _drawFrogEyeBumps(Canvas canvas, Color color, Paint outline) {
    _outlinedOval(canvas, const Rect.fromLTRB(28, 20, 48, 43), color, outline);
    _outlinedOval(canvas, const Rect.fromLTRB(52, 20, 72, 43), color, outline);
  }

  void _drawLionMane(Canvas canvas, Color color, Color accent, Paint outline) {
    canvas.drawCircle(const Offset(50, 53), 34, Paint()..color = color);
    canvas.drawCircle(const Offset(50, 53), 34, outline);
    for (var i = 0; i < 10; i++) {
      final angle = (i * 36 - 90) * math.pi / 180;
      final center = Offset(50 + 32 * math.cos(angle), 53 + 32 * math.sin(angle));
      canvas.drawCircle(center, 4.2, Paint()..color = accent);
    }
  }

  void _drawButterflyWings(Canvas canvas, Color color, Color accent, Paint outline) {
    _rotatedOval(canvas, const Offset(27, 52), 14, 22, -.35, accent, outline);
    _rotatedOval(canvas, const Offset(73, 52), 14, 22, .35, accent, outline);
    _rotatedOval(canvas, const Offset(29, 39), 9, 12, -.5, color, outline);
    _rotatedOval(canvas, const Offset(71, 39), 9, 12, .5, color, outline);
    canvas.drawCircle(const Offset(25, 49), 3, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(75, 49), 3, Paint()..color = Colors.white);
  }

  void _drawBeeWings(Canvas canvas, Paint outline) {
    _rotatedOval(
      canvas,
      const Offset(36, 37),
      9,
      15,
      -.45,
      const Color(0xFFEAFBFF),
      outline,
    );
    _rotatedOval(
      canvas,
      const Offset(64, 37),
      9,
      15,
      .45,
      const Color(0xFFEAFBFF),
      outline,
    );
  }

  void _drawAntlers(Canvas canvas, Color color, Paint outline) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final startX in [35.0, 65.0]) {
      final direction = startX < 50 ? -1.0 : 1.0;
      final path = Path()
        ..moveTo(startX, 38)
        ..lineTo(startX + direction * 2, 24)
        ..lineTo(startX + direction * 9, 17)
        ..moveTo(startX + direction * 2, 26)
        ..lineTo(startX + direction * 7, 20)
        ..moveTo(startX + direction * 4, 30)
        ..lineTo(startX - direction * 3, 24);
      canvas.drawPath(path, paint);
      canvas.drawPath(path, outline);
    }
  }

  void _drawBackSpines(Canvas canvas, Color color, Paint outline) {
    for (var i = 0; i < 5; i++) {
      final x = 34 + i * 8.0;
      final spike = Path()
        ..moveTo(x - 5, 40)
        ..lineTo(x, 26 + (i.isOdd ? 3 : 0))
        ..lineTo(x + 5, 40)
        ..close();
      canvas.drawPath(spike, Paint()..color = color);
      canvas.drawPath(spike, outline);
    }
  }

  void _drawHorn(Canvas canvas, Color color, Paint outline) {
    final horn = Path()
      ..moveTo(43, 33)
      ..lineTo(50, 10)
      ..lineTo(57, 33)
      ..close();
    canvas.drawPath(horn, Paint()..color = color);
    canvas.drawPath(horn, outline);
    canvas.drawLine(
      const Offset(47, 24),
      const Offset(54, 24),
      Paint()
        ..color = Colors.white.withOpacity(.75)
        ..strokeWidth = 2.3
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawElephantTrunk(Canvas canvas, Color accent, Color dark) {
    final trunk = Path()
      ..moveTo(48, 50)
      ..cubicTo(44, 60, 45, 74, 53, 74)
      ..cubicTo(62, 73, 57, 65, 58, 61);
    canvas.drawPath(
      trunk,
      Paint()
        ..color = accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      trunk,
      Paint()
        ..color = dark.withOpacity(.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(50, 48), 3.2, Paint()..color = dark);
    canvas.drawCircle(const Offset(62, 48), 3.2, Paint()..color = dark);
  }

  void _drawDuckBill(Canvas canvas, Color accent, Color dark, Paint outline) {
    final bill = Path()
      ..moveTo(41, 59)
      ..quadraticBezierTo(50, 52, 59, 59)
      ..quadraticBezierTo(50, 70, 41, 59)
      ..close();
    canvas.drawPath(bill, Paint()..color = accent);
    canvas.drawPath(bill, outline..color = dark.withOpacity(.65));
  }

  void _drawBeeStripes(Canvas canvas, Color dark, Path headPath) {
    canvas.save();
    canvas.clipPath(headPath);
    final stripe = Paint()..color = dark.withOpacity(.52);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(23, 57, 77, 63),
        const Radius.circular(4),
      ),
      stripe,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(27, 69, 73, 75),
        const Radius.circular(4),
      ),
      stripe,
    );
    canvas.restore();
  }

  void _drawPandaPatches(Canvas canvas, Color dark) {
    canvas.drawOval(const Rect.fromLTRB(32, 44, 44, 60), Paint()..color = dark);
    canvas.drawOval(const Rect.fromLTRB(56, 44, 68, 60), Paint()..color = dark);
  }

  void _drawTigerStripes(Canvas canvas, Color dark) {
    final paint = Paint()
      ..color = dark.withOpacity(.8)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(50, 32), const Offset(50, 39), paint);
    canvas.drawLine(const Offset(40, 34), const Offset(43, 40), paint);
    canvas.drawLine(const Offset(60, 34), const Offset(57, 40), paint);
  }

  void _drawOwlEyeRings(Canvas canvas, Color accent) {
    final ring = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(const Offset(40, 52.5), 8, ring);
    canvas.drawCircle(const Offset(60, 52.5), 8, ring);
  }

  void _drawEye(Canvas canvas, Offset center, double radius, Color dark) {
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    canvas.drawCircle(
      center.translate(0, .6),
      radius * .68,
      Paint()..color = dark,
    );
    canvas.drawCircle(
      center.translate(-1.2, -1.3),
      radius * .22,
      Paint()..color = Colors.white,
    );
  }

  void _drawSmile(Canvas canvas, Color dark) {
    final smile = Path()
      ..moveTo(45, 63)
      ..quadraticBezierTo(50, 68, 55, 63);
    canvas.drawPath(
      smile,
      Paint()
        ..color = dark
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawFaceMask(Canvas canvas, Color accent) {
    final mask = Path()
      ..moveTo(25, 49)
      ..quadraticBezierTo(37, 47, 50, 57)
      ..quadraticBezierTo(63, 47, 75, 49)
      ..quadraticBezierTo(68, 68, 50, 71)
      ..quadraticBezierTo(32, 68, 25, 49)
      ..close();
    canvas.drawPath(mask, Paint()..color = accent.withOpacity(.45));
  }

  void _drawForeheadStar(Canvas canvas, Color accent, Color dark) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? 5.0 : 2.4;
      final angle = (i * 36 - 90) * math.pi / 180;
      final point = Offset(50 + radius * math.cos(angle), 43 + radius * math.sin(angle));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = accent);
    canvas.drawPath(
      path,
      Paint()
        ..color = dark.withOpacity(.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawDragonNostrils(Canvas canvas, Color dark) {
    canvas.drawCircle(const Offset(46, 65), 1.7, Paint()..color = dark);
    canvas.drawCircle(const Offset(54, 65), 1.7, Paint()..color = dark);
  }

  void _outlinedOval(Canvas canvas, Rect rect, Color fill, Paint outline) {
    canvas.drawOval(rect, Paint()..color = fill);
    canvas.drawOval(rect, outline);
  }

  void _rotatedOval(
    Canvas canvas,
    Offset center,
    double radiusX,
    double radiusY,
    double rotation,
    Color fill,
    Paint? outline,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: radiusX * 2,
      height: radiusY * 2,
    );
    canvas.drawOval(rect, Paint()..color = fill);
    if (outline != null) canvas.drawOval(rect, outline);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChildAvatarPainter oldDelegate) =>
      oldDelegate.avatarIndex != avatarIndex;
}
