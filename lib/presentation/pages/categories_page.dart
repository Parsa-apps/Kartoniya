import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/cartoon_model.dart';
import '../../data/providers/cartoons_provider.dart';
import '../widgets/cartoon_card.dart';
import '../widgets/category_tile.dart';
import '../widgets/kartoniya_mascot.dart';
import '../widgets/kartoniya_story_banner.dart';
import '../widgets/page_intro.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/state_views.dart';
import 'cartoon_detail_page.dart';

/// دسته‌بندی‌ها: یک ریل افقی از کاشی‌های رنگی واقعی (با شمارش کاتالوگ) و
/// گرید فیلترشده با وضعیت‌های loading / empty / error.
///
/// فیلتر در [selectedCategoryProvider] می‌ماند تا بین برگه‌ها و جست‌وجو
/// هم‌خوان بماند. تصویر باغ قصه به‌عنوان نشان سربرگ استفاده می‌شود و کل
/// بارگذاری کاتالوگ از همان providerهای موجود انجام می‌شود.
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final cartoons = ref.watch(cartoonsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    final all = cartoons.valueOrNull ?? const <CartoonModel>[];
    final counts = <String, int>{
      for (final category in categories.valueOrNull ?? const <CategoryModel>[])
        category.name: category.id == 'all'
            ? all.length
            : all.where((item) => item.category == category.name).length,
    };

    final visible = selectedCategory == null
        ? all
        : all
            .where((item) => item.category == selectedCategory)
            .toList(growable: false);

    final subtitle = cartoons.maybeWhen(
      data: (items) {
        final categoryCount = categories.valueOrNull == null
            ? null
            : (categories.valueOrNull!.length - 1).clamp(0, 99);
        final countLabel = '${toFaDigits('${items.length}')} کارتون';
        return categoryCount == null
            ? countLabel
            : '${toFaDigits('$categoryCount')} دسته • $countLabel';
      },
      orElse: () => 'دسته‌ات را انتخاب کن',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'دسته‌بندی‌ها',
          subtitle: subtitle,
          icon: Icons.grid_view_rounded,
          gradient: AppColors.violetGradient,
          leading: const _SceneThumb(),
          trailing: selectedCategory == null
              ? null
              : IconButton.filledTonal(
                  tooltip: 'پاک کردن فیلتر',
                  onPressed: () =>
                      ref.read(selectedCategoryProvider.notifier).state = null,
                  icon: const Icon(Icons.filter_alt_off_rounded, size: 21),
                ),
        ),
        categories.when(
          data: (items) => SizedBox(
            height: 126,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.pageMargin,
                vertical: 4,
              ),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = items[index];
                final isAll = category.id == 'all';
                final selected = isAll
                    ? selectedCategory == null
                    : selectedCategory == category.name;
                return SizedBox(
                  width: 148,
                  child: StaggeredReveal(
                    index: index,
                    offsetY: 10,
                    child: CategoryTile(
                      category: category,
                      count: counts[category.name] ?? 0,
                      selected: selected,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(selectedCategoryProvider.notifier).state =
                            isAll ? null : category.name;
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          loading: () => const SizedBox(
            height: 126,
            child: _CategoryRailLoading(),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
            child: ErrorStateView(
              title: 'دسته‌ها باز نشدند',
              message: 'برای دیدن دسته‌بندی‌ها دوباره تلاش کن.',
              onRetry: () {
                ref.invalidate(categoriesProvider);
                ref.invalidate(cartoonsProvider);
              },
              compact: true,
            ),
          ),
        ),
        SectionHeader(
          title: selectedCategory ?? 'همهٔ کارتون‌ها',
          subtitle: cartoons.maybeWhen(
            data: (_) => '${toFaDigits('${visible.length}')} کارتون',
            orElse: () => null,
          ),
          icon: Icons.movie_filter_rounded,
          accent: selectedCategory == null
              ? AppColors.sky
              : AppColors.categoryColor(selectedCategory),
          actionLabel: selectedCategory == null ? null : 'پاک کردن',
          onAction: selectedCategory == null
              ? null
              : () => ref.read(selectedCategoryProvider.notifier).state = null,
          padding: const EdgeInsets.fromLTRB(
            AppTheme.pageMargin,
            16,
            AppTheme.pageMargin,
            8,
          ),
        ),
        Expanded(
          child: cartoons.when(
            data: (items) {
              if (items.isEmpty) {
                return EmptyStateView(
                  title: 'هنوز کارتونی آماده نیست',
                  message: 'کاتالوگ خالی است؛ با «تلاش دوباره» بررسی کن.',
                  mascot: MascotMood.sleepy,
                  action: OutlinedButton.icon(
                    onPressed: () => ref.invalidate(cartoonsProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('تلاش دوباره'),
                  ),
                );
              }
              final filtered = selectedCategory == null
                  ? items
                  : items
                      .where((item) => item.category == selectedCategory)
                      .toList(growable: false);
              if (filtered.isEmpty) {
                return EmptyStateView(
                  title: 'این دسته فعلاً خالی است',
                  message: 'این دسته به‌زودی با کارتون‌های تازه پر می‌شود؛ '
                      'یک دستهٔ دیگر را امتحان کن.',
                  mascot: MascotMood.confused,
                  accent: AppColors.coral,
                  action: OutlinedButton.icon(
                    onPressed: () => ref
                        .read(selectedCategoryProvider.notifier)
                        .state = null,
                    icon: const Icon(Icons.filter_alt_off_rounded),
                    label: const Text('نمایش همهٔ کارتون‌ها'),
                  ),
                );
              }
              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.pageMargin,
                  0,
                  AppTheme.pageMargin,
                  100,
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 210,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: cartoonGridAspectRatio(context),
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) => StaggeredReveal(
                  index: index,
                  child: CartoonCard(
                    key: ValueKey(
                      '${selectedCategory ?? 'all'}-${filtered[index].id}',
                    ),
                    cartoon: filtered[index],
                    onTap: () => pushAppPage<void>(
                      context,
                      CartoonDetailPage(cartoon: filtered[index]),
                    ),
                  ),
                ),
              );
            },
            loading: () => const _CategoryGridLoading(),
            error: (_, __) => ErrorStateView(
              title: 'کاتالوگ باز نشد',
              message: 'اتصال را بررسی کنید و دوباره تلاش کنید.',
              onRetry: () {
                ref.invalidate(cartoonsProvider);
                ref.invalidate(categoriesProvider);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SceneThumb extends StatelessWidget {
  const _SceneThumb();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium + 2),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Image.asset(
          KartoniyaScene.storybook.assetPath,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          excludeFromSemantics: true,
          cacheWidth: 144,
          errorBuilder: (context, error, stackTrace) => const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.violetGradient),
            child: Icon(Icons.menu_book_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _CategoryRailLoading extends StatelessWidget {
  const _CategoryRailLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.pageMargin,
        vertical: 4,
      ),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, __) => Container(
        width: 148,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
      ),
    );
  }
}

class _CategoryGridLoading extends StatelessWidget {
  const _CategoryGridLoading();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pageMargin,
        0,
        AppTheme.pageMargin,
        20,
      ),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 210,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: cartoonGridAspectRatio(context),
      ),
      itemCount: 4,
      itemBuilder: (_, __) => const ShimmerCard(),
    );
  }
}
