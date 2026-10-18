import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
