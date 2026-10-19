// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/game_model.dart';

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
    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: game.accentColor.withOpacity(.10),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: game.accentColor.withOpacity(.18)),
          boxShadow: [BoxShadow(color: game.accentColor.withOpacity(.12), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: game.accentColor.withOpacity(.16),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(game.thumbnailEmoji, style: const TextStyle(fontSize: 26))),
                ),
                const Spacer(),
                if (onFavorite != null)
                  GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isFavorite ? AppColors.coral.withOpacity(.14) : Colors.black.withOpacity(.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: isFavorite ? AppColors.coral : Colors.black45,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(game.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(game.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, height: 1.3)),
            const Spacer(),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: game.category.color.withOpacity(.12), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(game.category.emoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(game.category.labelFa, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(Icons.timer_outlined, size: 14, color: Colors.black45),
                const SizedBox(width: 3),
                Text('${game.estimatedMinutes}د', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Text(game.difficulty.labelFa, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            if (!game.isPlayable) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(.12), borderRadius: BorderRadius.circular(8)),
                child: const Text('به‌زودی', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.deepOrange, fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
