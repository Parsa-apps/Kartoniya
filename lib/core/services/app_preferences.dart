import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ذخیره‌سازی کوچک و محلی تنظیم‌ها؛ هیچ حساب کاربری، رمز یا دادهٔ حساس در این
/// سرویس نگه‌داری نمی‌شود.
class AppPreferences {
  AppPreferences(this._storage);

  final SharedPreferences _storage;

  static const _onboardingKey = 'onboarding_completed';
  static const _favoritesKey = 'favorite_cartoon_ids';
  static const _themeKey = 'theme_mode';
  static const _autoplayKey = 'autoplay_enabled';
  static const _parentNameKey = 'parent_display_name';
  static const _watchProgressKey = 'watch_progress';
  static const _reduceMotionKey = 'reduce_motion_enabled';
  static const _childProfileKey = 'child_profile';

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

  /// کاهش حرکت؛ کنار flag سیستمی، والد می‌تواند دستی آن را فعال کند.
  bool get reduceMotionEnabled => _storage.getBool(_reduceMotionKey) ?? false;
  Future<bool> saveReduceMotionEnabled(bool value) =>
      _storage.setBool(_reduceMotionKey, value);

  String get parentName => _storage.getString(_parentNameKey) ?? 'والد مهربان';
  Future<bool> saveParentName(String value) => _storage.setString(
        _parentNameKey,
        value.trim().isEmpty ? 'والد مهربان' : value.trim(),
      );

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

  Future<bool> saveChildProfile({String? name, int? avatarIndex}) async {
    final current = childProfileName;
    final currentAvatar = childAvatarIndex;
    final payload = <String, dynamic>{
      'name': name?.trim() ?? (current ?? ''),
      'avatar': avatarIndex ?? currentAvatar,
    };
    return _storage.setString(_childProfileKey, jsonEncode(payload));
  }

  Future<void> clearWatchProgress() async => _storage.remove(_watchProgressKey);
  Future<void> clearFavorites() async => _storage.remove(_favoritesKey);
}
