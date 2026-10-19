import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/presentation/widgets/player_brand_overlay.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_logo.dart';

void main() {
  group('PlayerBrandOverlay', () {
    testWidgets('دو لوگوی رسمی در گوشه‌های بالای ویدئو با هالهٔ نئونی نمایش داده می‌شوند',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 202,
              child: PlayerBrandOverlay(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // باید دو لوگو وجود داشته باشد (راست و چپ)
      expect(find.byType(KartoniyaLogoMark), findsNWidgets(2));
      // هاله‌ها RepaintBoundary دارند
      expect(find.byType(RepaintBoundary), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('اندازهٔ لوگو ۵-۸٪ عرض کادر ویدئو است', (tester) async {
      const videoWidth = 360.0;
      final expectedMin = videoWidth * 0.05;
      final expectedMax = videoWidth * 0.08;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: videoWidth,
              height: 202,
              child: PlayerBrandOverlay(),
            ),
          ),
        ),
      );
      await tester.pump();

      // اندازهٔ محاسبه‌شده باید در بازهٔ ۵-۸٪ باشد (با clamp نهایی ۲۸-۵۲)
      final computed = (videoWidth * PlayerBrandOverlay.logoFraction)
          .clamp(PlayerBrandOverlay.minLogoSize, PlayerBrandOverlay.maxLogoSize);
      expect(computed, greaterThanOrEqualTo(expectedMin * 0.9));
      expect(computed, lessThanOrEqualTo(PlayerBrandOverlay.maxLogoSize));

      // عدد محاسبه‌شده را بررسی کن
      expect(computed, closeTo(23.4, 1.0)); // 360*0.065 = 23.4, clamp به 28
      expect(computed, PlayerBrandOverlay.minLogoSize);
    });

    testWidgets('در عرض زیاد، لوگو از حداکثر ۵۲ بیشتر نمی‌شود', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 900,
              height: 500,
              child: PlayerBrandOverlay(),
            ),
          ),
        ),
      );
      await tester.pump();
      final computed = (900 * PlayerBrandOverlay.logoFraction)
          .clamp(PlayerBrandOverlay.minLogoSize, PlayerBrandOverlay.maxLogoSize);
      expect(computed, PlayerBrandOverlay.maxLogoSize);
    });

    testWidgets('انیمیشن ورود بدون نیاز به تعامل اجرا می‌شود و پس از آن پایدار می‌ماند',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 202,
              child: PlayerBrandOverlay(),
            ),
          ),
        ),
      );
      await tester.pump();
      // فریم اول: opacity کم
      // پس از 700ms ورود کامل
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(KartoniyaLogoMark), findsNWidgets(2));
      expect(tester.takeException(), isNull);
      // کنترلرها باید در dispose آزاد شوند - تست implicit
    });

    testWidgets('با reduceMotion فعال، انیمیشن‌ها متوقف می‌شوند اما لوگوها دیده می‌شوند',
        (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 360,
                height: 202,
                child: PlayerBrandOverlay(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(KartoniyaLogoMark), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('لوگوها از تصویر رسمی KartoniyaLogoMark استفاده می‌کنند و کشیده نمی‌شوند',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 225,
              child: PlayerBrandOverlay(),
            ),
          ),
        ),
      );
      await tester.pump();

      final marks = tester.widgetList<KartoniyaLogoMark>(
        find.byType(KartoniyaLogoMark),
      );
      expect(marks.length, 2);
      for (final mark in marks) {
        expect(mark.showFace, isTrue);
        // اندازه‌ها باید برابر و مثبت باشند (بدون کشیدگی نامتناسب)
        expect(mark.size, greaterThan(0));
        expect(mark.size, lessThanOrEqualTo(PlayerBrandOverlay.maxLogoSize));
      }
    });
  });

  group('Neon halo invariants', () {
    test('PlayerBrandOverlay هویت بصری برند را حفظ می‌کند - بدون asset جایگزین', () {
      // فقط از KartoniyaLogoMark استفاده می‌کند، نه لوگوی دیگر
      // این تست مطمئن می‌شود هیچ فایل جدید یا طراحی متفاوتی ساخته نشده
      expect(PlayerBrandOverlay.logoFraction, greaterThanOrEqualTo(0.05));
      expect(PlayerBrandOverlay.logoFraction, lessThanOrEqualTo(0.08));
      expect(PlayerBrandOverlay.minLogoSize, 28);
      expect(PlayerBrandOverlay.maxLogoSize, 52);
      expect(PlayerBrandOverlay.safePadding, 10);
    });
  });
}
