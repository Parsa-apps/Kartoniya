import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/models/cartoon_model.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/data/repositories/local_cartoon_repository.dart';
import 'package:kartoniya/main.dart';
import 'package:kartoniya/presentation/pages/cartoon_detail_page.dart';
import 'package:kartoniya/presentation/pages/categories_page.dart';
import 'package:kartoniya/presentation/pages/home_page.dart';
import 'package:kartoniya/presentation/pages/search_page.dart';
import 'package:kartoniya/presentation/widgets/cartoon_card.dart';
import 'package:kartoniya/presentation/widgets/category_tile.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_mascot.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// جریان‌های واقعی خانه → جست‌وجو و دسته‌ها، بدون mock داده.
void main() {
  Future<SharedPreferences> preferences() async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    return SharedPreferences.getInstance();
  }

  Future<void> pumpHome(
    WidgetTester tester,
    SharedPreferences prefs, {
    Size logicalSize = const Size(390, 844),
  }) async {
    tester.view.physicalSize = logicalSize * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const KartoniyaApp(),
      ),
    );
    await tester.pump();
    // Splash: ورود ۱۳۰۰ms + مکث ۱۷۰ms + خروج ۲۴۰ms + ترنزیشن مسیر.
    // به‌جای اتکا به یک زمان دقیق، تا ظاهر شدن خانه پمپ می‌کنیم.
    await tester.pump(const Duration(milliseconds: 1400));
    for (var i = 0; i < 20 && find.byType(HomePage).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byType(HomePage), findsOneWidget);
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(KartoniyaNavBar),
        matching: find.text(label),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
  }

  Finder searchField() => find.descendant(
        of: find.byType(SearchPage),
        matching: find.byType(TextField),
      );

  Finder searchCards() => find.descendant(
        of: find.byType(SearchPage),
        matching: find.byType(CartoonCard),
      );

  testWidgets('جست‌وجوی فارسی: نرمال‌سازی، نتایج، بدون نتیجه و پاک کردن',
      (tester) async {
    await pumpHome(tester, await preferences());
    await openTab(tester, 'جست‌وجو');

    expect(searchField(), findsOneWidget);
    expect(find.text('از دسته‌ها شروع کن'), findsOneWidget);

    // «ي» و «ك» عربی وارد می‌شوند؛ normalize باید «حیوانات» فارسی را پیدا کند.
    await tester.enterText(searchField(), 'حيوانات');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 150));

    expect(searchCards(), findsWidgets);
    expect(find.textContaining('نتیجه برای'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(searchField(), 'قققق');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('چیزی پیدا نشد'), findsOneWidget);
    expect(find.text('پاک کردن جست‌وجو'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('پاک کردن جست‌وجو').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(tester.widget<TextField>(searchField()).controller!.text, isEmpty);
    expect(find.text('از دسته‌ها شروع کن'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('پیشنهاد دسته در جست‌وجو، کوئری واقعی می‌سازد', (tester) async {
    await pumpHome(tester, await preferences());
    await openTab(tester, 'جست‌وجو');

    final chip = find.descendant(
      of: find.byType(SearchPage),
      matching: find.text('آموزشی'),
    );
    expect(chip, findsWidgets);
    await tester.tap(chip.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 200));

    expect(tester.widget<TextField>(searchField()).controller!.text, 'آموزشی');
    expect(searchCards(), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('دسته‌ها: فیلتر واقعی و پاک کردن فیلتر', (tester) async {
    await pumpHome(tester, await preferences());
    await openTab(tester, 'دسته‌ها');

    expect(find.byType(CategoryTile), findsWidgets);
    // «ماجراجویی» دومین کاشی است و در عرض ۳۹۰px بدون اسکرول ریل دیده می‌شود.
    final tile = find.descendant(
      of: find.byType(CategoryTile),
      matching: find.text('ماجراجویی'),
    );
    expect(tile, findsOneWidget);
    await tester.tap(tile);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    var cards = tester.widgetList<CartoonCard>(
      find.descendant(
        of: find.byType(CategoriesPage),
        matching: find.byType(CartoonCard),
      ),
    );
    expect(cards, isNotEmpty);
    expect(
      cards.every((card) => card.cartoon.category == 'ماجراجویی'),
      isTrue,
    );

    await tester.tap(find.text('پاک کردن'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    cards = tester.widgetList<CartoonCard>(
      find.descendant(
        of: find.byType(CategoriesPage),
        matching: find.byType(CartoonCard),
      ),
    );
    expect(
      cards.any((card) => card.cartoon.category != 'ماجراجویی'),
      isTrue,
      reason: 'پس از پاک کردن فیلتر، کاتالوگ کامل باید برگردد.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('کارت واقعی جزئیات را با همان کارتون باز می‌کند', (tester) async {
    await pumpHome(tester, await preferences());
    await openTab(tester, 'دسته‌ها');

    final card = find
        .descendant(
          of: find.byType(CategoriesPage),
          matching: find.byType(CartoonCard),
        )
        .first;
    final model = tester.widget<CartoonCard>(card).cartoon;
    await tester.tap(card);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(CartoonDetailPage), findsOneWidget);
    expect(find.text(model.title), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('گوشی کوچک ۳۲۰×۶۴۰: هیچ overflow در خانه/دسته/جست‌وجو نیست',
      (tester) async {
    await pumpHome(
      tester,
      await preferences(),
      logicalSize: const Size(320, 640),
    );
    expect(tester.takeException(), isNull);

    await openTab(tester, 'دسته‌ها');
    expect(tester.takeException(), isNull);

    await openTab(tester, 'جست‌وجو');
    expect(tester.takeException(), isNull);

    await tester.enterText(searchField(), 'الفبا');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('لمس فندوقی در کارت جست‌وجو، فیلد را فوکوس می‌کند',
      (tester) async {
    await pumpHome(tester, await preferences());
    await openTab(tester, 'جست‌وجو');

    final mascot = find.descendant(
      of: find.byType(SearchPage),
      matching: find.byType(KartoniyaMascot),
    );
    expect(mascot, findsWidgets);
    expect(
      tester.widget<KartoniyaMascot>(mascot.first).onTap,
      isNotNull,
      reason: 'شخصیت راهنما باید مثل کارتِ پشتش به جست‌وجو ببرد.',
    );

    await tester.tap(mascot.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(
      FocusManager.instance.primaryFocus?.context?.widget,
      isA<EditableText>(),
      reason: 'پس از لمس فندوقی، فیلد جست‌وجو باید فوکوس بگیرد.',
    );
    expect(tester.takeException(), isNull);
  });

  test('هر دستهٔ محلی یک آیکون برداری یکتا دارد', () async {
    final categories = await LocalCartoonRepository().fetchCategories();
    expect(categories, isNotEmpty);

    final icons = categories.map(categoryIcon).toList(growable: false);
    expect(
      icons.toSet(),
      hasLength(categories.length),
      reason: 'نشان دسته‌ها باید از هم قابل تشخیص باشد.',
    );

    // شناسهٔ ناشناخته نباید مربع خالی یا استثنا بسازد.
    expect(
      categoryIcon(
        const CategoryModel(
          id: 'unknown',
          name: 'ناشناخته',
          emoji: '✨',
          colorValue: 0xFF000000,
        ),
      ),
      Icons.category_rounded,
    );
  });
}
