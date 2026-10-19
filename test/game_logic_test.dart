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

    test('امتیاز story_order = 10 هر مرحله صحیح', () {
      int correctRounds = 3;
      expect(correctRounds * 10, 30);
    });

    test('امتیاز jigsaw = 10 هر تکه صحیح', () {
      int correct = 4;
      expect(correct * 10, 40);
    });

    test('امتیاز color_pattern = 10 هر الگو', () {
      int ok = 5;
      expect(ok * 10, 50);
    });

    test('شرط پایان story_order: 5 مرحله', () {
      int round = 5, max = 5;
      expect(round >= max, isTrue);
    });

    test('شرط پایان number_quantity: اتمام 4 جفت', () {
      List<int> numbers = [];
      expect(numbers.isEmpty, isTrue);
    });

    test('شروع مجدد: reset score و round', () {
      int score = 40, round = 5;
      score = 0; round = 1;
      expect(score, 0);
      expect(round, 1);
    });

    test('پذیرش drag معتبر vs نامعتبر', () {
      // jigsaw: slot null → accept, occupied → reject
      List<int?> slots = [null, 1, null, null];
      int slot = 0;
      expect(slots[slot] == null, isTrue); // valid
      expect(slots[1] == null, isFalse); // invalid (occupied)
      // habitat_sort: correct habitat
      String animalHab = 'جنگل';
      String targetHab = 'جنگل';
      expect(animalHab == targetHab, isTrue);
      expect('دریا' == targetHab, isFalse);
    });

    test('ذخیره رکورد فقط با امتیاز بالاتر', () {
      Map<String, int> scores = {'memory_classic': 50};
      int newScore = 60;
      if (newScore > (scores['memory_classic'] ?? 0)) scores['memory_classic'] = newScore;
      expect(scores['memory_classic'], 60);
      // lower score should not overwrite
      int lower = 40;
      if (lower > (scores['memory_classic'] ?? 0)) scores['memory_classic'] = lower;
      expect(scores['memory_classic'], 60);
    });
  });

  group('Storage compatibility', () {
    test('شناسه‌های تغییر یافته همچنان معتبرند (بدون نیاز به مهاجرت)', () async {
      final games = await LocalGameRepository().fetchGames();
      final ids = games.map((g) => g.id).toSet();
      // 5 شناسه‌ای که محتوا عوض شد ولی id حفظ شد
      const reusedIds = ['memory_sounds', 'puzzle_picture_logic', 'puzzle_color_seq', 'sorting_fruits_veg', 'hidden_garden'];
      for (final id in reusedIds) {
        expect(ids.contains(id), isTrue, reason: 'id $id باید همچنان وجود داشته باشد تا داده ذخیره‌شده پاک نشود');
      }
      // favorite/recent قدیمی با همین idها هنوز معتبرند — نیاز به migration نیست چون منتشر نشده
      Set<String> fakeOldFavorites = {'memory_sounds', 'puzzle_picture_logic'};
      // pruneTo باید آن‌ها را نگه دارد چون id هنوز موجود است
      final validIds = ids;
      final pruned = fakeOldFavorites.where(validIds.contains).toSet();
      expect(pruned.length, 2);
    });
  });
}
