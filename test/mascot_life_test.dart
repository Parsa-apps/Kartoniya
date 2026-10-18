import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/theme/app_motion.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_mascot.dart';

/// نگهبان «زنده بودن» فندوقی: نفس/تاب برگ حتی بدون شناوری، و ایست کامل
/// وقتی کاربر «کاهش حرکت» را روشن کرده است.
void main() {
  Widget host({
    required bool reduced,
    required double width,
    required double height,
  }) {
    return MaterialApp(
      home: MotionScope(
        info: MotionInfo(reduced: reduced),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: RepaintBoundary(
              child: KartoniyaMascot(
                width: width,
                height: height,
                float: false,
                entrance: false,
                greet: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ماتریس همهٔ ترنسفورم‌های داخلی ریگ؛ با تغییر هر لایه عوض می‌شود.
  List<String> pose(WidgetTester tester) => tester
      .widgetList<Transform>(
        find.descendant(
          of: find.byType(KartoniyaMascot),
          matching: find.byType(Transform),
        ),
      )
      .map(
        (transform) => transform.transform.storage
            .map((value) => value.toStringAsFixed(5))
            .join(','),
      )
      .toList();

  testWidgets('بدون شناوری هم چرخهٔ آیدل برگ و بدن را حرکت می‌دهد',
      (tester) async {
    await tester.pumpWidget(host(reduced: false, width: 140, height: 180));
    await tester.pump(const Duration(milliseconds: 200));
    final first = pose(tester);
    expect(first, isNotEmpty);

    await tester.pump(const Duration(milliseconds: 900));
    expect(
      pose(tester),
      isNot(equals(first)),
      reason: 'تاب برگ/نفس باید حتی با float:false هم ادامه داشته باشد.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('با کاهش حرکت، ریگ بین دو فریم کاملاً ثابت می‌ماند',
      (tester) async {
    await tester.pumpWidget(host(reduced: true, width: 140, height: 180));
    await tester.pump(const Duration(milliseconds: 200));
    final first = pose(tester);

    await tester.pump(const Duration(milliseconds: 900));
    expect(
      pose(tester),
      equals(first),
      reason: 'کاهش حرکت نباید هیچ لرزش یا تکان باقی بگذارد.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('اندازه‌های خیلی کوچک و کشیده هم بدون خطا رندر می‌شوند',
      (tester) async {
    for (final size in const [
      Size(40, 44),
      Size(240, 60),
      Size(60, 240),
      Size(320, 348),
    ]) {
      await tester.pumpWidget(
        host(reduced: false, width: size.width, height: size.height),
      );
      await tester.pump(const Duration(milliseconds: 250));
      expect(
        tester.takeException(),
        isNull,
        reason: 'رندر فندوقی در اندازهٔ ${size.width}×${size.height}',
      );
      expect(
        tester.getSize(find.byType(KartoniyaMascot)),
        size,
        reason: 'شخصیت باید دقیقاً داخل جعبهٔ خواسته‌شده بماند.',
      );
    }
  });
}
