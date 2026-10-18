/// تبدیل ارقام لاتین به فارسی برای نمایش.
///
/// فقط برای متن‌های نمایشی استفاده شود؛ شناسه‌ها، URLها و اعداد فنی نباید
/// تبدیل شوند. جداکننده اعشار لاتین `.` به ممیز فارسی `٫` تبدیل می‌شود.
library;

const _latinDigits = '0123456789';
const _faDigits = '۰۱۲۳۴۵۶۷۸۹';

String toFaDigits(String input, {bool decimalSeparator = true}) {
  final buffer = StringBuffer();
  for (final unit in input.codeUnits) {
    if (unit == 0x2E && decimalSeparator) {
      buffer.write('٫');
      continue;
    }
    final index = _latinDigits.codeUnits.indexOf(unit);
    if (index >= 0) {
      buffer.writeCharCode(_faDigits.codeUnitAt(index));
    } else {
      buffer.writeCharCode(unit);
    }
  }
  return buffer.toString();
}
