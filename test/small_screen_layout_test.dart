import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/main.dart';
import 'package:kartoniya/presentation/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نگهبان چیدمان روی کوچک‌ترین گوشی‌های واقعی (۳۲۰×۵۶۸ logical pixel).
///
/// نسبت ابعاد کارت‌ها از عرض واقعی کاشی حساب می‌شود؛ این تست تضمین می‌کند
/// که با آن محاسبه هیچ سرریزی روی صفحهٔ کوچک رخ نمی‌دهد و متن‌ها/قرص‌های
/// دسته هم جا می‌شوند. اگر سرریزی رخ دهد، نام و محل ویجت مقصر در پیام
/// خطا گزارش می‌شود تا رفع آن سرراست باشد.
void main() {
  void useSmallPhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    final prefs = await SharedPreferences.getInstance();
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
    expect(tester.takeException(), isNull, reason: 'چیدمان اول خانه');

    // اسکرول تا انتهای محتوا؛ همهٔ ریل‌ها و کارت‌ها ساخته و چیده می‌شوند.
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 12; i++) {
      await tester.drag(scrollable, const Offset(0, -320));
      await tester.pump(const Duration(milliseconds: 220));
      expect(tester.takeException(), isNull, reason: 'خانه، اسکرول $i');
    }
  });

  testWidgets('دسته‌ها و جست‌وجو روی گوشی ۳۲۰px جا می‌شوند', (tester) async {
    useSmallPhone(tester);
    await pumpApp(tester);

    await tester.tap(find.text('دسته‌ها').last);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull, reason: 'صفحهٔ دسته‌ها');

    await tester.tap(find.text('جست‌وجو').last);
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull, reason: 'صفحهٔ جست‌وجو');

    await tester.enterText(find.byType(TextField).first, 'حیوانات');
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(tester.takeException(), isNull, reason: 'نتایج جست‌وجو');
  });
}
