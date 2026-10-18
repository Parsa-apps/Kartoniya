import 'dart:math' as math;

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
  static const skyDeep = Color(0xFF1071C4);
  static const skySoft = Color(0xFFE7F4FF);

  // ——— فیروزه‌ای ———
  static const teal = Color(0xFF17BFA8);
  static const tealLight = Color(0xFF7BE0D0);
  static const tealDeep = Color(0xFF0A8F7C);
  static const tealSoft = Color(0xFFE4FAF6);

  // ——— بنفش ملایم ———
  static const violet = Color(0xFF8F7AED);
  static const violetLight = Color(0xFFC5B9FA);
  static const violetDeep = Color(0xFF5F47C4);
  static const violetSoft = Color(0xFFF1EDFF);

  // ——— مرجانی ———
  static const coral = Color(0xFFFF7A59);
  static const coralLight = Color(0xFFFFB19A);
  static const coralDeep = Color(0xFFD95433);
  static const coralSoft = Color(0xFFFFEFEA);

  // ——— زرد طلایی ———
  static const gold = Color(0xFFFFC53D);
  static const goldLight = Color(0xFFFFE08A);
  static const goldDark = Color(0xFFC68A1B);
  static const goldSoft = Color(0xFFFFF6DF);

  // ——— رنگ‌های کمکی ———
  static const pink = Color(0xFFFF6BA8);
  static const pinkDeep = Color(0xFFD63E7C);
  static const green = Color(0xFF3DC47E);
  static const greenDeep = Color(0xFF1F9558);
  static const red = Color(0xFFFF5D6C);
  static const redDeep = Color(0xFFD63A4A);

  static const success = greenDeep;
  static const warning = Color(0xFFE9980C);
  static const error = redDeep;

  // ——— نام‌های سازگار با نسخه‌های قبل (مرجع اصلی خود پالت است) ———
  static const primary = sky;
  static const primaryLight = skyLight;
  static const primaryDark = skyDeep;
  static const primarySoft = skySoft;
  static const secondary = teal;
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

  /// سازگار با نام قدیمی؛ اکنون گرادیان آسمانی برند است.
  static const primaryGradient = LinearGradient(
    colors: [sky, skyDeep],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const sunsetGradient = LinearGradient(
    colors: [gold, coral],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const coolGradient = LinearGradient(
    colors: [sky, violet],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const warmGradient = LinearGradient(
    colors: [pink, coral],
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

  /// کنتراست نسبی رنگ با سفید (WCAG 2.1).
  static double contrastWithWhite(Color color) => contrast(color, Colors.white);

  /// کنتراست WCAG بین دو رنگ (۱ تا ۲۱).
  static double contrast(Color a, Color b) {
    double channel(double value) => value <= .03928
        ? value / 12.92
        : math.pow((value + .055) / 1.055, 2.4).toDouble();
    double relative(Color c) =>
        .2126 * channel(c.red / 255) +
        .7152 * channel(c.green / 255) +
        .0722 * channel(c.blue / 255);
    final la = relative(a);
    final lb = relative(b);
    return (math.max(la, lb) + .05) / (math.min(la, lb) + .05);
  }

  /// متن تیرهٔ برند برای سطوح روشن (کنتراست با همهٔ رنگ‌های برند ≥۴٫۷).
  static const deepInk = Color(0xFF14203A);

  /// انتخاب پرکننده/متن یک دکمهٔ رنگی.
  ///
  /// روی رنگ‌های شاد برند (طلایی، مرجانی، فیروزه‌ای، آبی) متن سرمه‌ای
  /// می‌نشیند و خود رنگ دست‌نخورده و زنده می‌ماند (کودکان رنگ تیره روی
  /// سطوح روشن بهتر می‌خوانند)؛ فقط روی رنگ‌های بسیار تیره رنگ کمی
  /// روشن/تیره می‌شود و متن سفید می‌ماند. هیچ دکمه‌ای زیر ۴٫۵:۱ نمی‌ماند.
  static ({Color fill, Color foreground}) fillAndText(Color base) {
    if (contrast(base, deepInk) >= 4.5) {
      return (fill: base, foreground: deepInk);
    }
    return (fill: readableWithWhiteText(base), foreground: Colors.white);
  }

  /// همین انتخاب برای گرادیان؛ اگر هر دو سر طیف با متن تیره خوانا باشند
  /// گرادیان دست‌نخورده می‌ماند، وگرنه یکدست تیره می‌شود.
  static ({LinearGradient gradient, Color foreground}) gradientAndText(
    LinearGradient gradient,
  ) {
    final inkSafe = gradient.colors
        .every((color) => contrast(color, deepInk) >= 4.5);
    if (inkSafe) return (gradient: gradient, foreground: deepInk);
    return (gradient: readableGradient(gradient), foreground: Colors.white);
  }

  /// نسخهٔ خوانا از یک رنگ برند روی پس‌زمینهٔ مشخص.
  ///
  /// رنگ دسته‌ها (مثلاً طلایی) روی کارت روشن کنتراست ۱٫۶:۱ داشت و متن
  /// برچسب عملاً محو می‌شد. این تابع فقط تا رسیدن به [minContrast] رنگ را
  /// در جهت درست (تیره روی سطح روشن، روشن روی سطح تیره) حرکت می‌دهد.
  static Color readableOn(
    Color background,
    Color base, {
    double minContrast = 4.5,
  }) {
    if (contrast(background, base) >= minContrast) return base;
    final towardLight = contrast(background, Colors.white) >
        contrast(background, deepInk);
    final target = towardLight ? Colors.white : deepInk;
    for (var step = 1; step <= 40; step++) {
      final candidate = Color.lerp(base, target, step / 40)!;
      if (contrast(background, candidate) >= minContrast) return candidate;
    }
    return target;
  }

  /// نسخهٔ تیره‌شدهٔ یک رنگ برند که متن سفید روی آن حداقل [minContrast]
  /// (به‌صورت پیش‌فرض ۵:۱، با حاشیهٔ اطمینان بالای حد ۴٫۵:۱) کنتراست دارد.
  ///
  /// رنگ برند شاد می‌ماند، اما دکمه‌ها و نشان‌های دارای متن سفید دیگر
  /// ناخوانا نمی‌شوند (زرد طلایی به‌تنهایی فقط ۱٫۶:۱ است).
  static Color readableWithWhiteText(Color base, {double minContrast = 5.0}) {
    if (contrastWithWhite(base) >= minContrast) return base;
    for (var step = 1; step <= 25; step++) {
      final candidate =
          Color.lerp(base, const Color(0xFF101B33), step / 25)!;
      if (contrastWithWhite(candidate) >= minContrast) return candidate;
    }
    return const Color(0xFF101B33);
  }

  /// گرادیان امن برای دکمه‌های دارای متن سفید.
  static LinearGradient readableGradient(LinearGradient gradient) {
    return LinearGradient(
      begin: gradient.begin,
      end: gradient.end,
      stops: gradient.stops,
      colors: [
        for (final color in gradient.colors)
          readableWithWhiteText(color),
      ],
    );
  }

  /// رنگ «متن‌پس‌زمینهٔ ایمن» برای سطوح رنگی دسته.
  ///
  /// رنگ‌های برند شاد و روشن‌اند و متن سفید روی آن‌ها کنتراست کافی ندارد
  /// (۱٫۴ تا ۳٫۲ : ۱). این نسخه با ترکیب ۵۵٪ رنگ با سرمه‌ای تیره می‌سازد تا
  /// کنتراست متن سفید به بالای ۴٫۵ : ۱ برسد، در حالی که هویت رنگی دسته
  /// حفظ می‌شود. از این رنگ برای پس‌زمینهٔ متن، نه برای آیکون تزئینی،
  /// استفاده کنید.
  static Color textSafeColor(Color base) =>
      Color.lerp(base, const Color(0xFF101B33), .55)!;

  /// گرادیان متن‌پس‌زمینهٔ امن برای کاشی/قرص دسته‌ای که روی آن متن سفید
  /// نوشته می‌شود. هر سه توقف تیره‌اند تا در همهٔ نقاط کاشی کنتراست حفظ شود.
  static LinearGradient accessibleGradient(Color color) {
    final deep = textSafeColor(color);
    return LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color.lerp(deep, const Color(0xFF101B33), -.10)!,
        deep,
        Color.lerp(deep, const Color(0xFF0A1224), .22)!,
      ],
      stops: const [0, .55, 1],
    );
  }

  static LinearGradient categoryGradient(String category) {
    final color = categoryColor(category);
    return LinearGradient(
      colors: [
        Color.lerp(color, Colors.white, .25)!,
        color,
        Color.lerp(color, const Color(0xFF101627), .22)!,
      ],
      stops: const [0, .62, 1],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    );
  }
}
