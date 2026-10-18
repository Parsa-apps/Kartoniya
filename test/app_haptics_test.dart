import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/services/app_haptics.dart';

void main() {
  testWidgets('opt-out skips platform haptics and re-enabling restores them',
      (tester) async {
    var platformCalls = 0;
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') platformCalls++;
        return null;
      },
    );
    addTearDown(() {
      AppHaptics.setEnabled(true);
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });

    AppHaptics.setEnabled(false);
    AppHaptics.selection();
    await tester.pump();
    expect(platformCalls, 0);

    AppHaptics.setEnabled(true);
    AppHaptics.selection();
    await tester.pump();
    expect(platformCalls, 1);
  });
}
