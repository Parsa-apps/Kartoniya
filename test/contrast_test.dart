import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/theme/app_colors.dart';

void main() {
  group('کنتراست خوانایی متن', () {
    test('رنگ‌های برند با متن سفید به ۴٫۵:۱ می‌رسند', () {
      const brandColors = [
        AppColors.sky,
        AppColors.teal,
        AppColors.coral,
        AppColors.pink,
        AppColors.gold,
        AppColors.violet,
        AppColors.green,
      ];
      for (final color in brandColors) {
        final readable = AppColors.readableWithWhiteText(color);
        expect(
          AppColors.contrastWithWhite(readable),
          greaterThanOrEqualTo(4.5),
          reason: 'رنگ $color با متن سفید خوانا نیست',
        );
      }
    });

    test('fillAndText هیچ دکمه‌ای زیر ۴٫۵:۱ رها نمی‌کند', () {
      const brandColors = [
        AppColors.sky,
        AppColors.teal,
        AppColors.coral,
        AppColors.pink,
        AppColors.gold,
        AppColors.violet,
      ];
      for (final color in brandColors) {
        final resolved = AppColors.fillAndText(color);
        expect(
          AppColors.contrast(resolved.fill, resolved.foreground),
          greaterThanOrEqualTo(4.5),
          reason: 'دکمهٔ $color خوانا نیست',
        );
      }
      // رنگ‌های روشن باید شاد و دست‌نخورده بمانند، نه تیره و گل‌آلود.
      expect(AppColors.fillAndText(AppColors.gold).fill, AppColors.gold);
      expect(AppColors.fillAndText(AppColors.gold).foreground,
          AppColors.deepInk);
    });

    test('گرادیان کاشی دسته با متن سفید خوانا است', () {
      const categoryColors = [
        AppColors.coral,
        AppColors.sky,
        AppColors.pink,
        AppColors.violet,
        AppColors.teal,
        AppColors.gold,
      ];
      for (final color in categoryColors) {
        final gradient = AppColors.accessibleGradient(color);
        for (final stop in gradient.colors) {
          expect(
            AppColors.contrastWithWhite(stop),
            greaterThanOrEqualTo(4.5),
            reason: 'یکی از توقف‌های گرادیان کاشی $color خوانا نیست',
          );
        }
      }
    });

    test('سطح روشن و تیره هر دو رنگ خوانا می‌گیرند', () {
      const surfaces = [Color(0xFFF7FAFF), Color(0xFF141C2E)];
      for (final surface in surfaces) {
        for (final color in [
          AppColors.gold,
          AppColors.teal,
          AppColors.sky,
          AppColors.coral,
        ]) {
          expect(
            AppColors.contrast(surface, AppColors.readableOn(surface, color)),
            greaterThanOrEqualTo(4.5),
            reason: 'متن $color روی $surface خوانا نیست',
          );
        }
      }
    });

    test('برچسب دستهٔ کارت روی کارت روشن خوانا است', () {
      final label = AppColors.readableOn(
        AppColors.lightSurface,
        AppColors.categoryColor('موسیقی'),
      );
      expect(
        AppColors.contrast(AppColors.lightSurface, label),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('گرادیان دکمه‌ها با متن انتخاب‌شده خوانا است', () {
      for (final gradient in [
        AppColors.primaryGradient,
        const LinearGradient(colors: [AppColors.gold, AppColors.coral]),
        const LinearGradient(colors: [AppColors.sky, AppColors.violet]),
      ]) {
        final resolved = AppColors.gradientAndText(gradient);
        for (final stop in resolved.gradient.colors) {
          expect(
            AppColors.contrast(stop, resolved.foreground),
            greaterThanOrEqualTo(4.5),
          );
        }
      }
    });
  });
}
