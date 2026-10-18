import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/main.dart';
import 'package:kartoniya/presentation/pages/home_page.dart';
import 'package:kartoniya/presentation/pages/search_page.dart';
import 'package:kartoniya/presentation/widgets/cartoon_card.dart';
import 'package:kartoniya/presentation/widgets/category_tile.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_nav_bar.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// رندر واقعی صفحه‌ها با فونت و assetهای پروژه برای بازبینی طراحی.
///
/// فقط با `KARTONIYA_SCREENSHOTS=1` اجرا می‌شود. این تصاویر خروجی
/// `RenderRepaintBoundary.toImage` هستند، نه اسکرین‌شات دستگاه واقعی؛
/// برای تأیید چیدمان/فونت/RTL مفیدند و جای آزمون روی دستگاه را نمی‌گیرند.
final _enabled = Platform.environment['KARTONIYA_SCREENSHOTS'] == '1';

void main() {
  testWidgets(
    'capture splash, home, categories and search screens',
    (tester) async {
      if (!_enabled) return;

      final outDir = Directory('build/screenshots')
        ..createSync(recursive: true);
      final rootKey = GlobalKey();
      final previousShadows = debugDisableShadows;
      debugDisableShadows = false;
      addTearDown(() => debugDisableShadows = previousShadows);

      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      // آیکون‌های Material در محیط تست بارگذاری نمی‌شوند و به‌صورت مربع
      // خالی رندر می‌شدند. فونت آیکون از SDK خوانده می‌شود (فقط برای
      // اسکرین‌شات؛ اپ در دستگاه واقعی فونت را از asset خود Flutter دارد).
      await tester.runAsync(() async {
        final flutterRoot = Platform.environment['FLUTTER_ROOT'];
        if (flutterRoot == null) return;
        final file = File(
          '$flutterRoot/bin/cache/artifacts/material_fonts/'
          'MaterialIcons-Regular.otf',
        );
        if (!file.existsSync()) return;
        final bytes = file.readAsBytesSync();
        final loader = FontLoader('MaterialIcons')
          ..addFont(Future.value(ByteData.view(bytes.buffer)));
        await loader.load();
      });

      // فونت واقعی Vazirmatn؛ در تست پیش‌فرض فونت آزمون است.
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

      SharedPreferences.setMockInitialValues({'onboarding_completed': true});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        RepaintBoundary(
          key: rootKey,
          child: ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: const KartoniyaApp(),
          ),
        ),
      );
      await tester.pump();

      Future<void> settleImages() async {
        // decode تصاویر asset در تست نیاز به زمان واقعی دارد.
        for (var i = 0; i < 3; i++) {
          await tester.runAsync(() async {
            await Future<void>.delayed(const Duration(milliseconds: 220));
          });
          await tester.pump();
        }
        // ورودهای پلکانی (StaggeredReveal) و محو‌شدن تصاویر با فریم
        // جلو می‌روند؛ بدون این پمپ، کارت‌ها در فریم صفر (شفاف) ثبت می‌شدند.
        await tester.pump(const Duration(milliseconds: 900));
        await tester.pump();
      }

      Future<void> capture(String name) async {
        await settleImages();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(rootKey),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          image.dispose();
          File('${outDir.path}/$name.png')
              .writeAsBytesSync(bytes!.buffer.asUint8List());
        });
      }

      // ——— Splash ———
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await capture('01_splash');

      // ——— Home ———
      await tester.pump(const Duration(milliseconds: 700));
      for (var i = 0; i < 20 && find.byType(HomePage).evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      expect(find.byType(HomePage), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 900));
      await capture('02_home_top');

      await tester.drag(
        find.byType(CustomScrollView).first,
        const Offset(0, -620),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await capture('03_home_sections');

      // ——— Categories ———
      await tester.tap(
        find.descendant(
          of: find.byType(KartoniyaNavBar),
          matching: find.text('دسته‌ها'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await capture('04_categories');

      final tile = find.descendant(
        of: find.byType(CategoryTile),
        matching: find.text('ماجراجویی'),
      );
      await tester.tap(tile.first);
      await tester.pump(const Duration(milliseconds: 400));
      await capture('05_categories_filtered');

      // ——— Search ———
      await tester.tap(
        find.descendant(
          of: find.byType(KartoniyaNavBar),
          matching: find.text('جست‌وجو'),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await capture('06_search_landing');

      final field = find.descendant(
        of: find.byType(SearchPage),
        matching: find.byType(TextField),
      );
      await tester.enterText(field, 'حيوانات');
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 900));
      await capture('07_search_results');

      // ——— Detail ———
      await tester.tap(
        find
            .descendant(
              of: find.byType(SearchPage),
              matching: find.byType(CartoonCard),
            )
            .first,
      );
      await tester.pump(const Duration(milliseconds: 500));
      await capture('08_detail');

      expect(Directory(outDir.path).listSync(), isNotEmpty);
      expect(tester.takeException(), isNull);
      // اطمینان از اینکه چیدمان در دستگاه 390×844 با تم روشن رندر شد.
      expect(find.byType(Scaffold), findsWidgets);
    },
    skip: !_enabled,
  );

}
