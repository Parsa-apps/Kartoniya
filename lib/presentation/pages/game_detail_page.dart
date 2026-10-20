// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_motion.dart';
import '../../data/models/game_model.dart';
import '../../data/providers/games_provider.dart';
import '../games/game_router.dart';

class GameDetailPage extends ConsumerWidget {
  const GameDetailPage({required this.game, super.key});
  final GameModel game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoriteGamesProvider).contains(game.id);
    final best = ref.watch(gameScoresProvider)[game.id];

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: game.accentColor.withOpacity(.12),
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(.35),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? AppColors.coral : Colors.black54),
                    onPressed: () => ref.read(favoriteGamesProvider.notifier).toggle(game.id),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [game.accentColor.withOpacity(.18), game.accentColor.withOpacity(.06)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: game.accentColor.withOpacity(.18), blurRadius: 18)],
                      ),
                      child: Center(child: Text(game.thumbnailEmoji, style: const TextStyle(fontSize: 48))),
                    ),
                    const SizedBox(height: 12),
                    Text(game.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: game.category.color.withOpacity(.14), borderRadius: BorderRadius.circular(20)),
                      child: Text('${game.category.emoji} ${game.category.labelFa} • ${game.difficulty.labelFa}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.pageMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _InfoPill(icon: Icons.timer_outlined, text: '${game.estimatedMinutes} دقیقه'),
                      const SizedBox(width: 8),
                      _InfoPill(icon: Icons.child_care_rounded, text: game.ageLabel),
                      const SizedBox(width: 8),
                      _InfoPill(icon: Icons.emoji_events_rounded, text: best != null ? 'بهترین: $best' : 'بدون رکورد'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18, color: game.accentColor),
                            const SizedBox(width: 6),
                            Text('دربارهٔ بازی', style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(game.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
                        if (game.instructions.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: game.accentColor.withOpacity(.06), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline_rounded, size: 18, color: Colors.orange),
                                const SizedBox(width: 8),
                                Expanded(child: Text(game.instructions, style: Theme.of(context).textTheme.bodySmall)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () {
                        ref.read(recentGamesProvider.notifier).add(game.id);
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => buildGameForMechanics(game)));
                      },
                      icon: const Icon(Icons.play_arrow_rounded, size: 28),
                      label: const Text('شروع بازی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      style: FilledButton.styleFrom(
                        backgroundColor: game.accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  if (game.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: game.tags.map((t) => Chip(label: Text('#$t'), visualDensity: VisualDensity.compact)).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black54),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
