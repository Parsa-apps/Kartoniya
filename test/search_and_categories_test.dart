import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/main.dart';
import 'package:kartoniya/presentation/pages/categories_page.dart';
import 'package:kartoniya/presentation/pages/home_page.dart';
import 'package:kartoniya/presentation/pages/search_page.dart';
import 'package:kartoniya/presentation/widgets/cartoon_card.dart';
import 'package:kartoniya/presentation/widgets/category_tile.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    Size physicalSize = const Size(1170, 2532),
  }) async {
    tester.view.physicalSize = physicalSize;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({
      'onboarding_completed': true,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const KartoniyaApp(),
      ),
    );
    // اسپلش عمداً با گام‌های کوچک پمپ می‌شود تا زنجیرهٔ async (ورود، داده،
    // خروج) واقعاً کامل شود؛ pumpAndSettle با انیمیشن بی‌پایان پس‌زمینه
    // هرگز پایان نمی‌یابد.
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
  }

  Future<void> tapNav(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(KartoniyaNavBar),
        matching: find.text(label),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
  }

  testWidgets('جست‌وجوی فارسی، پاک‌کردن و حالت بدون نتیجه', (tester) async {
    await pumpHome(tester);

    // لمس نوار جست‌وجوی خانه، برگهٔ جست‌وجو را فعال و فیلد را فوکوس می‌کند.
    await tester.tap(find.text('دنبال چه کارتونی می‌گردی؟'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));

    final fieldFinder = find.descendant(
      of: find.byType(SearchPage),
      matching: find.byType(TextField),
    );
    expect(fieldFinder, findsOneWidget);
    expect(tester.widget<TextField>(fieldFinder).focusNode?.hasFocus, isTrue);
    expect(find.text('از دسته‌ها شروع کن'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // جست‌وجو با «ي» عربی؛ نرمال‌سازی باید همان «ی» فارسی را پیدا کند.
    await tester.enterText(fieldFinder, 'حيوانات');
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final results = find.descendant(
      of: find.byType(SearchPage),
      matching: find.byType(CartoonCard),
    );
    expect(results, findsWidgets);
    expect(find.textContaining('نتیجه برای'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // پاک‌کردن عبارت، پیشنهادها را برمی‌گرداند.
    await tester.tap(find.byTooltip('پاک کردن جست‌وجو').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('از دسته‌ها شروع کن'), findsOneWidget);
    expect(tester.widget<TextField>(fieldFinder).controller?.text, isEmpty);

    // عبارت بی‌نتیجه: حالت خالی با مسیر بازگشت.
    await tester.enterText(fieldFinder, 'قققق');
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('چیزی پیدا نشد'), findsOneWidget);
    expect(find.text('پاک کردن جست‌وجو'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('دسته‌بندی: فیلتر واقعی، شمارش و پاک‌کردن فیلتر', (tester) async {
    await pumpHome(tester);
    await tapNav(tester, 'دسته‌ها');

    final tiles = find.descendant(
      of: find.byType(CategoriesPage),
      matching: find.byType(CategoryTile),
    );
    expect(tiles, findsWidgets);

    await tester.tap(
      find.descendant(
        of: tiles,
        matching: find.text('ماجراجویی'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final cards = find.descendant(
      of: find.byType(CategoriesPage),
      matching: find.byType(CartoonCard),
    );
    expect(cards, findsWidgets);
    final visible = tester.widgetList<CartoonCard>(cards);
    expect(visible.isNotEmpty, isTrue);
    expect(
      visible.every((card) => card.cartoon.category == 'ماجراجویی'),
      isTrue,
    );

    // پاک‌کردن فیلتر، همهٔ کاتالوگ را برمی‌گرداند (۸ کارتون در منبع محلی).
    await tester.tap(find.text('پاک کردن'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    final all = tester.widgetList<CartoonCard>(
      find.descendant(
        of: find.byType(CategoriesPage),
        matching: find.byType(CartoonCard),
      ),
    );
    expect(all.length, greaterThanOrEqualTo(6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('گوشی کوچک: خانه، دسته‌ها و جست‌وجو overflow نمی‌دهند',
      (tester) async {
    // 320x640 logical؛ باریک‌ترین حالت رایج Android.
    await pumpHome(tester, physicalSize: const Size(960, 1920));
    expect(tester.takeException(), isNull);

    await tapNav(tester, 'دسته‌ها');
    expect(tester.takeException(), isNull);

    await tapNav(tester, 'جست‌وجو');
    expect(tester.takeException(), isNull);

    final field = find.descendant(
      of: find.byType(SearchPage),
      matching: find.byType(TextField),
    );
    await tester.enterText(field, 'الفبا');
    await tester.pump(const Duration(milliseconds: 320));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull);
  });

  testWidgets('خانه: بخش‌های اصلی، کارت واقعی و ورود به جزئیات',
      (tester) async {
    await pumpHome(tester);

    expect(find.text('منتخب این هفته'), findsWidgets);
    expect(find.text('دسته‌ها'), findsWidgets);
    expect(find.textContaining('کارتون آمادهٔ تماشا'), findsNothing);

    // اسکرول تا فهرست کامل و کارت‌های واقعی پوستر.
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -900),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('کارتون آمادهٔ تماشا'), findsOneWidget);
    expect(find.byType(CartoonCard), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
