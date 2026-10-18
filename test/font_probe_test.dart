import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// بررسی می‌کند فونت Vazirmatn باندل‌شده در محیط تست هم واقعاً بارگذاری شود.
///
/// تست‌های ویجت به‌صورت پیش‌فرض فونت جایگزین (جعبه‌ای) دارند؛ اگر ثبت فونت
/// شکست بخورد، اسکرین‌شات‌های رندر‌شده هم متن فارسی را جعبه‌ای نشان می‌دهند.
/// این تست همان مسیر `FontLoader` را اجرا و عرض متن را با فونت پیش‌فرض مقایسه
/// می‌کند تا چنین خطایی در CI دیده شود.
void main() {
  testWidgets('bundled Vazirmatn is actually used for Persian text',
      (tester) async {
    final previous = debugDisableShadows;
    debugDisableShadows = false;
    addTearDown(() => debugDisableShadows = previous);

    await tester.runAsync(() async {
      final loader = FontLoader('Vazirmatn');
      for (final asset in const [
        'asset/fonts/Vazirmatn-Regular.ttf',
        'asset/fonts/Vazirmatn-Medium.ttf',
        'asset/fonts/Vazirmatn-Bold.ttf',
        'asset/fonts/Vazirmatn-Black.ttf',
      ]) {
        final data = await rootBundle.load(asset);
        expect(data.lengthInBytes, greaterThan(40000), reason: asset);
        // ignore: avoid_print
        print('font probe: $asset = ${data.lengthInBytes} bytes');
        loader.addFont(Future.value(data));
      }
      await loader.load();
    });

    double width(String family) {
      final painter = TextPainter(
        text: TextSpan(
          text: 'کارتونیا و فِلَک',
          style: TextStyle(fontFamily: family, fontSize: 20),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      return painter.width;
    }

    final withBundle = width('Vazirmatn');
    final withoutBundle = width('NoSuchFontFamily');
    // ignore: avoid_print
    print('font probe widths: vazirmatn=$withBundle fallback=$withoutBundle');
    expect(
      withBundle,
      isNot(closeTo(withoutBundle, .01)),
      reason: 'فونت باندل‌شده استفاده نشد؛ متن‌ها جعبه‌ای رندر می‌شوند.',
    );
  });
}
