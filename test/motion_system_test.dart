import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/theme/app_motion.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_mascot.dart';

void main() {
  testWidgets('app tickers pause in background and resume in foreground',
      (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.rtl,
        child: AppLifecycleTickerMode(child: _TickerModeProbe()),
      ),
    );
    expect(find.text('active'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(find.text('muted'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('active'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('turning on reduced motion completes an active reveal',
      (tester) async {
    await tester.pumpWidget(const _RevealHost(reduced: false));
    await tester.pump(const Duration(milliseconds: 120));
    final before = tester.widget<FadeTransition>(find.byType(FadeTransition));
    expect(before.opacity.value, lessThan(1));

    await tester.pumpWidget(const _RevealHost(reduced: true));
    await tester.pump();
    final after = tester.widget<FadeTransition>(find.byType(FadeTransition));
    expect(after.opacity.value, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mascot reacts to touch and is exposed as a button',
      (tester) async {
    var taps = 0;
    final semanticsHandle = tester.ensureSemantics();
    addTearDown(semanticsHandle.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: KartoniyaMascot(
              size: 96,
              float: false,
              onTap: () => taps++,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // The semantics tree shows what a screen reader receives; the Semantics
    // widget itself only keeps its flags inside SemanticsProperties.
    final mascot = find.byType(KartoniyaMascot);
    expect(
      tester.getSemantics(mascot),
      containsSemantics(
        isButton: true,
        label: 'شخصیت کارتونی فِلَک',
      ),
    );

    await tester.tap(mascot);
    await tester.pump(const Duration(milliseconds: 180));
    expect(taps, 1);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _RevealHost extends StatelessWidget {
  const _RevealHost({required this.reduced});

  final bool reduced;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: MotionScope(
          info: MotionInfo(reduced: reduced),
          child: const StaggeredReveal(
            index: 0,
            child: Text('reveal'),
          ),
        ),
      );
}

class _TickerModeProbe extends StatelessWidget {
  const _TickerModeProbe();

  @override
  Widget build(BuildContext context) =>
      Text(TickerMode.of(context) ? 'active' : 'muted');
}
