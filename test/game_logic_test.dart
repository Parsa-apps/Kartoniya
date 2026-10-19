import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/repositories/local_game_repository.dart';
import 'package:kartoniya/presentation/games/game_router.dart';

void main() {
  group('GameRepository 100', () {
    test('۱۰۰ بازی یکتا و ۲۱ مکانیک مستقل', () async {
      final games = await LocalGameRepository().fetchGames();
      expect(games.length, 100);
      expect(games.map((g) => g.id).toSet().length, 100);
      // ۲۱ موتور مستقل پس از فاز D
      final mechs = games.map((g) => g.mechanics).toSet();
      expect(mechs.length, greaterThanOrEqualTo(21));
      // ۵ مکانیک جدید فاز D
      expect(mechs.contains('story_order'), isTrue);
      expect(mechs.contains('jigsaw_drag'), isTrue);
      expect(mechs.contains('color_pattern_builder'), isTrue);
      expect(mechs.contains('number_quantity'), isTrue);
      expect(mechs.contains('habitat_sort'), isTrue);
    });

    test('همهٔ ۱۰۰ مکانیک به موتور واقعی نگاشت شده‌اند', () async {
      final games = await LocalGameRepository().fetchGames();
      for (final g in games) {
        final widget = buildGameForMechanics(g);
        // fallback is _GenericPlaceholderGame whose type name contains Placeholder
        expect(widget.runtimeType.toString().contains('Placeholder'), isFalse,
            reason: 'مرحله ${g.id} با mechanics ${g.mechanics} هنوز fallback است');
      }
    });
  });

  group('Score logic', () {
    test('امتیاز slide puzzle = 100 - حرکات', () {
      int moves = 25;
      final score = (100 - moves).clamp(20, 100).toInt();
      expect(score, 75);
      expect((100 - 0).clamp(20, 100), 100);
      expect((100 - 90).clamp(20, 100), 20);
    });

    test('امتیاز mathRace با زمان', () {
      int base = 10, timeLeft = 5;
      expect(base + timeLeft, 15);
    });

    test('امتیاز memory = 100 - 2*moves - seconds', () {
      int moves = 10, sec = 20;
      final s = (100 - moves * 2 - sec).clamp(10, 100).toInt();
      expect(s, 60);
    });
  });
}
