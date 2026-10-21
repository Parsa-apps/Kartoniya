import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/theme/app_colors.dart';
import 'package:kartoniya/core/theme/app_motion.dart';
import 'package:kartoniya/core/theme/app_theme.dart';
import 'package:kartoniya/data/models/game_model.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/data/repositories/local_game_repository.dart';
import 'package:kartoniya/presentation/pages/game_detail_page.dart';
import 'package:kartoniya/presentation/pages/games_page.dart';
import 'package:kartoniya/presentation/widgets/game_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نگهبان «تب بازی‌ها در حالت تاریک».
///
/// تب بازی‌ها یک‌دور کامل با رنگ‌های ثابت روشن (سفید و مشکیِ نیمه‌شفاف) ساخته
/// شده بود؛ نتیجه این بود که در حالت تاریک متن‌ها روی سطح تیره محو یا روی
/// کارت سفید ناپیدا می‌شدند. این تست دو چیز را تضمین می‌کند:
/// ۱) هیچ متنی در تب بازی‌ها/جزئیات بازی رنگ تیرهٔ ثابت (`Colors.black*`) نگیرد.
/// ۲) گرید روی گوشی ۳۲۰px و با متن ۱٫۳× بدون سرریز ساخته شود.
void main() {
  Future<SharedPreferences> initPrefs() async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    return SharedPreferences.getInstance();
  }

  Widget host(
    SharedPreferences prefs,
    Widget child, {
    bool dark = true,
    double textScale = 1.0,
  }) {
    return ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        locale: const Locale('fa', 'IR'),
        supportedLocales: const [Locale('fa', 'IR'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: textScale == 1
                ? media
                : media.copyWith(textScaler: TextScaler.linear(textScale)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: MotionScope(
                info: MotionInfo.reducedNone,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          );
        },
        home: child,
      ),
    );
  }

  /// رنگ‌های «جوهری» که فقط روی سطح روشن خوانا هستند و در حالت تاریک
  /// ناخوانا می‌شوند. اگر جایی این رنگ‌ها با تم تاریک استفاده شوند، جرم است.
  const inkOnly = <Color>[
    Colors.black,
    Colors.black87,
    Colors.black54,
    Colors.black45,
    Colors.black38,
  ];

  void expectNoInkOnlyText(WidgetTester tester) {
    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      final color = text.style?.color;
      if (color == null) continue;
      expect(
        inkOnly.contains(color),
        isFalse,
        reason: 'متن «${text.data ?? text.textSpan?.toPlainText()}» رنگ '
            'تیرهٔ ثابت $color دارد و در تم تاریک ناخوانا می‌شود.',
      );
    }
  }

  testWidgets('تب بازی‌ها در حالت تاریک متن تیرهٔ ثابت ندارد',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final prefs = await initPrefs();
    await tester.pumpWidget(host(prefs, const GamesPage()));
    // کاتالوگ محلی سریع می‌آید؛ به‌جای pumpAndSettle (شیمر بی‌پایان است)
    // چند فریم صبر می‌کنیم تا گرید ساخته شود.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    expect(find.byType(GameCard), findsWidgets);
    expect(find.text('بازی‌ها'), findsOneWidget);
    expectNoInkOnlyText(tester);

    // زیرعنوان صفحه باید با رنگ متن ثانویهٔ تم و خوانا روی پس‌زمینهٔ تیره
    // باشد (نه مشکیِ نیمه‌شفاف که قبلاً روی پس‌زمینهٔ تیره محو می‌شد).
    final subtitle = tester.widget<Text>(
      find.textContaining('بازی تعاملی برای کودکان'),
    );
    final subtitleColor = subtitle.style?.color;
    expect(subtitleColor, isNotNull);
    expect(
      AppColors.contrast(subtitleColor!, AppColors.darkBackground),
      greaterThanOrEqualTo(4.5),
      reason: 'زیرعنوان تب بازی‌ها در تم تاریک خوانا نیست.',
    );

    // هیچ سطح سفیدِ کدری در این صفحه نباید بماند؛ کارت‌ها و فیلد جست‌وجو
    // باید از سطح تم بیایند تا متن روشن روی آن‌ها خوانا بماند.
    for (final container in tester.widgetList<Container>(
      find.descendant(
        of: find.byType(GamesPage),
        matching: find.byType(Container),
      ),
    )) {
      final decoration = container.decoration;
      if (decoration is! BoxDecoration) continue;
      final color = decoration.color;
      if (color == null || color.opacity < 0.99) continue;
      expect(
        color,
        isNot(Colors.white),
        reason: 'یک سطح سفیدِ کدر در تم تاریک باقی مانده است.',
      );
    }
  });

  testWidgets('جزئیات بازی در حالت تاریک خوانا و بدون رنگ ثابت است',
      (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final games = await LocalGameRepository().fetchGames();
    final game = games.firstWhere((item) => item.isPlayable);
    final prefs = await initPrefs();

    await tester.pumpWidget(host(prefs, GameDetailPage(game: game)));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('شروع بازی'), findsOneWidget);
    expect(find.text('دربارهٔ بازی'), findsOneWidget);
    expectNoInkOnlyText(tester);
    expect(tester.takeException(), isNull);
  });

  for (final scale in <double>[1.0, 1.3]) {
    testWidgets(
        'گرید بازی‌ها روی گوشی ۳۲۰px با متن ${scale}× سرریز نمی‌شود',
        (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final prefs = await initPrefs();
      await tester.pumpWidget(
        host(prefs, const GamesPage(), textScale: scale),
      );
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 150));
      }
      expect(find.byType(GameCard), findsWidgets);
      expect(tester.takeException(), isNull, reason: 'چیدمان اول گرید');

      // اسکرول تا انتهای گرید: همهٔ کاشی‌ها ساخته و چیده می‌شوند.
      final scrollable = find.byType(Scrollable).first;
      for (var i = 0; i < 8; i++) {
        await tester.drag(scrollable, const Offset(0, -280));
        await tester.pump(const Duration(milliseconds: 180));
        expect(tester.takeException(), isNull, reason: 'اسکرول $i');
      }
    });
  }

  test('بازی‌های قابل پخش همه موتور واقعی دارند و مدل معتبرند', () async {
    final games = await LocalGameRepository().fetchGames();
    expect(games.where((game) => game.isPlayable).length, 100);
    for (final game in games) {
      expect(game.mechanics, isNotEmpty, reason: game.id);
      expect(GameCategory.values.contains(game.category), isTrue);
    }
  });
}
