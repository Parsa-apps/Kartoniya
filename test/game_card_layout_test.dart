import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/theme/app_theme.dart';
import 'package:kartoniya/data/models/game_model.dart';
import 'package:kartoniya/data/repositories/local_game_repository.dart';
import 'package:kartoniya/presentation/widgets/game_card.dart';

/// کارت بازی در دو موقعیتی که در برنامه واقعاً رخ می‌دهد تست می‌شود:
/// ۱) ردیف افقی خانه با ارتفاع ثابت (کاشی کوچک) — توضیح باید کنار برود.
/// ۲) داخل ستون/اسکرول با ارتفاع نامحدود — هیچ خطای چیدمانی نباشد.
///
/// مورد دوم یک باگ واقعی بود: `Flexible` داخل `Column` با ارتفاع نامحدود
/// خطای «children have non-zero flex but incoming height constraints are
/// unbounded» می‌دهد. کارت اکنون فقط وقتی ارتفاع محدود باشد از Flexible
/// استفاده می‌کند.
void main() {
  late GameModel game;

  setUpAll(() async {
    game = (await LocalGameRepository().fetchGames()).first;
  });

  Widget host(Widget page) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('fa', 'IR'),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: page,
    );
  }

  testWidgets('کارت در ستون با ارتفاع نامحدود بدون خطای چیدمان ساخته می‌شود',
      (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      host(
        Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: 220,
                  child: GameCard(game: game, onTap: () {}),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(GameCard), findsOneWidget);
    expect(find.text(game.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('کارت کوتاه توضیح را کنار می‌گذارد و عنوان را نگه می‌دارد',
      (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      host(
        Scaffold(
          body: Center(
            child: SizedBox(
              width: 190,
              height: 120,
              child: GameCard(game: game, onTap: () {}),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(game.title), findsOneWidget);
    expect(
      find.text(game.description),
      findsNothing,
      reason: 'در ارتفاع ۱۲۰ پیکسل توضیح باید کنار برود تا سرریز نشود',
    );
    expect(tester.takeException(), isNull);
  });
}
