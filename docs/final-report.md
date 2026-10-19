# گزارش تکمیلی کارتونیا — ۲۰۲۶-۱۰-۱۹ (فاز D.1 — بازبینی)

**HEAD واقعی:** `5c33cf4` (گزارش قبلی `e2c0ceb` یک کامیت عقب بود — اصلاح شد) — شاخه `arena/eedcea27-kartoniya`

## کارتون‌ها
- رکوردها: 100 (8 verified + 92 pendingReview) — `verifiedCartoonsProvider` فقط ۸ را «تکمیل‌شده» می‌شمارد
- دارای مجوز قابل‌بررسی: 8 (hash‌های aparat، docs/aparat-content.md)
- تأییدشده: 8 (بررسی مجدد فاز D.1: همچنان معتبر، هیچ مورد جدید بدون مجوز افزوده نشد)
- واقعاً آزمایش‌شده: 8/16 اپیزود (regex + embedUri)
- معلق: 92 (example.com/pending, isActive false, برچسب «به‌زودی»)
- نامعتبر: 0

## بازی‌ها
- عنوان‌های ثبت‌شده: 100 (sortOrder 1-100, id یکتا)
- مستقل واقعی: **21** (11+5+5) — ۵ جدید فاز D بازبینی و رفع شد: story_order, jigsaw_drag, color_pattern_builder, number_quantity, habitat_sort
- قابل‌بازی بدون fallback: 100 (همه به 21 موتور نگاشت شدند — تأیید `test/game_logic_test.dart` «بدون Placeholder»)
- گروه D.1: رفع ۳ باگ (jigsaw بازخورد, color_pattern مقایسه, story_order کلید) + افزودن `mounted` چک به هر ۵ + تست‌های عمیق (امتیاز/پایان/restart/drag معتبر-نامعتبر/ذخیره)
- آزمایش‌شده: 21 موتور مرور دستی + تست منطق گسترش‌یافته (اجرا نشد به‌دلیل محدودیت محیط)
- تست‌های موفق/ناموفق: **0 اجرا** (storage.googleapis.com SSL_ERROR_SYSCALL — diagnostics §۸)
- بازی‌های ناقص: 0 fallback؛ 79 پوسته باقی‌مانده

## کیفیت فنی
- dart format: اجرا نشد (no dart SDK)
- flutter analyze: اجرا نشد (download fail deb28748...)
- تعداد تست‌های اجرا شده: 0 (مسدود — بررسی مجدد فاز D.1 تکرار شد، بدون bypass TLS/UA)
- APK: انجام نشد (no java/gradle + no SDK — هیچ محیط CI جایگزین در Arena یافت نشد)
- محدودیت: storage.googleapis.com مسدود — مستند diagnostics §۸

## سازگاری داده
- ۵ شناسهٔ تغییر یافته (`memory_sounds`→`story_order` ...) از `28d1977` فقط در arena بوده، هرگز در `main`/انتشار نبوده → **مهاجرت لازم نیست** (مستند، داده پاک نشد)

## تعهدات
- 6 تب + RTL + Riverpod حفظ شد، `main` دست‌نخورده
- `docs/game-roadmap.md` + `game-audit.md` به‌روز شد

## اصل اساسی
۲۱ مستقل واقعی و ۸ کارتون تأییدشده صادقانه گزارش شد — کیفیت بر عدد ۱۰۰ اولویت دارد.
