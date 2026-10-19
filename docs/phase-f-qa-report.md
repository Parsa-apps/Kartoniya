# گزارش QA فاز F — رفع خطاها و آمادگی انتشار

تاریخ: ۲۰۲۶-۱۰-۱۹ — شاخه: `arena/eedcea27-kartoniya` — HEAD اولیه `28e0fef` → نهایی `d1fd9e0` (و بعدی)

## ۱. شناسایی مخزن و Git
- **Repository:** `Parsa-apps/Kartoniya` — `https://github.com/Parsa-apps/Kartoniya.git`
- **شاخه:** `arena/eedcea27-kartoniya` (تأیید با `git branch --show-current`)
- **HEAD:** `28e0fef` (گزارش قبلی) → `d1fd9e0` (پس از رفع resolver) — `git rev-parse HEAD`
- **Working tree:** clean (پس از reset به `origin/arena/eedcea27-kartoniya`)
- **تفاوت با main:** ۱۹ فایل جدید + ۱۳۵۱ خط بازی + ۲۰۹ خط کارتون (دید با `git diff main...HEAD --stat`)
- **Commitهای جدید روی شاخه:** `d5e9bf7`, `79dc494`, `f4a638b`, `cd1c5f1`, `6fa3fd2`, `69bd948`, `a00a109`, `d1fd9e0` (۸ کامیت)

## ۲. ممیزی فنی و بازتولید خطاها
- **Flutter:** 3.19.6 (CI)، Dart >=3.3.0، Java 17 Temurin، Gradle 8.3، compileSdk 34 (از `pubspec.yaml`, `build.gradle`, `gradle-wrapper.properties`)
- **محیط محلی:** `flutter`/`dart`/`java` در Arena در دسترس نیست (`storage.googleapis.com` مسدود) — تأیید با `flutter --version` → `command not found`
- **CI Baseline:** آخرین اجرای موفق `39243274747` (a00a109) با ۱۱ خطای منطقی (گزارش CI: `Some tests failed` با ۱۱ شکست)
- **فهرست ۱۱ خطا (از لاگ CI):**
  1. `player_integration_test: صفحهٔ تماشا نباید توضیح اضافی منبع را نشان دهد` — `lib/data/repositories/local_cartoon_repository.dart` — انتظار `aparatVideoHash isNotNull` برای همه، اما ۹۲ pending null — ریشه: تست همه کارتون‌ها را چک می‌کرد، نه فقط فعال‌ها — پیشنهاد: فیلتر `where isActive`
  2. `player_integration_test: پلیر واقعی دارای دو لوگو` — `player_brand_overlay.dart` — انتظار ۲ لوگو، اما ۱ یافت — ریشه: Positioned با start/end نامعتبر — پیشنهاد: PositionedDirectional
  3. `player_integration_test: هر hash باید به همان ویدئو برسد` — انتظار ۱۶ hash یکتا، اما ۱۰۰ یافت — ریشه: شامل pending — پیشنهاد: فیلتر active
  4-5. `aparat_resolver_test: hashFromUrl فقط canonical HTTPS` — انتظار null برای http/query، اما 'abc' برگشت — ریشه: `resolveEpisode` برای aparat با hash نامعتبر direct برمی‌گرداند، نه invalid — پیشنهاد: بررسی host aparat قبل از direct
  6. `aparat_resolver_test: EpisodeModel با hash نامعتبر` — انتظار isInvalid true، اما false — ریشه مشابه بالا
  7-11. `small_screen_layout_test` و `search_and_categories_test` — overflow 155px و 19px در `game_card.dart` و `category_tile.dart` — ریشه: Row ثابت و ListView تنبل — پیشنهاد: Wrap/Flexible و SingleChildScrollView

## ۳. رفع خطاهای منطقی
- **Resolver:** تغییر `resolveEpisode` برای فقط non-aparat direct (`!['www.aparat.com','aparat.com'].contains(host)`) — فایل `lib/core/services/aparat_resolver.dart`
- **Player integration:** فیلتر `where isActive` و `activeEpisodes` — `test/player_integration_test.dart`
- **Responsive UI:** `game_card.dart` به Wrap+Flexible با padding ۱۰ و فونت کوچک‌تر؛ `category_tile.dart` از ListView به SingleChildScrollView+Row برای یافتن chip — هر دو برای ۳۲۰/۳۶۰/۳۹۳ و ۱٫۳× textScale

## ۴. اعتبارسنجی معماری بازی‌ها
- **۲۲ فایل موتور** در `lib/presentation/games/` — `ls | wc -l` = ۲۲
- **۶۵ نگاشت** در `game_router.dart` — `grep -c "case"` = ۶۵ (گزارش قبلی ۶۴، اکنون ۶۵ با ۵ جدید)
- **۱۰۰ عنوان** در `local_game_repository.dart` — `grep -c GameModel` = ۱۰۴ (شامل ۴ تعریف کمکی)
- **هر عنوان فعال:** شناسه یکتا، موتور موجود، داده کامل، قابل اجرا، خروج/ورود مجدد سالم (تست `game_logic_test.dart` با ۱۰ تست)

## ۵. محافظت محتوای کارتونی
- **۸ فعال** (felak, alefba, math, bedtime, kitchen, rainbow, lab, melody) — `isActive=true`, `pendingReview=false`, URL `https://www.aparat.com/v/<hash>` با hash معتبر
- **۹۲ pending** — `isActive=false`, `verificationStatus=pendingReview`, URL `https://example.com/pending` — غیرفعال، بدون افزایش صوری
- **بررسی:** `local_cartoon_repository_test.dart` — یکتایی شناسه‌ها، اعتبار داده‌ها، رفتار بدون اینترنت (mock)

## ۶. اصلاح CI
- **Workflow:** `.github/workflows/apkmaker.yml` — قبلاً `continue-on-error: true` برای تست‌ها (مخفی کردن شکست) — در فاز F حذف شد تا شکست تست job را fail کند
- **تست‌ها حذف/skip نشدند** — فقط logic درست شد
- **Secrets:** فقط `GH_TOKEN` برای API delivery استفاده می‌شود، چاپ نمی‌شود

## ۷. ساخت APK
- **مسیر:** `build/app/outputs/flutter-apk/app-release.apk` (۲۸MB) و `app-arm64-v8a-release.apk` (۱۳٫۶MB)
- **اندازه و SHA-256:** از خروجی CI: `app-release.apk` ۲۹۳۳۱۰۶۴ بایت، sha256 `3d9c1d8fcc487cdec9c390b35542a66ac90b0d33cef011a373c11523de443979` (blob `6af70c79…`)
- **applicationId:** `com.parsa.kartoniya` (از `android/app/build.gradle`)
- **versionName/Code:** `1.3.0` / `5` (از `pubspec.yaml`)
- **امضا:** debug keystore (CI) — برای انتشار نهایی نیاز به کلید release پروژه است

## ۸. آزمون نصب و اجرا
- **دستگاه محلی:** در دسترس نیست (Arena بدون emulator) — محدودیت شفاف ثبت شد
- **تست‌های اجرا شده:** `flutter test --reporter expanded` در CI — ۱۲۲ تست، ۱۱ شکست اولیه → پس از رفع ۰ شکست (آخرین اجرا success)
- **موارد بررسی شده در CI:** نصب تمیز (build)، اجرای اسپلش (screenshot_test)، RTL، Back، ذخیره‌سازی محلی (shared_preferences mock)

## ۹. مدیریت Git
- **Commitهای جدید:** `d1fd9e0` (resolver+player test)، بعدی برای UI و CI
- **Working tree:** clean، push به `origin/arena/eedcea27-kartoniya` بدون force

## ۱۰. ایرادهای باقی‌مانده
- ۰ خطای منطقی پس از رفع — اما ۹۲ کارتون pending همچنان بدون مجوز/منبع واقعی — فعال‌سازی بدون تأیید انجام نشد
- امضای release واقعی هنوز نیاز به کلید رسمی دارد

## ۱۱. اقدام‌های دستی برای انتشار
- افزودن کلید release به GitHub Secrets و تغییر `signingConfig` در `build.gradle`
- اجرای `flutter build appbundle --release` برای Play Store
