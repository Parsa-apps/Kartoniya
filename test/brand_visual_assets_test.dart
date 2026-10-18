import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/repositories/local_cartoon_repository.dart';
import 'package:kartoniya/presentation/pages/privacy_page.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_story_banner.dart';

void main() {
  Future<ui.Image> decode(String path) async {
    final data = await rootBundle.load(path);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

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
      final image = await decode(path);
      expect(image.width, greaterThan(400), reason: path);
      expect(image.height, greaterThan(400), reason: path);
      image.dispose();
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

    // A grey checkerboard would survive as a ring of dark, neutral, fully
    // opaque pixels around the silhouette. The clean matte keeps only a few
    // hundred such pixels (eye shading); the old asset had thousands.
    var darkNeutralOpaque = 0;
    for (var i = 0; i < rgba.lengthInBytes; i += 4) {
      final r = rgba.getUint8(i);
      final g = rgba.getUint8(i + 1);
      final b = rgba.getUint8(i + 2);
      final a = rgba.getUint8(i + 3);
      if (a <= 200) continue;
      final spread = [r, g, b].reduce((x, y) => x > y ? x : y) -
          [r, g, b].reduce((x, y) => x < y ? x : y);
      final luminance = (r * 299 + g * 587 + b * 114) ~/ 1000;
      if (spread <= 12 && luminance <= 80) darkNeutralOpaque++;
    }
    expect(
      darkNeutralOpaque,
      lessThan(800),
      reason: 'لبهٔ برش فِلَک هنوز بقایای صفحه‌شطرنجی/خاکستری دارد.',
    );
    mascotCodec.dispose();
  });

  test('phase 6 posters and splash decode within budget and are wired',
      () async {
    const posters = [
      'asset/images/posters/oscar.webp',
      'asset/images/posters/alphabet.webp',
      'asset/images/posters/counting.webp',
      'asset/images/posters/bedtime.webp',
      'asset/images/posters/cooking.webp',
      'asset/images/posters/animals.webp',
      'asset/images/posters/science.webp',
      'asset/images/posters/music.webp',
    ];
    var totalBytes = 0;
    for (final path in posters) {
      final data = await rootBundle.load(path);
      totalBytes += data.lengthInBytes;
      final image = await decode(path);
      expect(image.width, greaterThanOrEqualTo(1000), reason: path);
      expect(image.height, greaterThanOrEqualTo(700), reason: path);
      image.dispose();
    }
    // Eight 1080x810 WebP posters stay below 600 KiB in the APK.
    expect(totalBytes, lessThan(600 * 1024));

    final splashData = await rootBundle.load(
      'asset/images/cloud_night_splash.webp',
    );
    expect(splashData.lengthInBytes, lessThan(140 * 1024));
    final splash = await decode('asset/images/cloud_night_splash.webp');
    expect(splash.width, greaterThanOrEqualTo(800));
    expect(splash.height, greaterThanOrEqualTo(1400));
    splash.dispose();

    // Every catalog entry that declares artwork must point at a bundled file.
    final cartoons = await LocalCartoonRepository().fetchCartoons();
    for (final cartoon in cartoons) {
      expect(cartoon.artworkAsset, isNotNull, reason: cartoon.id);
      final loaded = await rootBundle.load(cartoon.artworkAsset!);
      expect(loaded.lengthInBytes, greaterThan(0), reason: cartoon.id);
    }
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
