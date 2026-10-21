import 'package:flutter/material.dart';

import '../../core/services/app_haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/game_achievement.dart';
import 'kartoniya_mascot.dart';

/// جشن کوتاهِ باز شدن یک نشان تازه.
///
/// فقط وقتی صدا زده می‌شود که فهرست نشان‌های باز قبل و بعد از یک بازی واقعاً
/// تفاوت کرده باشد؛ هیچ وضعیت «دیده‌شده» ذخیره نمی‌شود و هیچ داده‌ای جابه‌جا
/// نمی‌شود. اگر «کاهش حرکت» روشن باشد، ورود بی‌درنگ است.
Future<void> showAchievementCelebration(
  BuildContext context,
  List<GameAchievement> achievements,
) {
  if (achievements.isEmpty) return Future<void>.value();
  AppHaptics.medium();
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'بستن پیام دستاورد',
    barrierColor: Colors.black.withOpacity(.45),
    transitionDuration: context.motion.dur(AppMotion.soft),
    pageBuilder: (dialogContext, _, __) => AchievementCelebrationCard(
      achievements: achievements,
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.curvePop,
        reverseCurve: AppMotion.curveExit,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: .93, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// کارت جشن نشان‌های تازه‌بازشده.
///
/// رنگ‌ها از تم خوانده می‌شوند تا در حالت تاریک هم روی سطح تیره خوانا بماند و
/// محتوا در `SingleChildScrollView` است تا با متن بزرگ‌تر از ۱٫۳× روی گوشی
/// کوچک سرریز ندهد.
class AchievementCelebrationCard extends StatelessWidget {
  const AchievementCelebrationCard({
    required this.achievements,
    super.key,
  });

  final List<GameAchievement> achievements;

  @override
  Widget build(BuildContext context) {
    final stars = achievements.fold(0, (sum, item) => sum + item.stars);
    final goldText = AppColors.readableOn(context.surfaceColor, AppColors.gold);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusXXLarge),
                border: Border.all(color: AppColors.gold.withOpacity(.35)),
                boxShadow: AppTheme.mediumShadow(context),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 104,
                      height: 112,
                      child: KartoniyaMascot(
                        width: 104,
                        height: 112,
                        mood: MascotMood.cheering,
                        accent: AppColors.gold,
                        float: false,
                        entrance: true,
                        semanticLabel: 'فندوقی برای نشان تازه جشن می‌گیرد',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      achievements.length == 1
                          ? 'یک نشان تازه!'
                          : 'نشان‌های تازه!',
                      textAlign: TextAlign.center,
                      style: context.appText.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievements.length == 1
                          ? 'کارت عالی بود؛ یک نشان گرفتی.'
                          : '${toFaDigits('${achievements.length}')} نشان '
                              'با هم گرفتی.',
                      textAlign: TextAlign.center,
                      style: context.appText.bodySmall?.copyWith(
                        color: context.secondaryTextColor,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // حداکثر سه نشان نمایش داده می‌شود تا کارت بلند نشود؛
                    // بقیه با شمارش باقی‌مانده خلاصه می‌شوند.
                    for (final achievement in achievements.take(3))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _CelebrationRow(achievement: achievement),
                      ),
                    if (achievements.length > 3)
                      Text(
                        'و ${toFaDigits('${achievements.length - 3}')} '
                        'نشان دیگر',
                        style: context.appText.labelSmall?.copyWith(
                          color: context.secondaryTextColor,
                        ),
                      ),
                    if (stars > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: goldText,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${toFaDigits('$stars')} ستاره گرفتی',
                              style: context.appText.labelLarge?.copyWith(
                                color: goldText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text('آفرین!'),
                      ),
                    ),
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

class _CelebrationRow extends StatelessWidget {
  const _CelebrationRow({required this.achievement});

  final GameAchievement achievement;

  @override
  Widget build(BuildContext context) {
    final accent = Color(achievement.colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Color.alphaBlend(accent.withOpacity(.12), context.surfaceColor),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: accent.withOpacity(.28)),
      ),
      child: Row(
        children: [
          Text(achievement.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  achievement.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  achievement.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.appText.bodySmall?.copyWith(
                    color: context.secondaryTextColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${toFaDigits('${achievement.stars}')} ⭐',
            style: context.appText.labelMedium,
          ),
        ],
      ),
    );
  }
}
