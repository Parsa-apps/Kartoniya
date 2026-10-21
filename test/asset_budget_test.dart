import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// بودجهٔ واقعی دارایی‌های تصویری.
///
/// این تست از خودِ فایل‌های مخزن می‌خواند تا «سبک ماندن بستهٔ اپ» به یک قانون
/// قابل اجرا تبدیل شود، نه یک آرزو در مستندات:
/// - هیچ تصویری بیش از [maxFileBytes] نباشد (تصویر بزرگ = حافظهٔ decode و
///   حجم APK بیشتر)؛
/// - مجموع تصاویر از [maxTotalBytes] بیشتر نشود؛
/// - هیچ تصویری در بستهٔ اپ «یتیم» نماند؛ یعنی نامش در `lib/` یا در تست‌ها
///   استفاده نشده باشد. (این مورد قبلاً سه فایل مرده و ۱۰۳ KiB حجم بی‌مصرف
///   را پنهان کرده بود.)
/// - هر فایل موجود در پوشه‌های asset یک WebP معتبر (امضای RIFF/WEBP) باشد تا
///   فایل خراب یا نیمه‌ساخته وارد بسته نشود.
void main() {
  const imageDir = 'asset/images';
  const maxFileBytes = 260 * 1024;
  const maxTotalBytes = 1700 * 1024;

  /// مسیرهای مجاز که عمداً فقط در مستندات/اعتبارنامه ذکر شده‌اند؛ نباید اینجا
  /// چیزی باشد. اگر روزی لازم شد، دلیلش باید همین‌جا نوشته شود.
  const documentedAllowList = <String>{};

  List<File> imageFiles() {
    final dir = Directory(imageDir);
    expect(dir.existsSync(), isTrue, reason: 'پوشهٔ تصاویر پیدا نشد');
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.webp'))
        .toList(growable: false);
  }

  String dartSources(String folder) {
    final buffer = StringBuffer();
    for (final entity in Directory(folder).listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        buffer.writeln(entity.readAsStringSync());
      }
    }
    return buffer.toString();
  }

  test('هر دارایی تصویری سبک و معتبر است و مجموع در بودجه می‌ماند', () {
    final files = imageFiles();
    expect(files, isNotEmpty);

    var total = 0;
    final oversized = <String>[];
    final broken = <String>[];

    for (final file in files) {
      final bytes = file.readAsBytesSync();
      total += bytes.length;
      if (bytes.length > maxFileBytes) {
        oversized.add('${file.path} → ${(bytes.length / 1024).round()} KiB');
      }
      final isWebp = bytes.length > 12 &&
          String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
          String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
      if (!isWebp) broken.add(file.path);
    }

    expect(broken, isEmpty, reason: 'فایل WebP معتبر نیست');
    expect(
      oversized,
      isEmpty,
      reason: 'تصویر بزرگ‌تر از بودجهٔ $maxFileBytes بایت',
    );
    expect(
      total,
      lessThan(maxTotalBytes),
      reason: 'مجموع ${(total / 1024).round()} KiB از بودجهٔ '
          '${(maxTotalBytes / 1024).round()} KiB بیشتر است',
    );
  });

  test('هیچ تصویری در بستهٔ اپ بی‌استفاده (یتیم) نمانده است', () {
    final libSources = dartSources('lib');
    final testSources = dartSources('test');
    final orphans = <String>[];

    for (final file in imageFiles()) {
      final name = file.uri.pathSegments.last;
      if (documentedAllowList.contains(name)) continue;
      final used = libSources.contains(name) || testSources.contains(name);
      if (!used) orphans.add(file.path);
    }

    expect(
      orphans,
      isEmpty,
      reason: 'این فایل‌ها در lib/ و test/ استفاده نمی‌شوند و فقط حجم '
          'بسته را زیاد می‌کنند',
    );
  });

  test('هر پوشهٔ asset اعلام‌شده در pubspec واقعاً وجود دارد', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final matches = RegExp(r'^\s*-\s*(asset/[^\s#]+)', multiLine: true)
        .allMatches(pubspec)
        .map((match) => match.group(1)!.trim())
        .toList();

    expect(matches, isNotEmpty, reason: 'هیچ asset در pubspec اعلام نشده');
    for (final declared in matches) {
      final path = declared.endsWith('/')
          ? declared.substring(0, declared.length - 1)
          : declared;
      final exists = Directory(path).existsSync() || File(path).existsSync();
      expect(exists, isTrue, reason: 'مسیر اعلام‌شده وجود ندارد: $declared');
    }
  });
}
