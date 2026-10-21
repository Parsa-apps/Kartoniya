// ignore_for_file: dangling_library_doc_comments
import 'game_model.dart';

/// معیارهای پیشرفت کودک در بخش بازی‌ها.
///
/// همه چیز از دادهٔ محلیِ همین دستگاه ساخته می‌شود: بهترین رکورد هر بازی
/// (`game_scores`)، بازی‌های نشان‌شده و کاتالوگ بازی‌ها برای تشخیص دسته.
/// هیچ شمارندهٔ جداگانه یا ارسال شبکه‌ای در کار نیست؛ پس دستاورد فقط زمانی
/// «باز» می‌شود که واقعاً کار انجام شده باشد و با پاک‌کردن داده‌ها هم صفر
/// می‌شود.
enum AchievementMetric {
  playedGames('بازی‌های تجربه‌شده'),
  maxBestScore('بهترین رکورد یک بازی'),
  totalBestScore('مجموع بهترین رکوردها'),
  favoriteGames('بازی‌های نشان‌شده'),
  categoryVariety('تنوع دسته‌ها');

  const AchievementMetric(this.labelFa);
  final String labelFa;
}

/// آمار خامِ بازی کودک که از دادهٔ محلی استخراج می‌شود.
class GameStats {
  const GameStats({
    this.playedGames = 0,
    this.maxBestScore = 0,
    this.totalBestScore = 0,
    this.favoriteGames = 0,
    this.categoryVariety = 0,
  });

  /// از رکوردها و علاقه‌مندی‌ها آمار می‌سازد.
  ///
  /// شناسه‌های ناشناخته (بازی حذف‌شده از کاتالوگ) نادیده گرفته می‌شوند تا
  /// نشان‌ها با کاتالوگ قدیمی باز نشوند.
  factory GameStats.from({
    required Map<String, int> bestScores,
    required Set<String> favoriteIds,
    required List<GameModel> games,
  }) {
    final byId = {for (final game in games) game.id: game};
    var played = 0;
    var maxBest = 0;
    var totalBest = 0;
    final categories = <String>{};
    bestScores.forEach((id, score) {
      final game = byId[id];
      if (game == null || score <= 0) return;
      played++;
      totalBest += score;
      if (score > maxBest) maxBest = score;
      categories.add(game.category.id);
    });
    return GameStats(
      playedGames: played,
      maxBestScore: maxBest,
      totalBestScore: totalBest,
      favoriteGames: favoriteIds.where(byId.containsKey).length,
      categoryVariety: categories.length,
    );
  }

  final int playedGames;
  final int maxBestScore;
  final int totalBestScore;
  final int favoriteGames;
  final int categoryVariety;

  int valueOf(AchievementMetric metric) => switch (metric) {
        AchievementMetric.playedGames => playedGames,
        AchievementMetric.maxBestScore => maxBestScore,
        AchievementMetric.totalBestScore => totalBestScore,
        AchievementMetric.favoriteGames => favoriteGames,
        AchievementMetric.categoryVariety => categoryVariety,
      };

  bool get isEmpty => playedGames == 0 && favoriteGames == 0;
}

/// یک نشان (دستاورد) قابل باز شدن در بخش بازی‌ها.
class GameAchievement {
  const GameAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.metric,
    required this.target,
    required this.colorValue,
    this.stars = 1,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
  final AchievementMetric metric;

  /// آستانهٔ باز شدن نشان؛ همیشه بزرگ‌تر از صفر است.
  final int target;

  /// رنگ برند هر نشان (مثل `GameModel.thumbnailColorValue`).
  final int colorValue;

  /// ستاره‌ای که این نشان به کیف پول کودک اضافه می‌کند.
  final int stars;

  int valueOf(GameStats stats) => stats.valueOf(metric);
  bool isUnlocked(GameStats stats) => valueOf(stats) >= target;

  double progressOf(GameStats stats) =>
      (valueOf(stats) / target).clamp(0.0, 1.0).toDouble();

  int remainingOf(GameStats stats) =>
      (target - valueOf(stats)).clamp(0, target).toInt();
}

/// کاتالوگ نشان‌های کارتونیا.
///
/// آستانه‌ها عمداً پله‌ای‌اند (۱ → ۵ → ۲۰ بازی) تا کودک در چند جلسه بازخورد
/// بگیرد و برای نشان آخر لازم نباشد ساعت‌ها بازی کند.
const List<GameAchievement> kGameAchievements = [
  GameAchievement(
    id: 'first_game',
    title: 'اولین قدم',
    description: 'اولین بازی را تا پایان ببر',
    emoji: '🎈',
    metric: AchievementMetric.playedGames,
    target: 1,
    colorValue: 0xFF17BFA8,
  ),
  GameAchievement(
    id: 'five_games',
    title: 'کاشف',
    description: '۵ بازی متفاوت را امتحان کن',
    emoji: '🧭',
    metric: AchievementMetric.playedGames,
    target: 5,
    colorValue: 0xFF8F7AED,
    stars: 2,
  ),
  GameAchievement(
    id: 'twenty_games',
    title: 'جهان‌گرد',
    description: '۲۰ بازی متفاوت را تجربه کن',
    emoji: '🚀',
    metric: AchievementMetric.playedGames,
    target: 20,
    colorValue: 0xFF2E9BEB,
    stars: 3,
  ),
  GameAchievement(
    id: 'score_fifty',
    title: 'ستاره‌ساز',
    description: 'در یک بازی ۵۰ امتیاز بگیر',
    emoji: '⭐',
    metric: AchievementMetric.maxBestScore,
    target: 50,
    colorValue: 0xFFFFC53D,
    stars: 2,
  ),
  GameAchievement(
    id: 'score_eighty',
    title: 'قهرمان',
    description: 'رکورد ۸۰ امتیاز در یک بازی',
    emoji: '🏆',
    metric: AchievementMetric.maxBestScore,
    target: 80,
    colorValue: 0xFFC68A1B,
    stars: 3,
  ),
  GameAchievement(
    id: 'star_treasure',
    title: 'گنجینهٔ ستاره',
    description: 'مجموع بهترین رکوردها را به ۳۰۰ برسان',
    emoji: '💎',
    metric: AchievementMetric.totalBestScore,
    target: 300,
    colorValue: 0xFF17BFA8,
    stars: 3,
  ),
  GameAchievement(
    id: 'five_favorites',
    title: 'دلبسته',
    description: '۵ بازی را نشان کن',
    emoji: '❤️',
    metric: AchievementMetric.favoriteGames,
    target: 5,
    colorValue: 0xFFFF6BA8,
  ),
  GameAchievement(
    id: 'five_categories',
    title: 'همه‌چیزدان',
    description: 'در ۵ دستهٔ مختلف بازی کن',
    emoji: '🌈',
    metric: AchievementMetric.categoryVariety,
    target: 5,
    colorValue: 0xFFFF7A59,
    stars: 2,
  ),
];

/// مجموع ستاره‌های ممکن؛ برای نمایش «۱۲ از ۱۷ ستاره».
int get totalAchievementStars =>
    kGameAchievements.fold(0, (sum, item) => sum + item.stars);
