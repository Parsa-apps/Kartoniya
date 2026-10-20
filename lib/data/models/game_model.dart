import 'dart:ui';

import 'content_source.dart';

/// مدل بازی/فعالیت تعاملی کارتونیا.
///
/// هر بازی مکانیک مستقل، قوانین مشخص و نتیجهٔ قابل محاسبه دارد.
/// کارت نمایشی نیست — تعامل واقعی و پایان/امتیاز/تلاش ثبت می‌شود.

enum GameDifficulty { easy, medium, hard }

extension GameDifficultyX on GameDifficulty {
  String get labelFa => switch (this) {
        GameDifficulty.easy => 'آسان',
        GameDifficulty.medium => 'متوسط',
        GameDifficulty.hard => 'سخت',
      };
}

enum GameCategory {
  puzzle('puzzle', 'پازل و جورچین', '🧩', 0xFF8F7AED),
  memory('memory', 'حافظه و جفت‌یابی', '🎯', 0xFF2E9BEB),
  focus('focus', 'تمرکز و دقت', '👀', 0xFF17BFA8),
  guess('guess', 'حدس تصویر', '🔍', 0xFFFF8A50),
  letters('letters', 'حروف و کلمات', '🔤', 0xFFB79BE8),
  numbers('numbers', 'اعداد و شمارش', '🔢', 0xFF53B86A),
  coloring('coloring', 'رنگ‌آمیزی', '🎨', 0xFFFF6BA8),
  difference('difference', 'تفاوت‌ها', '✨', 0xFFFFC53D),
  hidden('hidden', 'اشیای پنهان', '🕵️', 0xFF9B765F),
  riddle('riddle', 'معما و مسئله', '💡', 0xFFFF8A50),
  reaction('reaction', 'واکنش سریع', '⚡', 0xFFFF5D6C),
  toddler('toddler', 'خردسالان', '🐣', 0xFF7BC4FF),
  shapes('shapes', 'شکل و سایه', '⭐', 0xFFC68A1B),
  sorting('sorting', 'مرتب‌سازی و الگو', '📊', 0xFF17BFA8),
  maze('maze', 'مسیریابی', '🗺️', 0xFF3DC47E);

  const GameCategory(this.id, this.labelFa, this.emoji, this.colorValue);
  final String id;
  final String labelFa;
  final String emoji;
  final int colorValue;
  Color get color => Color(colorValue);
}

class GameModel {
  const GameModel({
    required this.id,
    required this.title,
    required this.titleEn,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.mechanics,
    this.instructions = '',
    this.thumbnailEmoji = '🎮',
    this.thumbnailColorValue = 0xFF2E9BEB,
    this.artworkAsset,
    this.isActive = true,
    this.verification = VerificationStatus.verified,
    this.source = ContentSource.localAsset,
    this.sortOrder = 0,
    this.minAge = 3,
    this.maxAge = 10,
    this.supportsScore = true,
    this.supportsTimer = false,
    this.maxLevel = 1,
    this.tags = const [],
  });

  final String id;
  final String title; // فارسی
  final String titleEn; // عنوان اصلی / انگلیسی
  final String description; // توضیح کوتاه فارسی
  final GameCategory category;
  final GameDifficulty difficulty;
  final int estimatedMinutes;
  final String mechanics; // شناسهٔ مکانیک برای routing (مثلاً memory_match)
  final String instructions;
  final String thumbnailEmoji;
  final int thumbnailColorValue;
  final String? artworkAsset;
  final bool isActive;
  final VerificationStatus verification;
  final ContentSource source;
  final int sortOrder;
  final int minAge;
  final int maxAge;
  final bool supportsScore;
  final bool supportsTimer;
  final int maxLevel;
  final List<String> tags;

  String get ageLabel => '$minAge تا $maxAge سال';
  Color get accentColor => Color(thumbnailColorValue);
  bool get isPlayable => isActive && verification.isPlayable;

  GameModel copyWith({
    String? title,
    String? description,
    GameCategory? category,
    bool? isActive,
    VerificationStatus? verification,
    int? sortOrder,
  }) =>
      GameModel(
        id: id,
        title: title ?? this.title,
        titleEn: titleEn,
        description: description ?? this.description,
        category: category ?? this.category,
        difficulty: difficulty,
        estimatedMinutes: estimatedMinutes,
        mechanics: mechanics,
        instructions: instructions,
        thumbnailEmoji: thumbnailEmoji,
        thumbnailColorValue: thumbnailColorValue,
        artworkAsset: artworkAsset,
        isActive: isActive ?? this.isActive,
        verification: verification ?? this.verification,
        source: source,
        sortOrder: sortOrder ?? this.sortOrder,
        minAge: minAge,
        maxAge: maxAge,
        supportsScore: supportsScore,
        supportsTimer: supportsTimer,
        maxLevel: maxLevel,
        tags: tags,
      );
}
