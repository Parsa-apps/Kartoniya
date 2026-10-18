import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/repositories/local_cartoon_repository.dart';

void main() {
  group('LocalCartoonRepository', () {
    test('کاتالوگ دارای شناسه‌های یکتا و قسمت قابل پخش است', () async {
      final repository = LocalCartoonRepository();
      final cartoons = await repository.fetchCartoons();

      expect(cartoons, isNotEmpty);
      expect(cartoons.map((item) => item.id).toSet().length, cartoons.length);
      expect(
        cartoons.every(
          (cartoon) =>
              cartoon.episodes.isNotEmpty &&
              cartoon.episodes.every((episode) => episode.videoUrl.startsWith('https://')),
        ),
        isTrue,
      );
    });

    test('هر بخش دو ویدیوی متمایز آپارات دارد؛ هیچ فایل نمونه‌ای نیست', () async {
      final cartoons = await LocalCartoonRepository().fetchCartoons();
      final episodes = cartoons.expand((cartoon) => cartoon.episodes).toList();
      expect(cartoons.length, 8);
      expect(cartoons.every((cartoon) => cartoon.episodes.length == 2), isTrue);
      expect(episodes.length, 16);
      expect(episodes.map((episode) => episode.aparatVideoHash).toSet().length, 16);
      expect(episodes.every((episode) => episode.aparatEmbedUri != null), isTrue);
      expect(episodes.every((episode) => episode.durationSeconds >= 30), isTrue);
      expect(episodes.every((episode) => episode.description.contains('آپارات')), isTrue);
      expect(episodes.any((episode) => episode.videoUrl.contains('bee.mp4')), isFalse);
    });

    test('دادهٔ تأییدنشده به‌عنوان رتبه، ردهٔ سنی یا تازگی نمایش‌پذیر نیست', () async {
      final cartoons = await LocalCartoonRepository().fetchCartoons();
      expect(
        cartoons.every(
          (cartoon) =>
              cartoon.rating == null &&
              (cartoon.ageRange == null || cartoon.ageRange!.isEmpty) &&
              !cartoon.isNew &&
              cartoon.episodes.every((episode) => !episode.isNew),
        ),
        isTrue,
      );
      expect(
        cartoons.every(
          (cartoon) =>
              cartoon.totalDurationSeconds ==
              cartoon.episodes.fold<int>(
                0,
                (sum, episode) => sum + episode.durationSeconds,
              ),
        ),
        isTrue,
      );
    });

    test('دستهٔ همه در ابتدای فهرست قرار دارد', () async {
      final categories = await LocalCartoonRepository().fetchCategories();
      expect(categories.first.id, 'all');
    });
  });
}
