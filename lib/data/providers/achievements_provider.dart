// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/game_achievement.dart';
import '../models/game_model.dart';
import 'games_provider.dart';

/// آمار زندهٔ بازی کودک؛ با تغییر رکوردها یا علاقه‌مندی‌ها دوباره ساخته می‌شود.
///
/// اگر کاتالوگ هنوز بارگذاری نشده باشد، آمار خالی برمی‌گردد و به‌محض آماده
/// شدن بازی‌ها همهٔ نشان‌ها دوباره ارزیابی می‌شوند.
final gameStatsProvider = Provider<GameStats>((ref) {
  final scores = ref.watch(gameScoresProvider);
  final favorites = ref.watch(favoriteGamesProvider);
  final games =
      ref.watch(playableGamesProvider).valueOrNull ?? const <GameModel>[];
  return GameStats.from(
    bestScores: scores,
    favoriteIds: favorites,
    games: games,
  );
});

/// وضعیت یک نشان برای نمایش در فهرست.
class AchievementProgress {
  const AchievementProgress({
    required this.achievement,
    required this.value,
    required this.progress,
    required this.unlocked,
  });

  final GameAchievement achievement;
  final int value;

  /// پیشرفت ۰..۱ برای نوار پیشرفت.
  final double progress;
  final bool unlocked;

  int get remaining => unlocked ? 0 : (achievement.target - value);
}

final achievementsProvider = Provider<List<AchievementProgress>>((ref) {
  final stats = ref.watch(gameStatsProvider);
  return List<AchievementProgress>.unmodifiable([
    for (final achievement in kGameAchievements)
      AchievementProgress(
        achievement: achievement,
        value: achievement.valueOf(stats),
        progress: achievement.progressOf(stats),
        unlocked: achievement.isUnlocked(stats),
      ),
  ]);
});

final unlockedAchievementsProvider = Provider<List<AchievementProgress>>(
  (ref) => ref.watch(achievementsProvider).where((item) => item.unlocked).toList(),
);

/// ستاره‌های کسب‌شده؛ جمع ستارهٔ نشان‌های بازشده.
final earnedStarsProvider = Provider<int>((ref) {
  var stars = 0;
  for (final item in ref.watch(achievementsProvider)) {
    if (item.unlocked) stars += item.achievement.stars;
  }
  return stars;
});

/// نزدیک‌ترین نشانِ قفل‌شده (بیشترین پیشرفت)؛ برای تشویق در پروفایل.
final nextAchievementProvider = Provider<AchievementProgress?>((ref) {
  final locked = ref
      .watch(achievementsProvider)
      .where((item) => !item.unlocked)
      .toList(growable: false);
  if (locked.isEmpty) return null;
  return locked.reduce(
    (best, item) => item.progress > best.progress ? item : best,
  );
});

/// شناسهٔ نشان‌های بازشده؛ برای مقایسهٔ «قبل و بعد» یک بازی.
Set<String> unlockedAchievementIds(List<AchievementProgress> items) => {
      for (final item in items)
        if (item.unlocked) item.achievement.id,
    };

/// نشان‌هایی که تازه باز شده‌اند.
///
/// [before] مجموعهٔ شناسه‌های باز پیش از بازی است؛ خروجی فقط نشان‌هایی است
/// که بعد از بازی باز شده‌اند. این تابع هیچ وضعیتی ذخیره نمی‌کند و کاملاً
/// مشتق است؛ بنابراین اگر دادهٔ بازی‌ها پاک شود، دیگر «نشان تازه»ی کاذب
/// نمایش داده نمی‌شود.
List<GameAchievement> newlyUnlockedAchievements({
  required Set<String> before,
  required List<AchievementProgress> after,
}) =>
    [
      for (final item in after)
        if (item.unlocked && !before.contains(item.achievement.id))
          item.achievement,
    ];
