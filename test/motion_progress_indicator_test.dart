import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/presentation/widgets/motion_progress_indicator.dart';

void main() {
  testWidgets('reduced motion replaces the spinner with a static indicator',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Scaffold(body: MotionProgressIndicator()),
        ),
      ),
    );

    expect(find.byIcon(Icons.hourglass_empty_rounded), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('normal motion keeps the indeterminate progress indicator',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: MotionProgressIndicator()),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
