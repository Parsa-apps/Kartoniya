import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/cartoon_model.dart';
import '../../data/providers/cartoons_provider.dart';
import 'animated_progress.dart';
import 'cartoon_artwork.dart';
import 'favorite_button.dart';

/// کارت یکپارچهٔ کاتالوگ: پوستر، وضعیت علاقه‌مندی، درصد واقعی ادامهٔ تماشا
/// و بازخورد لمسی نرم. برای شبکهٔ ستونی، ردیف‌های افقی و نتایج جست‌وجو.
class CartoonCard extends ConsumerWidget {
  const CartoonCard({
    super.key,
    required this.cartoon,
    required this.onTap,
    this.compact = false,
    this.showProgress = true,
  });

  final CartoonModel cartoon;
  final VoidCallback onTap;
  final bool compact;
  final bool showProgress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(cartoon.id);
    final categoryColor = AppColors.categoryColor(cartoon.category);
    final progress = showProgress
        ? _maxProgress(ref.watch(watchHistoryProvider))
        : 0.0;

    return Semantics(
      button: true,
      label: '${cartoon.title}، ${cartoon.category}، امتیاز '
          '${toFaDigits(cartoon.rating.toStringAsFixed(1))}',
      child: PressableScale(
        onTap: onTap,
        child: Card(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: compact ? 1.55 : 1.42,
                    child: CartoonArtwork(
                      cartoon: cartoon,
                      borderRadius: 0,
                      showPlayAffordance: !compact,
                      showAgeBadge: !compact,
                    ),
                  ),
                  PositionedDirectional(
                    top: 8,
                    start: 8,
                    child: FavoriteButton(
                      isFavorite: isFavorite,
                      size: 32,
                      iconSize: 17,
                      onPressed: () =>
                          ref.read(favoritesProvider.notifier).toggle(cartoon.id),
                    ),
                  ),
                  if (progress > 0)
                    PositionedDirectional(
                      bottom: 0,
                      start: 0,
                      end: 0,
                      child: AnimatedProgressBar(
                        value: progress,
                        color: AppColors.gold,
                        height: 5,
                        background: Colors.black.withOpacity(.35),
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cartoon.title,
                        maxLines: compact ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: compact ? 13.5 : 15,
                            ),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(.13),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                cartoon.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: categoryColor,
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.gold,
                            size: 15,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            toFaDigits(cartoon.rating.toStringAsFixed(1)),
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _maxProgress(Map<String, double> history) {
    var max = 0.0;
    for (final episode in cartoon.episodes) {
      final value = history[episode.id] ?? 0.0;
      if (value > max) max = value;
    }
    return max;
  }
}

/// هدر کوتاه یک ردیف (عنوان + توضیح) که در خانه استفاده می‌شود.
class RowSectionTitle extends StatelessWidget {
  const RowSectionTitle({
    required this.title,
    required this.emoji,
    super.key,
    this.trailing,
  });

  final String title;
  final String emoji;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageMargin),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// برچسب‌های اطلاعاتی یکپارچه (امتیاز، مدت، سن، تعداد قسمت).
class InfoPill extends StatelessWidget {
  const InfoPill({
    required this.icon,
    required this.text,
    super.key,
    this.color,
  });

  final IconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final pillColor = color ?? context.secondaryTextColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: pillColor.withOpacity(.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
        border: Border.all(color: pillColor.withOpacity(.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: pillColor, size: 15),
          const SizedBox(width: 5),
          Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: pillColor,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
