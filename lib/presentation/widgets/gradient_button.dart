import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';

/// دکمهٔ فراخوان اصلی (شروع تماشا، ادامهٔ تماشا، …) با گرادیان برند،
/// هالهٔ رنگی و مقیاس لمسی. برای اکشن‌های پرکاربرد در سراسر برنامه.
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
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Gradient? gradient;
  final Color? glowColor;
  final bool expand;
  final double height;
  final bool compact;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final requested = widget.gradient ?? AppColors.primaryGradient;
    // رنگ پرکننده و متن با هم انتخاب می‌شوند: روی طلایی/مرجانی متن سرمه‌ای
    // (کنتراست >۷) و روی آبی برند متن سفید با پرکنندهٔ کمی تیره‌تر.
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

    Widget content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
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
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : .55,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          onTapUp: enabled
              ? (_) {
                  setState(() => _pressed = false);
                  HapticFeedback.selectionClick();
                  widget.onPressed?.call();
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
                  widget.compact ? AppTheme.radiusMedium : AppTheme.radiusLarge,
                ),
                boxShadow: enabled && !_pressed
                    ? AppTheme.glow(glow, opacity: .38, lift: 8)
                    : AppTheme.glow(glow, opacity: .18, lift: 3),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // هایلایت شیشه‌ای فقط وقتی متن سرمه‌ای است؛ سفیدِ روی
                  // پرکنندهٔ تیره کنتراست متن سفید را زیر ۴٫۵ می‌آورد.
                  if (foreground != Colors.white)
                    PositionedDirectional(
                      top: 0,
                      start: 0,
                      end: 0,
                      height: widget.height * .5,
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
                  content,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
