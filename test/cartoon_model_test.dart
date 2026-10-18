import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/models/cartoon_model.dart';

void main() {
  EpisodeModel episode(int number, int minutes, {int seconds = 0}) => EpisodeModel(
        id: 'x-$number',
        title: 'قسمت $number',
        durationSeconds: minutes * 60 + seconds,
        videoUrl: 'https://example.com/$number.mp4',
      );

  CartoonModel cartoon() => CartoonModel(
        id: 'x',
        title: 'آزمون',
        description: 'توضیح آزمون',
        category: 'آموزشی',
        duration: 12,
        rating: 4.5,
        ageRange: '۴ تا ۶',
        artworkEmoji: '🧪',
        artworkColorValue: 0xFF123456,
        episodes: [episode(1, 12), episode(2, 13, seconds: 30)],
      );

  group('CartoonModel', () {
    test('copyWith شناسه را حفظ می‌کند و فیلدها را جایگزین می‌کند', () {
      final copy = cartoon().copyWith(title: 'آزمون ۲', isNew: true);
      expect(copy.id, 'x');
      expect(copy.title, 'آزمون ۲');
      expect(copy.isNew, isTrue);
      expect(copy.isFeatured, isFalse);
      expect(copy.episodes.length, 2);
    });

    test('برچسب مدت و تعداد قسمت‌ها درست است', () {
      final value = cartoon();
      expect(value.durationLabel, '12 دقیقه');
      expect(value.episodeCount, 2);
      expect(value.firstEpisode.id, 'x-1');
    });

    test('رنگ artwork از مقدار عددی ساخته می‌شود', () {
      expect(cartoon().artworkColor.value, 0xFF123456);
    });
  });

  group('EpisodeModel.durationLabel', () {
    test('دقیق دقیقه‌ای بدون ثانیه نمایش داده می‌شود', () {
      expect(episode(1, 14).durationLabel, '14 دقیقه');
    });

    test('ثانیه با دو رقم pad می‌شود', () {
      expect(episode(2, 13, seconds: 30).durationLabel, '13:30 دقیقه');
      expect(episode(3, 9, seconds: 5).durationLabel, '9:05 دقیقه');
    });
  });
}
