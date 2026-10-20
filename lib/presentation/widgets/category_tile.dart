import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/cartoon_model.dart';

/// آیکون برداری هر دسته.
///
/// پیش‌تر مدالیون دسته اموجی سیستم را نشان می‌داد؛ چون شکل اموجی به فونت
/// دستگاه وابسته است و در همه‌جا یکسان رندر نمی‌شود، به آیکون برداری
/// Material تغییر کرد. شناسهٔ ناشناخته هم آیکون عمومی می‌گیرد تا هرگز
/// مربع خالی دیده نشود.
IconData categoryIcon(CategoryModel category) {
  switch (category.id) {
    case 'all':
      return Icons.auto_awesome_rounded;
    case 'adventure':
      return Icons.rocket_launch_rounded;
    case 'comedy':
      return Icons.sentiment_very_satisfied_rounded;
    case 'animals':
      return Icons.pets_rounded;
    case 'educational':
      return Icons.auto_stories_rounded;
    case 'friendship':
      return Icons.diversity_3_rounded;
    case 'fantasy':
      return Icons.auto_fix_high_rounded;
    case 'short':
      return Icons.movie_rounded;
    case 'classic':
      return Icons.history_edu_rounded;
    case 'toddler':
      return Icons.child_care_rounded;
    case 'education':
      return Icons.menu_book_rounded;
    case 'fun':
      return Icons.celebration_rounded;
    case 'art':
      return Icons.palette_rounded;
    case 'science':
      return Icons.science_rounded;
    case 'music':
      return Icons.music_note_rounded;
    default:
      return Icons.category_rounded;
  }
}

/// قرص دستهٔ افقی برای ریل خانه و فیلترهای جست‌وجو.
///
/// حالت انتخاب‌شده با گرادیان دسته و متن سفید مشخص می‌شود؛ حالت عادی یک
/// سطح روشن با حاشیهٔ رنگی بسیار ملایم است تا صفحه شلوغ نشود.
class CategoryPill extends StatelessWidget {
  const CategoryPill({
    required this.category,
    required this.selected,
    required this.onTap,
    super.key,
    this.count,
    this.compact = false,
  });

  final CategoryModel category;
  final bool selected;
  final VoidCallback onTap;

  /// تعداد واقعی محتوا؛ اگر null باشد نمایش داده نمی‌شود.
  final int? count;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    // کاشی روشن با متن سرمه‌ای: رنگ برند زنده می‌ماند و متن خوانا است.
    final contentColor =
        selected ? AppColors.deepInk : context.primaryTextColor;
    return Semantics(
      button: true,
      selected: selected,
      label: count == null
          ? category.name
          : '${category.name}، ${toFaDigits('$count')} کارتون',
      excludeSemantics: true,
      child: PressableScale(
        onTap: onTap,
        pressedScale: .95,
        child: AnimatedContainer(
          duration: context.motion.dur(AppMotion.quick),
          curve: AppMotion.curveStandard,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 8 : 9,
          ),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.tileGradient(color) : null,
            color: selected ? null : context.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
            border: Border.all(
              color: selected
                  ? AppColors.deepInk.withOpacity(.16)
                  : color.withOpacity(.26),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(selected ? .32 : .10),
                blurRadius: selected ? 16 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 22 : 25,
                height: compact ? 22 : 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(.20)
                      : color.withOpacity(.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  categoryIcon(category),
                  size: compact ? 14 : 16,
                  color: AppColors.deepInk.withOpacity(selected ? .92 : .74),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                category.name,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: contentColor,
                      fontSize: compact ? 12.5 : 13.5,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Text(
                  toFaDigits('$count'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected
                            ? AppColors.deepInk.withOpacity(.72)
                            : AppColors.readableOn(
                                context.surfaceColor,
                                color,
                              ),
                        fontWeight: FontWeight.w700,
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

/// کاشی بزرگ دسته در صفحهٔ دسته‌بندی‌ها.
///
/// یک سطح گرادیانی با مدالیون ایموجی، نام، تعداد واقعی و نشان انتخاب. روی
/// هر اندازه‌ای یک layout ثابت و لمس‌پذیر دارد و متن‌ها با ellipsis مهار
/// می‌شوند تا overflow رخ ندهد.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    required this.category,
    required this.count,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final CategoryModel category;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = category.color;
    return Semantics(
      button: true,
      selected: selected,
      label: '${category.name}، ${toFaDigits('$count')} کارتون',
      excludeSemantics: true,
      child: PressableScale(
        onTap: onTap,
        pressedScale: .96,
        child: AnimatedContainer(
          duration: context.motion.dur(AppMotion.soft),
          curve: AppMotion.curveStandard,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            // کاشی روشن با متن سرمه‌ای: شادی رنگ دسته حفظ می‌شود و
            // برچسب/تعداد/آیکون‌ها ≥۴٫۵:۱ خوانا می‌مانند.
            gradient: AppColors.tileGradient(color),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: selected
                  ? AppColors.deepInk.withOpacity(.55)
                  : AppColors.deepInk.withOpacity(.10),
              width: selected ? 2.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(selected ? .40 : .22),
                blurRadius: selected ? 24 : 16,
                spreadRadius: selected ? 1 : -2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // هالهٔ تزئینی گوشه؛ بدون حرکت و ارزان.
              PositionedDirectional(
                top: -18,
                end: -14,
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.34),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.55),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: Colors.white.withOpacity(.70),
                          ),
                        ),
                        child: Icon(
                          categoryIcon(category),
                          size: 20,
                          color: AppColors.deepInk.withOpacity(.86),
                        ),
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: context.motion.dur(AppMotion.micro),
                        child: selected
                            ? Container(
                                key: const ValueKey('selected'),
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 17,
                                  color: color,
                                ),
                              )
                            : Icon(
                                Icons.chevron_left_rounded,
                                key: const ValueKey('idle'),
                                size: 18,
                                color: AppColors.deepInk.withOpacity(.55),
                              ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.deepInk,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    count == 0 ? 'به‌زودی' : '${toFaDigits('$count')} کارتون',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.deepInk.withOpacity(.78),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ردیف افقی قرص‌های دسته با padding صفحه؛ برای خانه و نتایج.
class CategoryPillRow extends StatelessWidget {
  const CategoryPillRow({
    required this.categories,
    required this.selectedName,
    required this.onSelected,
    super.key,
    this.counts,
    this.height = 44,
    this.includeAll = false,
    this.compact = false,
  });

  final List<CategoryModel> categories;
  final String? selectedName;
  final ValueChanged<CategoryModel?> onSelected;
  final Map<String, int>? counts;
  final double height;
  final bool includeAll;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final visible = (includeAll
            ? categories
            : categories.where((category) => category.id != 'all'))
        .toList(growable: false);
    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageMargin),
        child: Row(
          children: [
            for (var i = 0; i < visible.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Builder(builder: (context) {
                final category = visible[i];
                final isAll = category.id == 'all';
                final selected = isAll
                    ? selectedName == null
                    : selectedName == category.name;
                return CategoryPill(
                  category: category,
                  selected: selected,
                  compact: compact,
                  count:
                      counts == null ? null : counts![category.name] ?? 0,
                  onTap: () => onSelected(isAll ? null : category),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
