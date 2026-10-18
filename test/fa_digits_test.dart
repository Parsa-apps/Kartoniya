import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/core/utils/fa_digits.dart';

void main() {
  group('toFaDigits', () {
    test('ارقام لاتین به فارسی تبدیل می‌شوند', () {
      expect(toFaDigits('4.8'), '۴٫۸');
      expect(toFaDigits('12 دقیقه'), '۱۲ دقیقه');
    });

    test('جداکننده اعشار قابل خاموش‌کردن است', () {
      expect(toFaDigits('4.8', decimalSeparator: false), '۴.۸');
    });

    test('متن بدون رقم دست‌نخورده می‌ماند', () {
      expect(toFaDigits('کارتونیا'), 'کارتونیا');
    });
  });
}
