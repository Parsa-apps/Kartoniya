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

  group('Aparat sources', () {
    EpisodeModel source(String url) => EpisodeModel(
      id: 'source', title: 'منبع', durationSeconds: 60, videoUrl: url,
    );

    test('watch page becomes the official embed URL, preserving hash case', () {
      final value = source('https://www.aparat.com/v/SfomR');
      expect(value.aparatVideoHash, 'SfomR');
      expect(value.aparatEmbedUri.toString(),
          'https://www.aparat.com/video/video/embed/videohash/SfomR/vt/frame');
      expect(source('https://aparat.com/v/ddy5427').aparatVideoHash, 'ddy5427');
    });

    test('non-Aparat, malformed and insecure sources cannot enter WebView', () {
      for (final url in [
        'https://example.com/video.mp4',
        'http://www.aparat.com/v/abc',
        'https://aparat.com.evil.test/v/abc',
        'https://evil.test@www.aparat.com/v/abc',
        'https://www.aparat.com:444/v/abc',
        'https://www.aparat.com/v/abc?redirect=evil',
        'https://www.aparat.com/v/abc#fragment',
        'https://www.aparat.com/v/',
        'https://www.aparat.com/v/abc/extra',
        'https://www.aparat.com/v/ab%2Fcd',
      ]) {
        expect(source(url).aparatEmbedUri, isNull, reason: url);
      }
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
