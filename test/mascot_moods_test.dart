import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/theme/app_motion.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_mascot.dart';

/// هر حالت چهره باید با لایه‌های تازه بدون استثنا ساخته شود؛ این تست
/// جلوی اشتباه در نام فایل یا هندسهٔ چهره‌ها را می‌گیرد.
void main() {
  testWidgets('همهٔ حالت‌های فندوقی بدون خطا ساخته می‌شوند', (tester) async {
    for (final mood in MascotMood.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: KartoniyaMascot(
              width: 120,
              height: 152,
              float: false,
              mood: mood,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));

      expect(tester.takeException(), isNull, reason: 'حالت $mood');
      expect(find.byType(KartoniyaMascot), findsOneWidget);
    }
  });

  testWidgets('افکت‌های حالت با کاهش حرکت خاموش می‌شوند', (tester) async {
    Future<void> pumpMascot({required bool reduced}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MotionScope(
            info: MotionInfo(reduced: reduced),
            child: const Center(
              child: KartoniyaMascot(
                width: 140,
                height: 180,
                float: false,
                mood: MascotMood.sleepy,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }

    await pumpMascot(reduced: false);
    expect(find.text('z'), findsWidgets,
        reason: 'حالت خواب‌آلود باید «z»های شناور داشته باشد.');
    expect(tester.takeException(), isNull);

    await pumpMascot(reduced: true);
    expect(find.text('z'), findsNothing,
        reason: 'با کاهش حرکت هیچ افکت اضافه‌ای نباید اجرا شود.');
    expect(tester.takeException(), isNull);
  });
}
