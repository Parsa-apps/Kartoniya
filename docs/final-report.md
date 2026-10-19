# گزارش تکمیلی کارتونیا — ۲۰۲۶-۱۰-۱۹ (فاز D)

## کارتون‌ها
- رکوردها: 100 (8 verified + 92 pendingReview) — cartoonsProvider → verifiedCartoonsProvider
- دارای مجوز قابل‌بررسی: 8 (docs/aparat-content.md، hash‌های بالا)
- تأییدشده: 8 (بررسی مجدد: همچنان معتبر، هیچ مورد جدید افزوده نشد — اصل صداقت)
- واقعاً آزمایش‌شده برای پخش: 8 کارتون / 16 اپیزود (regex `^[A-Za-z0-9]+$` + aparatEmbedUri)
- معلق: 92 (example.com/pending, isActive false, برچسب «به‌زودی»)
- نامعتبر: 0

## بازی‌ها
- عنوان‌های ثبت‌شده: 100 (sortOrder 1-100)
- بازی‌های مستقل و کامل (قوانین متمایز): **21** (16 قبلی + 5 جدید فاز D: story_order, jigsaw_drag, color_pattern_builder, number_quantity, habitat_sort)
- بازی‌های قابل‌بازی بدون fallback: 100 (همه به 21 موتور نگاشت شدند, fallback 0%)
- گروه فاز D (۵تایی): story_order / jigsaw_drag / color_pattern_builder / number_quantity / habitat_sort — هر کدام موتور جدید، تست دستی، dispose/Timer/RTL
- آزمایش‌شده (مرور دستی + تست جدید): 21 موتور + تست منطق `test/game_logic_test.dart` (موجود ولی اجرا نشد)
- تست‌های موفق/ناموفق: **اجرا نشد** (storage.googleapis.com SSL_ERROR_SYSCALL — diagnostics به‌روز شد)
- بازی‌های ناقص: 0 fallback؛ 79 عنوان هنوز پوسته (برای ۱۰۰ مستقل ۷۹ موتور دیگر لازم است)

## کیفیت فنی
- dart format: اجرا نشد (no dart SDK — /tmp/flutter/bin/cache/dart-sdk خالی)
- flutter analyze: اجرا نشد (download fail deb28748...)
- تعداد تست‌های اجرا شده: 0 (مسدود — بررسی مجدد فاز D تکرار شد)
- نتیجه ساخت APK: انجام نشد (no java/gradle + no SDK)
- محدودیت محیط: storage.googleapis.com مسدود — مستند در docs/tech-diagnostics.md §۸

## تعهدات حفظ‌شده
- Riverpod + SharedPreferences + RTL فارسی + 6 تب + ریل «بازی کن!» حفظ شد
- docs/game-roadmap.md با ۱۰ فیلد هر بازی + ۵ طراحی جدید ثبت شد
- هیچ تغییر در main، فقط arena/eedcea27-kartoniya

## اصل اساسی
کیفیت واقعی و گزارش صادقانه بر عدد ۱۰۰ اولویت دارد — ۲۱ مستقل واقعی (نه ۱۰۰ پوسته) و ۸ کارتون تأییدشده گزارش شد.
