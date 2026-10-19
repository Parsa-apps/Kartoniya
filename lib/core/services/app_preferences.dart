import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// تنظیمات و پروفایل نمایشی کودک را فقط در حافظهٔ محلی همین دستگاه نگه می‌دارد؛
/// حساب کاربری، رمز، تاریخ تولد یا شناسهٔ کودک در این سرویس ثبت نمی‌شود.
class AppPreferences {
  AppPreferences(this._storage);

  final SharedPreferences _storage;

  static const _onboardingKey = 'onboarding_completed';
  static const _favoritesKey = 'favorite_cartoon_ids';
  static const _themeKey = 'theme_mode';
  static const _autoplayKey = 'autoplay_enabled';
  static const _legacyParentNameKey = 'parent_display_name';
  static const _watchProgressKey = 'watch_progress';
  static const _hapticsKey = 'haptics_enabled';
  static const _childProfileKey = 'child_profile';
  static const _favoriteGamesKey = 'favorite_game_ids';
  static const _recentGamesKey = 'recent_game_ids';
  static const _gameScoresKey = 'game_scores';

  bool get onboardingCompleted => _storage.getBool(_onboardingKey) ?? false;
  Future<bool> completeOnboarding() => _storage.setBool(_onboardingKey, true);

  Set<String> get favoriteIds =>
      (_storage.getStringList(_favoritesKey) ?? const <String>[]).toSet();

  Future<bool> saveFavoriteIds(Set<String> ids) {
    final sorted = ids.toList()..sort();
    return _storage.setStringList(_favoritesKey, sorted);
  }

  ThemeMode get themeMode {
    switch (_storage.getString(_themeKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<bool> saveThemeMode(ThemeMode mode) =>
      _storage.setString(_themeKey, mode.name);

  bool get autoplayEnabled => _storage.getBool(_autoplayKey) ?? true;
  Future<bool> saveAutoplayEnabled(bool value) =>
      _storage.setBool(_autoplayKey, value);

  /// اختیاری‌بودن بازخورد لمسی؛ خاموش‌کردن آن همهٔ بازخوردهای رابط را
  /// غیرفعال می‌کند، درحالی‌که تنظیم هپتیک سیستم‌عامل همچنان مرجع نهایی است.
  bool get hapticsEnabled => _storage.getBool(_hapticsKey) ?? true;
  Future<bool> saveHapticsEnabled(bool value) =>
      _storage.setBool(_hapticsKey, value);

  /// پاک‌کردن نام والد ذخیره‌شده در نسخه‌های قبلی؛ اپ دیگر این داده را نمی‌خواند.
  Future<bool> clearLegacyParentName() =>
      _storage.remove(_legacyParentNameKey);

  Map<String, double> get watchProgress {
    final raw = _storage.getString(_watchProgressKey);
    if (raw == null || raw.isEmpty) return <String, double>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return <String, double>{};
      final result = <String, double>{};
      decoded.forEach((key, value) {
        final number = value is num ? value.toDouble() : 0.0;
        result[key] = number.clamp(0.0, 1.0).toDouble();
      });
      return result;
    } on FormatException {
      return <String, double>{};
    }
  }

  Future<bool> saveWatchProgress(Map<String, double> progress) {
    final normalized = progress.map(
      (key, value) => MapEntry(key, value.clamp(0.0, 1.0).toDouble()),
    );
    return _storage.setString(_watchProgressKey, jsonEncode(normalized));
  }

  /// پروفایل کودک به‌صورت JSON خوانده می‌شود؛ دادهٔ خراب باعث خطا نمی‌شود
  /// و به حالت خالی برمی‌گردد.
  String? get childProfileName {
    final raw = _storage.getString(_childProfileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final name = decoded['name'];
      return name is String ? name : null;
    } on FormatException {
      return null;
    }
  }

  int get childAvatarIndex {
    final raw = _storage.getString(_childProfileKey);
    if (raw == null || raw.isEmpty) return 0;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return 0;
      final index = decoded['avatar'];
      return index is int && index >= 0 ? index : 0;
    } on FormatException {
      return 0;
    }
  }

  int? get childProfileAge {
    final raw = _storage.getString(_childProfileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final age = decoded['ageYears'];
      return age is int && age >= 1 && age <= 18 ? age : null;
    } on FormatException {
      return null;
    }
  }

  Future<bool> saveChildProfile({
    String? name,
    int? ageYears,
    int? avatarIndex,
  }) async {
    final current = childProfileName;
    final currentAvatar = childAvatarIndex;
    final requestedAge = ageYears ?? childProfileAge;
    final payload = <String, dynamic>{
      'name': name?.trim() ?? (current ?? ''),
      if (requestedAge != null && requestedAge >= 1 && requestedAge <= 18)
        'ageYears': requestedAge,
      'avatar': avatarIndex ?? currentAvatar,
    };
    return _storage.setString(_childProfileKey, jsonEncode(payload));
  }

  Set<String> get favoriteGameIds =>
      (_storage.getStringList(_favoriteGamesKey) ?? const <String>[]).toSet();
  Future<bool> saveFavoriteGameIds(Set<String> ids) {
    final sorted = ids.toList()..sort();
    return _storage.setStringList(_favoriteGamesKey, sorted);
  }

  List<String> get recentGameIds =>
      _storage.getStringList(_recentGamesKey) ?? const <String>[];
  Future<bool> saveRecentGameIds(List<String> ids) =>
      _storage.setStringList(_recentGamesKey, ids.take(10).toList());

  Map<String, int> get gameScores {
    final raw = _storage.getString(_gameScoresKey);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const {};
      return decoded.map((k, v) => MapEntry(k, v is int ? v : 0));
    } catch (_) {
      return const {};
    }
  }

  Future<bool> saveGameScore(String gameId, int score) {
    final current = Map<String, int>.from(gameScores);
    final existing = current[gameId] ?? 0;
    if (score <= existing) return Future.value(true);
    current[gameId] = score;
    return _storage.setString(_gameScoresKey, jsonEncode(current));
  }

  Future<void> clearGameScores() async => _storage.remove(_gameScoresKey);

  Future<void> clearWatchProgress() async => _storage.remove(_watchProgressKey);
  Future<void> clearFavorites() async => _storage.remove(_favoritesKey);
}
