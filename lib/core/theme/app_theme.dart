import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// توکن‌های طراحی کارتونیا: رنگ، فاصله، شعاع، سایه و تایپوگرافی.
///
/// تمام صفحه‌ها باید از همین توکن‌ها استفاده کنند؛ تعریف مستقیم عدد و رنگ
/// در ویجت‌ها فقط برای جزئیات دقیق (مثلاً اندازهٔ آیکون) مجاز است.
abstract final class AppTheme {
  static const fontFamily = 'Vazirmatn';

  // ——— شعاع‌ها ———
  static const radiusSmall = 12.0;
  static const radiusMedium = 18.0;
  static const radiusLarge = 24.0;
  static const radiusXLarge = 32.0;
  static const radiusXXLarge = 42.0;
  static const radiusCircular = 100.0;

  // ——— فاصله‌ها ———
  static const spacingXs = 4.0;
  static const spacingSm = 8.0;
  static const spacingMd = 16.0;
  static const spacingLg = 24.0;
  static const spacingXl = 32.0;

  /// حاشیهٔ پیش‌فرض افقی صفحات.
  static const pageMargin = 20.0;

  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.sky,
      brightness: brightness,
    );
    final scheme = baseScheme.copyWith(
      primary: AppColors.sky,
      onPrimary: Colors.white,
      primaryContainer: isDark ? const Color(0xFF0E3A5E) : AppColors.skySoft,
      onPrimaryContainer: isDark ? const Color(0xFFCDE8FF) : AppColors.skyDeep,
      secondary: AppColors.teal,
      onSecondary: Colors.white,
      secondaryContainer: isDark ? const Color(0xFF0C3F39) : AppColors.tealSoft,
      onSecondaryContainer:
          isDark ? const Color(0xFFB5F2E6) : AppColors.tealDeep,
      tertiary: AppColors.violet,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: isDark ? AppColors.darkInk : AppColors.lightInk,
      surfaceVariant:
          isDark ? AppColors.darkSurfaceAlt : const Color(0xFFEAF1FB),
      onSurfaceVariant:
          isDark ? const Color(0xFFB9C4DC) : const Color(0xFF55637C),
      outline: isDark ? const Color(0xFF8794B1) : const Color(0xFF5E6B84),
      error: AppColors.error,
      onError: Colors.white,
    );

    final rawTextTheme =
        ThemeData(brightness: brightness, useMaterial3: true).textTheme;
    // family/رنگ اول اعمال می‌شود تا copyWithهای زیر آن را از دست ندهند؛
    // در غیر این صورت عنوان‌ها با fontFamily خالی (Roboto/فال‌بک سیستم)
    // رندر می‌شدند و Vazirmatn فقط روی بدنه می‌ماند.
    final baseTextTheme = rawTextTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
      fontFamily: fontFamily,
    );
    final textTheme = baseTextTheme.copyWith(
          displayLarge: baseTextTheme.displayLarge?.copyWith(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            height: 1.25,
          ),
          displayMedium: baseTextTheme.displayMedium?.copyWith(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.3,
          ),
          displaySmall: baseTextTheme.displaySmall?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.3,
          ),
          headlineMedium: baseTextTheme.headlineMedium?.copyWith(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            height: 1.4,
          ),
          headlineSmall: baseTextTheme.headlineSmall?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.42,
          ),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
            fontSize: 17.5,
            fontWeight: FontWeight.w800,
            height: 1.5,
          ),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
          titleSmall: baseTextTheme.titleSmall?.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
          bodyLarge: baseTextTheme.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.75,
          ),
          bodyMedium: baseTextTheme.bodyMedium?.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            height: 1.7,
          ),
          bodySmall: baseTextTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            height: 1.55,
          ),
          labelLarge: baseTextTheme.labelLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
          labelMedium: baseTextTheme.labelMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          labelSmall: baseTextTheme.labelSmall?.copyWith(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        );

    final cardBorder = BorderSide(
      color: isDark
          ? Colors.white.withOpacity(.07)
          : AppColors.skyDeep.withOpacity(.10),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardTheme(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: cardBorder,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // همان قاعدهٔ دکمه‌های گرادیانی: پرکننده و متن با هم انتخاب
          // می‌شوند تا کنتراست همیشه ≥۴٫۵:۱ باشد و رنگ برند شاد بماند.
          backgroundColor: AppColors.fillAndText(scheme.primary).fill,
          foregroundColor: AppColors.fillAndText(scheme.primary).foreground,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: scheme.outline.withOpacity(.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: textTheme.labelLarge,
          foregroundColor: AppColors.skyDeep,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.lightSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: cardBorder,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: cardBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.sky, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 1.6),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.coral,
        inactiveTrackColor: Colors.white38,
        thumbColor: Colors.white,
        overlayColor: AppColors.coral.withOpacity(.18),
        trackHeight: 4,
        valueIndicatorTextStyle: textTheme.labelSmall?.copyWith(
          color: Colors.black87,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: AppColors.sky,
        secondarySelectedColor: AppColors.sky,
        labelStyle: textTheme.labelLarge?.copyWith(fontSize: 13),
        side: cardBorder,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCircular),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
          side: cardBorder,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkInk : AppColors.lightInk,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.lightInk : Colors.white,
        ),
        actionTextColor: AppColors.goldLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withOpacity(.14),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightInk,
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: isDark ? AppColors.darkInk : Colors.white,
        ),
      ),
    );
  }

  // ——— سایه‌ها ———

  static List<BoxShadow> softShadow(BuildContext context) => [
        BoxShadow(
          color: Colors.black.withOpacity(
            Theme.of(context).brightness == Brightness.dark ? .22 : .06,
          ),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> mediumShadow(BuildContext context) => [
        BoxShadow(
          color: Colors.black.withOpacity(
            Theme.of(context).brightness == Brightness.dark ? .32 : .12,
          ),
          blurRadius: 30,
          spreadRadius: -4,
          offset: const Offset(0, 14),
        ),
      ];

  /// هالهٔ رنگی نرم برای دکمه‌ها و کارت‌های شاخص.
  static List<BoxShadow> glow(Color color,
          {double opacity = .32, double lift = 10}) =>
      [
        BoxShadow(
          color: color.withOpacity(opacity),
          blurRadius: 26,
          spreadRadius: -4,
          offset: Offset(0, lift),
        ),
      ];
}

extension KartoniyaThemeContext on BuildContext {
  Color get pageBackground => Theme.of(this).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get surfaceAltColor => Theme.of(this).colorScheme.surfaceVariant;
  Color get primaryTextColor => Theme.of(this).colorScheme.onSurface;
  Color get secondaryTextColor => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get softBorderColor => isDarkMode
      ? Colors.white.withOpacity(.07)
      : AppColors.skyDeep.withOpacity(.10);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get appText => Theme.of(this).textTheme;
}
