import 'package:url_launcher/url_launcher.dart';

/// نتیجهٔ تلاش برای بازکردن صفحهٔ رسمی جزیره فندقی.
enum FandoghiStoreLaunchResult { opened, failed }

typedef FandoghiUrlLauncher = Future<bool> Function(
  Uri uri, {
  required LaunchMode mode,
});

/// بازکردن صفحهٔ رسمی ابتدا با Intent اندروید و سپس با روش پیش‌فرض سیستم.
/// در صورت نصب بودن مایکت، سیستم می‌تواند آن را انتخاب کند؛ در غیر این صورت
/// مرورگرِ پیش‌فرض مقصد HTTPS را باز می‌کند.
class FandoghiStoreLauncher {
  FandoghiStoreLauncher({FandoghiUrlLauncher? launch})
      : _launch = launch ?? launchUrl;

  static final Uri storeUri = Uri.parse(
    'https://myket.ir/app/com.parsaapps.amoozesh_fandoghi',
  );

  final FandoghiUrlLauncher _launch;

  Future<FandoghiStoreLaunchResult> open() async {
    try {
      if (await _launch(storeUri, mode: LaunchMode.externalApplication)) {
        return FandoghiStoreLaunchResult.opened;
      }
    } catch (_) {
      // بعضی سیستم‌ها برای Intent ناموفق exception می‌دهند؛ مرورگر را امتحان کن.
    }

    try {
      if (await _launch(storeUri, mode: LaunchMode.platformDefault)) {
        return FandoghiStoreLaunchResult.opened;
      }
    } catch (_) {
      // شکست هر دو روش به UI برمی‌گردد تا پیام موفقیت اشتباه نشان داده نشود.
    }

    return FandoghiStoreLaunchResult.failed;
  }
}
