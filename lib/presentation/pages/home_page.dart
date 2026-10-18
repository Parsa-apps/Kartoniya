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
import '../widgets/animated_progress.dart';
import '../widgets/aurora_background.dart';
import '../widgets/cartoon_artwork.dart';
import '../widgets/cartoon_card.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/kartoniya_logo.dart';
import '../widgets/kartoniya_nav_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/state_views.dart';
import 'categories_page.dart';
import 'cartoon_detail_page.dart';
import 'favorites_page.dart';
import 'player_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

/// پوستهٔ اصلی برنامه. IndexedStack وضعیت هر برگه (به‌ویژه جست‌وجو) را هنگام
/// جابه‌جایی در نوار پایین حفظ می‌کند؛ نوار پیمایش اختصاصی کارتونیا است.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  var _selectedIndex = 0;

  void _selectTab(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              _DiscoverTab(
                onOpenCategories: () => _selectTab(1),
                onOpenProfile: () => _selectTab(4),
                onOpenSearch: () => _selectTab(3),
              ),
              const CategoriesPage(),
              FavoritesPage(onBrowse: () => _selectTab(0)),
              const SearchPage(),
              const ProfilePage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: KartoniyaNavBar(
        selectedIndex: _selectedIndex,
        onSelected: _selectTab,
        items: const [
          KartoniyaNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'خانه',
          ),
          KartoniyaNavItem(
            icon: Icons.grid_view_outlined,
            activeIcon: Icons.grid_view_rounded,
            label: 'دسته‌ها',
          ),
          KartoniyaNavItem(
            icon: Icons.favorite_border_rounded,
            activeIcon: Icons.favorite_rounded,
            label: 'دلخواه',
          ),
          KartoniyaNavItem(
            icon: Icons.search_rounded,
            activeIcon: Icons.search_rounded,
            label: 'جست‌وجو',
          ),
          KartoniyaNavItem(
            icon: Icons.tune_outlined,
            activeIcon: Icons.tune_rounded,
            label: 'والدین',
          ),
        ],
      ),
    );
  }
}

class _DiscoverTab extends ConsumerStatefulWidget {
  const _DiscoverTab({
    required this.onOpenCategories,
    required this.onOpenProfile,
    required this.onOpenSearch,
  });

  final VoidCallback onOpenCategories;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenSearch;

  @override
  ConsumerState<_DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends ConsumerState<_DiscoverTab> {
  void _openDetail(CartoonModel cartoon) {
    pushAppPage<void>(context, CartoonDetailPage(cartoon: cartoon));
  }

  void _play(CartoonModel cartoon) {
    pushAppPageFade<void>(
      context,
      PlayerPage(cartoon: cartoon, episode: cartoon.firstEpisode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartoons = ref.watch(cartoonsProvider);
    final categories = ref.watch(categoriesProvider);
    final featured = ref.watch(featuredCartoonsProvider);
    final newOnes = ref.watch(newCartoonsProvider);
    final popular = ref.watch(popularCartoonsProvider);
    final continueWatching = ref.watch(continueWatchingProvider);
    final favorites = ref.watch(favoritesProvider);
    final childProfile = ref.watch(childProfileProvider);

    return RefreshIndicator(
      color: AppColors.sky,
      onRefresh: () async {
        ref.invalidate(cartoonsProvider);
        ref.invalidate(categoriesProvider);
        await ref.read(cartoonsProvider.future);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pageMargin,
                14,
                AppTheme.pageMargin,
                2,
              ),
              child: _HomeHeader(
                childName: childProfile.hasName
                    ? childProfile.name
                    : null,
                onProfileTap: widget.onOpenProfile,
                onSearchTap: widget.onOpenSearch,
              ),
            ),
          ),
          // ——— بنر محتوای منتخب ———
          SliverToBoxAdapter(
            child: StaggeredReveal(
              index: 0,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: featured.when(
                  data: (items) => FeaturedCarousel(
                    cartoons: items,
                    onOpen: _openDetail,
                    onPlay: _play,
                    isFavorite: (cartoon) => favorites.contains(cartoon.id),
                    onToggleFavorite: (cartoon) => ref
                        .read(favoritesProvider.notifier)
                        .toggle(cartoon.id),
                  ),
                  loading: () => const ShimmerHeroBanner(height: 224),
                  error: (_, __) => ErrorStateView(
                    title: 'بنر منتخب باز نشد',
                    message: 'اتصال یا فهرست محتوا را بررسی کنید.',
                    onRetry: () => ref.invalidate(featuredCartoonsProvider),
                    compact: true,
                  ),
                ),
              ),
            ),
          ),
          // ——— دسته‌بندی‌ها ———
          SliverToBoxAdapter(
            child: StaggeredReveal(
              index: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: categories.when(
                  data: (items) => _CategoryChipRow(
                    categories: items,
                    onSelected: (category) {
                      ref.read(selectedCategoryProvider.notifier).state =
                          category.id == 'all' ? null : category.name;
                      widget.onOpenCategories();
                    },
                  ),
                  loading: () => const _ChipsLoading(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          // ——— ادامهٔ تماشا ———
          SliverToBoxAdapter(
            child: continueWatching.when(
              data: (entries) {
                if (entries.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    const SectionHeader(
                      title: 'ادامهٔ تماشا',
                      subtitle: 'از همان‌جا که ول کردی ادامه بده',
                    ),
                    StaggeredReveal(
                      index: 2,
                      child: SizedBox(
                        height: 118,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.pageMargin,
                          ),
                          itemCount: entries.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) => _ContinueCard(
                            entry: entries[index],
                            onPlay: () => pushAppPageFade<void>(
                              context,
                              PlayerPage(
                                cartoon: entries[index].cartoon,
                                episode: entries[index].episode,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          // ——— تازه‌ها ———
          SliverToBoxAdapter(
            child: StaggeredReveal(
              index: 3,
              child: newOnes.maybeWhen(
                data: (items) => items.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          const SectionHeader(title: 'تازه‌ها'),
                          _HorizontalCompactRow(
                            cartoons: items,
                            onTap: _openDetail,
                          ),
                        ],
                      ),
                orElse: () => const _CompactRowLoading(),
              ),
            ),
          ),
          // ——— محبوب‌ترین‌ها ———
          SliverToBoxAdapter(
            child: StaggeredReveal(
              index: 4,
              child: popular.maybeWhen(
                data: (items) => Column(
                  children: [
                    const SectionHeader(title: 'محبوب‌ترین‌ها'),
                    _HorizontalCompactRow(
                      cartoons: items,
                      onTap: _openDetail,
                    ),
                  ],
                ),
                orElse: () => const _CompactRowLoading(),
              ),
            ),
          ),
          // ——— همهٔ کارتون‌ها ———
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'همهٔ کارتون‌ها'),
          ),
          cartoons.when(
            data: (items) => _CartoonGridSliver(
              cartoons: items,
              onTap: _openDetail,
            ),
            loading: () => const _CartoonGridLoadingSliver(),
            error: (_, __) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 40),
                child: ErrorStateView(
                  title: 'کاتالوگ باز نشد',
                  message: 'اتصال اینترنت را بررسی کنید و دوباره تلاش کنید.',
                  onRetry: () => ref.invalidate(cartoonsProvider),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.childName,
    required this.onProfileTap,
    required this.onSearchTap,
  });

  final String? childName;
  final VoidCallback onProfileTap;
  final VoidCallback onSearchTap;

  static String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صبح بخیر';
    if (hour < 17) return 'بعدازظهر بخیر';
    if (hour < 21) return 'عصر بخیر';
    return 'شب بخیر';
  }

  @override
  Widget build(BuildContext context) {
    final name = childName;
    return Row(
      children: [
        const KartoniyaLogoMark(size: 44),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'کارتونیا',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              Text(
                name == null || name.isEmpty
                    ? _timeGreeting()
                    : '${_timeGreeting()} $name!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.secondaryTextColor,
                    ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'جست‌وجوی کارتون',
          onPressed: onSearchTap,
          icon: const Icon(Icons.search_rounded, size: 22),
        ),
        const SizedBox(width: 6),
        IconButton.filledTonal(
          tooltip: 'فضای والدین',
          onPressed: onProfileTap,
          icon: const Icon(Icons.tune_rounded, size: 22),
        ),
      ],
    );
  }
}

class _CategoryChipRow extends StatefulWidget {
  const _CategoryChipRow({required this.categories, required this.onSelected});

  final List<CategoryModel> categories;
  final ValueChanged<CategoryModel> onSelected;

  @override
  State<_CategoryChipRow> createState() => _CategoryChipRowState();
}

class _CategoryChipRowState extends State<_CategoryChipRow> {
  int _tapped = -1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageMargin),
        itemCount: widget.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final color = category.color;
          return GestureDetector(
            onTapDown: (_) {
              if (context.motion.enabled) setState(() => _tapped = index);
            },
            onTapUp: (_) => setState(() => _tapped = -1),
            onTapCancel: () => setState(() => _tapped = -1),
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onSelected(category);
            },
            child: AnimatedScale(
              scale: _tapped == index ? .93 : 1,
              duration: AppMotion.micro,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                  border: Border.all(color: color.withOpacity(.28)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(.14),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: context.primaryTextColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.entry, required this.onPlay});

  final ContinueWatchingEntry entry;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final percent = (entry.progress * 100).round();
    final color = AppColors.categoryColor(entry.cartoon.category);
    return Semantics(
      button: true,
      label: 'ادامهٔ ${entry.cartoon.title}، ${entry.episode.title}، '
          '${toFaDigits('$percent')} درصد دیده‌شده',
      excludeSemantics: true,
      child: PressableScale(
        onTap: onPlay,
        child: Container(
          width: 264,
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: context.softBorderColor),
            boxShadow: AppTheme.softShadow(context),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: 92,
                  height: 96,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                    child: CartoonArtwork(
                      cartoon: entry.cartoon,
                      borderRadius: 0,
                      showPlayAffordance: false,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.cartoon.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 14,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.episode.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.secondaryTextColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedProgressBar(value: entry.progress, color: color),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${toFaDigits('$percent')}٪ تماشا شده',
                              style:
                                  Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: color,
                                        fontWeight: FontWeight.w700,
                                      ),
                            ),
                          ),
                          Icon(Icons.play_circle_fill_rounded, color: color, size: 22),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                ProgressRing(
                  value: entry.progress,
                  color: color,
                  size: 34,
                  strokeWidth: 3.6,
                  child: const Icon(Icons.play_arrow_rounded, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HorizontalCompactRow extends StatelessWidget {
  const _HorizontalCompactRow({
    required this.cartoons,
    required this.onTap,
  });

  final List<CartoonModel> cartoons;
  final ValueChanged<CartoonModel> onTap;

  @override
  Widget build(BuildContext context) {
    if (cartoons.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 196,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageMargin),
        itemCount: cartoons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SizedBox(
          width: 176,
          child: CartoonCard(
            cartoon: cartoons[index],
            compact: true,
            onTap: () => onTap(cartoons[index]),
          ),
        ),
      ),
    );
  }
}

class _CompactRowLoading extends StatelessWidget {
  const _CompactRowLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 212, child: ShimmerCompactRow(itemWidth: 176));
  }
}

class _ChipsLoading extends StatelessWidget {
  const _ChipsLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageMargin),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, __) => Container(
          width: 96,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
          ),
        ),
      ),
    );
  }
}

class _CartoonGridSliver extends StatelessWidget {
  const _CartoonGridSliver({required this.cartoons, required this.onTap});

  final List<CartoonModel> cartoons;
  final ValueChanged<CartoonModel> onTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pageMargin,
        AppTheme.spacingSm,
        AppTheme.pageMargin,
        AppTheme.spacingLg,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 210,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: .74,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => CartoonCard(
            cartoon: cartoons[index],
            onTap: () => onTap(cartoons[index]),
          ),
          childCount: cartoons.length,
        ),
      ),
    );
  }
}

class _CartoonGridLoadingSliver extends StatelessWidget {
  const _CartoonGridLoadingSliver();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pageMargin,
        AppTheme.spacingSm,
        AppTheme.pageMargin,
        AppTheme.spacingLg,
      ),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 210,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: .74,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const ShimmerCard(),
          childCount: 6,
        ),
      ),
    );
  }
}
