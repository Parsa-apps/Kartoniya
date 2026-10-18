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
import '../widgets/aurora_background.dart';
import '../widgets/cartoon_artwork.dart';
import '../widgets/cartoon_card.dart';
import '../widgets/category_tile.dart';
import '../widgets/featured_carousel.dart';
import '../widgets/kartoniya_logo.dart';
import '../widgets/kartoniya_mascot.dart';
import '../widgets/kartoniya_nav_bar.dart';
import '../widgets/kartoniya_story_banner.dart';
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
                onOpenSearch: () {
                  ref.read(searchFocusRequestProvider.notifier).state++;
                  _selectTab(3);
                },
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

  Future<void> _refresh() async {
    ref.invalidate(cartoonsProvider);
    ref.invalidate(categoriesProvider);
    // خطای شبکه/منبع نباید RefreshIndicator را با exception رها کند؛
    // همان خطا در ویجت‌ها با ErrorStateView نمایش داده می‌شود.
    try {
      await ref.read(cartoonsProvider.future);
    } catch (_) {
      // intentionally ignored
    }
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

    final catalogue = cartoons.valueOrNull ?? const <CartoonModel>[];
    final categoryCounts = <String, int>{
      for (final category in categories.valueOrNull ?? const <CategoryModel>[])
        category.name: category.id == 'all'
            ? catalogue.length
            : catalogue
                .where((cartoon) => cartoon.category == category.name)
                .length,
    };

    return RefreshIndicator(
      color: AppColors.sky,
      backgroundColor: context.surfaceColor,
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // ——— سربرگ برند + خوشامد کودک ———
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pageMargin,
                12,
                AppTheme.pageMargin,
                2,
              ),
              child: _HomeHeader(
                childName: childProfile.hasName ? childProfile.name : null,
                avatarEmoji: childProfile.avatar.$1,
                avatarColor: Color(childProfile.avatar.$2),
                onProfileTap: widget.onOpenProfile,
              ),
            ),
          ),
          // ——— دسترسی سریع به جست‌وجو ———
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pageMargin,
                10,
                AppTheme.pageMargin,
                2,
              ),
              child: _SearchPrompt(onTap: widget.onOpenSearch),
            ),
          ),
          // ——— منتخب این هفته ———
          const SliverToBoxAdapter(
            child: SectionHeader(
              title: 'منتخب این هفته',
              subtitle: 'انتخاب‌شده برای تماشای امروز',
              icon: Icons.auto_awesome_rounded,
              accent: AppColors.coral,
            ),
          ),
          SliverToBoxAdapter(
            child: StaggeredReveal(
              index: 0,
              offsetY: 14,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: featured.when(
                  data: (items) => items.isEmpty
                      ? const SizedBox.shrink()
                      : FeaturedCarousel(
                          cartoons: items,
                          onOpen: _openDetail,
                          onPlay: _play,
                          isFavorite: (cartoon) =>
                              favorites.contains(cartoon.id),
                          onToggleFavorite: (cartoon) => ref
                              .read(favoritesProvider.notifier)
                              .toggle(cartoon.id),
                        ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: ShimmerHeroBanner(height: 232),
                  ),
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
            child: SectionHeader(
              title: 'دسته‌ها',
              subtitle: 'با یک لمس، دنیای دلخواهت را پیدا کن',
              icon: Icons.grid_view_rounded,
              accent: AppColors.violet,
              actionLabel: 'همه',
              onAction: widget.onOpenCategories,
            ),
          ),
          SliverToBoxAdapter(
            child: StaggeredReveal(
              index: 1,
              offsetY: 12,
              child: categories.when(
                data: (items) => CategoryPillRow(
                  categories: items,
                  selectedName: null,
                  includeAll: true,
                  counts: categoryCounts,
                  onSelected: (category) {
                    if (category != null) {
                      ref.read(selectedCategoryProvider.notifier).state =
                          category.name;
                    }
                    widget.onOpenCategories();
                  },
                ),
                loading: () => const _ChipsLoading(),
                error: (_, __) => const SizedBox.shrink(),
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
                      subtitle: 'از همان‌جا که رها کردی ادامه بده',
                      icon: Icons.play_circle_fill_rounded,
                      accent: AppColors.teal,
                    ),
                    StaggeredReveal(
                      index: 2,
                      offsetY: 12,
                      child: SizedBox(
                        height: 116,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.pageMargin,
                          ),
                          itemCount: entries.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
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
              offsetY: 12,
              child: newOnes.maybeWhen(
                data: (items) => items.isEmpty
                    ? const SizedBox.shrink()
                    : _RailSection(
                        title: 'تازه‌ها',
                        subtitle: 'قصه‌های تازه‌رسیده',
                        icon: Icons.auto_awesome_rounded,
                        accent: AppColors.gold,
                        cartoons: items,
                        onTap: _openDetail,
                      ),
                orElse: () => const _RailLoading(title: 'تازه‌ها'),
              ),
            ),
          ),
          // ——— دعوت برندی فندوقی ———
          SliverToBoxAdapter(
            child: StaggeredReveal(
              index: 4,
              offsetY: 14,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.pageMargin,
                  18,
                  AppTheme.pageMargin,
                  2,
                ),
                child: KartoniyaStoryBanner(
                  // صحنهٔ رنگیِ بدون شخصیت؛ خود فندوقیِ زنده سمت راست
                  // می‌نشیند تا شخصیت دوتایی نشود.
                  scene: KartoniyaScene.fandaqNight,
                  height: 172,
                  showMascot: true,
                  mood: MascotMood.cheering,
                  greet: true,
                  eyebrow: 'همراه فندوقی',
                  title: childProfile.hasName
                      ? '${childProfile.name}، امروز کجا بریم؟'
                      : 'امروز کجا بریم؟',
                  subtitle: 'یک قصهٔ تازه همیشه منتظر توست.',
                  actionLabel: 'دیدن دسته‌ها',
                  onAction: widget.onOpenCategories,
                  semanticLabel: 'فندوقی در جزیرهٔ ابری کارتونیا',
                ),
              ),
            ),
          ),
          // ——— محبوب‌ترین‌ها ———
          SliverToBoxAdapter(
            child: StaggeredReveal(
              index: 5,
              offsetY: 12,
              child: popular.maybeWhen(
                data: (items) => items.isEmpty
                    ? const SizedBox.shrink()
                    : _RailSection(
                        title: 'محبوب‌ترین‌ها',
                        subtitle: 'پیشنهاد بچه‌ها',
                        icon: Icons.local_fire_department_rounded,
                        accent: AppColors.pink,
                        cartoons: items,
                        onTap: _openDetail,
                      ),
                orElse: () => const _RailLoading(title: 'محبوب‌ترین‌ها'),
              ),
            ),
          ),
          // ——— پیشنهاد آرام شب ———
          SliverToBoxAdapter(
            child: StaggeredReveal(
              index: 6,
              offsetY: 14,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.pageMargin,
                  18,
                  AppTheme.pageMargin,
                  2,
                ),
                child: KartoniyaStoryBanner(
                  scene: KartoniyaScene.cloudworld,
                  height: 158,
                  showMascot: true,
                  mood: MascotMood.sleepy,
                  eyebrow: 'وقت خواب',
                  title: 'قصه‌های آرام شب',
                  subtitle: 'فندوقی قصه‌های خیلی آرام را پیشنهاد می‌دهد.',
                  actionLabel: 'قصه‌های شب',
                  onAction: widget.onOpenCategories,
                  semanticLabel: 'فندوقی خوابیده روی ابرها',
                ),
              ),
            ),
          ),
          // ——— همهٔ کارتون‌ها ———
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'همهٔ کارتون‌ها',
              subtitle: catalogue.isEmpty
                  ? null
                  : '${toFaDigits('${catalogue.length}')} کارتون آمادهٔ تماشا',
              icon: Icons.movie_filter_rounded,
              accent: AppColors.sky,
            ),
          ),
          cartoons.when(
            data: (items) => items.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 40),
                      child: EmptyStateView(
                        title: 'هنوز کارتونی آماده نیست',
                        message: 'کاتالوگ خالی است؛ با «تلاش دوباره» بررسی کن '
                            'یا کمی بعد برگرد.',
                        accent: AppColors.sky,
                        action: OutlinedButton.icon(
                          onPressed: () {
                            ref.invalidate(cartoonsProvider);
                            ref.invalidate(categoriesProvider);
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('تلاش دوباره'),
                        ),
                      ),
                    ),
                  )
                : _CartoonGridSliver(
                    cartoons: items,
                    onTap: _openDetail,
                  ),
            loading: () => const _CartoonGridLoadingSliver(),
            error: (_, __) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 40),
                child: ErrorStateView(
                  title: 'کاتالوگ باز نشد',
                  message: 'اتصال اینترنت را بررسی کن و دوباره تلاش کن.',
                  onRetry: () {
                    ref.invalidate(cartoonsProvider);
                    ref.invalidate(featuredCartoonsProvider);
                    ref.invalidate(categoriesProvider);
                  },
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

/// سربرگ خانه: نشان برند، خوشامد زمان‌محور و آواتار کودک.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.childName,
    required this.avatarEmoji,
    required this.avatarColor,
    required this.onProfileTap,
  });

  final String? childName;
  final String avatarEmoji;
  final Color avatarColor;
  final VoidCallback onProfileTap;

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
    final greeting = name == null || name.isEmpty
        ? '${_timeGreeting()}!'
        : '${_timeGreeting()}، $name!';
    return Row(
      children: [
        const KartoniyaLogoMark(size: 42),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 19,
                    ),
              ),
              Text(
                'امروز چه کارتونی ببینیم؟',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.secondaryTextColor,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: 'پروفایل کودک و فضای والدین',
          excludeSemantics: true,
          child: PressableScale(
            onTap: onProfileTap,
            pressedScale: .92,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color.lerp(avatarColor, Colors.white, .55)!,
                    avatarColor,
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(.9),
                  width: 2,
                ),
                boxShadow: AppTheme.glow(avatarColor, opacity: .3, lift: 5),
              ),
              child: Text(
                avatarEmoji,
                style: const TextStyle(fontSize: 22, height: 1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// نوار جست‌وجوی فشرده در خانه؛ با لمس به برگهٔ جست‌وجو می‌رود.
class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'جست‌وجوی کارتون',
      excludeSemantics: true,
      child: PressableScale(
        onTap: onTap,
        pressedScale: .985,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsetsDirectional.only(
            start: 9,
            end: 16,
            top: 8,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge - 4),
            border: Border.all(color: context.softBorderColor),
            boxShadow: AppTheme.softShadow(context),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow:
                      AppTheme.glow(AppColors.sky, opacity: .28, lift: 4),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'دنبال چه کارتونی می‌گردی؟',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.secondaryTextColor,
                      ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sky.withOpacity(.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                ),
                child: Text(
                  'جست‌وجو',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.skyDeep,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                ),
              ),
            ],
          ),
        ),
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
          width: 272,
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge - 2),
            border: Border.all(color: context.softBorderColor),
            boxShadow: AppTheme.softShadow(context),
          ),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Row(
              children: [
                SizedBox(
                  width: 94,
                  height: 96,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: CartoonArtwork(
                      cartoon: entry.cartoon,
                      borderRadius: 0,
                      showPlayAffordance: false,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.cartoon.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 13.5,
                                ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        entry.episode.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.secondaryTextColor,
                              fontSize: 11,
                            ),
                      ),
                      const SizedBox(height: 9),
                      AnimatedProgressBar(value: entry.progress, color: color),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${toFaDigits('$percent')}٪ تماشا شده',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: AppColors.readableOn(
                                      context.surfaceColor,
                                      color,
                                    ),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10.5,
                                  ),
                            ),
                          ),
                          Icon(
                            Icons.play_circle_fill_rounded,
                            color: color,
                            size: 21,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                ProgressRing(
                  value: entry.progress,
                  color: color,
                  size: 32,
                  strokeWidth: 3.4,
                  child: const Icon(Icons.play_arrow_rounded, size: 17),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// یک ردیف افقی کامل با سرتیتر یکپارچه.
class _RailSection extends StatelessWidget {
  const _RailSection({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.cartoons,
    required this.onTap,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final List<CartoonModel> cartoons;
  final ValueChanged<CartoonModel> onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (cartoons.isEmpty) return const SizedBox.shrink();
    final visible = cartoons.take(10).toList(growable: false);
    return Column(
      children: [
        SectionHeader(
          title: title,
          subtitle: subtitle,
          icon: icon,
          accent: accent,
        ),
        SizedBox(
          height: 198,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.pageMargin,
            ),
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (context, index) => SizedBox(
              width: 168,
              child: CartoonCard(
                cartoon: visible[index],
                compact: true,
                onTap: () => onTap(visible[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RailLoading extends StatelessWidget {
  const _RailLoading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: title),
        const SizedBox(
          height: 198,
          child: Padding(
            padding: EdgeInsets.only(top: 4, bottom: 12),
            child: ShimmerCompactRow(itemWidth: 168, itemCount: 3),
          ),
        ),
      ],
    );
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
          width: 92,
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
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 210,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: cartoonGridAspectRatio(context),
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
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 210,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: cartoonGridAspectRatio(context),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const ShimmerCard(),
          childCount: 6,
        ),
      ),
    );
  }
}
