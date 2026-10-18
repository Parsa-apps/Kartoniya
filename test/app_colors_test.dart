import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/theme/app_colors.dart';
import 'package:kartoniya/core/theme/app_theme.dart';

void main() {
  const categories = [
    'ماجراجویی',
    'آموزشی',
    'سرگرمی',
    'هنری',
    'علمی',
    'موسیقی',
  ];

  test('category foregrounds meet text contrast in both themes', () {
    for (final category in categories) {
      final lightForeground = AppColors.categoryForeground(
        category,
        brightness: Brightness.light,
      );
      final darkForeground = AppColors.categoryForeground(
        category,
        brightness: Brightness.dark,
      );

      expect(
        _contrastRatio(lightForeground, AppColors.lightBackground),
        greaterThanOrEqualTo(4.5),
        reason: 'light theme: $category',
      );
      expect(
        _contrastRatio(darkForeground, AppColors.darkSurfaceAlt),
        greaterThanOrEqualTo(4.5),
        reason: 'dark theme: $category',
      );
    }
  });

  test('theme primary, secondary, tertiary, and error pairs are readable', () {
    for (final scheme in [
      AppTheme.lightTheme.colorScheme,
      AppTheme.darkTheme.colorScheme,
    ]) {
      expect(
        _contrastRatio(scheme.primary, scheme.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(scheme.secondary, scheme.onSecondary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(scheme.tertiary, scheme.onTertiary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(scheme.error, scheme.onError),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  test('action colors and gradients keep white foreground contrast', () {
    const accents = [
      AppColors.sky,
      AppColors.teal,
      AppColors.violet,
      AppColors.coral,
      AppColors.gold,
      AppColors.pink,
      AppColors.green,
      AppColors.red,
    ];

    for (final accent in accents) {
      expect(
        _contrastRatio(AppColors.actionColor(accent), Colors.white),
        greaterThanOrEqualTo(4.8),
      );
      for (final stop in AppColors.actionGradient(accent).colors) {
        expect(
          _contrastRatio(stop, Colors.white),
          greaterThanOrEqualTo(4.8),
        );
      }
    }
  });

  test('brand gradients keep white foreground contrast at every stop', () {
    const gradients = [
      AppColors.primaryGradient,
      AppColors.sunsetGradient,
      AppColors.coolGradient,
      AppColors.warmGradient,
    ];

    for (final gradient in gradients) {
      for (final stop in gradient.colors) {
        expect(
          _contrastRatio(stop, Colors.white),
          greaterThanOrEqualTo(4.5),
        );
      }
    }
  });

  test('bright accents get readable ink on light artwork surfaces', () {
    const accents = [
      AppColors.sky,
      AppColors.teal,
      AppColors.violet,
      AppColors.coral,
      AppColors.gold,
      AppColors.pink,
    ];

    for (final accent in accents) {
      expect(
        _contrastRatio(
          AppColors.readableOnLightSurface(accent),
          AppColors.lightBackground,
        ),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + .05) / (darker + .05);
}
