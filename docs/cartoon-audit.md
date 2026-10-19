# ممیزی کارتون‌ها — 100 رکورد

تاریخ: ۲۰۲۶-۱۰-۱۹ — شاخه: `arena/eedcea27-kartoniya`

## شمارش واقعی (بر اساس `local_cartoon_repository.dart`)

| معیار | تعداد | توضیح |
|---|---|---|
| رکورد کل | 100 | `_verified (8) + _pending (92)` |
| دارای `source: aparat, verification: verified, license: licensed` | 8 | 16 ویدئو با hash متمایز، تست‌شده |
| دارای ویدئوی واقعی قابل پخش (`aparatVideoHash != null`) | 16 اپیزود (8 کارتون) | vsb5i06, z803g86, ddy5427, SfomR, ymji038, rfa2n7f, wyz0s88, g0716gm, l0498kh, ncky1g1, d1391q9, j93q0wf, ywrbs8s, z0666k3, a15fnfv, a02g7w9 |
| دارای پوستر محلی `asset/images/posters/*.webp` | 8 | بقیه 92 از vector fallback استفاده می‌کنند |
| pendingReview (غیرقابل‌پخش) | 92 | `source: pending, verification: pendingReview, isActive:false, videoUrl: https://example.com/pending/...` — عمداً disabled |
| دارای مجوز قابل‌بررسی | 8 | docs/aparat-content.md |
| واقعاً آزمایش‌شده برای پخش (aparatEmbedUri) | 8 کارتون / 16 اپیزود | hash validation regex `^[A-Za-z0-9]+$` |
| نامعتبر/جعلی | 0 | هیچ YouTube/API/scrape/UA forgery وجود ندارد |

## دسته‌بندی‌ها (15)
همه، ماجراجویی، کمدی و خنده‌دار، حیوانات و طبیعت، داستان آموزنده، دوستی و همکاری، تخیلی و فانتزی، انیمیشن کوتاه، کلاسیک، خردسالان، آموزشی، سرگرمی، هنری، علمی، موسیقی

## مدیریت pending
- به‌صورت پیش‌فرض `isActive:true` ولی `episode.isActive:false` و `verification:pendingReview` — در کارت با برچسب «به‌زودی» و در Detail با بنر نارنجی
- لینک `example.com/pending` هرگز به‌عنوان `aparatVideoHash` شناخته نمی‌شود (strict `https://www.aparat.com/v/{hash}` only)
- هیچ hash حدسی یا重复 شمارش نشده

## معماری چندمنبعی
- `ContentSource` enum: aparat/localAsset/creativeCommons/officialPublisher/pending
- `VerificationStatus` enum: verified/pendingReview/draft/disabled — `isPlayable == verified` only
- `CartoonModel.source/verification/license/originalTitle` نگه‌داری داخلی، عدم نمایش در UI (فقط عنوان/توضیح + overlay نئونی)

## محدودیت صادقانه
- برای رسیدن به 100 تأییدشده باید 92 منبع دارای مجوز دیگر (CC-BY, ناشر رسمی، آرشیو آزاد) با بررسی حقوقی جداگانه تأمین شود — در این فاز انجام نشد و عدد واقعی 8 گزارش می‌شود
- هیچ درخواست YouTube ارسال نشده (بررسی grep برای `youtube|youtu.be|googlevideo` در کل lib صفر مورد)
