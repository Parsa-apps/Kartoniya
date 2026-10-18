import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/main.dart';
import 'package:kartoniya/presentation/pages/categories_page.dart';
import 'package:kartoniya/presentation/pages/home_page.dart';
import 'package:kartoniya/presentation/pages/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نگهبان چیدمان روی کوچک‌ترین گوشی‌های واقعی (۳۲۰×۵۶۸ logical pixel).
///
/// نسبت ابعاد کارت‌ها از عرض واقعی کاشی حساب می‌شود؛ این تست تضمین می‌کند
/// که با آن محاسبه هیچ سرریزی روی صفحهٔ کوچک رخ نمی‌دهد و متن‌ها/قرص‌های
/// دسته هم جا می‌شوند.
void main() {
  void useSmallPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<SharedPreferences> initPrefs() async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    return SharedPreferences.getInstance();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    final prefs = await initPrefs();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const KartoniyaApp(),
      ),
    );
    // اسپلش کوتاه است و بعد از آن خانه بالا می‌آید.
    await tester.pump(const Duration(milliseconds: 1400));
    for (var i = 0; i < 20 && find.byType(HomePage).evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets('خانه روی گوشی ۳۲۰px بدون سرریز بالا می‌آید', (tester) async {
    useSmallPhone(tester);
    await pumpApp(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);

    // اسکرول تا انتهای محتوا؛ همهٔ ریل‌ها و کارت‌ها ساخته و چیده می‌شوند.
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 12; i++) {
      await tester.drag(scrollable, const Offset(0, -320));
      await tester.pump(const Duration(milliseconds: 220));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('گروه‌بندی و جست‌وجو روی گوشی ۳۲۰px جا می‌شوند', (tester) async {
    useSmallPhone(tester);
    final prefs = await initPrefs();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CategoriesPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(CategoriesPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SearchPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.byType(SearchPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField).first, 'حیوانات');
    await tester.pump(const Duration(milliseconds: 400));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(tester.takeException(), isNull);
  });
}
