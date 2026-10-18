import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/theme/app_theme.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_logo.dart';

/// بررسی می‌کند فونت Vazirmatn باندل‌شده در محیط تست هم واقعاً بارگذاری و در
/// تم برنامه به‌کار گرفته شود. تست‌های ویجت به‌صورت پیش‌فرض فونت جعبه‌ای
/// دارند؛ اگر این مسیر بشکند، اسکرین‌شات‌های رندر‌شده هم متن فارسی را جعبه‌ای
/// نشان می‌دهند. مقدارهای اندازه‌گیری‌شده چاپ می‌شوند تا در لاگ CI دیده شوند.
void main() {
  testWidgets('bundled Vazirmatn is applied to the real app theme',
      (tester) async {
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
        loader.addFont(Future.value(data));
      }
      await loader.load();
    });

    double measure(String family, String text, double fontSize) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(fontFamily: family, fontSize: fontSize),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      return painter.width;
    }

    const sample = 'دنیای شاد و امن کودکان';
    final bundled = measure('Vazirmatn', sample, 24);
    final fallback = measure('NoSuchFontFamily', sample, 24);
    // ignore: avoid_print
    print('font probe: vazirmatn=$bundled fallback=$fallback');
    expect(bundled, isNot(closeTo(fallback, .01)));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('fa', 'IR'),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(child: KartoniyaWordmark(markSize: 40)),
          ),
        ),
      ),
    );
    await tester.pump();

    final finder = find.text('دنیای شاد و امن کودکان');
    expect(finder, findsOneWidget);
    final paragraph = tester.renderObject<RenderParagraph>(finder);
    final family = paragraph.text.style?.fontFamily;
    // ignore: avoid_print
    print('font probe: app text family=$family width=${paragraph.size.width}');
    expect(family, 'Vazirmatn');
  });
}
