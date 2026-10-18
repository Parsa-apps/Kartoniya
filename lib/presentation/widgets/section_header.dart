import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';

/// سرتیتر بخش‌های خانه و صفحات.
///
/// یک مدالیون کوچک (آیکون/اموجی) با گرادیان برند، عنوان، زیرعنوان و اکشن
/// اختیاری «دیدن همه». این ساختار در همهٔ ریل‌ها تکرار می‌شود تا سلسله‌مراتب
/// بصری خانه یکدست بماند.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    super.key,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.emoji,
    this.accent = AppColors.sky,
    this.padding = const EdgeInsets.fromLTRB(
      AppTheme.pageMargin,
      AppTheme.spacingLg,
      AppTheme.pageMargin,
      AppTheme.spacingSm + 4,
    ),
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final String? emoji;
  final Color accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final hasBadge = icon != null || emoji != null;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (hasBadge)
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color.lerp(accent, Colors.white, .28)!,
                    accent,
                    Color.lerp(accent, const Color(0xFF14213B), .22)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(.24),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: emoji != null
                  ? Text(
                      emoji!,
                      style: const TextStyle(fontSize: 16, height: 1),
                    )
                  : Icon(icon, color: Colors.white, size: 19),
            )
          else
            Container(
              width: 8,
              height: 26,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.lerp(accent, Colors.white, .25)!, accent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.secondaryTextColor,
                        ),
                  ),
              ],
            ),
          ),
          if (actionLabel != null)
            PressableScale(
              onTap: onAction,
              enableHaptics: false,
              pressedScale: .94,
              child: Container(
                padding: const EdgeInsetsDirectional.only(
                  start: 12,
                  end: 7,
                  top: 6,
                  bottom: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withOpacity(context.isDarkMode ? .18 : .10),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 17,
                      color: accent,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// نسخهٔ سبک سربرگ برای داخل کارت‌ها و بخش‌های فشرده.
class MiniSectionLabel extends StatelessWidget {
  const MiniSectionLabel({
    required this.title,
    super.key,
    this.icon,
    this.color = AppColors.skyDeep,
  });

  final String title;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: .2,
              ),
        ),
      ],
    );
  }
}
