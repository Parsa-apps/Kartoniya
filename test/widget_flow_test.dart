import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/services/app_haptics.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/data/repositories/local_cartoon_repository.dart';
import 'package:kartoniya/main.dart';
import 'package:kartoniya/presentation/global_widgets/parental_gate_widget.dart';
import 'package:kartoniya/presentation/pages/onboarding_page.dart';
import 'package:kartoniya/presentation/pages/home_page.dart';
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

    expect(find.text('دنیای شاد و امن کودکان'), findsOneWidget);

    // اسپلش پس از ~۱٫۷ ثانیه جای خود را به آن‌بوردینگ می‌دهد؛ چند فریم
    // کوچک پمپ می‌شود تا ورود، مکث و خروج در زمان‌بندی واقعی کامل شوند.
    await tester.pump(const Duration(milliseconds: 1400));
    for (var i = 0; i < 16 && find.text('رد کردن').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
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
    expect(find.text('کاهش حرکت'), findsNothing);
    expect(find.text('بازخورد لمسی'), findsOneWidget);
  });

  testWidgets('کنترل کاهش حرکت در تنظیمات والدین نمایش داده نمی‌شود',
      (tester) async {
    usePhone(tester);
    // ترجیح نسخهٔ قدیمی نباید کنترل حذف‌شده را دوباره در رابط نشان دهد.
    final prefs = await initPrefs({'reduce_motion_enabled': true});
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

    expect(find.text('کاهش حرکت'), findsNothing);
    expect(find.text('بازخورد لمسی'), findsOneWidget);
    expect(prefs.getBool('reduce_motion_enabled'), isTrue);
  });

  testWidgets('بازخورد لمسی از تنظیمات والدین قابل خاموش‌کردن است',
      (tester) async {
    usePhone(tester);
    addTearDown(() => AppHaptics.setEnabled(true));
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

    final hapticsTile = find.ancestor(
      of: find.text('بازخورد لمسی'),
      matching: find.byType(SwitchListTile),
    );
    expect(hapticsTile, findsOneWidget);
    await tester.ensureVisible(hapticsTile);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(hapticsTile);
    await tester.pump();
    await tester.pump();

    expect(container.read(hapticsProvider), isFalse);
    expect(AppHaptics.enabled, isFalse);
    expect(prefs.getBool('haptics_enabled'), isFalse);
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
