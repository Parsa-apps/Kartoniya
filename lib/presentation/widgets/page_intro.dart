import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';

/// سربرگ یکپارچهٔ برگه‌ها (دسته‌ها، جست‌وجو، علاقه‌مندی‌ها).
///
/// ترکیب یک نشان گرادیانی کوچک، عنوان، زیرعنوان و اکشن اختیاری. زیرعنوان
/// با AnimatedSwitcher عوض می‌شود تا شمارنده‌ها بدون پرش layout تغییر کنند.
class PageIntro extends StatelessWidget {
  const PageIntro({
    required this.title,
    required this.subtitle,
    required this.icon,
    super.key,
    this.gradient,
    this.trailing,
    this.leading,
    this.padding = const EdgeInsets.fromLTRB(
      AppTheme.pageMargin,
      18,
      AppTheme.pageMargin,
      10,
    ),
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient? gradient;
  final Widget? trailing;

  /// جایگزین اختیاری مدالیون آیکون؛ برای تصویر صحنه یا آواتار.
  final Widget? leading;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          leading ??
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: gradient ?? AppColors.coolGradient,
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusMedium + 2),
                  boxShadow: AppTheme.glow(
                    gradient == null ? AppColors.violet : AppColors.sky,
                    opacity: .26,
                    lift: 6,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                AnimatedSwitcher(
                  duration: context.motion.dur(AppMotion.quick),
                  child: Text(
                    subtitle,
                    key: ValueKey(subtitle),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.secondaryTextColor,
                        ),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
