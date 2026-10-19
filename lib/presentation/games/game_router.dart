import 'package:flutter/material.dart';

import '../../data/models/game_model.dart';
import 'memory_game.dart';
import 'counting_game.dart';
import 'slide_puzzle_game.dart';
import 'coloring_game.dart';
import 'reaction_game.dart';
import 'shadow_match_game.dart';
import 'maze_game.dart';
import 'odd_one_out_game.dart';
import 'sorting_game.dart';
import 'difference_game.dart';
import 'pattern_game.dart';
import 'guess_game.dart';
import 'word_game.dart';
import 'riddle_game.dart';
import 'math_race_game.dart';

/// نگاشت mechanics → ویجت قابل اجرا
/// برای مکانیک‌های هنوز پیاده‌نشده، یک بازی تعمیم‌یافته یا پیام «به‌زودی» نمایش داده می‌شود.

Widget buildGameForMechanics(GameModel game) {
  switch (game.mechanics) {
    case 'memory_match':
    case 'memory_sequence':
    case 'memory_position':
      return MemoryGamePage(game: game);
    case 'slide_puzzle':
      return SlidePuzzleGamePage(game: game);
    case 'jigsaw':
    case 'rotate_puzzle':
    case 'block_fit':
    case 'tangram':
      return SlidePuzzleGamePage(game: game);
    case 'coloring':
    case 'color_by_number':
      return ColoringGamePage(game: game);
    case 'spot_difference':
      return DifferenceGamePage(game: game);
    case 'hidden_objects':
      return DifferenceGamePage(game: game);
    case 'shadow_match':
    case 'shape_match':
    case 'shape_sort':
    case 'mirror_match':
      return ShadowMatchGamePage(game: game);
    case 'counting':
    case 'addition':
    case 'subtraction':
    case 'number_sort':
    case 'compare':
    case 'even_odd':
    case 'number_hunt':
      return CountingGamePage(game: game);
    case 'tap_green':
    case 'catch_fall':
    case 'whack':
    case 'balloon_pop':
    case 'traffic':
    case 'quick_tap':
    case 'avoid':
      return ReactionGamePage(game: game);
    case 'maze':
    case 'maze_collect':
      return MazeGamePage(game: game);
    case 'odd_one_out':
    case 'find_one':
    case 'color_tap':
      return OddOneOutGamePage(game: game);
    case 'size_sort':
    case 'color_sort':
    case 'sorting':
      return SortingGamePage(game: game);
    // ——— ۵ موتور جدید ———
    case 'pattern_complete':
    case 'pattern_follow':
    case 'logic_pick':
    case 'logic_grid':
      return PatternGamePage(game: game);
    case 'guess_blur':
    case 'silhouette_guess':
    case 'partial_guess':
    case 'sound_guess':
    case 'emoji_guess':
    case 'sound_match':
      return GuessGamePage(game: game);
    case 'word_build':
    case 'missing_letter':
    case 'letter_pick':
    case 'letter_hunt':
    case 'word_search':
    case 'tracing':
    case 'rhyme_match':
      return WordGamePage(game: game);
    case 'riddle_pick':
    case 'mixed_challenge':
      return RiddleGamePage(game: game);
    case 'math_race':
      return MathRaceGamePage(game: game);
    // پوشش باقی‌مانده برای حذف کامل fallback
    case 'color_match':
    case 'shape_fit':
      return ShadowMatchGamePage(game: game);
    default:
      return _GenericPlaceholderGame(game: game);
  }
}

class _GenericPlaceholderGame extends StatelessWidget {
  const _GenericPlaceholderGame({required this.game});
  final GameModel game;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(game.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(game.thumbnailEmoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              Text(game.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(game.description, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: game.accentColor.withOpacity(.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: game.accentColor.withOpacity(.2)),
                ),
                child: Text(
                  'این بازی با مکانیک «${game.mechanics}» به‌زودی با محتوای کامل منتشر می‌شود. در نسخهٔ فعلی، نسخهٔ سادهٔ قابل بازی با امتیاز در دسترس است.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => CountingGamePage(game: game)),
                ),
                child: const Text('اجرای نسخهٔ نمایشی (شمارش)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
