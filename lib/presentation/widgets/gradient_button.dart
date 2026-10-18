import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/app_haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';

/// دکمهٔ فراخوان اصلی (شروع تماشا، ادامهٔ تماشا، …) با گرادیان برند،
/// هالهٔ رنگی و حالت‌های لمس، فوکوس، غیرفعال و بارگذاری.
class GradientButton extends StatefulWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.gradient,
    this.glowColor,
    this.expand = false,
    this.height = 54,
    this.compact = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? glowColor;
  final bool expand;
  final double height;
  final bool compact;

  /// تا پایان کار واقعی، اکشن قفل می‌شود و نشانگر درون دکمه دیده می‌شود.
  final bool loading;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  late final FocusNode _focusNode;
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'Kartoniya primary action')
      ..addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    final focused = _focusNode.hasFocus;
    if (!mounted || _focused == focused) return;
    setState(() => _focused = focused);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GradientButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled && (_pressed || _focused)) {
      _pressed = false;
      _focused = false;
    }
  }

  void _activate() {
    if (!_enabled) return;
    AppHaptics.selection();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _enabled;
    final requested = widget.gradient ?? AppColors.primaryGradient;
    // رنگ پرکننده و متن با هم انتخاب می‌شوند: روی طلایی/مرجانی متن سرمه‌ای
    // و روی آبی برند متن سفید با پرکنندهٔ کمی تیره‌تر.
    final Gradient gradient;
    final Color foreground;
    if (requested is LinearGradient) {
      final resolved = AppColors.gradientAndText(requested);
      gradient = resolved.gradient;
      foreground = resolved.foreground;
    } else {
      gradient = requested;
      foreground = Colors.white;
    }
    final glow = widget.glowColor ?? AppColors.sky;

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading) ...[
          SizedBox(
            width: widget.compact ? 17 : 20,
            height: widget.compact ? 17 : 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, color: foreground, size: widget.compact ? 20 : 24),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foreground,
                  fontSize: widget.compact ? 13 : 15,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      value: widget.loading ? 'در حال بارگذاری' : null,
      liveRegion: widget.loading,
      excludeSemantics: true,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        enabled: enabled,
        mouseCursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: Opacity(
          opacity: widget.loading || enabled ? 1 : .55,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
            onTapCancel: enabled
                ? () => setState(() => _pressed = false)
                : null,
            onTapUp: enabled
                ? (_) {
                    setState(() => _pressed = false);
                    _activate();
                  }
                : null,
            child: AnimatedScale(
              scale: _pressed && context.motion.enabled ? .97 : 1,
              duration: context.motion.dur(AppMotion.micro),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: context.motion.dur(AppMotion.quick),
                height: widget.height,
                width: widget.expand ? double.infinity : null,
                padding: EdgeInsets.symmetric(
                  horizontal: widget.compact ? 16 : 24,
                ),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(
                    widget.compact
                        ? AppTheme.radiusMedium
                        : AppTheme.radiusLarge,
                  ),
                  border: Border.all(
                    color: _focused
                        ? AppColors.deepInk.withOpacity(.82)
                        : Colors.white.withOpacity(.30),
                    width: _focused ? 2 : 1,
                  ),
                  boxShadow: [
                    ...AppTheme.glow(
                      _focused ? AppColors.gold : glow,
                      opacity: _focused
                          ? .52
                          : (enabled && !_pressed ? .38 : .18),
                      lift: _focused ? 9 : (enabled && !_pressed ? 8 : 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // هایلایت شیشه‌ای فقط وقتی متن سرمه‌ای است؛ سفیدِ روی
                    // پرکنندهٔ تیره کنتراست متن سفید را کاهش می‌دهد.
                    if (foreground != Colors.white)
                      PositionedDirectional(
                        top: 0,
                        start: 0,
                        end: 0,
                        height: widget.height * .5,
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(
                                  widget.compact
                                      ? AppTheme.radiusMedium
                                      : AppTheme.radiusLarge,
                                ),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(.16),
                                  Colors.white.withOpacity(.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    content,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
