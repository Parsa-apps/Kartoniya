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
              cartoon.episodes
                  .every((episode) => episode.videoUrl.startsWith('https://')),
        ),
        isTrue,
      );
    });

    test('هر بخش دو ویدیوی متمایز آپارات دارد؛ هیچ فایل نمونه‌ای نیست',
        () async {
      final cartoons = await LocalCartoonRepository().fetchCartoons();
      final episodes = cartoons.expand((cartoon) => cartoon.episodes).toList();
      expect(cartoons.length, 8);
      expect(cartoons.every((cartoon) => cartoon.episodes.length == 2), isTrue);
      expect(episodes.length, 16);
      expect(episodes.map((episode) => episode.aparatVideoHash).toSet().length,
          16);
      expect(
          episodes.every((episode) => episode.aparatEmbedUri != null), isTrue);
      expect(
          episodes.every((episode) => episode.durationSeconds >= 30), isTrue);
      // توضیح هر قسمت باید محتوایی باشد؛ معرفی منبع در پلیر نمایش داده نمی‌شود
      // جزئیات حقوقی/منبع در docs/aparat-content.md نگه‌داری می‌شود.
      expect(
          episodes.every((episode) => episode.description.isNotEmpty),
          isTrue);
      // اطمینان از اینکه description دیگر برچسب منبع را در UI حمل نمی‌کند
      expect(
          episodes.any((episode) => episode.description.contains('منبع:')),
          isFalse);
      expect(episodes.any((episode) => episode.videoUrl.contains('bee.mp4')),
          isFalse);
    });

    test('دستهٔ همه در ابتدای فهرست قرار دارد', () async {
      final categories = await LocalCartoonRepository().fetchCategories();
      expect(categories.first.id, 'all');
    });

    test('هر کارتون تصویر پوستر محلی و یکتای خود را دارد', () async {
      final cartoons = await LocalCartoonRepository().fetchCartoons();
      final assets = cartoons.map((cartoon) => cartoon.artworkAsset).toList();
      expect(assets.every((asset) => asset != null), isTrue);
      expect(assets.toSet().length, cartoons.length);
      expect(
        assets.every(
          (asset) =>
              asset!.startsWith('asset/images/posters/') &&
              asset.endsWith('.webp'),
        ),
        isTrue,
      );
    });
  });
}
