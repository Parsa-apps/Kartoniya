// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/game_model.dart';

/// کارت یک بازی در گرید.
///
/// سطح کارت **کدر** است (رنگ دسته روی رنگ سطح تم بلند می‌شود) تا متن‌ها در
/// حالت روشن و تاریک هر دو خوانا بمانند؛ اگر پس‌زمینه نیمه‌شفاف بماند، متنِ
/// روشنِ تم تاریک روی آن به‌طور تصادفی تیره یا ناخوانا می‌شود. رنگ برچسب‌ها با
/// [AppColors.readableOn] روی همان سطح کدر محاسبه می‌شود، پس کنتراست از
/// ۴٫۵:۱ پایین نمی‌آید.
class GameCard extends StatelessWidget {
  const GameCard({
    required this.game,
    required this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    super.key,
  });

  final GameModel game;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final surface = Color.alphaBlend(
      game.accentColor.withOpacity(isDark ? .18 : .08),
      context.surfaceColor,
    );
    final categoryChip =
        Color.alphaBlend(game.category.color.withOpacity(.16), surface);
    final categoryText =
        AppColors.readableOn(categoryChip, game.category.color);
    final accentTile =
        Color.alphaBlend(game.accentColor.withOpacity(.18), surface);
    final secondary = context.secondaryTextColor;
    final favoriteInk = isFavorite
        ? AppColors.readableOn(surface, AppColors.coral)
        : secondary;
    // متن بزرگ سیستم نباید کارت را سرریز کند؛ همان‌طور که ارتفاع لازم برای
    // متن زیاد می‌شود، بخش‌های کم‌اهمیت‌تر (توضیح، سپس برچسب‌ها) کنار می‌روند
    // تا عنوان و برچسب اصلی همیشه خوانا و بدون سرریز بمانند.
    final textScale =
        MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4).toDouble();

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final showDescription = !height.isFinite || height >= 165 * textScale;
        final showMeta = !height.isFinite || height >= 118 * textScale;
        return _buildCard(
          context,
          surface: surface,
          accentTile: accentTile,
          categoryChip: categoryChip,
          categoryText: categoryText,
          secondary: secondary,
          favoriteInk: favoriteInk,
          showDescription: showDescription,
          showMeta: showMeta,
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required Color surface,
    required Color accentTile,
    required Color categoryChip,
    required Color categoryText,
    required Color secondary,
    required Color favoriteInk,
    required bool showDescription,
    required bool showMeta,
  }) {
    final isDark = context.isDarkMode;
    return PressableScale(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: '${game.title} — ${game.category.labelFa}',
        child: Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: game.accentColor.withOpacity(isDark ? .30 : .18),
            ),
            boxShadow: AppTheme.softShadow(context),
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentTile,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        game.thumbnailEmoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (onFavorite != null)
                    Semantics(
                      button: true,
                      label: isFavorite
                          ? 'حذف ${game.title} از علاقه‌مندی‌ها'
                          : 'افزودن ${game.title} به علاقه‌مندی‌ها',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onFavorite,
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: isFavorite
                                    ? AppColors.coral.withOpacity(.16)
                                    : context.surfaceAltColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 17,
                                color: favoriteInk,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                game.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appText.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  height: 1.35,
                ),
              ),
              if (showDescription) ...[
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    game.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.appText.bodySmall?.copyWith(
                      color: secondary,
                      height: 1.25,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
              if (showMeta) ...[
                const SizedBox(height: 6),
                Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 3,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: categoryChip,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          game.category.emoji,
                          style: const TextStyle(fontSize: 10),
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            game.category.labelFa,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: categoryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 13,
                        color: secondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${game.estimatedMinutes}د',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: secondary,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.surfaceAltColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          game.difficulty.labelFa,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: context.primaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                ),
              ],
              if (!game.isPlayable) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'به‌زودی',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.readableOn(surface, AppColors.warning),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
