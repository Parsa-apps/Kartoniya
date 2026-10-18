import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/main.dart';
import 'package:kartoniya/presentation/pages/search_page.dart';
import 'package:kartoniya/presentation/widgets/cartoon_card.dart';
import 'package:kartoniya/presentation/widgets/category_tile.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// عکس‌های واقعی رندر ویجت‌ها (بدون دستگاه).
///
/// این تست فقط وقتی اجرا می‌شود که `KARTONIYA_SCREENSHOTS=1` تنظیم شده باشد؛
/// CI آن را با فونت Vazirmatn و تصاویر واقعی asset اجرا می‌کند و خروجی PNG
/// را به‌عنوان artifact نگه می‌دارد. این عکس‌ها برای بازبینی طراحی‌اند و
/// جای آزمون روی گوشی را نمی‌گیرند.
final _enabled = Platform.environment['KARTONIYA_SCREENSHOTS'] == '1';

void main() {
  testWidgets(
    'render UI screenshots with bundled font and assets',
    (tester) async {
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = true);

      final output = Directory('build/screenshots')
        ..createSync(recursive: true);

      tester.view.physicalSize = const Size(1170, 2532); // iPhone 13-ish @3x
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.runAsync(() async {
        final loader = FontLoader('Vazirmatn');
        for (final asset in const [
          'asset/fonts/Vazirmatn-Regular.ttf',
          'asset/fonts/Vazirmatn-Medium.ttf',
          'asset/fonts/Vazirmatn-Bold.ttf',
          'asset/fonts/Vazirmatn-Black.ttf',
        ]) {
          loader.addFont(rootBundle.load(asset));
        }
        await loader.load();
      });

      SharedPreferences.setMockInitialValues(const {});
      final prefs = await SharedPreferences.getInstance();
      final rootKey = GlobalKey();

      await tester.pumpWidget(
        RepaintBoundary(
          key: rootKey,
          child: ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: const KartoniyaApp(),
          ),
        ),
      );

      Future<void> wait(int milliseconds, {int step = 100}) async {
        var elapsed = 0;
        while (elapsed < milliseconds) {
          await tester.pump(Duration(milliseconds: step));
          elapsed += step;
        }
      }

      Future<void> allowImages() async {
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 450));
        });
        await tester.pump();
      }

      Future<void> capture(String name) async {
        await tester.pump();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(rootKey),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          image.dispose();
          File('${output.path}/$name.png')
              .writeAsBytesSync(bytes!.buffer.asUint8List());
        });
      }

      // ——— Splash ———
      await wait(1150);
      await allowImages();
      await capture('01_splash');

      // ——— Onboarding ———
      await wait(1000);
      await wait(300);
      await allowImages();
      await capture('02_onboarding');

      // ——— Home (first run completed) ———
      await tester.tap(find.text('رد کردن'));
      await wait(900);
      await allowImages();
      await capture('03_home_top');

      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -760),
      );
      await wait(500);
      await allowImages();
      await capture('04_home_sections');

      // ——— Categories ———
      await tester.tap(
        find.descendant(
          of: find.byType(KartoniyaNavBar),
          matching: find.text('دسته‌ها'),
        ),
      );
      await wait(500);
      await allowImages();
      await capture('05_categories');

      await tester.tap(
        find.descendant(
          of: find.byType(CategoryTile),
          matching: find.text('ماجراجویی'),
        ),
      );
      await wait(500);
      await allowImages();
      await capture('06_categories_filtered');

      // ——— Search ———
      await tester.tap(
        find.descendant(
          of: find.byType(KartoniyaNavBar),
          matching: find.text('جست‌وجو'),
        ),
      );
      await wait(400);
      await allowImages();
      await capture('07_search_landing');

      final field = find.descendant(
        of: find.byType(SearchPage),
        matching: find.byType(TextField),
      );
      await tester.enterText(field, 'حیوانات');
      await wait(700);
      await allowImages();
      await capture('08_search_results');

      // ——— Detail (real poster hero) ———
      final firstResult = find
          .descendant(
            of: find.byType(SearchPage),
            matching: find.byType(CartoonCard),
          )
          .first;
      await tester.tap(firstResult);
      await wait(700);
      await allowImages();
      await capture('09_detail');

      expect(Directory('build/screenshots').listSync(), isNotEmpty);
      expect(tester.takeException(), isNull);
    },
    skip: !_enabled,
  );
}
