import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/models/cartoon_model.dart';
import 'package:kartoniya/data/models/child_profile_model.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/domain/repositories/cartoon_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> _container([
  Map<String, Object> initialValues = const {},
  CartoonRepository? repository,
]) async {
  SharedPreferences.setMockInitialValues(initialValues);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      if (repository != null)
        cartoonRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

class _TestCartoonRepository implements CartoonRepository {
  const _TestCartoonRepository(this.cartoons);

  final List<CartoonModel> cartoons;

  @override
  Future<List<CartoonModel>> fetchCartoons() async => cartoons;

  @override
  Future<List<CategoryModel>> fetchCategories() async =>
      const <CategoryModel>[];
}

void main() {
  group('FavoritesNotifier', () {
    test('toggle افزودن/حذف را ذخیره می‌کند', () async {
      final container = await _container();
      final notifier = container.read(favoritesProvider.notifier);

      notifier.toggle('felak');
      expect(container.read(favoritesProvider), {'felak'});

      notifier.toggle('felak');
      expect(container.read(favoritesProvider), isEmpty);
      await Future<void>.delayed(Duration.zero);
    });

    test('pruneTo شناسه‌های نامعتبر را دور می‌ریزد', () async {
      final container = await _container({
        'favorite_cartoon_ids': <String>['felak', 'ghost'],
      });
      expect(container.read(favoritesProvider), {'felak', 'ghost'});

      container.read(favoritesProvider.notifier).pruneTo({'felak', 'alefba'});
      expect(container.read(favoritesProvider), {'felak'});
      await Future<void>.delayed(Duration.zero);
    });

    test('pruneTo بدون تغییر، نوشتن مجدد نمی‌کند', () async {
      final container = await _container({
        'favorite_cartoon_ids': <String>['felak'],
      });
      final before = container.read(favoritesProvider);
      container.read(favoritesProvider.notifier).pruneTo({'felak'});
      expect(identical(container.read(favoritesProvider), before), isTrue);
    });
  });

  group('WatchHistoryNotifier', () {
    test('درصد کم ذخیره و صد درصد پاک می‌شود', () async {
      final container = await _container();
      final notifier = container.read(watchHistoryProvider.notifier);

      notifier.saveProgress('e1', .005);
      expect(container.read(watchHistoryProvider), isEmpty);

      notifier.saveProgress('e1', .3);
      expect(container.read(watchHistoryProvider)['e1'], .3);

      notifier.saveProgress('e1', 1.0);
      expect(container.read(watchHistoryProvider), isEmpty);
      await Future<void>.delayed(Duration.zero);
    });

    test('pruneTo فقط شناسه‌های معتبر را نگه می‌دارد', () async {
      final container = await _container({
        'watch_progress': '{"felak-1":0.4,"ghost-1":0.9}',
      });
      final history = container.read(watchHistoryProvider);
      expect(history.keys, containsAll(['felak-1', 'ghost-1']));

      container
          .read(watchHistoryProvider.notifier)
          .pruneTo({'felak-1', 'felak-2'});
      expect(container.read(watchHistoryProvider).keys, ['felak-1']);
    });
  });

  group('ChildProfileNotifier', () {
    test('نام با فاصله‌گذاری ذخیره و آواتار کلمپ می‌شود', () async {
      final container = await _container();
      final notifier = container.read(childProfileProvider.notifier);

      await notifier.rename('  آرش  ');
      expect(container.read(childProfileProvider).name, 'آرش');

      await notifier.setAvatar(99);
      expect(
        container.read(childProfileProvider).avatarIndex,
        lessThan(ChildProfileModel.avatars.length),
      );
    });
  });

  group('ReduceMotion / Theme / Autoplay', () {
    test('مقادیر اولیه از SharedPreferences خوانده و ذخیره می‌شوند', () async {
      final container = await _container({
        'theme_mode': 'dark',
        'reduce_motion_enabled': true,
      });

      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(container.read(reduceMotionProvider), isTrue);

      await container.read(reduceMotionProvider.notifier).setEnabled(false);
      expect(container.read(reduceMotionProvider), isFalse);
    });
  });

  group('جست‌وجو و فیلتر', () {
    test('حروف عربی و فارسی یک نتیجه می‌دهند', () async {
      final container = await _container();
      container.read(searchQueryProvider.notifier).state = 'ماجراجوي';
      final results = await container.read(searchResultsProvider.future);
      expect(results.map((c) => c.id), contains('felak'));
    });

    test('مرتب‌سازی بر اساس مرتبط‌بودن است و در تساوی ترتیب کاتالوگ می‌ماند',
        () async {
      final container = await _container();
      container.read(searchQueryProvider.notifier).state = 'آموزشی';
      final results = await container.read(searchResultsProvider.future);
      expect(results.map((cartoon) => cartoon.id), ['alefba', 'math']);
    });

    test('continueWatching پیشرفت embed را قابل ازسرگیری نشان نمی‌دهد',
        () async {
      final container = await _container({
        'watch_progress': '{"felak-1":0.5,"felak-99":0.5,"math-1":0.999}',
      });
      final entries = await container.read(continueWatchingProvider.future);
      expect(entries, isEmpty);
    });

    test('continueWatching فقط پیشرفت URL مستقیم امن را نشان می‌دهد', () async {
      const cartoon = CartoonModel(
        id: 'test',
        title: 'آزمون',
        description: '',
        category: 'آموزشی',
        artworkEmoji: '🧪',
        artworkColorValue: 0xFFFFFFFF,
        episodes: [
          EpisodeModel(
            id: 'native-1',
            title: 'ویدئوی مستقیم',
            durationSeconds: 60,
            videoUrl: 'https://cdn.example.test/video.mp4',
          ),
          EpisodeModel(
            id: 'embed-1',
            title: 'ویدئوی embed',
            durationSeconds: 60,
            videoUrl: 'https://www.aparat.com/v/abc123',
          ),
        ],
      );
      final container = await _container(
        {'watch_progress': '{"native-1":0.5,"embed-1":0.6}'},
        const _TestCartoonRepository([cartoon]),
      );

      final entries = await container.read(continueWatchingProvider.future);
      expect(entries.map((entry) => entry.episode.id), ['native-1']);
    });
  });
}
