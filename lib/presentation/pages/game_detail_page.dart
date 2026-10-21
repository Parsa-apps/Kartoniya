// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/services/app_haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/game_model.dart';
import '../../data/providers/achievements_provider.dart';
import '../../data/providers/games_provider.dart';
import '../games/game_router.dart';
import '../widgets/achievement_celebration.dart';

/// صفحهٔ معرفی یک بازی: هدر رنگی، مشخصات، دستورالعمل و دکمهٔ شروع واقعی.
///
/// سطح‌ها و متن‌ها از تم خوانده می‌شوند تا حالت تاریک هم خوانا بماند؛ رنگ
/// لهجهٔ هر بازی فقط برای آیکون و قاب استفاده می‌شود، نه پس‌زمینهٔ متن.
class GameDetailPage extends ConsumerWidget {
  const GameDetailPage({required this.game, super.key});

  final GameModel game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoriteGamesProvider).contains(game.id);
    final best = ref.watch(gameScoresProvider)[game.id];
    final startFill = AppColors.fillAndText(game.accentColor);
    final accentText = AppColors.readableOn(context.surfaceColor, game.accentColor);

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: context.pageBackground,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(.28),
                child: IconButton(
                  tooltip: 'بازگشت',
                  icon: const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: CircleAvatar(
                  backgroundColor: context.surfaceColor,
                  child: IconButton(
                    tooltip: isFav ? 'حذف از علاقه‌مندی‌ها' : 'افزودن به علاقه‌مندی‌ها',
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav
                          ? AppColors.readableOn(context.surfaceColor, AppColors.coral)
                          : context.secondaryTextColor,
                    ),
                    onPressed: () {
                      AppHaptics.light();
                      ref.read(favoriteGamesProvider.notifier).toggle(game.id);
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      game.accentColor.withOpacity(.22),
                      game.accentColor.withOpacity(.05),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
                    // هدر با ارتفاع ثابت است؛ اسکرول غیرقابل‌حرکت تضمین می‌کند
                    // با متن بزرگ سیستم هم سرریز و نوار زرد رخ ندهد.
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: game.accentColor.withOpacity(.28),
                            ),
                            boxShadow: AppTheme.glow(game.accentColor,
                                opacity: .18, lift: 8),
                          ),
                          child: Center(
                            child: Text(
                              game.thumbnailEmoji,
                              style: const TextStyle(fontSize: 44),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          game.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.appText.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              game.category.color.withOpacity(.16),
                              context.surfaceColor,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${game.category.emoji} ${game.category.labelFa} • ${game.difficulty.labelFa}',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.readableOn(
                                Color.alphaBlend(
                                  game.category.color.withOpacity(.16),
                                  context.surfaceColor,
                                ),
                                game.category.color,
                              ),
                            ),
                          ),
                        ),
                      ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.pageMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoPill(
                        icon: Icons.timer_outlined,
                        text: '${toFaDigits('${game.estimatedMinutes}')} دقیقه',
                      ),
                      _InfoPill(
                        icon: Icons.child_care_rounded,
                        text: toFaDigits(game.ageLabel),
                      ),
                      _InfoPill(
                        icon: Icons.emoji_events_rounded,
                        text: best == null
                            ? 'بدون رکورد'
                            : 'بهترین: ${toFaDigits('$best')}',
                        accent: best == null ? null : AppColors.goldDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.surfaceColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(color: context.softBorderColor),
                      boxShadow: AppTheme.softShadow(context),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 18, color: accentText),
                            const SizedBox(width: 6),
                            Text(
                              'دربارهٔ بازی',
                              style: context.appText.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          game.description,
                          style:
                              context.appText.bodyMedium?.copyWith(height: 1.7),
                        ),
                        if (game.instructions.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color.alphaBlend(
                                game.accentColor.withOpacity(.10),
                                context.surfaceColor,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.lightbulb_outline_rounded,
                                    size: 18,
                                    color: AppColors.readableOn(
                                      context.surfaceColor,
                                      AppColors.warning,
                                    )),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    game.instructions,
                                    style: context.appText.bodySmall
                                        ?.copyWith(height: 1.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () => _startGame(context, ref),
                      icon: const Icon(Icons.play_arrow_rounded, size: 26),
                      label: const Text(
                        'شروع بازی',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: startFill.fill,
                        foregroundColor: startFill.foreground,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                    ),
                  ),
                  if (game.tags.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: game.tags
                          .map(
                            (tag) => Chip(
                              label: Text('#$tag'),
                              visualDensity: VisualDensity.compact,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بازی را باز می‌کند و پس از بازگشت، نشان‌های تازه را جشن می‌گیرد.
  ///
  /// مقایسهٔ فهرست نشان‌های باز «قبل و بعد» انجام می‌شود؛ چون خودِ نشان‌ها
  /// مشتق از رکوردهای ذخیره‌شده‌اند، بدون هیچ وضعیت تازه‌ای دقیقاً همان
  /// نشان‌هایی که با همین بازی باز شده‌اند نمایش داده می‌شوند.
  Future<void> _startGame(BuildContext context, WidgetRef ref) async {
    final before = unlockedAchievementIds(ref.read(achievementsProvider));
    AppHaptics.medium();
    ref.read(recentGamesProvider.notifier).add(game.id);
    await pushAppPage<void>(context, buildGameForMechanics(game));
    if (!context.mounted) return;
    final gained = newlyUnlockedAchievements(
      before: before,
      after: ref.read(achievementsProvider),
    );
    if (gained.isEmpty || !context.mounted) return;
    await showAchievementCelebration(context, gained);
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text, this.accent});

  final IconData icon;
  final String text;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.softBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent ?? context.secondaryTextColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: context.appText.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
