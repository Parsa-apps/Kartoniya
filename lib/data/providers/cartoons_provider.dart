import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/app_haptics.dart';
import '../../core/services/app_preferences.dart';
import '../../core/utils/text_normalizer.dart';
import '../../domain/repositories/cartoon_repository.dart';
import '../models/cartoon_model.dart';
import '../models/child_profile_model.dart';
import '../repositories/local_cartoon_repository.dart';

/// در [main] با نمونهٔ واقعی SharedPreferences override می‌شود.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
      'SharedPreferences باید هنگام شروع برنامه فراهم شود.');
});

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  return AppPreferences(ref.watch(sharedPreferencesProvider));
});

final cartoonRepositoryProvider = Provider<CartoonRepository>((ref) {
  return LocalCartoonRepository();
});

final cartoonsProvider = FutureProvider<List<CartoonModel>>((ref) {
  return ref.watch(cartoonRepositoryProvider).fetchCartoons();
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(cartoonRepositoryProvider).fetchCategories();
});

final featuredCartoonsProvider =
    FutureProvider<List<CartoonModel>>((ref) async {
  final cartoons = await ref.watch(cartoonsProvider.future);
  return cartoons
      .where((cartoon) => cartoon.isFeatured)
      .toList(growable: false);
});

final newCartoonsProvider = FutureProvider<List<CartoonModel>>((ref) async {
  final cartoons = await ref.watch(cartoonsProvider.future);
  return cartoons.where((cartoon) => cartoon.isNew).toList(growable: false);
});

final popularCartoonsProvider = FutureProvider<List<CartoonModel>>((ref) async {
  final cartoons = await ref.watch(cartoonsProvider.future);
  final sorted = [...cartoons]..sort((a, b) => b.rating.compareTo(a.rating));
  return List.unmodifiable(sorted);
});

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final filteredCartoonsProvider =
    FutureProvider<List<CartoonModel>>((ref) async {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final cartoons = await ref.watch(cartoonsProvider.future);
  if (selectedCategory == null) return cartoons;
  return cartoons
      .where((cartoon) => cartoon.category == selectedCategory)
      .toList(growable: false);
});

final searchQueryProvider = StateProvider<String>((ref) => '');

/// شمارندهٔ درخواست فوکوس برای فیلد جست‌وجو.
///
/// برگهٔ جست‌وجو داخل IndexedStack همیشه mount است؛ با افزایش این مقدار،
/// صفحهٔ جست‌وجو فیلد را فوکوس می‌کند تا لمس «جست‌وجو» در خانه کاربر را
/// مستقیم به تایپ برساند (بدون autofocus ناخواسته هنگام شروع برنامه).
final searchFocusRequestProvider = StateProvider<int>((ref) => 0);

/// امتیاز مرتبط‌بودن برای مرتب‌سازی نتایج جست‌وجو.
/// هرچه عدد کوچک‌تر، مرتبط‌تر.
int searchRelevanceScore(CartoonModel cartoon, String normalizedQuery) {
  final title = normalizeForSearch(cartoon.title);
  if (title == normalizedQuery) return 0;
  if (title.startsWith(normalizedQuery)) return 1;
  if (title.contains(normalizedQuery)) return 2;
  if (normalizeForSearch(cartoon.category).contains(normalizedQuery)) return 3;
  if (cartoon.tags.any(
    (tag) => normalizeForSearch(tag).contains(normalizedQuery),
  )) {
    return 4;
  }
  return 5;
}

final searchResultsProvider = FutureProvider<List<CartoonModel>>((ref) async {
  final query = normalizeForSearch(ref.watch(searchQueryProvider));
  if (query.isEmpty) return const <CartoonModel>[];
  final cartoons = await ref.watch(cartoonsProvider.future);
  final matches = cartoons.where((cartoon) {
    final searchableText = <String>[
      cartoon.title,
      cartoon.description,
      cartoon.category,
      ...cartoon.tags,
    ].join(' ');
    return normalizeForSearch(searchableText).contains(query);
  }).toList();
  matches.sort((a, b) {
    final score = searchRelevanceScore(a, query).compareTo(
      searchRelevanceScore(b, query),
    );
    if (score != 0) return score; // امتیاز کمتر یعنی مرتبط‌تر
    return b.rating.compareTo(a.rating);
  });
  return List.unmodifiable(matches);
});

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier(ref.watch(appPreferencesProvider));
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier(this._preferences) : super(_preferences.favoriteIds);

  final AppPreferences _preferences;

  void toggle(String cartoonId) {
    final next = <String>{...state};
    if (!next.add(cartoonId)) next.remove(cartoonId);
    state = Set<String>.unmodifiable(next);
    unawaited(_preferences.saveFavoriteIds(state));
  }

  /// شناسه‌های نامعتبر (کارتون حذف‌شده از کاتالوگ) از فهرست و حافظه پاک
  /// می‌شوند تا شمارنده و UI همیشه با دادهٔ واقعی هم‌خوان بمانند.
  void pruneTo(Set<String> validIds) {
    if (state.every(validIds.contains)) return;
    final next = state.where(validIds.contains).toSet();
    state = Set<String>.unmodifiable(next);
    unawaited(_preferences.saveFavoriteIds(next));
  }

  Future<void> clear() async {
    state = const <String>{};
    await _preferences.clearFavorites();
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(appPreferencesProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._preferences) : super(_preferences.themeMode);

  final AppPreferences _preferences;

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await _preferences.saveThemeMode(mode);
  }
}

final autoplayProvider = StateNotifierProvider<AutoplayNotifier, bool>((ref) {
  return AutoplayNotifier(ref.watch(appPreferencesProvider));
});

class AutoplayNotifier extends StateNotifier<bool> {
  AutoplayNotifier(this._preferences) : super(_preferences.autoplayEnabled);

  final AppPreferences _preferences;

  Future<void> setEnabled(bool value) async {
    state = value;
    await _preferences.saveAutoplayEnabled(value);
  }
}

/// کاهش حرکت (برای گوشی‌های ضعیف یا کودکان حساس به انیمیشن).
final reduceMotionProvider =
    StateNotifierProvider<ReduceMotionNotifier, bool>((ref) {
  return ReduceMotionNotifier(ref.watch(appPreferencesProvider));
});

class ReduceMotionNotifier extends StateNotifier<bool> {
  ReduceMotionNotifier(this._preferences)
      : super(_preferences.reduceMotionEnabled);

  final AppPreferences _preferences;

  Future<void> setEnabled(bool value) async {
    state = value;
    await _preferences.saveReduceMotionEnabled(value);
  }
}

/// بازخورد لمسی اختیاری؛ یک تنظیم واحد برای همهٔ اجزای تعاملی.
final hapticsProvider = StateNotifierProvider<HapticsNotifier, bool>((ref) {
  return HapticsNotifier(ref.watch(appPreferencesProvider));
});

class HapticsNotifier extends StateNotifier<bool> {
  HapticsNotifier(this._preferences) : super(_preferences.hapticsEnabled) {
    AppHaptics.setEnabled(state);
  }

  final AppPreferences _preferences;

  Future<void> setEnabled(bool value) async {
    state = value;
    AppHaptics.setEnabled(value);
    await _preferences.saveHapticsEnabled(value);
  }
}

final childProfileProvider =
    StateNotifierProvider<ChildProfileNotifier, ChildProfileModel>((ref) {
  return ChildProfileNotifier(ref.watch(appPreferencesProvider));
});

class ChildProfileNotifier extends StateNotifier<ChildProfileModel> {
  ChildProfileNotifier(this._preferences)
      : super(
          ChildProfileModel(
            name: _preferences.childProfileName ?? '',
            ageYears: _preferences.childProfileAge,
            avatarIndex: _preferences.childAvatarIndex,
          ),
        );

  final AppPreferences _preferences;

  Future<void> updateProfile({
    required String name,
    required int ageYears,
    required int avatarIndex,
  }) async {
    final safeAge = ageYears.clamp(1, 18).toInt();
    final safeAvatar =
        avatarIndex.clamp(0, ChildProfileModel.avatars.length - 1).toInt();
    final next = ChildProfileModel(
      name: name.trim(),
      ageYears: safeAge,
      avatarIndex: safeAvatar,
    );
    state = next;
    await _preferences.saveChildProfile(
      name: next.name,
      ageYears: next.ageYears,
      avatarIndex: next.avatarIndex,
    );
  }

  Future<void> rename(String value) async {
    final next = state.copyWith(name: value.trim());
    state = next;
    await _preferences.saveChildProfile(name: next.name);
  }

  Future<void> setAvatar(int index) async {
    final next = state.copyWith(
      avatarIndex: index.clamp(0, ChildProfileModel.avatars.length - 1).toInt(),
    );
    state = next;
    await _preferences.saveChildProfile(avatarIndex: next.avatarIndex);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier(ref.watch(appPreferencesProvider));
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._preferences)
      : super(_preferences.onboardingCompleted);

  final AppPreferences _preferences;

  Future<void> complete() async {
    state = true;
    await _preferences.completeOnboarding();
  }
}

final watchHistoryProvider =
    StateNotifierProvider<WatchHistoryNotifier, Map<String, double>>((ref) {
  return WatchHistoryNotifier(ref.watch(appPreferencesProvider));
});

class WatchHistoryNotifier extends StateNotifier<Map<String, double>> {
  WatchHistoryNotifier(this._preferences)
      : super(Map<String, double>.unmodifiable(_preferences.watchProgress));

  final AppPreferences _preferences;

  void saveProgress(String episodeId, double value) {
    final normalized = value.clamp(0.0, 1.0).toDouble();
    final next = <String, double>{...state};
    if (normalized >= .995) {
      next.remove(episodeId);
    } else if (normalized > .01) {
      next[episodeId] = normalized;
    }
    state = Map<String, double>.unmodifiable(next);
    unawaited(_preferences.saveWatchProgress(state));
  }

  /// موقعیت‌های مربوط به قسمت‌های حذف‌شده از کاتالوگ پاک می‌شوند.
  void pruneTo(Set<String> validEpisodeIds) {
    if (state.keys.every(validEpisodeIds.contains)) return;
    final next = Map.fromEntries(
      state.entries.where((entry) => validEpisodeIds.contains(entry.key)),
    );
    state = Map<String, double>.unmodifiable(next);
    unawaited(_preferences.saveWatchProgress(next));
  }

  Future<void> clear() async {
    state = const <String, double>{};
    await _preferences.clearWatchProgress();
  }
}

final episodeProgressProvider =
    Provider.family<double, String>((ref, episodeId) {
  return ref.watch(watchHistoryProvider)[episodeId] ?? 0.0;
});

/// یک آیتم «ادامهٔ تماشا»؛ فقط برای قسمت‌های معتبر کاتالوگ ساخته می‌شود.
class ContinueWatchingEntry {
  const ContinueWatchingEntry({
    required this.cartoon,
    required this.episode,
    required this.progress,
  });

  final CartoonModel cartoon;
  final EpisodeModel episode;
  final double progress;
}

/// ردیف ادامهٔ تماشا در خانه و صفحهٔ جزئیات از همین provider تغذیه می‌شود
/// تا منطق «درصد واقعی + حذف محتوای نامعتبر» یک‌جا و قابل‌تست بماند.
final continueWatchingProvider =
    FutureProvider<List<ContinueWatchingEntry>>((ref) async {
  final cartoons = await ref.watch(cartoonsProvider.future);
  final history = ref.watch(watchHistoryProvider);
  final entries = <ContinueWatchingEntry>[];
  for (final cartoon in cartoons) {
    for (final episode in cartoon.episodes) {
      final amount = history[episode.id];
      if (amount != null && amount > .01 && amount < .995) {
        entries.add(
          ContinueWatchingEntry(
            cartoon: cartoon,
            episode: episode,
            progress: amount,
          ),
        );
      }
    }
  }
  return List.unmodifiable(entries);
});
