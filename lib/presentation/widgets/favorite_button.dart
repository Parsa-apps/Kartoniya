import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_motion.dart';

/// دکمهٔ علاقه‌مندی با بازخورد آنی: پاپ قلب، موج حلقوی هنگام افزودن و
/// تغییر رنگ نرم. منطق ذخیره‌سازی بیرون از ویجت است؛ این فقط نمایش/لمس.
class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    required this.isFavorite,
    required this.onPressed,
    super.key,
    this.size = 34,
    this.iconSize = 19,
    this.tooltip,
    this.style = FavoriteButtonStyle.glass,
  });

  final bool isFavorite;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final String? tooltip;
  final FavoriteButtonStyle style;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

enum FavoriteButtonStyle { glass, solid, plain }

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burst;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.32),
        weight: 3,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.32, end: .92).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: .92, end: 1.0).chain(
          CurveTween(curve: AppMotion.curvePop),
        ),
        weight: 3,
      ),
    ]).animate(_burst);
  }

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isFavorite && widget.isFavorite && context.motion.enabled) {
      _burst.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    if (widget.isFavorite && context.motion.enabled) _burst.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isFav = widget.isFavorite;
    final background = switch (widget.style) {
      FavoriteButtonStyle.glass =>
        isFav ? AppColors.red.withOpacity(.95) : Colors.white.withOpacity(.92),
      FavoriteButtonStyle.solid =>
        isFav ? AppColors.red : Theme.of(context).colorScheme.surfaceVariant,
      FavoriteButtonStyle.plain =>
        isFav ? AppColors.red.withOpacity(.14) : Colors.transparent,
    };
    final foreground = switch (widget.style) {
      FavoriteButtonStyle.glass => isFav ? Colors.white : AppColors.red,
      FavoriteButtonStyle.solid =>
        isFav ? Colors.white : context.secondaryTextColor,
      FavoriteButtonStyle.plain =>
        isFav ? AppColors.red : context.secondaryTextColor,
    };

    Widget icon = AnimatedSwitcher(
      duration: context.motion.dur(AppMotion.quick),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: Icon(
        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        key: ValueKey(isFav),
        size: widget.iconSize,
        color: foreground,
      ),
    );

    final button = AnimatedBuilder(
      animation: _burst,
      builder: (context, child) {
        final ripple = _burst.isAnimating || _burst.value > 0
            ? Curves.easeOutCubic.transform(1 - _burst.value)
            : 0.0;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (isFav && ripple > 0)
              Container(
                width: widget.size + widget.size * .5 * _burst.value,
                height: widget.size + widget.size * .5 * _burst.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.red.withOpacity(.45 * ripple),
                    width: 2,
                  ),
                ),
              ),
            Transform.scale(scale: _scale.value, child: child),
          ],
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: widget.style == FavoriteButtonStyle.plain
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(.14),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Center(child: icon),
      ),
    );

    return Semantics(
      button: true,
      toggled: isFav,
      label: isFav ? 'حذف از علاقه‌مندی‌ها' : 'افزودن به علاقه‌مندی‌ها',
      excludeSemantics: true,
      child: Tooltip(
        message: widget.tooltip ??
            (isFav ? 'حذف از علاقه‌مندی‌ها' : 'افزودن به علاقه‌مندی‌ها'),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _handleTap,
            child: button,
          ),
        ),
      ),
    );
  }
}
