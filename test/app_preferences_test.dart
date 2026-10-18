import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/services/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppPreferences', () {
    test('علاقه‌مندی‌ها مرتب و بازیابی می‌شوند', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferences(prefs);

      await service.saveFavoriteIds({'b', 'a', 'c'});
      expect(prefs.getStringList('favorite_cartoon_ids'), ['a', 'b', 'c']);
      expect(service.favoriteIds, {'a', 'b', 'c'});

      await service.clearFavorites();
      expect(service.favoriteIds, isEmpty);
    });

    test('تم، پخش خودکار و کاهش حرکت پایدارند', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferences(prefs);

      expect(service.themeMode, ThemeMode.system);
      await service.saveThemeMode(ThemeMode.dark);
      expect(service.themeMode, ThemeMode.dark);

      expect(service.autoplayEnabled, isTrue);
      await service.saveAutoplayEnabled(false);
      expect(service.autoplayEnabled, isFalse);

      expect(service.reduceMotionEnabled, isFalse);
      await service.saveReduceMotionEnabled(true);
      expect(service.reduceMotionEnabled, isTrue);
    });

    test('پیشرفت تماشا خارج از بازهٔ ۰ تا ۱ کلمپ می‌شود', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferences(prefs);

      await service.saveWatchProgress({
        'e1': 1.4,
        'e2': -0.2,
        'e3': 0.5,
      });
      final restored = service.watchProgress;
      expect(restored['e1'], 1.0);
      expect(restored['e2'], 0.0);
      expect(restored['e3'], 0.5);
    });

    test('JSON خراب پیشرفت و پروفایل کودک باعث خطا نمی‌شود', () async {
      SharedPreferences.setMockInitialValues({
        'watch_progress': '{این JSON نیست',
        'child_profile': '???',
      });
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferences(prefs);

      expect(service.watchProgress, isEmpty);
      expect(service.childProfileName, isNull);
      expect(service.childAvatarIndex, 0);
    });

    test('پروفایل کودک فقط نام نمایشی و ایندکس آواتار را نگه می‌دارد',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferences(prefs);

      await service.saveChildProfile(name: '  آرش  ', avatarIndex: 4);
      expect(service.childProfileName, 'آرش');
      expect(service.childAvatarIndex, 4);

      final raw = prefs.getString('child_profile');
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded.keys, unorderedEquals(['name', 'avatar']));
    });

    test('نام خالی والد به پیش‌فرض مهربان برمی‌گردد', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = AppPreferences(prefs);

      await service.saveParentName('   ');
      expect(service.parentName, 'والد مهربان');
    });
  });
}
