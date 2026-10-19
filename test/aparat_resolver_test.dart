// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/services/aparat_resolver.dart';
import 'package:kartoniya/data/models/cartoon_model.dart';

void main() {
  group('AparatResolver', () {
    test('hash معتبر حروف و اعداد را می‌پذیرد (حساس به حروف بزرگ)', () {
      expect(AparatResolver.isValidHash('SfomR'), isTrue);
      expect(AparatResolver.isValidHash('ddy5427'), isTrue);
      expect(AparatResolver.isValidHash('vsb5i06'), isTrue);
      expect(AparatResolver.isValidHash(''), isFalse);
      expect(AparatResolver.isValidHash('abc-123'), isFalse);
      expect(AparatResolver.isValidHash('ab/cd'), isFalse);
    });

    test('watchUrl و embedUri از hash ساخته می‌شوند', () {
      expect(AparatResolver.watchUrl('ddy5427'),
          'https://www.aparat.com/v/ddy5427');
      expect(AparatResolver.embedUri('SfomR').toString(),
          'https://www.aparat.com/video/video/embed/videohash/SfomR/vt/frame');
    });

    test('hashFromUrl فقط canonical HTTPS را می‌پذیرد', () {
      expect(AparatResolver.hashFromUrl('https://www.aparat.com/v/ddy5427'),
          'ddy5427');
      expect(AparatResolver.hashFromUrl('https://aparat.com/v/SfomR'), 'SfomR');
      // نامعتبرها
      expect(AparatResolver.hashFromUrl('http://www.aparat.com/v/abc'), isNull);
      expect(
          AparatResolver.hashFromUrl(
              'https://www.aparat.com/v/abc?redirect=evil'),
          isNull);
      expect(
          AparatResolver.hashFromUrl('https://www.aparat.com/v/abc#frag'),
          isNull);
      expect(AparatResolver.hashFromUrl('https://evil.com/v/abc'), isNull);
      expect(AparatResolver.hashFromUrl('https://www.aparat.com:443/v/abc'),
          isNull);
      expect(AparatResolver.hashFromUrl('https://www.aparat.com/v/'), isNull);
      expect(
          AparatResolver.hashFromUrl('https://www.aparat.com/v/abc/extra'),
          isNull);
      expect(
          AparatResolver.hashFromUrl('https://aparat.com.evil.test/v/abc'),
          isNull);
      expect(
          AparatResolver.hashFromUrl('https://evil.test@www.aparat.com/v/abc'),
          isNull);
    });

    test('isAparatSource و embedUriFromUrl', () {
      expect(AparatResolver.isAparatSource('https://www.aparat.com/v/abc123'),
          isTrue);
      expect(
          AparatResolver.embedUriFromUrl('https://www.aparat.com/v/abc123')
              .toString(),
          'https://www.aparat.com/video/video/embed/videohash/abc123/vt/frame');
      expect(
          AparatResolver.isAparatSource('https://example.com/video.mp4'),
          isFalse);
    });

    test('resolveEpisode بین embed و direct و invalid تفکیک می‌کند', () {
      final aparatEpisode = EpisodeModel(
        id: 'e1',
        title: 'تست',
        durationSeconds: 60,
        videoUrl: 'https://www.aparat.com/v/ddy5427',
      );
      final res1 = AparatResolver.resolveEpisode(aparatEpisode);
      expect(res1.isEmbedded, isTrue);
      expect(res1.hash, 'ddy5427');
      expect(res1.embedUri, isNotNull);

      final directEpisode = EpisodeModel(
        id: 'e2',
        title: 'مستقیم',
        durationSeconds: 60,
        videoUrl: 'https://example.com/video.mp4',
      );
      final res2 = AparatResolver.resolveEpisode(directEpisode);
      expect(res2.isDirect, isTrue);
      expect(res2.directUri.toString(), 'https://example.com/video.mp4');

      final invalidEpisode = EpisodeModel(
        id: 'e3',
        title: 'خالی',
        durationSeconds: 60,
        videoUrl: '',
      );
      final res3 = AparatResolver.resolveEpisode(invalidEpisode);
      expect(res3.isInvalid, isTrue);
    });

    test('EpisodeModel با hash نامعتبر embed ندارد و خطای کنترل‌شده می‌دهد', () {
      final bad = EpisodeModel(
        id: 'bad',
        title: 'bad',
        durationSeconds: 60,
        videoUrl: 'https://www.aparat.com/v/bad-hash!',
      );
      expect(bad.aparatVideoHash, isNull);
      expect(bad.aparatEmbedUri, isNull);
      expect(bad.isAparatSource, isFalse);
      final res = AparatResolver.resolveEpisode(bad);
      expect(res.isInvalid, isTrue);
    });
  });

  group('EpisodeModel extended fields', () {
    test('فیلدهای فعال/غیرفعال و ترتیب مقدار پیش‌فرض دارند', () {
      const ep = EpisodeModel(
        id: 'x-1',
        title: 'قسمت ۱',
        durationSeconds: 60,
        videoUrl: 'https://www.aparat.com/v/abc123',
      );
      expect(ep.isActive, isTrue);
      expect(ep.sortOrder, 0);
      expect(ep.hasValidAparatHash, isTrue);
    });

    test('قسمت غیرفعال همچنان hash دارد اما فعال نیست', () {
      const ep = EpisodeModel(
        id: 'x-2',
        title: 'ق ۲',
        durationSeconds: 60,
        videoUrl: 'https://www.aparat.com/v/abc123',
        isActive: false,
        sortOrder: 2,
      );
      expect(ep.isActive, isFalse);
      expect(ep.aparatVideoHash, 'abc123');
    });
  });

  group('CartoonModel active & sort', () {
    test('فقط قسمت‌های فعال برگردانده می‌شوند', () {
      const cartoon = CartoonModel(
        id: 'c1',
        title: 'تست',
        description: 'توضیح',
        category: 'آموزشی',
        duration: 10,
        rating: 4.5,
        ageRange: '۴ تا ۶',
        artworkEmoji: '🧪',
        artworkColorValue: 0xFF123456,
        episodes: [
          EpisodeModel(
              id: 'c1-1',
              title: '۱',
              durationSeconds: 60,
              videoUrl: 'https://www.aparat.com/v/abc1',
              isActive: true),
          EpisodeModel(
              id: 'c1-2',
              title: '۲',
              durationSeconds: 60,
              videoUrl: 'https://www.aparat.com/v/abc2',
              isActive: false),
        ],
      );
      expect(cartoon.activeEpisodes.length, 1);
      expect(cartoon.activeEpisodes.first.id, 'c1-1');
    });

    test('hasAllValidHashes درست کار می‌کند', () {
      const ok = CartoonModel(
        id: 'ok',
        title: 'ok',
        description: 'd',
        category: 'سرگرمی',
        duration: 5,
        rating: 4.0,
        ageRange: '۳ تا ۶',
        artworkEmoji: '🌈',
        artworkColorValue: 0xFFFFC83D,
        episodes: [
          EpisodeModel(
              id: 'ok-1',
              title: '1',
              durationSeconds: 60,
              videoUrl: 'https://www.aparat.com/v/ab12'),
          EpisodeModel(
              id: 'ok-2',
              title: '2',
              durationSeconds: 60,
              videoUrl: 'https://www.aparat.com/v/cd34'),
        ],
      );
      expect(ok.hasAllValidHashes, isTrue);

      const bad = CartoonModel(
        id: 'bad',
        title: 'bad',
        description: 'd',
        category: 'سرگرمی',
        duration: 5,
        rating: 4.0,
        ageRange: '۳ تا ۶',
        artworkEmoji: '🌈',
        artworkColorValue: 0xFFFFC83D,
        episodes: [
          EpisodeModel(
              id: 'bad-1',
              title: '1',
              durationSeconds: 60,
              videoUrl: 'https://www.aparat.com/v/ab12'),
          EpisodeModel(
              id: 'bad-2',
              title: '2',
              durationSeconds: 60,
              videoUrl: 'https://example.com/video.mp4'),
        ],
      );
      expect(bad.hasAllValidHashes, isFalse);
    });
  });
}
