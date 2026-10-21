// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/game_achievement.dart';
import '../../data/providers/achievements_provider.dart';
import '../widgets/animated_progress.dart';
import '../widgets/kartoniya_mascot.dart';
import '../widgets/page_intro.dart';

/// صفحهٔ «دستاوردهای من».
///
/// همهٔ نشان‌ها **مشتق** از دادهٔ محلی‌اند: بهترین رکورد هر بازی، بازی‌های
/// نشان‌شده و دستهٔ آن‌ها. هیچ شمارندهٔ ساختگی یا سرور در کار نیست؛ پس با
/// پاک‌کردن داده در تنظیمات والدین، نشان‌ها هم واقعاً به صفر برمی‌گردند.
class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 230,
    mainAxisExtent: 200,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(achievementsProvider);
    final stats = ref.watch(gameStatsProvider);
    final stars = ref.watch(earnedStarsProvider);
    final next = ref.watch(nextAchievementProvider);
    final unlocked = items.where((item) => item.unlocked).length;
    final total = items.length;
    final ratio = total == 0 ? 0.0 : unlocked / total;
    final goldInk = AppColors.readableOn(context.surfaceColor, AppColors.gold);

    return Scaffold(
      appBar: AppBar(
        title: const Text('دستاوردها'),
        leading: IconButton(
          tooltip: 'بازگشت',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: PageIntro(
                    title: 'پیشرفت کودک',
                    subtitle:
                        '${toFaDigits('$unlocked')} از ${toFaDigits('$total')} نشان • ${toFaDigits('$stars')} ستاره',
                    icon: Icons.emoji_events_rounded,
                    gradient: AppColors.goldGradient,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(
                          AppColors.gold.withOpacity(.16),
                          context.surfaceColor,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 16, color: goldInk),
                          const SizedBox(width: 4),
                          Text(
                            toFaDigits('$stars'),
                            style: context.appText.labelLarge?.copyWith(
                              fontSize: 13,
                              color: goldInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.pageMargin,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.surfaceColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        border: Border.all(color: context.softBorderColor),
                        boxShadow: AppTheme.softShadow(context),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 76,
                            height: 84,
                            child: KartoniyaMascot(
                              width: 76,
                              height: 84,
                              mood: unlocked > 0
                                  ? MascotMood.cheering
                                  : MascotMood.sleepy,
                              accent: AppColors.gold,
                              float: false,
                              semanticLabel:
                                  'فندوقی و پیشرفت بازی‌های کودک',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  unlocked == total
                                      ? 'همهٔ نشان‌ها جمع شد!'
                                      : 'یک قدم تا نشان بعدی',
                                  style: context.appText.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                AnimatedProgressBar(
                                  value: ratio,
                                  color: AppColors.gold,
                                  height: 7,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  unlocked == total
                                      ? 'همهٔ ${toFaDigits('$total')} نشان باز شده‌اند؛ سالن افتخار کامل است.'
                                      : next == null
                                          ? 'نشان‌ها با بازی‌کردن باز می‌شوند.'
                                          : '«${next.achievement.title}» — ${toFaDigits('${next.value}')} از ${toFaDigits('${next.achievement.target}')}',
                                  style: context.appText.bodySmall?.copyWith(
                                    color: context.secondaryTextColor,
                                    height: 1.6,
                                  ),
                                ),
                                if (stats.isEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'با تمام‌کردن اولین بازی، اولین نشان را بگیر.',
                                    style: context.appText.bodySmall?.copyWith(
                                      color: context.secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.pageMargin,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: _gridDelegate,
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _AchievementTile(item: items[index]),
                      childCount: items.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.pageMargin,
                      18,
                      AppTheme.pageMargin,
                      32,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(
                          AppColors.teal.withOpacity(.10),
                          context.surfaceColor,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        border: Border.all(
                          color: AppColors.teal.withOpacity(.22),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 20,
                            color: AppColors.readableOn(
                              context.surfaceColor,
                              AppColors.teal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'نشان‌ها فقط از رکوردهای همین دستگاه ساخته می‌شوند؛ '
                              'هیچ داده‌ای به اینترنت فرستاده نمی‌شود و با پاک‌کردن '
                              'دادهٔ بازی‌ها در تنظیمات والدین، پیشرفت هم پاک می‌شود.',
                              style: context.appText.bodySmall?.copyWith(
                                color: context.secondaryTextColor,
                                height: 1.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// کاشی یک نشان؛ قفل‌شده‌ها خاکستری و با نوار پیشرفتِ واقعی نمایش داده
/// می‌شوند تا کودک بداند چقدر مانده، نه اینکه فقط «قفل» ببیند.
class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.item});

  final AchievementProgress item;

  @override
  Widget build(BuildContext context) {
    final achievement = item.achievement;
    final accent = Color(achievement.colorValue);
    final unlocked = item.unlocked;
    final surface = unlocked
        ? Color.alphaBlend(accent.withOpacity(.12), context.surfaceColor)
        : context.surfaceColor;
    final ink = unlocked
        ? AppColors.readableOn(surface, accent)
        : context.secondaryTextColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: unlocked ? accent.withOpacity(.35) : context.softBorderColor,
        ),
        boxShadow: unlocked ? AppTheme.softShadow(context) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: unlocked
                      ? LinearGradient(
                          colors: [
                            Color.lerp(accent, Colors.white, .28)!,
                            accent,
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        )
                      : null,
                  color: unlocked ? null : context.surfaceAltColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    achievement.emoji,
                    style: TextStyle(
                      fontSize: 22,
                      color: unlocked ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (unlocked)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, size: 12, color: ink),
                      const SizedBox(width: 2),
                      Text(
                        toFaDigits('${achievement.stars}'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: ink,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(Icons.lock_outline_rounded,
                    size: 18, color: context.secondaryTextColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appText.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              achievement.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.appText.bodySmall?.copyWith(
                color: context.secondaryTextColor,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 6),
          AnimatedProgressBar(
            value: item.progress,
            color: unlocked ? accent : context.scheme.outline,
            height: 5,
          ),
          const SizedBox(height: 4),
          Text(
            unlocked
                ? 'باز شد ✓'
                : '${toFaDigits('${item.value}')} از ${toFaDigits('${achievement.target}')}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appText.labelSmall?.copyWith(
              fontSize: 10.5,
              color: unlocked ? ink : context.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
