import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/theme/app_theme.dart';

void main() {
  test('body and display typography use the selected families', () {
    final textTheme = AppTheme.lightTheme.textTheme;

    expect(textTheme.bodyMedium?.fontFamily, AppTheme.fontFamily);
    expect(textTheme.headlineMedium?.fontFamily, AppTheme.headingFontFamily);
    expect(textTheme.titleLarge?.fontFamily, AppTheme.headingFontFamily);
  });

  testWidgets('licensed rounded display weights are bundled', (_) async {
    final bold = await rootBundle.load('asset/fonts/Vazirmatn-RD-Bold.ttf');
    final black = await rootBundle.load('asset/fonts/Vazirmatn-RD-Black.ttf');
    final license = await rootBundle.loadString(
      'asset/fonts/LICENSE-Vazirmatn.txt',
    );

    expect(bold.lengthInBytes, greaterThan(100000));
    expect(black.lengthInBytes, greaterThan(100000));
    expect(license, contains('SIL OPEN FONT LICENSE Version 1.1'));
  });
}
