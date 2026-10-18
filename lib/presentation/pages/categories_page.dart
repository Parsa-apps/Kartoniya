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
import '../widgets/kartoniya_mascot.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/state_views.dart';
import 'cartoon_detail_page.dart';

/// دسته‌بندی‌ها با کاشی‌های رنگی واقعی (شمارش از کاتالوگ) و فیلتر فوری.
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final cartoons = ref.watch(cartoonsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.pageMargin,
            18,
            AppTheme.pageMargin,
            6,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دسته‌بندی‌ها',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'دسته‌ات را انتخاب کن',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.secondaryTextColor,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.coolGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: categories.when(
                    data: (items) => cartoons.maybeWhen(
                      data: (allCartoons) => _CategoryTiles(
                        categories: items,
                        cartoons: allCartoons,
                        selected: selectedCategory,
                        onSelected: (category) {
                          HapticFeedback.selectionClick();
                          ref.read(selectedCategoryProvider.notifier).state =
                              category.id == 'all' ? null : category.name;
                        },
                      ),
                      orElse: () => const _CategoryTilesSkeleton(),
                    ),
                    loading: () => const _CategoryTilesSkeleton(),
                    error: (_, __) => ErrorStateView(
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
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: selectedCategory ?? 'همهٔ کارتون‌ها',
                    subtitle: cartoons.maybeWhen(
                      data: (all) {
                        final count = selectedCategory == null
                            ? all.length
                            : all
                                .where((c) => c.category == selectedCategory)
                                .length;
                        return '${toFaDigits('$count')} کارتون';
                      },
                      orElse: () => null,
                    ),
                    actionLabel: selectedCategory == null ? null : 'پاک کردن فیلتر',
                    onAction: selectedCategory == null
                        ? null
                        : () =>
                            ref.read(selectedCategoryProvider.notifier).state = null,
                  ),
                ),
                cartoons.when(
                  data: (items) {
                    final visible = selectedCategory == null
                        ? items
                        : items
                            .where((item) => item.category == selectedCategory)
                            .toList(growable: false);
                    if (visible.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyStateView(
                          title: 'هنوز چیزی در این دسته نیست',
                          message: 'این دسته به‌زودی با کارتون‌های تازه پر می‌شود؛ '
                              'یک دستهٔ دیگر را امتحان کن.',
                          mascot: MascotMood.sleepy,
                        ),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.pageMargin,
                        0,
                        AppTheme.pageMargin,
                        AppTheme.spacingLg,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: .74,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => CartoonCard(
                            cartoon: visible[index],
                            onTap: () => pushAppPage<void>(
                              context,
                              CartoonDetailPage(cartoon: visible[index]),
                            ),
                          ),
                          childCount: visible.length,
                        ),
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: SizedBox(height: 240, child: _CategoryGridLoading()),
                  ),
                  error: (_, __) => SliverToBoxAdapter(
                    child: ErrorStateView(
                      title: 'کاتالوگ باز نشد',
                      message: 'اتصال را بررسی کنید و دوباره تلاش کنید.',
                      onRetry: () => ref.invalidate(cartoonsProvider),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }
}

class _CategoryTiles extends StatelessWidget {
  const _CategoryTiles({
    required this.categories,
    required this.cartoons,
    required this.selected,
    required this.onSelected,
  });

  final List<CategoryModel> categories;
  final List<CartoonModel> cartoons;
  final String? selected;
  final ValueChanged<CategoryModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppTheme.pageMargin, 8, AppTheme.pageMargin, 4),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 190,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category.id == 'all'
            ? selected == null
            : selected == category.name;
        final count = category.id == 'all'
            ? cartoons.length
            : cartoons
                .where((cartoon) => cartoon.category == category.name)
                .length;
        return StaggeredReveal(
          index: index,
          child: _CategoryTile(
            category: category,
            count: count,
            selected: isSelected,
            onTap: () => onSelected(category),
          ),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.count,
    required this.selected,
    required this.onTap,
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
        child: AnimatedContainer(
          duration: context.motion.dur(AppMotion.quick),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [
                      Color.lerp(color, Colors.white, .22)!,
                      color,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  )
                : null,
            color: selected ? null : context.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: selected ? color : color.withOpacity(.32),
              width: selected ? 1.6 : 1,
            ),
            boxShadow: selected
                ? AppTheme.glow(color, opacity: .30)
                : AppTheme.softShadow(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(category.emoji, style: const TextStyle(fontSize: 24)),
                  const Spacer(),
                  AnimatedScale(
                    scale: selected ? 1 : 0,
                    duration: context.motion.dur(AppMotion.quick),
                    curve: AppMotion.curvePop,
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: selected ? Colors.white : null,
                          ),
                    ),
                  ),
                  Text(
                    toFaDigits('$count'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected
                              ? Colors.white70
                              : context.secondaryTextColor,
                          fontSize: 12,
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

class _CategoryTilesSkeleton extends StatelessWidget {
  const _CategoryTilesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTheme.pageMargin, 8, AppTheme.pageMargin, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 190,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.35,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: context.surfaceAltColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: .74,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => const ShimmerCard(),
    );
  }
}
