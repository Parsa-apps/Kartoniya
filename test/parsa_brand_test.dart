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
/// ورود یک‌باره به خانه، رفتار کاهش‌حرکت، خطای آماده‌سازی و صفحهٔ دربارهٔ ما.
void main() {
  Future<SharedPreferences> initPrefs({
    bool onboarding = true,
    bool reduceMotion = false,
  }) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_completed': onboarding,
      'reduce_motion_enabled': reduceMotion,
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
    expect(find.byType(SplashPage), findsNothing);
    expect(find.byType(ParsaBrandMark), findsNothing);

    // بدون نمایش دوبارهٔ اسپلش و بدون ناوبری تکراری.
    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(SplashPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('با کاهش حرکت، اسپلش ثابت می‌ماند و سریع وارد می‌شود',
      (tester) async {
    usePhone(tester);
    final prefs = await initPrefs(reduceMotion: true);

    await tester.pumpWidget(app(prefs));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(ParsaBrandMark), findsOneWidget);

    for (var i = 0; i < 14 && find.byType(HomePage).evaluate().isEmpty; i++) {
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
    expect(find.byType(SplashPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('نشان استودیو شفاف، در بودجهٔ حافظه و با تناسپ اصلی است', () async {
    final data = await rootBundle.load(ParsaBrandMark.assetPath);
    expect(data.lengthInBytes, lessThan(950 * 1024));

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
