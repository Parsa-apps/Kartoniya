import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/theme/app_motion.dart';

/// حس لمس فیزیکی: هر سطح تپ‌شدنی هنگام فشردن کمی به داخل صفحه می‌رود.
/// این تست مطمئن می‌شود عمق واقعاً اعمال می‌شود و «کاهش حرکت» آن را خاموش
/// می‌کند (بدون جاگذاشتن انیمیشن نیمه‌کاره).
void main() {
  Widget wrap(Widget child, {bool reduced = false}) => MotionScope(
        info: reduced
            ? const MotionInfo(reduced: true)
            : const MotionInfo(reduced: false),
        child: MaterialApp(
          home: Scaffold(body: Center(child: child)),
        ),
      );

  testWidgets('فشردن سطح، پرسپکتیو و مقیاس ملایم اعمال می‌کند',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        PressableScale(
          onTap: () {},
          child: const SizedBox(width: 120, height: 80),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PressableScale)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final transforms = tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byType(PressableScale),
            matching: find.byType(Transform),
          ),
        )
        .toList();
    expect(transforms, isNotEmpty);
    // بیرونی‌ترین Transform همان ماتریس عمق است؛ ورودی پرسپکتیو آن باید
    // پس از فشردن غیرصفر باشد.
    expect(transforms.first.transform.entry(3, 2), isNot(0));

    await gesture.up();
    await tester.pumpAndSettle();

    final settled = tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byType(PressableScale),
            matching: find.byType(Transform),
          ),
        )
        .toList();
    expect(settled.first.transform.entry(3, 2), 0);
  });

  testWidgets('با کاهش حرکت، فشردن هیچ عمقی ایجاد نمی‌کند', (tester) async {
    await tester.pumpWidget(
      wrap(
        PressableScale(
          onTap: () {},
          child: const SizedBox(width: 120, height: 80),
        ),
        reduced: true,
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PressableScale)),
    );
    await tester.pump();

    final transforms = tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byType(PressableScale),
            matching: find.byType(Transform),
          ),
        )
        .toList();
    expect(transforms.first.transform.entry(3, 2), 0);

    await gesture.up();
    await tester.pumpAndSettle();
  });
}
