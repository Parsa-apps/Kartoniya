// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/services/app_haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import '../widgets/game_card.dart';
import '../widgets/kartoniya_mascot.dart';
import '../widgets/page_intro.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/state_views.dart';
import 'game_detail_page.dart';

/// تب «بازی‌ها»: جست‌وجوی محلی، فیلتر دسته و گرید تطبیقی.
///
/// همهٔ رنگ‌ها از توکن‌های تم می‌آیند، پس حالت روشن و تاریک هر دو خوانا
/// هستند. گرید با [SliverGridDelegateWithMaxCrossAxisExtent] و ارتفاع ثابت
/// کاشی ساخته می‌شود تا روی گوشی ۳۲۰px دو ستون و روی تبلت چهار ستون داشته
/// باشیم و هیچ کاشی‌ای سرریز نکند.
class GamesPage extends ConsumerStatefulWidget {
  const GamesPage({super.key});

  @override
  ConsumerState<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends ConsumerState<GamesPage> {
  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 210,
    mainAxisExtent: 182,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  );

  String _selectedCategory = 'all';
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openGame(GameModel game) {
    ref.read(recentGamesProvider.notifier).add(game.id);
    pushAppPage(context, GameDetailPage(game: game));
  }

  void _clearFilters() {
    setState(() {
      _search = '';
      _selectedCategory = 'all';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(playableGamesProvider);
    final favorites = ref.watch(favoriteGamesProvider);
    final total = gamesAsync.maybeWhen(
      data: (games) => games.length,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: PageIntro(
              title: 'بازی‌ها',
              subtitle: total == null
                  ? 'بازی تعاملی برای کودکان'
                  : '${toFaDigits('$total')} بازی تعاملی برای کودکان',
              icon: Icons.videogame_asset_rounded,
              gradient: AppColors.violetGradient,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pageMargin,
                2,
                AppTheme.pageMargin,
                10,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _search = value.trim()),
                textInputAction: TextInputAction.search,
                textDirection: TextDirection.rtl,
                style: context.appText.bodyLarge?.copyWith(fontSize: 14.5),
                decoration: InputDecoration(
                  hintText: 'جست‌وجوی بازی…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _search.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'پاک کردن جست‌وجو',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _search = '');
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                        ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.pageMargin),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: GameCategory.values.length + 1,
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final category = isAll ? null : GameCategory.values[index - 1];
                  final id = isAll ? 'all' : category!.id;
                  final selected = _selectedCategory == id;
                  // متن چیپ انتخاب‌شده روی رنگ برند با [fillAndText] انتخاب
                  // می‌شود تا در هر دو تم ≥۴٫۵:۱ بماند.
                  final selectedFill =
                      AppColors.fillAndText(category?.color ?? AppColors.violet);
                  return Center(
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isAll) ...[
                            Text(
                              category!.emoji,
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Text(isAll ? 'همه' : category!.labelFa),
                        ],
                      ),
                      labelStyle: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? selectedFill.foreground
                            : context.primaryTextColor,
                      ),
                      showCheckmark: false,
                      selected: selected,
                      selectedColor: selectedFill.fill,
                      backgroundColor: context.surfaceColor,
                      side: BorderSide(
                        color: selected
                            ? selectedFill.fill
                            : context.softBorderColor,
                      ),
                      onSelected: (_) {
                        AppHaptics.selection();
                        setState(() => _selectedCategory = id);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          gamesAsync.when(
            data: (games) {
              var filtered = games;
              if (_selectedCategory != 'all') {
                filtered = games
                    .where((game) => game.category.id == _selectedCategory)
                    .toList();
              }
              if (_search.isNotEmpty) {
                final query = _search.toLowerCase();
                filtered = filtered
                    .where((game) =>
                        game.title.contains(query) ||
                        game.titleEn.toLowerCase().contains(query) ||
                        game.description.contains(query) ||
                        game.tags.any((tag) => tag.contains(query)))
                    .toList();
              }
              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 96),
                    child: EmptyStateView(
                      title: 'بازی‌ای پیدا نشد',
                      message: _search.isEmpty
                          ? 'در این دسته فعلاً بازی‌ای نیست؛ دستهٔ دیگری را امتحان کن.'
                          : 'برای «$_search» نتیجه‌ای نبود. عبارت کوتاه‌تری بنویس یا فیلترها را پاک کن.',
                      mascot: MascotMood.confused,
                      action: OutlinedButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('پاک کردن فیلترها'),
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.pageMargin,
                  0,
                  AppTheme.pageMargin,
                  100,
                ),
                sliver: SliverGrid(
                  gridDelegate: _gridDelegate,
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final game = filtered[index];
                      return GameCard(
                        game: game,
                        isFavorite: favorites.contains(game.id),
                        onFavorite: () {
                          AppHaptics.light();
                          ref
                              .read(favoriteGamesProvider.notifier)
                              .toggle(game.id);
                        },
                        onTap: () => _openGame(game),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pageMargin,
                0,
                AppTheme.pageMargin,
                100,
              ),
              sliver: SliverGrid(
                gridDelegate: _gridDelegate,
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const ShimmerCard(),
                  childCount: 8,
                ),
              ),
            ),
            error: (error, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 96),
                child: ErrorStateView(
                  title: 'بازی‌ها بارگذاری نشد',
                  message: 'کاتالوگ محلی خوانده نشد. یک‌بار دیگر تلاش کن.',
                  onRetry: () => ref.invalidate(gamesProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
