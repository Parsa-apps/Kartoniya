import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/cartoon_model.dart';

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
    final contentColor = selected ? Colors.white : context.primaryTextColor;
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
            gradient: selected
                ? LinearGradient(
                    colors: [
                      Color.lerp(color, Colors.white, .18)!,
                      color,
                      Color.lerp(color, const Color(0xFF12203A), .18)!,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  )
                : null,
            color: selected ? null : context.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
            border: Border.all(
              color: selected ? Colors.transparent : color.withOpacity(.26),
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
                child: Text(
                  category.emoji,
                  style: TextStyle(fontSize: compact ? 12 : 13.5, height: 1),
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
                            ? Colors.white.withOpacity(.8)
                            : color.withOpacity(.9),
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
    final deep = Color.lerp(color, const Color(0xFF10203A), .34)!;
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
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.lerp(color, Colors.white, .24)!,
                color,
                deep,
              ],
              stops: const [0, .58, 1],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: selected
                  ? Colors.white
                  : Colors.white.withOpacity(.28),
              width: selected ? 2.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(selected ? .42 : .22),
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
                    color: Colors.white.withOpacity(.13),
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
                          color: Colors.white.withOpacity(.22),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: Colors.white.withOpacity(.34),
                          ),
                        ),
                        child: Text(
                          category.emoji,
                          style: const TextStyle(fontSize: 19, height: 1),
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
                                color: Colors.white.withOpacity(.72),
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
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    count == 0
                        ? 'به‌زودی'
                        : '${toFaDigits('$count')} کارتون',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white.withOpacity(.84),
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
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageMargin),
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = visible[index];
          final isAll = category.id == 'all';
          final selected =
              isAll ? selectedName == null : selectedName == category.name;
          return CategoryPill(
            category: category,
            selected: selected,
            compact: compact,
            count: counts == null ? null : counts![category.name] ?? 0,
            onTap: () => onSelected(isAll ? null : category),
          );
        },
      ),
    );
  }
}
