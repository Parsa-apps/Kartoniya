import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// توکن‌های حرکتی کارتونیا.
///
/// همهٔ انیمیشن‌ها باید از همین مقادیر استفاده کنند تا ریتم برنامه یکدست
/// بماند. با فعال‌بودن «کاهش حرکت» (تنظیم سیستم یا تنظیم والدین) مقدار
/// durationها صفر می‌شود و ویجت‌ها وضعیت نهایی را نشان می‌دهند.
abstract final class AppMotion {
  static const micro = Duration(milliseconds: 150);
  static const quick = Duration(milliseconds: 260);
  static const soft = Duration(milliseconds: 380);
  static const entrance = Duration(milliseconds: 520);
  static const hero = Duration(milliseconds: 430);
  static const slow = Duration(milliseconds: 650);

  static const curveStandard = Curves.easeOutCubic;
  static const curveEntrance = Cubic(.22, 1, .36, 1);
  static const curveExit = Curves.easeInCubic;
  static const curvePop = Curves.easeOutBack;
  static const curveGentle = Curves.easeInOut;

  /// گام تأخیر بین عناصر پلکانی.
  static const staggerStep = Duration(milliseconds: 70);
  static const staggerStartDelay = Duration(milliseconds: 60);

  static const heroTagPrefix = 'kartoniya-artwork';
  static String heroTag(String cartoonId) => '$heroTagPrefix-$cartoonId';
}

/// اطلاعات حرکت برای یک BuildContext.
class MotionInfo {
  const MotionInfo({required this.reduced});

  static const reducedNone = MotionInfo(reduced: true);

  final bool reduced;

  bool get enabled => !reduced;

  Duration dur(Duration duration) => reduced ? Duration.zero : duration;

  double offsetDelta(double value) => reduced ? 0 : value;

  double scaleFrom(double value) => reduced ? 1 : value;
}

extension MotionContext on BuildContext {
  /// `context.motion.enabled` را در ویجت‌های متحرک بخوانید؛ اگر کاربر کاهش
  /// حرکت را فعال کرده باشد انیمیشن‌ها رد می‌شوند.
  MotionInfo get motion {
    final scope = dependOnInheritedWidgetOfExactType<MotionScope>()?.info ??
        const MotionInfo(reduced: false);
    final systemReduce = MediaQuery.maybeOf(this)?.disableAnimations ?? false;
    if (!scope.reduced && systemReduce) return const MotionInfo(reduced: true);
    return scope;
  }

  Duration motionDur(Duration duration) => motion.dur(duration);
}

/// یک لایه در ریشهٔ برنامه؛ «کاهش حرکت» تنظیم‌شده در فضای والدین را به همهٔ
/// زیردرخت می‌رساند بدون اینکه هر ویجت به Riverpod وصل باشد.
class MotionScope extends InheritedWidget {
  const MotionScope({required this.info, required super.child, super.key});

  final MotionInfo info;

  @override
  bool updateShouldNotify(MotionScope oldWidget) =>
      oldWidget.info.reduced != info.reduced;
}

/// Wrapper یک‌بار‌مصرف برای ظاهر شدن پلکانی اجزا هنگام ورود صفحه.
///
/// فقط شفافیت و جابه‌جایی عمودی را انیمیت می‌کند و پس از پایان، هیچ
/// Ticker فعالی باقی نمی‌ماند؛ برای لیست‌های طولانی ارزان است.
class StaggeredReveal extends StatefulWidget {
  const StaggeredReveal({
    required this.index,
    required this.child,
    this.offsetY = 18,
    this.scale = 1,
    super.key,
  });

  final int index;
  final Widget child;
  final double offsetY;
  final double scale;

  @override
  State<StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<StaggeredReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final reduced = !context.motion.enabled;
    _controller = AnimationController(
      vsync: this,
      duration: AppMotion.entrance,
    );
    if (reduced) {
      _controller.value = 1;
    } else {
      _controller.forward(
        delay: AppMotion.staggerStartDelay +
            AppMotion.staggerStep * widget.index.clamp(0, 8),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: AppMotion.curveEntrance,
    );
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, (1 - curved.value) * widget.offsetY),
          child: widget.scale == 1 ? child : Transform.scale(
            scale: 1 - (1 - curved.value) * (1 - widget.scale),
            child: child,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

/// مقیاس ظریف هنگام لمس + بازگشت فنری؛ جایگزین مستقیم InkWell برای کارت‌ها.
class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressedScale = .965,
    this.enableHaptics = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final bool enableHaptics;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed && context.motion.enabled
        ? widget.pressedScale
        : 1.0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) {
        _setPressed(false);
        if (widget.enableHaptics) HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: scale,
        duration: _pressed ? AppMotion.micro : AppMotion.quick,
        curve: _pressed ? Curves.easeOut : AppMotion.curvePop,
        child: widget.child,
      ),
    );
  }
}
