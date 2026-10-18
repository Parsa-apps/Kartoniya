import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_mascot.dart';

void main() {
  testWidgets(
    'interactive mascot has a clear label and tap reaction',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: KartoniyaMascot(size: 120, reactToTouch: true),
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.label == 'فِلَک؛ برای دیدن واکنش لمس کن',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byType(KartoniyaMascot));
      await tester.pump(const Duration(milliseconds: 180));
      expect(
        tester
            .widgetList<Transform>(find.byType(Transform))
            .any((transform) =>
                (transform.transform.storage[0] - 1).abs() > .001),
        isTrue,
      );
      await tester.pump(const Duration(milliseconds: 220));

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'reduce motion keeps the mascot renderable after touch',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Center(
                child: KartoniyaMascot(size: 120, reactToTouch: true),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(KartoniyaMascot));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(KartoniyaMascot), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
