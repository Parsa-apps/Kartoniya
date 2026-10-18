import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/services/app_haptics.dart';
import 'package:kartoniya/presentation/widgets/gradient_button.dart';

void main() {
  testWidgets('loading and disabled buttons cannot invoke their action',
      (tester) async {
    AppHaptics.setEnabled(false);
    addTearDown(() => AppHaptics.setEnabled(true));
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GradientButton(
              label: 'ادامهٔ تماشا',
              icon: Icons.play_arrow_rounded,
              onPressed: () => taps++,
              loading: true,
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(GradientButton));
    await tester.pump();
    expect(taps, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GradientButton(
              label: 'غیرفعال',
              onPressed: null,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(GradientButton));
    await tester.pump();
    expect(taps, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('focused button exposes a focus ring and keyboard activation',
      (tester) async {
    AppHaptics.setEnabled(false);
    addTearDown(() => AppHaptics.setEnabled(true));
    var taps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GradientButton(
              label: 'پخش',
              onPressed: () => taps++,
            ),
          ),
        ),
      ),
    );

    final button = find.byType(GradientButton);
    final focus = tester
        .widgetList<Focus>(
          find.descendant(of: button, matching: find.byType(Focus)),
        )
        .first;
    focus.focusNode!.requestFocus();
    await tester.pump();

    final decoration = tester
        .widgetList<AnimatedContainer>(
          find.descendant(
            of: button,
            matching: find.byType(AnimatedContainer),
          ),
        )
        .first
        .decoration as BoxDecoration;
    expect((decoration.border! as Border).top.width, 2);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });
}
