import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/presentation/pages/privacy_page.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_story_banner.dart';

void main() {
  test('bundled 3D stills decode within the mobile asset budget', () async {
    const assets = [
      'asset/images/flak_3d.webp',
      'asset/images/flak_reading_scene.webp',
      'asset/images/cloudworld_hero.webp',
      'asset/images/storybook_garden.webp',
      'asset/images/twilight_library.webp',
    ];
    var totalBytes = 0;

    for (final path in assets) {
      final data = await rootBundle.load(path);
      totalBytes += data.lengthInBytes;
      final bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(400), reason: path);
      expect(frame.image.height, greaterThan(400), reason: path);
      codec.dispose();
    }

    expect(totalBytes, lessThan(300 * 1024));

    final mascotData = await rootBundle.load(PreRenderedFlak.assetPath);
    final mascotBytes = mascotData.buffer.asUint8List(
      mascotData.offsetInBytes,
      mascotData.lengthInBytes,
    );
    final mascotCodec = await ui.instantiateImageCodec(mascotBytes);
    final mascotFrame = await mascotCodec.getNextFrame();
    final rgba = await mascotFrame.image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    expect(rgba, isNotNull);
    // The cut-out has real alpha, not a checkerboard baked into the image.
    expect(rgba!.getUint8(3), 0);
    mascotCodec.dispose();
  });

  testWidgets('world banner exposes an action and renders its Persian copy',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: KartoniyaStoryBanner(
                title: 'امروز کجا بریم؟',
                subtitle: 'یک قصهٔ تازه همیشه منتظر توست.',
                actionLabel: 'بزن بریم',
                onAction: () => taps++,
                height: 190,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('امروز کجا بریم؟'), findsOneWidget);
    expect(find.text('بزن بریم'), findsOneWidget);
    await tester.tap(find.text('بزن بریم'));
    await tester.pump();
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('privacy page distinguishes local settings from video hosting',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PrivacyPage()),
    );
    await tester.pump();

    expect(find.text('حریم خصوصی'), findsOneWidget);
    expect(find.text('چه چیزهایی روی همین دستگاه می‌ماند؟'), findsOneWidget);
    expect(find.text('هنگام پخش چه ارتباطی برقرار می‌شود؟'), findsOneWidget);
    expect(find.textContaining('IP'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
