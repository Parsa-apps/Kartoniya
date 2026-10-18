import 'package:flutter/material.dart';

/// پالت رسمی برند «کارتونیا».
///
/// هویت بصری روی آبی آسمانی، فیروزه‌ای، بنفش ملایم، مرجانی و زرد طلایی
/// ساخته شده است. رنگ‌های خنثی و سطح‌ها از [ThemeData] خوانده می‌شوند تا
/// حالت روشن و تاریک در تمام صفحه‌ها یکپارچه بماند. هیچ صفحه‌ای نباید
/// رنگ خام خارج از این فایل استفاده کند؛ استایل‌های پراکنده عمدتاً از
/// توکن‌های [AppTheme] می‌آیند.
abstract final class AppColors {
  // ——— رنگ اصلی: آبی آسمانی ———
  static const sky = Color(0xFF2E9BEB);
  static const skyLight = Color(0xFF7BC4FF);
  static const skyDeep = Color(0xFF0A5FA7);
  static const skySoft = Color(0xFFE7F4FF);

  // ——— فیروزه‌ای ———
  static const teal = Color(0xFF17BFA8);
  static const tealLight = Color(0xFF7BE0D0);
  static const tealDeep = Color(0xFF087365);
  static const tealSoft = Color(0xFFE4FAF6);

  // ——— بنفش ملایم ———
  static const violet = Color(0xFF8F7AED);
  static const violetLight = Color(0xFFC5B9FA);
  static const violetDeep = Color(0xFF5F47C4);
  static const violetSoft = Color(0xFFF1EDFF);

  // ——— مرجانی ———
  static const coral = Color(0xFFFF7A59);
  static const coralLight = Color(0xFFFFB19A);
  static const coralDeep = Color(0xFFB64226);
  static const coralSoft = Color(0xFFFFEFEA);

  // ——— زرد طلایی ———
  static const gold = Color(0xFFFFC53D);
  static const goldLight = Color(0xFFFFE08A);
  static const goldDark = Color(0xFF805400);
  static const goldSoft = Color(0xFFFFF6DF);

  // ——— رنگ‌های کمکی ———
  static const pink = Color(0xFFFF6BA8);
  static const pinkDeep = Color(0xFFB22A63);
  static const green = Color(0xFF3DC47E);
  static const greenDeep = Color(0xFF187747);
  static const red = Color(0xFFFF5D6C);
  static const redDeep = Color(0xFFB92E3E);

  static const success = greenDeep;
  static const warning = Color(0xFFA86700);
  static const error = redDeep;

  // ——— نام‌های سازگار با نسخه‌های قبل (مرجع اصلی خود پالت است) ———
  static const primary = skyDeep;
  static const primaryLight = skyLight;
  static const primaryDark = skyDeep;
  static const primarySoft = skySoft;
  static const secondary = tealDeep;
  static const secondaryLight = tealLight;
  static const secondaryDark = tealDeep;
  static const secondarySoft = tealSoft;
  static const purple = violet;

  // ——— سطوح ———
  static const lightBackground = Color(0xFFF1F7FE);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFF7FBFF);
  static const darkBackground = Color(0xFF0E1526);
  static const darkSurface = Color(0xFF1A2338);
  static const darkSurfaceAlt = Color(0xFF222D47);
  static const lightInk = Color(0xFF1B2436);
  static const darkInk = Color(0xFFEFF4FE);

  // ——— گرادیان‌های امضای کارتونیا ———
  static const skyGradient = LinearGradient(
    colors: [skyLight, sky, skyDeep],
    stops: [.0, .55, 1],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  /// سازگار با نام قدیمی؛ دو توقف آن برای نشان سفید کنتراست کافی دارند.
  static const primaryGradient = LinearGradient(
    colors: [skyDeep, Color(0xFF084A80)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const sunsetGradient = LinearGradient(
    colors: [goldDark, coralDeep],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const coolGradient = LinearGradient(
    colors: [skyDeep, violetDeep],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const warmGradient = LinearGradient(
    colors: [pinkDeep, coralDeep],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const tealGradient = LinearGradient(
    colors: [tealLight, teal, tealDeep],
    stops: [.0, .55, 1],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const violetGradient = LinearGradient(
    colors: [violetLight, violet, violetDeep],
    stops: [.0, .55, 1],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const coralGradient = LinearGradient(
    colors: [coralLight, coral, coralDeep],
    stops: [.0, .55, 1],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const goldGradient = LinearGradient(
    colors: [goldLight, gold, goldDark],
    stops: [.0, .6, 1],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const nightGradient = LinearGradient(
    colors: [Color(0xFF35426B), Color(0xFF141B33)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static Color categoryColor(String category) {
    switch (category) {
      case 'ماجراجویی':
        return coral;
      case 'آموزشی':
        return sky;
      case 'سرگرمی':
        return pink;
      case 'هنری':
        return violet;
      case 'علمی':
        return teal;
      case 'موسیقی':
        return gold;
      default:
        return sky;
    }
  }

  /// رنگ نوشته/آیکن دسته را با سطح روشن یا تاریک هماهنگ می‌کند.
  static Color categoryForeground(
    String category, {
    required Brightness brightness,
  }) {
    if (brightness == Brightness.dark) {
      switch (category) {
        case 'ماجراجویی':
          return coralLight;
        case 'آموزشی':
          return skyLight;
        case 'سرگرمی':
          return pink;
        case 'هنری':
          return violetLight;
        case 'علمی':
          return tealLight;
        case 'موسیقی':
          return goldLight;
        default:
          return skyLight;
      }
    }

    switch (category) {
      case 'ماجراجویی':
        return coralDeep;
      case 'آموزشی':
        return skyDeep;
      case 'سرگرمی':
        return pinkDeep;
      case 'هنری':
        return violetDeep;
      case 'علمی':
        return tealDeep;
      case 'موسیقی':
        return goldDark;
      default:
        return skyDeep;
    }
  }

  /// تیره‌سازی حداقلی برای رنگ نوشته یا آیکن روی سطح روشن.
  static Color readableOnLightSurface(Color color) =>
      _darkenToContrast(color, Colors.white, 5.0);

  /// پس‌زمینهٔ دکمهٔ رنگی با حداقل کنتراست 4.8:1 برای محتوای سفید.
  static Color actionColor(Color color) =>
      _darkenToContrast(color, Colors.white, 4.8);

  static LinearGradient actionGradient(Color color) {
    final accessible = actionColor(color);
    final lighter = Color.lerp(accessible, Colors.white, .08)!;
    return LinearGradient(
      colors: [
        _contrastRatio(lighter, Colors.white) >= 4.8 ? lighter : accessible,
        Color.lerp(accessible, Colors.black, .10)!,
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
  }

  /// گرادیان دسته‌ها برای کاشی‌های منتخب با نوشتهٔ سفید.
  static LinearGradient categoryGradient(String category) =>
      actionGradient(categoryColor(category));

  static Color _darkenToContrast(
    Color color,
    Color background,
    double minimumContrast,
  ) {
    var candidate = color.withAlpha(255);
    for (var attempt = 0;
        attempt < 24 && _contrastRatio(candidate, background) < minimumContrast;
        attempt++) {
      candidate = Color.lerp(candidate, Colors.black, .08)!;
    }
    return candidate;
  }

  static double _contrastRatio(Color first, Color second) {
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
}
