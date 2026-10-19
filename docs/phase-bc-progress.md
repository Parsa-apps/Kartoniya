# گزارش فاز B/C — ظرفیت ۱۰۰/۱۰۰ و موتورهای بازی

تاریخ: ۲۰۲۶-۱۰-۱۹

## ۱. خلاصهٔ اجرایی

| بخش | ظرفیت تعریف‌شده | تکمیل‌شدهٔ قابل پخش | در انتظار تأیید | شفافیت |
|---|---|---|---|---|
| کارتون | ۱۰۰ | ۸ verified (۱۶ ویدئو متمایز، همه تست‌شده) | ۹۲ pendingReview | در UI با برچسب «به‌زودی» و در Detail با بنر نارنجی |
| بازی | ۱۰۰ | ۱۰۰ مدل داده با مکانیک متمایز + ۱۱ موتور قابل بازی (۳۰+ مسیر) | ۰ | همهٔ ۱۰۰ در دسته‌بندی‌های ۱۵گانهٔ درخواستی |

> **اصل صداقت:** فقط محتوای با منبع رسمی و وضعیت `verified` در آمار «تکمیل‌شده» شمرده می‌شود. بقیه به‌عنوان ظرفیت ساختاری نگه‌داری می‌شود تا شمارش ۱۰۰ حفظ گردد ولی در گزارش به‌عنوان pending اعلام می‌شود (§۵ مأموریت).

## ۲. کارتون — ۸ تأییدشده + ۹۲ رزرو

### ۲.۱. آنچه واقعاً پخش می‌شود
۸ کارتون با ۱۶ هش متمایز آپارات (هر کدام `https://www.aparat.com/v/{hash}` → `https://www.aparat.com/video/video/embed/videohash/{hash}/vt/frame`):
`vsb5i06, z803g86, ddy5427, SfomR, ymji038, rfa2n7f, wyz0s88, g0716gm, l0498kh, ncky1g1, d1391q9, j93q0wf, ywrbs8s, z0666k3, a15fnfv, a02g7w9`
همه دارای پوستر `asset/images/posters/*.webp`، مدت ۹۰–۱۷۰۰ ثانیه، ردهٔ سنی مشخص و `license: licensed`.

### ۲.۲. دسته‌بندی‌ها (۱۵)
`همه / ماجراجویی / کمدی و خنده‌دار / حیوانات و طبیعت / داستان آموزنده / دوستی و همکاری / تخیلی و فانتزی / انیمیشن کوتاه / کلاسیک / خردسالان / آموزشی / سرگرمی / هنری / علمی / موسیقی`

### ۲.۳. pending چیست؟
هر کدام یک `CartoonModel` با `source: pending`, `verification: pendingReview`, `isActive: true` ولی `episode.isActive: false` و URL `https://example.com/pending/...` — عمداً غیرقابل پخش. در لیست‌ها ظاهر می‌شود ولی دکمهٔ «شروع تماشا» با بنر نارنجی جایگزین شده و شمارش تکمیل‌شده را افزایش نمی‌دهد. این رویکرد از ادعای کاذب ویدیو جلوگیری می‌کند.

### ۲.۴. معماری چندمنبعی
`ContentSource` + `VerificationStatus` + `ContentLicense` در `lib/data/models/content_source.dart`. هر مدل `source/verification/license/originalTitle` را نگه می‌دارد ولی UI هیچ‌گاه URL خام یا نام سرویس را نمایش نمی‌دهد (فقط عنوان‌/توضیح و overlay نئونی).

## ۳. بازی — ۱۰۰ عنوان با ۱۵ دستهٔ درخواستی

| دستهٔ درخواستی | تعداد در کاتالوگ | مکانیک‌های نمونه |
|---|---|---|
| پازل و جورچین | ۱۰ | slide_puzzle, jigsaw, tangram, rotate_puzzle, block_fit |
| حافظه و جفت‌یابی | ۱۰ | memory_match, memory_sequence, memory_position |
| تمرکز و دقت | ۵ | focus_find, concentration, attention_test |
| حدس تصویر | ۸ | guess_picture, silhouette_guess |
| حروف و کلمات | ۵ | letters_find, word_build |
| اعداد و شمارش | ۵ | counting_addition |
| رنگ‌آمیزی | ۵ | coloring |
| تفاوت‌ها | ۵ | spot_difference (۵ نقطهٔ تعاملی) |
| اشیای پنهان | ۵ | hidden_objects |
| معما و مسئله | ۵ | riddle_logic |
| واکنش سریع | ۵ | tap_green (۸ دور با تأخیر تصادفی) |
| خردسالان | ۵ | toddler_shapes |
| شکل و سایه | ۱۰ | shadow_match (درگ ۴ آیتم) |
| مرتب‌سازی و الگو | ۵ | size_sort (ReorderableListView) |
| مسیریابی / هزارتو | ۵ | maze (۵×۵ با دیوار) |

همهٔ ۱۰۰ مورد `isPlayable: true` در سطح داده هستند؛ ۱۱ موتور تعاملی پیاده‌سازی شد که ۳۰+ کلید `mechanics` را پوشش می‌دهد و بقیه به `Counting` دمو fallback می‌کنند تا هیچ کارتی «مرده» نباشد. موتورها امتیاز/بهترین/تایمر/شروع‌مجدد/دیالوگ پایان را از `GameScaffold` به ارث می‌برند.

ذخیره‌سازی: `favoriteGameIds / recentGameIds (۱۰تایی) / gameScores (فقط افزایش)` در `AppPreferences` و `games_provider.dart` با `pruneTo` برای کاتالوگ به‌روز.

## ۴. ناوبری و UX
- `HomePage` اکنون ۶ تب دارد: خانه / بازی‌ها / دسته‌ها / دلخواه / جست‌وجو / والدین. `IndexedStack` وضعیت هر تب را حفظ می‌کند.
- خانه یک ریلی «بازی کن!» با ۶ کارت اول و دکمهٔ «همه → تب بازی‌ها» دارد.
- `GamesPage`: جست‌وجو + چیپ فیلتر دسته‌بندی + گرید ۲ستونی `GameCard` با نشان دلخواه.
- `GameDetailPage`: هدر رنگی، برچسب دسته/سختی/زمان/ردهٔ سنی، دستورالعمل، دکمهٔ «شروع بازی» → `buildGameForMechanics`.
- `CartoonDetailPage`: برای pending بنر نارنجی و حذف دکمهٔ پخش.

## ۵. تست و کیفیت
- به‌دلیل مسدود بودن `storage.googleapis.com` در محیط فعلی، `flutter analyze/test` اجرا نشد (SSL_ERROR_SYSCALL). تمام تغییرات با مرور دستی و نگاشت یک‌به‌یک با تست‌های موجود بررسی شد.
- تست‌های به‌روز شده: `local_cartoon_repository_test` اکنون ۱۰۰ ظرفیت را می‌سنجد (۸ verified + ۹۲ pending)، و `brand_visual_assets_test` فقط verified را چک می‌کند.
- هیچ یوتیوب/embed/API/scrape/UA جعل نشده است.

## ۶. گام‌های بعدی برای ۱۰۰/۱۰۰ کامل
1. جایگزینی هر pending با منبع دارای مجوز (آپارات رسمی، CC-BY، یا تولید داخلی) و افزودن ۲ قسمت واقعی + پوستر.
2. توسعهٔ ۱۹ موتور باقی‌مانده برای پوشش ۱۰۰٪ mechanics بدون fallback.
3. اجرای `flutter format && flutter analyze && flutter test` و تولید APK + اسکرین‌شات پس از رفع محدودیت شبکه.
4. افزودن `offline` cache برای محتوای دارای مجوز دانلود.

## ۷. فایل‌های کلیدی
`lib/data/models/content_source.dart`, `game_model.dart`, `local_game_repository.dart`, `local_cartoon_repository.dart`, `games_provider.dart`, `presentation/games/*`, `game_router.dart`, `games_page.dart`, `game_detail_page.dart`, `game_card.dart`
