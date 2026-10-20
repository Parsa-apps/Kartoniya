// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_motion.dart';
import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import '../widgets/game_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/state_views.dart';
import 'game_detail_page.dart';

class GamesPage extends ConsumerStatefulWidget {
  const GamesPage({super.key});

  @override
  ConsumerState<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends ConsumerState<GamesPage> {
  String _selectedCategory = 'all';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(playableGamesProvider);
    final allGames = ref.watch(gamesProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.pageMargin, 16, AppTheme.pageMargin, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppColors.violetGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.videogame_asset_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('بازی‌ها', style: Theme.of(context).textTheme.headlineSmall),
                          Text('۱۰۰ بازی تعاملی برای کودکان',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                        ],
                      ),
                      const Spacer(),
                      FutureBuilder(
                        future: ref.read(gameRepositoryProvider).fetchGames(),
                        builder: (context, snapshot) {
                          final total = snapshot.data?.length ?? 100;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('$total بازی', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.success)),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    onChanged: (v) => setState(() => _search = v.trim()),
                    decoration: InputDecoration(
                      hintText: 'جست‌وجوی بازی…',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageMargin),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: GameCategory.values.length + 1,
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final cat = isAll ? null : GameCategory.values[index - 1];
                  final id = isAll ? 'all' : cat!.id;
                  final label = isAll ? 'همه' : cat!.labelFa;
                  final selected = _selectedCategory == id;
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isAll) Text(cat!.emoji, style: const TextStyle(fontSize: 14)),
                        if (!isAll) const SizedBox(width: 4),
                        Text(label),
                      ],
                    ),
                    selected: selected,
                    selectedColor: AppColors.violet.withOpacity(.14),
                    backgroundColor: Colors.white,
                    onSelected: (_) => setState(() => _selectedCategory = id),
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
                filtered = games.where((g) => g.category.id == _selectedCategory).toList();
              }
              if (_search.isNotEmpty) {
                filtered = filtered.where((g) => g.title.contains(_search) || g.description.contains(_search)).toList();
              }
              if (filtered.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('بازی‌ای یافت نشد')),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppTheme.pageMargin, 0, AppTheme.pageMargin, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final game = filtered[index];
                      final fav = ref.watch(favoriteGamesProvider).contains(game.id);
                      return GameCard(
                        game: game,
                        isFavorite: fav,
                        onFavorite: () => ref.read(favoriteGamesProvider.notifier).toggle(game.id),
                        onTap: () {
                          ref.read(recentGamesProvider.notifier).add(game.id);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => GameDetailPage(game: game)),
                          );
                        },
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              );
            },
            loading: () => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: 6,
                  itemBuilder: (_, __) => const ShimmerCard(),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: ErrorStateView(
                title: 'خطا در بارگذاری بازی‌ها',
                message: '$e',
                onRetry: () => ref.invalidate(gamesProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
