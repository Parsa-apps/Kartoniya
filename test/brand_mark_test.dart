import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_logo.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_mascot.dart';

/// نشان برند از این پس پرترهٔ فندوقی است؛ این تست مطمئن می‌شود کاشی برند
/// همیشه تصویر شخصیت را نشان دهد و نسخهٔ برداری قبلی هم قابل بازگشت باشد.
void main() {
  testWidgets('نشان برند پرترهٔ فندوقی را داخل کاشی نشان می‌دهد',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: KartoniyaLogoMark(size: 96, showOrbit: true)),
        ),
      ),
    );
    await tester.pump();

    final image = tester.widget<Image>(
      find.descendant(
        of: find.byType(KartoniyaLogoMark),
        matching: find.byType(Image),
      ),
    );
    final provider = image.image;
    final assetName = provider is ResizeImage
        ? (provider.imageProvider as AssetImage).assetName
        : (provider as AssetImage).assetName;
    expect(assetName, FandaqAssets.faceMark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('نسخهٔ برداری قبلی با showFace:false برمی‌گردد', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: KartoniyaLogoMark(size: 56, showFace: false)),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(KartoniyaLogoMark),
        matching: find.byType(Image),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
