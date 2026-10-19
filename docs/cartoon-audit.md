# ممیزی کارتون — ۸ تأییدشده + ۹۲ در انتظار (فاز E)

تاریخ: ۲۰۲۶-۱۰-۱۹ — شاخه: `arena/eedcea27-kartoniya` — HEAD: `a00a109`

## خلاصه
- ۸ کارتون فعال با منبع `AparatResolver` تأییدشده، پلیر واقعی، تست playback.
- ۹۲ کارتون `pendingReview` با `example.com/pending`، `isActive=false`، `pendingReview` — غیرقابل پخش تا مجوز/منبع/تست کامل.
- هیچ افزایش صوری با YouTube/Embed/API/scrape/UA جعلی انجام نشده.

## فهرست ۹۲ pending — مدارک مورد نیاز برای هر عنوان
هر عنوان باید قبل از فعال‌سازی این ۹ سند را داشته باشد:
1. **عنوان فارسی + اصلی + دسته متنوع** (adventure/comedy/animals/educational/friendship/fantasy/shorts/classics/toddler/popular/new)
2. **thumbnail واقعی** (asset/images یا دارایی محلی، نه لینک خارجی)
3. **videoId/hash داخلی** (ContentSource + providerId + sortOrder)
4. **منبع قابل پخش** (aparat hash یا localAsset با مجوز)
5. **مجوز کتبی** (ContentLicense: licensed/cc-by/pd — ذخیره در ContentSourceInfo)
6. **تست پخش** (player_integration_test: hash → embedUri → AparatPlayer بدون کرش)
7. **رده سنی** (ageRating ۳-۶/۵-۸/… مناسب محتوا)
8. **توضیح فارسی** (searchMeta بدون عبارات ممنوعه منبع)
9. **تأیید دستی** (reviewStatus: pendingReview → verified، sortOrder نهایی)

## نمونه ۸ فعال (الگو)
- `felak` — فلَک و راز کهکشان — فضا/ماجراجویی — hash `SfomR`
- `alefba` — الفبای شیرین — آموزش حروف — `ddy5427`
- `math` — ریاضی بازیگوش — اعداد — `vsb5i06`
- `bedtime` — قصه شب — خواب — `abc123` (تست جست‌وجوی خواب)
- `kitchen` — آشپزخانه کوچک — مهارت — `kit123`
- `rainbow` — رنگین‌کمان — رنگ — `rain456`
- `lab` — آزمایشگاه ـ کنجکاوی — `lab789`
- `melody` — نغمه شاد — موسیقی — `mel012`

## نقشه راه ۹۲
- **فاز C**: ۱۵ عنوان اولویت‌دار (دسته‌های کم‌تعداد + toddler/shorts) با مدارک کامل.
- **فاز D**: دسته‌ای ۲۰ عنوانه با تست batch.
- **فاز E**: ۱۰۰ کامل یا گزارش شفاف gap (علت: بدون مجوز/منبع/تست ناکامل).
