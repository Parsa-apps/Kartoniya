# عیب‌یابی فنی — عدم اجرای `flutter analyze/test/apk`

تاریخ: ۲۰۲۶-۱۰-۱۹ — محیط: Arena sandbox `e2b`

## 1. وضعیت SDK
- `which flutter` → `/tmp/flutter/bin/flutter` (clone از `stable`)
- `flutter --version` → تلاش برای دانلود Dart SDK `deb287481...` و شکست
- `java -version` → not found
- `gradle --version` → not found
- `dart --version` → not found (وابسته به Flutter SDK)
- `cache/dart-sdk` → خالی (2 فایل stamp/realm، بدون bin/dart)

## 2. خطای دقیق
```
Downloading Linux x64 Dart SDK from Flutter engine deb287481e3ce9468f3434937ced4240a70539ca...
curl: (35) OpenSSL SSL_connect: SSL_ERROR_SYSCALL in connection to storage.googleapis.com:443
```
- تکرارپذیر در هر `flutter analyze`, `flutter pub get`, `dart analyze`, `flutter test`
- `curl -I https://storage.googleapis.com` → همان `SSL_ERROR_SYSCALL`
- `env` → هیچ proxy تنظیم نشده
- `hosts` → فقط localhost/e2b

## 3. علت محتمل
- فایروال محیط اجازهٔ اتصال به `storage.googleapis.com` (محل میزبانی Dart SDK و pub packages) را نمی‌دهد — در حالی که `github.com, registry.npmjs.org, pypi.org` مجازند (طبق محدودیت اولیه task)
- بنابراین `pub get` و دانلود `Dart SDK` مسدود است — نه مشکل پروژه

## 4. آنچه امتحان شد (بدون دور زدن امنیتی)
- استفاده از cache موجود (`/tmp/flutter/bin/cache/dart-sdk.old` خالی بود)
- بررسی `~/.pub-cache` → وجود ندارد
- عدم دست‌کاری `pubspec.lock`, امضا یا تنظیمات امنیتی برای bypass
- عدم اعلام تست موفق بدون اجرا

## 5. نتایج واقعی دستورات
- `dart format` → اجرا نشد (no dart binary)
- `flutter analyze` → اجرا نشد (SDK missing)
- `flutter test` → اجرا نشد
- `flutter build apk` → اجرا نشد (no SDK + no java/gradle)

## 6. کارهای جایگزین انجام‌شده
- مرور دستی تمام فایل‌های جدید (imports, ConsumerState, dispose, mounted)
- نگاشت 1:1 تست‌های موجود با تغییرات (به‌روزرسانی `local_cartoon_repository_test` برای 100 ظرفیت)
- بررسی `grep -r youtube` → 0 مورد

## 7. باقی‌مانده
- پس از رفع محدودیت شبکه: `dart format . && flutter analyze && flutter test && flutter build apk` باید با خروجی واقعی گزارش شود
- نصب `openjdk-17` و `gradle` برای ساخت APK
