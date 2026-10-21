import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/theme/app_theme.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/main.dart';
import 'package:kartoniya/presentation/pages/about_us_page.dart';
import 'package:kartoniya/presentation/pages/home_page.dart';
import 'package:kartoniya/presentation/pages/splash_page.dart';
import 'package:kartoniya/presentation/widgets/parsa_brand.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// پوشش رگرسیون برای هویت استودیوی Parsa Apps: پردهٔ آغازین اسپلش،
/// ورود یک‌باره به خانه، تنظیم قدیمی کاهش‌حرکت، خطای آماده‌سازی و صفحهٔ دربارهٔ ما.
void main() {
  Future<SharedPreferences> initPrefs({
    bool onboarding = true,
    bool legacyReduceMotion = false,
  }) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_completed': onboarding,
      'reduce_motion_enabled': legacyReduceMotion,
    });
    return SharedPreferences.getInstance();
  }

  Widget app(
    SharedPreferences prefs, {
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ...overrides,
      ],
      child: const KartoniyaApp(),
    );
  }

  void usePhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
  }

  testWidgets('هویت استودیو پیش از صحنهٔ کارتونیا می‌آید و ورود یک‌بار است',
      (tester) async {
    usePhone(tester);
    final prefs = await initPrefs();

    await tester.pumpWidget(app(prefs));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // پردهٔ استودیو: لوگوی اصلی، نوار طلایی و متن آماده‌سازی.
    expect(find.byType(ParsaBrandMark), findsOneWidget);
    expect(find.text('در حال آماده‌سازی...'), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);

    // کراس‌فید به صحنهٔ کارتونیا و سپس ورود به خانه.
    for (var i = 0; i < 24 && find.byType(HomePage).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byType(HomePage), findsOneWidget);

    // خروج اسپلش یک ترنزیشن محو است؛ تا پایان آن صبر می‌کنیم تا صفحه و
    // نشان استودیو کاملاً از درخت حذف شوند.
    bool splashGone() => find.byType(SplashPage).evaluate().isEmpty;
    for (var i = 0; i < 8 && !splashGone(); i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(ParsaBrandMark), findsNothing);

    // بدون نمایش دوبارهٔ اسپلش و بدون ناوبری تکراری.
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SplashPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('تنظیم قدیمی کاهش حرکت، انیمیشن اسپلش را غیرفعال نمی‌کند',
      (tester) async {
    usePhone(tester);
    final prefs = await initPrefs(legacyReduceMotion: true);

    await tester.pumpWidget(app(prefs));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));
    expect(find.byType(SplashPage), findsOneWidget);
    expect(find.byType(HomePage), findsNothing);

    for (var i = 0; i < 24 && find.byType(HomePage).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('خطای آماده‌سازی کاتالوگ اسپلش را قفل نمی‌کند', (tester) async {
    usePhone(tester);
    final prefs = await initPrefs();

    await tester.pumpWidget(
      app(
        prefs,
        overrides: [
          cartoonsProvider.overrideWith((ref) async {
            throw StateError('catalog unavailable');
          }),
        ],
      ),
    );
    await tester.pump();

    for (var i = 0; i < 24 && find.byType(HomePage).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    // خانه با نمای خطا و «تلاش دوباره» باز می‌شود؛ اسپلش گیر نمی‌کند.
    expect(find.byType(HomePage), findsOneWidget);
    bool splashGone() => find.byType(SplashPage).evaluate().isEmpty;
    for (var i = 0; i < 8 && !splashGone(); i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byType(SplashPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('نشان استودیو شفاف، در بودجهٔ حافظه و با تناسپ اصلی است', () async {
    final data = await rootBundle.load(ParsaBrandMark.assetPath);
    // بودجهٔ فاز J: کیفیت ۹۰ با alpha بدون تغییر، ۲۳۱ KiB.
    expect(data.lengthInBytes, lessThan(300 * 1024));

    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    expect(image.width, 810);
    expect(image.height, 1024);

    final rgba = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    // گوشهٔ بالا-چپ کاملاً شفاف است (پس‌زمینهٔ ساخته‌شده نداریم).
    expect(rgba.getUint8(3), 0);
    // مرکز نشان (بدنهٔ حرف P) کاملاً مات است.
    const center = (512 * 810 + 405) * 4;
    expect(rgba.getUint8(center + 3), greaterThan(200));

    image.dispose();
    codec.dispose();
  });

  testWidgets('دربارهٔ ما نشان استودیو را یک‌بار و با تناسپ صحیح نشان می‌دهد',
      (tester) async {
    usePhone(tester);
    final prefs = await initPrefs();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const AboutUsPage(),
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(ParsaBrandMark), findsOneWidget);
    expect(find.text('استودیوی Parsa Apps'), findsOneWidget);
    final size = tester.getSize(find.byType(ParsaBrandMark));
    expect(
      size.width / size.height,
      closeTo(ParsaBrandMark.aspectRatio, .02),
    );
    expect(tester.takeException(), isNull);
  });
}
