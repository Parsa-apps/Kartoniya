import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/services/fandoghi_promotion_metrics.dart';
import 'package:kartoniya/core/services/fandoghi_store_launcher.dart';
import 'package:kartoniya/presentation/widgets/fandoghi_promotion_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  group('FandoghiStoreLauncher', () {
    test('نشانی رسمی را ابتدا با روش external سیستم باز می‌کند', () async {
      Uri? openedUri;
      LaunchMode? usedMode;
      final launcher = FandoghiStoreLauncher(
        launch: (uri, {required mode}) async {
          openedUri = uri;
          usedMode = mode;
          return true;
        },
      );

      expect(await launcher.open(), FandoghiStoreLaunchResult.opened);
      expect(openedUri, FandoghiStoreLauncher.storeUri);
      expect(
        openedUri?.toString(),
        'https://myket.ir/app/com.parsaapps.amoozesh_fandoghi',
      );
      expect(usedMode, LaunchMode.externalApplication);
    });

    test('اگر روش external شکست بخورد، روش پیش‌فرض سیستم را امتحان می‌کند',
        () async {
      final modes = <LaunchMode>[];
      final launcher = FandoghiStoreLauncher(
        launch: (_, {required mode}) async {
          modes.add(mode);
          return mode == LaunchMode.platformDefault;
        },
      );

      expect(await launcher.open(), FandoghiStoreLaunchResult.opened);
      expect(
        modes,
        [LaunchMode.externalApplication, LaunchMode.platformDefault],
      );
    });

    test('شکست هر دو روش را به‌درستی گزارش می‌کند', () async {
      var attempts = 0;
      final launcher = FandoghiStoreLauncher(
        launch: (_, {required mode}) async {
          attempts++;
          return false;
        },
      );

      expect(await launcher.open(), FandoghiStoreLaunchResult.failed);
      expect(attempts, 2);
    });

    test('exception روش اول را می‌گیرد و fallback را ادامه می‌دهد', () async {
      final launcher = FandoghiStoreLauncher(
        launch: (_, {required mode}) async {
          if (mode == LaunchMode.externalApplication) {
            throw StateError('no activity handler');
          }
          return true;
        },
      );

      expect(await launcher.open(), FandoghiStoreLaunchResult.opened);
    });
  });

  testWidgets('در شکست لینک پیام خطا می‌دهد و موفقیت کاذب نشان نمی‌دهد',
      (tester) async {
    final results = <FandoghiStoreLaunchResult>[];
    var clicks = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FandoghiPromotionCard(
            onLaunchStarted: () => clicks++,
            onLaunchResult: results.add,
            launchStore: () async => FandoghiStoreLaunchResult.failed,
          ),
        ),
      ),
    );

    await tester.tap(find.text('مشاهده در مایکت'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(clicks, 1);
    expect(results, [FandoghiStoreLaunchResult.failed]);
    expect(find.textContaining('باز کردن صفحهٔ جزیره فندقی ممکن نشد'),
        findsOneWidget);
    expect(find.text('با موفقیت باز شد'), findsNothing);
  });

  testWidgets('در موفقیت پیام خطا نشان نمی‌دهد', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FandoghiPromotionCard(
            onLaunchStarted: () {},
            onLaunchResult: (_) {},
            launchStore: () async => FandoghiStoreLaunchResult.opened,
          ),
        ),
      ),
    );

    await tester.tap(find.text('مشاهده در مایکت'));
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
  });

  test('رویدادهای معرفی فقط در شمارنده‌های محلی ذخیره می‌شوند', () async {
    SharedPreferences.setMockInitialValues({});
    const metrics = FandoghiPromotionMetrics();

    await metrics.record(FandoghiPromotionEvent.impression);
    await metrics.record(FandoghiPromotionEvent.click);
    await metrics.record(FandoghiPromotionEvent.opened);
    await metrics.record(FandoghiPromotionEvent.failed);
    final preferences = await SharedPreferences.getInstance();

    expect(preferences.getInt('fandoghi_promo_impressions'), 1);
    expect(preferences.getInt('fandoghi_promo_clicks'), 1);
    expect(preferences.getInt('fandoghi_promo_opened'), 1);
    expect(preferences.getInt('fandoghi_promo_failed'), 1);
  });
}
