import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/theme/app_motion.dart';
import 'package:kartoniya/core/theme/app_theme.dart';
import 'package:kartoniya/data/models/game_achievement.dart';
import 'package:kartoniya/data/models/game_model.dart';
import 'package:kartoniya/data/providers/achievements_provider.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/data/providers/games_provider.dart';
import 'package:kartoniya/data/repositories/local_game_repository.dart';
import 'package:kartoniya/presentation/pages/achievements_page.dart';
import 'package:kartoniya/presentation/widgets/achievement_celebration.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// دستاوردها از دادهٔ محلی مشتق می‌شوند؛ این تست هم ریاضیِ آمار و هم صفحهٔ
/// نمایش را می‌سنجد تا نشان‌ها نه «ساختگی» باشند و نه در حالت تاریک/متن بزرگ
/// بشکنند.
void main() {
  late List<GameModel> games;

  setUpAll(() async {
    games = await LocalGameRepository().fetchGames();
  });

  GameModel gameAt(int index) => games[index];

  Widget host(
    SharedPreferences prefs,
    Widget child, {
    bool dark = false,
    double textScale = 1.0,
  }) {
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        locale: const Locale('fa', 'IR'),
        supportedLocales: const [Locale('fa', 'IR'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: textScale == 1
                ? media
                : media.copyWith(textScaler: TextScaler.linear(textScale)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: MotionScope(
                info: MotionInfo.reducedNone,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          );
        },
        home: child,
      ),
    );
  }

  group('آمار پیشرفت', () {
    test('بدون داده، آمار خالی و بدون نشان باز است', () {
      final stats = GameStats.from(
        bestScores: const {},
        favoriteIds: const {},
        games: games,
      );
      expect(stats.isEmpty, isTrue);
      expect(stats.playedGames, 0);
      expect(stats.totalBestScore, 0);
      for (final achievement in kGameAchievements) {
        expect(achievement.isUnlocked(stats), isFalse, reason: achievement.id);
      }
    });

    test('شناسهٔ ناشناخته و امتیاز صفر در آمار حساب نمی‌شوند', () {
      final stats = GameStats.from(
        bestScores: {
          'game-that-does-not-exist': 90,
          gameAt(0).id: 0,
          gameAt(1).id: 40,
        },
        favoriteIds: {'game-that-does-not-exist', gameAt(2).id},
        games: games,
      );
      expect(stats.playedGames, 1);
      expect(stats.totalBestScore, 40);
      expect(stats.maxBestScore, 40);
      expect(stats.favoriteGames, 1);
      expect(stats.categoryVariety, 1);
    });

    test('بازی‌های متفاوت، دسته و رکورد درست جمع می‌شوند', () {
      Map<String, int> scoresFor(Iterable<GameModel> selection, int score) =>
          {for (final game in selection) game.id: score};

      final byCategory = <String, GameModel>{};
      for (final game in games) {
        byCategory.putIfAbsent(game.category.id, () => game);
      }
      final selection = byCategory.values.take(5).toList();
      expect(selection.length, 5);

      final stats = GameStats.from(
        bestScores: scoresFor(selection, 62),
        favoriteIds: selection.take(3).map((game) => game.id).toSet(),
        games: games,
      );
      expect(stats.playedGames, 5);
      expect(stats.categoryVariety, 5);
      expect(stats.maxBestScore, 62);
      expect(stats.totalBestScore, 310);
      expect(stats.favoriteGames, 3);
    });

    test('آستانه و پیشرفت نشان‌ها درست کلامپ می‌شوند', () {
      const achievement = GameAchievement(
        id: 'probe',
        title: 'آزمون',
        description: 'آزمون',
        emoji: '🧪',
        metric: AchievementMetric.playedGames,
        target: 5,
        colorValue: 0xFF2E9BEB,
        stars: 2,
      );
      const half = GameStats(playedGames: 2);
      const enough = GameStats(playedGames: 5);
      const more = GameStats(playedGames: 40);

      expect(achievement.progressOf(half), closeTo(.4, .001));
      expect(achievement.remainingOf(half), 3);
      expect(achievement.isUnlocked(half), isFalse);
      expect(achievement.isUnlocked(enough), isTrue);
      expect(achievement.progressOf(more), 1);
      expect(achievement.remainingOf(more), 0);
    });

    test('کاتالوگ نشان‌ها شناسهٔ یکتا، آستانه و ستارهٔ مثبت دارد', () {
      expect(kGameAchievements, isNotEmpty);
      expect(
        kGameAchievements.map((item) => item.id).toSet().length,
        kGameAchievements.length,
      );
      for (final achievement in kGameAchievements) {
        expect(achievement.target, greaterThan(0), reason: achievement.id);
        expect(achievement.stars, greaterThan(0), reason: achievement.id);
        expect(achievement.title.trim(), isNotEmpty);
      }
      expect(
        totalAchievementStars,
        kGameAchievements.fold(0, (sum, item) => sum + item.stars),
      );
    });
  });

  group('provider دستاوردها', () {
    test('نشان‌ها فقط از رکوردها و علاقه‌مندی‌های واقعی باز می‌شوند', () async {
      final scores = {
        gameAt(0).id: 85,
        gameAt(1).id: 40,
        gameAt(2).id: 40,
      };
      final favorites = [for (var i = 0; i < 5; i++) gameAt(i).id];
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'game_scores': jsonEncode(scores),
        'favorite_game_ids': favorites,
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      await container.read(playableGamesProvider.future);

      final items = container.read(achievementsProvider);
      expect(items.length, kGameAchievements.length);
      final unlocked = items
          .where((item) => item.unlocked)
          .map((item) => item.achievement.id)
          .toSet();
      // ۳ بازی (۱، ۵، ۲۰) → فقط «اولین قدم»؛ رکورد ۸۵ → «ستاره‌ساز» و
      // «قهرمان»؛ ۵ علاقه‌مندی → «دلبسته». مجموع رکوردها ۱۶۵ است، پس
      // «گنجینهٔ ستاره» (۳۰۰) نباید باز شود.
      expect(
        unlocked,
        {'first_game', 'score_fifty', 'score_eighty', 'five_favorites'},
      );
      expect(container.read(earnedStarsProvider), 1 + 2 + 3 + 1);

      final next = container.read(nextAchievementProvider);
      expect(next, isNotNull);
      expect(next!.unlocked, isFalse);
      expect(next.progress, greaterThan(0));

      // پاک‌کردن داده‌ها باید پیشرفت را واقعاً صفر کند، نه اینکه نشان‌ها
      // جای دیگری ذخیره شده باشند.
      await prefs.remove('game_scores');
      await prefs.remove('favorite_game_ids');
      final fresh = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(fresh.dispose);
      await fresh.read(playableGamesProvider.future);
      expect(fresh.read(earnedStarsProvider), 0);
      expect(
        fresh.read(achievementsProvider).every((item) => !item.unlocked),
        isTrue,
      );
    });
  });

  group('صفحهٔ دستاوردها', () {
    testWidgets('بدون رکورد، همهٔ نشان‌ها قفل‌اند و صفحه بدون خطا بالا می‌آید',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({'onboarding_completed': true});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(host(prefs, const AchievementsPage()));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }

      expect(find.text('پیشرفت کودک'), findsOneWidget);
      expect(find.text('۰ از ۸ نشان • ۰ ستاره'), findsOneWidget);
      expect(find.text('باز شد ✓'), findsNothing);
      expect(find.byIcon(Icons.lock_outline_rounded), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('با رکورد واقعی، شمارش و نشان‌های باز درست نمایش داده می‌شوند',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final scores = {
        gameAt(0).id: 85,
        gameAt(1).id: 40,
        gameAt(2).id: 40,
      };
      final favorites = [for (var i = 0; i < 5; i++) gameAt(i).id];
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'game_scores': jsonEncode(scores),
        'favorite_game_ids': favorites,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(host(prefs, const AchievementsPage()));
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }

      expect(find.text('۴ از ۸ نشان • ۷ ستاره'), findsOneWidget);
      expect(find.text('اولین قدم'), findsOneWidget);
      expect(find.text('باز شد ✓'), findsWidgets);
      // «جهان‌گرد» با ۳ بازی از ۲۰ هنوز قفل است و پیشرفت واقعی نشان می‌دهد.
      expect(find.text('۳ از ۲۰'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('روی ۳۲۰px با متن ۱٫۳× و تم تاریک بدون سرریز اسکرول می‌شود',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final scores = {
        for (var i = 0; i < 8; i++) gameAt(i).id: 70 - i * 5,
      };
      SharedPreferences.setMockInitialValues({
        'onboarding_completed': true,
        'game_scores': jsonEncode(scores),
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        host(prefs, const AchievementsPage(), dark: true, textScale: 1.3),
      );
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      expect(tester.takeException(), isNull, reason: 'چیدمان اول');

      final scrollable = find.byType(Scrollable).first;
      for (var i = 0; i < 6; i++) {
        await tester.drag(scrollable, const Offset(0, -260));
        await tester.pump(const Duration(milliseconds: 180));
        expect(tester.takeException(), isNull, reason: 'اسکرول $i');
      }
    });
  });

  group('جشن نشان تازه', () {
    List<AchievementProgress> progressFor(GameStats stats) => [
          for (final achievement in kGameAchievements)
            AchievementProgress(
              achievement: achievement,
              value: achievement.valueOf(stats),
              progress: achievement.progressOf(stats),
              unlocked: achievement.isUnlocked(stats),
            ),
        ];

    test('فقط نشان‌های تازه باز شده برمی‌گردند', () {
      final items = progressFor(
        const GameStats(playedGames: 5, maxBestScore: 85),
      );
      final allUnlocked = unlockedAchievementIds(items);
      expect(allUnlocked, contains('first_game'));
      expect(allUnlocked, contains('five_games'));

      final gained = newlyUnlockedAchievements(
        before: {'first_game'},
        after: items,
      );
      final gainedIds = gained.map((item) => item.id).toList();
      expect(gainedIds, isNot(contains('first_game')));
      expect(gainedIds, contains('five_games'));

      expect(
        newlyUnlockedAchievements(before: allUnlocked, after: items),
        isEmpty,
      );
      expect(
        newlyUnlockedAchievements(before: const {}, after: progressFor(const GameStats())),
        isEmpty,
      );
    });

    testWidgets('کارت جشن نشان و دکمه را نشان می‌دهد و بسته می‌شود',
        (tester) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({'onboarding_completed': true});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        host(
          prefs,
          Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showAchievementCelebration(
                    context,
                    [kGameAchievements.first],
                  ),
                  child: const Text('باز کن'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('باز کن'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('یک نشان تازه!'), findsOneWidget);
      expect(find.text('اولین قدم'), findsOneWidget);
      expect(find.textContaining('ستاره گرفتی'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('آفرین!'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('یک نشان تازه!'), findsNothing);
    });

    testWidgets('کارت جشن روی ۳۲۰px با متن ۱٫۳× سرریز نمی‌کند',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({'onboarding_completed': true});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        host(
          prefs,
          Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showAchievementCelebration(
                    context,
                    [kGameAchievements[0], kGameAchievements[1]],
                  ),
                  child: const Text('باز کن'),
                ),
              ),
            ),
          ),
          dark: true,
          textScale: 1.3,
        ),
      );

      await tester.tap(find.text('باز کن'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('نشان‌های تازه!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
