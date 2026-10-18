import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/cartoon_model.dart';
import '../../data/providers/cartoons_provider.dart';
import '../widgets/animated_progress.dart';
import '../widgets/cartoon_artwork.dart';
import '../widgets/cartoon_card.dart';
import '../widgets/favorite_button.dart';
import '../widgets/gradient_button.dart';
import '../widgets/kartoniya_mascot.dart';
import 'player_page.dart';

/// صفحهٔ جزئیات کارتون با Hero Transition از بنر/کارت انتخاب‌شده.
class CartoonDetailPage extends ConsumerWidget {
  const CartoonDetailPage({super.key, required this.cartoon});

  final CartoonModel cartoon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(cartoon.id);
    final history = ref.watch(watchHistoryProvider);
    final categoryColor = AppColors.categoryColor(cartoon.category);
    final categoryForeground = AppColors.categoryForeground(
      cartoon.category,
      brightness: Theme.of(context).brightness,
    );

    final resume = _resumeTarget(history);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: context.pageBackground,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: _CircleIconButton(
                tooltip: 'بازگشت',
                icon: Icons.arrow_forward_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: FavoriteButton(
                  isFavorite: isFavorite,
                  size: 42,
                  iconSize: 22,
                  style: context.isDarkMode
                      ? FavoriteButtonStyle.solid
                      : FavoriteButtonStyle.glass,
                  onPressed: () =>
                      ref.read(favoritesProvider.notifier).toggle(cartoon.id),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: CartoonArtwork.heroTagFor(cartoon),
                    child: CartoonArtwork(
                      cartoon: cartoon,
                      borderRadius: 0,
                      showPlayAffordance: false,
                      showTitle: false,
                      emphasis: true,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(.16),
                          Colors.transparent,
                          context.pageBackground,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.pageMargin,
                    14,
                    AppTheme.pageMargin,
                    40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StaggeredReveal(
                        index: 0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                cartoon.title,
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      StaggeredReveal(
                        index: 1,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            InfoPill(
                              icon: Icons.category_outlined,
                              color: categoryForeground,
                              text: cartoon.category,
                            ),
                            InfoPill(
                              icon: Icons.schedule_rounded,
                              text: 'مجموع زمان ${toFaDigits(cartoon.durationLabel)}',
                            ),
                            InfoPill(
                              icon: Icons.movie_outlined,
                              color: categoryForeground,
                              text: '${toFaDigits('${cartoon.episodeCount}')} قسمت',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      StaggeredReveal(
                        index: 2,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLarge),
                            border: Border.all(color: context.softBorderColor),
                            boxShadow: AppTheme.softShadow(context),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    size: 19,
                                    color: categoryForeground,
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    'دربارهٔ این کارتون',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cartoon.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: context.secondaryTextColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      StaggeredReveal(
                        index: 3,
                        child: GradientButton(
                          label: resume == null
                              ? 'شروع تماشا'
                              : 'ادامه از ${resume.episodeTitle}',
                          icon: resume == null
                              ? Icons.play_circle_fill_rounded
                              : Icons.play_arrow_rounded,
                          expand: true,
                          gradient: AppColors.actionGradient(categoryColor),
                          glowColor: categoryColor,
                          onPressed: () =>
                              _play(context, resume?.episode ?? cartoon.firstEpisode),
                        ),
                      ),
                      const SizedBox(height: 26),
                      StaggeredReveal(
                        index: 4,
                        child: Row(
                          children: [
                            Text(
                              'قسمت‌ها',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                toFaDigits('${cartoon.episodeCount}'),
                                style:
                                    Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: categoryForeground,
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...cartoon.episodes.map(
                        (episode) => _EpisodeTile(
                          episode: episode,
                          color: categoryForeground,
                          progress: episode.secureDirectVideoUri == null
                              ? 0.0
                              : history[episode.id] ?? 0.0,
                          onTap: () => _play(context, episode),
                        ),
                      ),
                      if (cartoon.tags.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        StaggeredReveal(
                          index: 5,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: cartoon.tags
                                .map(
                                  (tag) => Chip(
                                    label: Text('#$tag'),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          KartoniyaMascot(
                            mood: MascotMood.happy,
                            size: 54,
                            float: false,
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'رده‌بندی سنی رسمی ثبت نشده؛ بزرگ‌ترها پیش از پخش، محتوا را بررسی کنند.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// اولین قسمتی که کاربر نیمه‌کاره رها کرده (بیشترین درصد موجود).
  ({EpisodeModel episode, String episodeTitle})? _resumeTarget(
    Map<String, double> history,
  ) {
    EpisodeModel? best;
    var bestValue = 0.0;
    for (final episode in cartoon.episodes) {
      if (episode.secureDirectVideoUri == null) continue;
      final value = history[episode.id] ?? 0.0;
      if (value > .01 && value < .995 && value > bestValue) {
        best = episode;
        bestValue = value;
      }
    }
    if (best == null) return null;
    return (episode: best, episodeTitle: best.title);
  }

  void _play(BuildContext context, EpisodeModel episode) {
    pushAppPageFade<void>(
      context,
      PlayerPage(cartoon: cartoon, episode: episode),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      excludeSemantics: true,
      child: Tooltip(
        message: tooltip ?? '',
        child: Material(
          color: Colors.black.withOpacity(.34),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({
    required this.episode,
    required this.color,
    required this.progress,
    required this.onTap,
  });

  final EpisodeModel episode;
  final Color color;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasProgress = progress > .01 && progress < .995;
    final isDone = progress >= .995;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PressableScale(
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                ProgressRing(
                  value: isDone ? 1 : progress,
                  color: color,
                  size: 46,
                  child: Icon(
                    hasProgress
                        ? Icons.play_arrow_rounded
                        : isDone
                            ? Icons.check_rounded
                            : Icons.movie_rounded,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        episode.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        toFaDigits(episode.durationLabel),
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: context.secondaryTextColor,
                            ),
                      ),
                      if (hasProgress) ...[
                        const SizedBox(height: 7),
                        AnimatedProgressBar(
                          value: progress,
                          color: color,
                          height: 4.5,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: color,
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
