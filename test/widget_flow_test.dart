import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/data/repositories/local_cartoon_repository.dart';
import 'package:kartoniya/main.dart';
import 'package:kartoniya/presentation/global_widgets/parental_gate_widget.dart';
import 'package:kartoniya/presentation/pages/onboarding_page.dart';
import 'package:kartoniya/presentation/pages/home_page.dart';
import 'package:kartoniya/presentation/pages/premium_readiness_page.dart';
import 'package:kartoniya/presentation/pages/privacy_information_page.dart';
import 'package:kartoniya/presentation/pages/settings_page.dart';
import 'package:kartoniya/presentation/widgets/cartoon_card.dart';
import 'package:kartoniya/presentation/widgets/favorite_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  void usePhone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2280);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  Future<SharedPreferences> initPrefs([
    Map<String, Object> values = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(values);
    return SharedPreferences.getInstance();
  }

  Future<void> revealTextInList(WidgetTester tester, String text) async {
    final scrollable = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.textContaining(text),
      240,
      scrollable: scrollable.first,
    );
  }

  testWidgets('مسیر اولین اجرا: اسپلش → آن‌بوردینگ → خانه', (tester) async {
    usePhone(tester);
    final prefs = await initPrefs();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const KartoniyaApp(),
      ),
    );
    await tester.pump();

    expect(find.text('قصه‌ها اینجا شروع می‌شوند'), findsOneWidget);

    // اسپلش کوتاه و قابل ردکردن است؛ در این جریان، زمان‌سنج خودکار آن را رد می‌کند.
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('رد کردن'), findsOneWidget);

    await tester.tap(find.text('رد کردن'));
    await tester.pump();
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    expect(find.byType(OnboardingPage), findsNothing);
    // The catalogue heading is lazily built below the phone viewport.
    expect(find.byType(HomePage), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(prefs.getBool('onboarding_completed'), isTrue);
  });

  testWidgets('اسپلش با دکمهٔ ردکردن سریع به آن‌بوردینگ می‌رود',
      (tester) async {
    usePhone(tester);
    final prefs = await initPrefs();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const KartoniyaApp(),
      ),
    );
    await tester.pump();

    expect(find.text('قصه‌ها اینجا شروع می‌شوند'), findsOneWidget);
    await tester.tap(find.text('رد کردن'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'آن‌بوردینگ با بزرگ‌نمایی متن قابل پیمایش می‌ماند',
    (tester) async {
      usePhone(tester);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: const OnboardingPage(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('ماجرای بعدی را پیدا کن'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('قلب کارت، علاقه‌مندی را ذخیره می‌کند', (tester) async {
    usePhone(tester);
    final prefs = await initPrefs();
    final cartoon = (await LocalCartoonRepository().fetchCartoons()).first;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 260,
                child: CartoonCard(cartoon: cartoon, onTap: () {}),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      prefs.getStringList('favorite_cartoon_ids') ?? const <String>[],
      isNot(contains(cartoon.id)),
    );

    await tester.tap(find.byType(FavoriteButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(prefs.getStringList('favorite_cartoon_ids'), contains(cartoon.id));
  });

  testWidgets('صفحهٔ وضعیت خرید قیمت یا تراکنش ساختگی ندارد', (tester) async {
    usePhone(tester);
    await tester.pumpWidget(
      const MaterialApp(home: PremiumReadinessPage()),
    );
    await tester.pump();

    expect(find.text('خرید هنوز فعال نیست'), findsOneWidget);
    expect(find.text('انتخاب فروشگاه مقصد'), findsOneWidget);
    await revealTextInList(tester, 'اعتبارسنجی و بازیابی');
    expect(find.text('اعتبارسنجی و بازیابی'), findsOneWidget);
    expect(find.textContaining('تومان'), findsNothing);
    expect(find.textContaining('€'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('خلاصهٔ حریم خصوصی تفاوت ذخیرهٔ محلی و میزبان بیرونی را می‌گوید',
      (tester) async {
    usePhone(tester);
    await tester.pumpWidget(
      const MaterialApp(home: PrivacyInformationPage()),
    );
    await tester.pump();

    expect(find.text('حریم خصوصی'), findsOneWidget);
    expect(find.text('اطلاعات ذخیره‌شده روی دستگاه'), findsOneWidget);
    await revealTextInList(tester, 'جایگزین سیاست حقوقی');
    expect(find.textContaining('جایگزین سیاست حقوقی'), findsOneWidget);
    await revealTextInList(tester, 'پخش و پیوندهای بیرونی');
    expect(find.text('پخش و پیوندهای بیرونی'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'قفل والدین: پاسخ غلط دیالوگ را باز نگه می‌دارد و '
      'پاسخ درست اجازه ورود می‌دهد', (tester) async {
    usePhone(tester);
    final prefs = await initPrefs();
    var gateResolved = false;
    var gateAllowed = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    showParentalGate(context).then((value) {
                      gateResolved = true;
                      gateAllowed = value;
                    });
                  },
                  child: const Text('باز کردن قفل'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('باز کردن قفل'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('ورود والدین'), findsOneWidget);

    // پاسخ نادرست: دیالوگ باید باز بماند و مسئله تازه‌ای بدهد.
    final firstChallenge = _readChallenge(tester);
    await tester.enterText(
      find.byType(TextField),
      '${firstChallenge.answer + 1}',
    );
    await tester.tap(find.text('تأیید'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('ورود والدین'), findsOneWidget);
    expect(gateResolved, isFalse);

    // پاسخ درست: دیالوگ با اجازهٔ ورود بسته می‌شود.
    final secondChallenge = _readChallenge(tester);
    await tester.enterText(
      find.byType(TextField),
      '${secondChallenge.answer}',
    );
    await tester.tap(find.text('تأیید'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    expect(gateResolved, isTrue);
    expect(gateAllowed, isTrue);

    // صفحه تنظیمات والدین هم باید درست رندر شود.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('کاهش حرکت'), findsOneWidget);
  });

  testWidgets('کاهش حرکت از تنظیمات والدین ذخیره می‌شود', (tester) async {
    usePhone(tester);
    final prefs = await initPrefs();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(container.read(reduceMotionProvider), isTrue);
    // Widget tests use a fake clock: pump flushes storage microtasks
    // without waiting on an unadvanced Timer.
    await tester.pump();
    expect(prefs.getBool('reduce_motion_enabled'), isTrue);
  });
}

class _Challenge {
  _Challenge(this.answer);

  final int answer;
}

_Challenge _readChallenge(WidgetTester tester) {
  for (final element in find.textContaining('=').evaluate()) {
    final widget = element.widget;
    if (widget is Text && widget.data != null && widget.data!.contains('؟')) {
      final match =
          RegExp(r'(\d+)\s*([+×−\-])\s*(\d+)').firstMatch(widget.data!);
      if (match == null) continue;
      final a = int.parse(match.group(1)!);
      final b = int.parse(match.group(3)!);
      return switch (match.group(2)) {
        '+' => _Challenge(a + b),
        '×' => _Challenge(a * b),
        _ => _Challenge(a - b),
      };
    }
  }
  throw StateError('مسئله قفل والدین پیدا نشد');
}
