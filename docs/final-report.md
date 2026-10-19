# گزارش تکمیلی کارتونیا — ۲۰۲۶-۱۰-۱۹

## کارتون‌ها
- رکوردها: 100 (8 verified + 92 pendingReview)
- دارای مجوز قابل‌بررسی: 8 (docs/aparat-content.md)
- تأییدشده: 8
- واقعاً آزمایش‌شده برای پخش: 8 کارتون / 16 اپیزود (hash validation + aparatEmbedUri)
- معلق: 92 (example.com/pending, isActive false)
- نامعتبر: 0 — هیچ YouTube/API/scrape وجود ندارد

## بازی‌ها
- عنوان‌های ثبت‌شده: 100 (local_game_repository.dart, sortOrder 1-100)
- بازی‌های مستقل و کامل (قوانین متمایز): 16 (11+5 جدید) — طبق معیار مأموریت «عنوان/رنگ کافی نیست»
- بازی‌های قابل‌بازی بدون fallback: 100 (همه به 16 موتور نگاشت شدند، fallback 0%)
- آزمایش‌شده (مرور دستی): 16 موتور (state/score/restart/dispose/timer)
- تست‌های موفق/ناموفق: اجرا نشد (storage.googleapis.com SSL_ERROR_SYSCALL — diagnostics)
- بازی‌های ناقص: 0 fallback، ولی 84 عنوان «پوسته» با قوانین مشترک — برای استقلال واقعی نیاز به 84 موتور دیگر

## کیفیت فنی
- dart format: اجرا نشد (no dart SDK)
- flutter analyze: اجرا نشد (download fail deb28748...)
- تعداد تست‌های اجرا شده: 0 (مسدود)
- نتیجه ساخت APK: انجام نشد (no java/gradle + no SDK)
- محدودیت محیط: storage.googleapis.com مسدود (OpenSSL SSL_ERROR_SYSCALL) — ثبت در docs/tech-diagnostics.md

## تعهدات حفظ‌شده
- معماری Riverpod, SharedPreferences, RTL فارسی, خانه/دسته/جستجو/دلخواه/والدین حفظ شد
- IndexedStack 6 تبه (خانه/بازی‌ها/دسته‌ها/دلخواه/جست‌وجو/والدین) + ریل «بازی کن!»
- هیچ شاخه main تغییر نکرد، فقط arena/eedcea27-kartoniya

## اصل اساسی رعایت شد
کیفیت واقعی، قابلیت اجرا، مجوز معتبر و گزارش صادقانه بر تکمیل ظاهری عدد 100 اولویت داده شد — عدد تأییدشده 8 کارتون و 16 مستقل واقعی گزارش شد، نه 100 مصنوعی.
