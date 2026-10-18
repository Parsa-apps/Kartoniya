import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/theme/app_motion.dart';
import 'package:kartoniya/core/theme/app_theme.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/presentation/pages/categories_page.dart';
import 'package:kartoniya/presentation/pages/home_page.dart';
import 'package:kartoniya/presentation/pages/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نگهبان خوانایی برای کودکانی که در تنظیمات اندروید «اندازهٔ فونت» را
/// بزرگ کرده‌اند: صفحه‌های اصلی روی کوچک‌ترین گوشی (۳۲۰×۵۶۸) و با متن
/// ۱٫۳ برابر باید بدون سرریز بالا بیایند.
///
/// حرکت عمداً خاموش است تا چیدمان در هر فریم ثابت بماند و تست به زمان‌بندی
/// انیمیشن‌ها وابسته نباشد.
void main() {
  const phone = Size(320, 568);

  Future<void> pumpPage(
    WidgetTester tester,
    Widget page, {
    double textScale = 1.3,
  }) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          locale: const Locale('fa', 'IR'),
          supportedLocales: const [Locale('fa', 'IR'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: MotionScope(
              info: MotionInfo.reducedNone,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
          home: MediaQuery(
            data: MediaQueryData(
              size: phone,
              devicePixelRatio: 1,
              textScaler: TextScaler.linear(textScale),
            ),
            child: page,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('خانه با متن ۱٫۳× روی ۳۲۰px بدون سرریز اسکرول می‌شود',
      (tester) async {
    await pumpPage(tester, const HomePage());
    expect(tester.takeException(), isNull, reason: 'چیدمان اول خانه');

    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 10; i++) {
      await tester.drag(scrollable, const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 180));
      expect(
        tester.takeException(),
        isNull,
        reason: 'خانه با متن بزرگ، اسکرول $i',
      );
    }
  });

  testWidgets('دسته‌ها با متن ۱٫۳× سرریز نمی‌شوند', (tester) async {
    await pumpPage(tester, const CategoriesPage());
    for (var i = 0; i < 8; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -280));
      await tester.pump(const Duration(milliseconds: 180));
      expect(
        tester.takeException(),
        isNull,
        reason: 'دسته‌ها با متن بزرگ، اسکرول $i',
      );
    }
  });

  testWidgets('جست‌وجو با متن ۱٫۳× سرریز نمی‌شود', (tester) async {
    await pumpPage(tester, const SearchPage());
    expect(tester.takeException(), isNull, reason: 'صفحهٔ جست‌وجو');

    await tester.enterText(find.byType(TextField).first, 'قصه');
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 180));
    }
    expect(
      tester.takeException(),
      isNull,
      reason: 'نتایج جست‌وجو با متن بزرگ',
    );
  });
}
