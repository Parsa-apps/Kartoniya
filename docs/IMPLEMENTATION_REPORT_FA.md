# گزارش پیاده‌سازی — بازطراحی سیستم پخش کارتونیا

تاریخ: 2026-10-19  
شاخه: `arena/eedcea27-kartoniya`  
نسخهٔ پایه: `1.3.0+5` (commit 5c76e3d)

---

## ۱. فایل‌های تغییر‌یافته / ایجاد‌شده

| فایل | نوع | توضیح |
|---|---|---|
| `lib/data/models/cartoon_model.dart` | ویرایش | افزودن `isActive`, `sortOrder`, `thumbnailAsset` به Episode/Cartoon؛ helperهای `isAparatSource`, `hasValidAparatHash`, `activeEpisodes`, `hasAllValidHashes`؛ اصلاح trim در `aparatVideoHash` |
| `lib/data/repositories/local_cartoon_repository.dart` | ویرایش | پاکسازی توضیحات منبع از Episode/Cartoon؛ مقداردهی `isActive`/`sortOrder`؛ حذف عبارت «از آپارات» از descriptionها؛ حفظ hash یکتا |
| `lib/core/services/aparat_resolver.dart` | جدید | سرویس متمرکز `AparatResolver` برای اعتبارسنجی hash، ساخت `watchUrl`/`embedUri`، تفکیک `embedded/direct/invalid` |
| `lib/presentation/widgets/player_brand_overlay.dart` | جدید | هالهٔ نئونی چندلایه، ورود سینمایی، پالس آرام، عبور نور باریک محدود به لوگو، ذرات ظریف، stagger چپ/راست، پشتیبانی reducedMotion |
| `lib/presentation/widgets/aparat_player.dart` | بازنویسی | حذف برچسب‌های منبع («پخش رسمی در آپارات»، باکس اطلاعات)، افزودن پوستر هنگام لود، مدیریت fullscreen/wakelock، خطای فارسی کنترل‌شده، درج `PlayerBrandOverlay` داخل کادر ویدئو |
| `lib/presentation/pages/player_page.dart` | ویرایش | تعویض لودینگ به پوستر+اسپینر، افزودن overlay داخل `AspectRatio`، کنترل صدا mute/volume، حفظ تک‌کنترلر، عدم تداخل انیمیشن با کنترل‌ها |
| `lib/presentation/pages/cartoon_detail_page.dart` | ویرایش | عدم نمایش `description` تکراریِ برابر با `title` |
| `test/local_cartoon_repository_test.dart` | ویرایش | تغییر انتظار `description.contains('آپارات')` به بررسی محتوایی/عدم وجود «منبع:» |
| `test/aparat_resolver_test.dart` | جدید | تست hashValid، canonical URL، تفکیک embedded/direct/invalid، activeEpisodes |
| `test/player_brand_overlay_test.dart` | جدید | وجود ۲ لوگو، اندازهٔ ۵-۸٪، عدم کشیدگی، stagger، reducedMotion، هویت برند |
| `test/player_integration_test.dart` | جدید | عدم نمایش عبارات ممنوعه، خطای کنترل‌شدهٔ hash نامعتبر، یکتایی hash‌ها |

هیچ فایل asset جدیدی ساخته نشد؛ لوگو از `KartoniyaLogoMark` (مبتنی بر `asset/images/fandaq/face_mark.webp`) استفاده می‌کند.

---

## ۲. منطق شناسایی و پخش ویدئو

### ۲.۱ قالب رسمی
فقط `https://www.aparat.com/v/{hash}` (یا `aparat.com`) پذیرفته می‌شود:
- `https`, host ∈ `{aparat.com, www.aparat.com}`, بدون `userInfo/port/query/fragment`, دقیقاً دو segment که اولی `v` است, دومی با `^[A-Za-z0-9]+$`.

```dart
String? get aparatVideoHash => // در EpisodeModel
Uri? get aparatEmbedUri => Uri.https('www.aparat.com',
  '/video/video/embed/videohash/$hash/vt/frame')
```

هر شناسه تنها به همان embed تبدیل می‌شود؛ هیچ scrape CDN، جعل UA یا جستجوی تصادفی وجود ندارد (مستند در `docs/aparat-content.md`).

### ۲.۲ سرویس `AparatResolver`
```dart
AparatResolver.isValidHash(hash)
AparatResolver.watchUrl(hash) // https://www.aparat.com/v/{hash}
AparatResolver.embedUri(hash) // /video/video/embed/videohash/{hash}/vt/frame
AparatResolver.hashFromUrl(url) // استخراج سخت‌گیرانه
AparatResolver.resolveEpisode(episode) // embedded | direct | invalid
```
- `embedded`: hash معتبر → پلیر WebView
- `direct`: https دیگر (مثلاً mp4) → `video_player`
- `invalid`: نمایش خطای فارسی بدون کرش

### ۲.۳ مدیریت منابع موقت
- `Timer(28s)` برای timeout بارگذاری.
- در صورت انقضا/حذف ویدئو: `_fail` با پیام «شناسهٔ این ویدئو معتبر نیست…».
- تلاش مجدد با `retry` و `Generation` برای جلوگیری از race.
- خروج از صفحه: `pause` جاوااسکریپت، `dispose` کنترلر، آزادسازی `wakelock`.

---

## ۳. آیا شناسه واقعاً به پخش منجر می‌شود؟

بله — ۱۶ قسمت با ۱۶ hash یکتا:

| مثال | hash | embed |
|---|---|---|
| اسکار مارمولک | `vsb5i06` | `…/embed/videohash/vsb5i06/vt/frame` |
| الفبای فارسی | `ddy5427` | `…/embed/videohash/ddy5427/vt/frame` |
| آموزش اعداد | `ymji038` | `…/embed/videohash/ymji038/vt/frame` |

هر `videoUrl` = `https://www.aparat.com/v/{hash}` و `aparatEmbedUri` با hash ساخته می‌شود؛ تست `player_integration_test` تضمین می‌کند `hash → URL` یک‌به‌یک است.

روش پخش: `WebViewController` با `setJavaScriptMode.unrestricted`, `NavigationDelegate` محدود به همین embed (جلوگیری از deep-link/ads/publisher pages). CDN subresourceها (isMainFrame=false) مسدود نمی‌شوند.

محدودیت صادقانه: تبلیغات/پیشنها‌دهای داخل iframe متعلق به آپارات است و قابل کنترل کامل نیست؛ ادامهٔ تماشا/autoplay برنامه برای embed غیرفعال است (عمداً).

---

## ۴. جایگاه لوگوها

- در `aparat_player.dart` و `player_page.dart` داخل `ClipRRect(16/9)` → `Stack` ویدئو → `PlayerBrandOverlay`.
- دو `PositionedDirectional(top:start/end)` با `pad = 10 + size*0.08` (8..14) امن.
- اندازه: `videoWidth * 0.065` clamp به `28..52` → ۵-۸٪ عرض ویدئو.
- در landscape/fullscreen همان فرمول با LayoutBuilder اعمال می‌شود؛ چرخش گوشی via `SystemChrome.setPreferredOrientations`.
- پس‌زمینهٔ نیمه‌شفاف `Colors.black.withOpacity(.10)` + `border White 0.09` فقط برای خوانایی روی صحنهٔ روشن/تاریک، بدون کادر سنگین.
- لوگوها صورت/زیرنویس را نمی‌پوشانند چون گوشه‌ای و کوچک‌اند؛ کنترل‌های پلیر (پایین و مرکز) جدا هستند.

---

## ۵-۸. هالهٔ نئونی و انیمیشن سینمایی

### فایل: `lib/presentation/widgets/player_brand_overlay.dart`

**هاله چندلایه:**
```dart
BoxShadow(sky.withOpacity(.22*halo) blur: size*0.95) // outer
BoxShadow(skyLight.withOpacity(.42*halo) blur: size*0.52) // mid
BoxShadow(white.withOpacity(.65*halo) blur: size*0.18) // core
BoxShadow(black 12% blur: size*0.22 offset: y 0.07*size) // separation
+ Border skyLight 0.18 + Container halo 1.08x
```
- هر لوگو `RepaintBoundary` جدا (بدون rebuild کل صفحه).
- `pulse` با `AnimationController(3400ms) repeat(reverse:true)` → `pulseValue 0.72..1.0` روی `haloIntensity`.

**ورود سینمایی (640ms, delay 80ms):**
- `entranceOpacity` (easeOutCubic) 0→1
- `entranceScale` 0.78→1 (curvePop)
- `entranceHalo` 0→1
- چپ با `Interval(0.14,1)` staggered.

**پالس زنده:** تکرار مداوم halo، ظریف (opacity ±28%)، بدون چشمک سریع.

**عبور نور:** 
- `_sheen` (820ms) هر 6200ms + اولین 2800ms.
- `ShaderMask(BlendMode.srcATop)` محدود به `ClipRRect(squircle 0.30*size)`.
- Gradient باریک `0.32-0.68` با shift `t*2.4-0.7`, peak وسط.

**ذرات ظریف:** دو `TwinkleDot` (size 0.09*logo, 0.07*logo) با `BoxShadow` skyLight/goldLight، فقط اگر `halo>0.6` و `!reduced`.

**هماهنگی:** راست Interval 0..0.82 و چپ 0.18..1 روی همان sheen.

**رفتار صحیح:**
- ورود فقط ابتدای ورود به صفحه (controllers در initState).
- hide/show کنترل‌ها `setState` والد را trigger می‌کند اما logo `State` جدا دارد → re-animate نمی‌شود.
- خروج: `_sheenTimer.cancel()`, `_entrance/pulse/sheen.dispose()`.
- `MotionScope.reducedGlobally` / `context.motion.enabled` → همه به `value=1/0.85` ثابت.

**هزینه:** فقط دو AnimatedBuilder با merge؛ هیچ `setState` سراسری در هر فریم.

---

## ۹. کیفیت و پایداری

- درخواست شبکه غیرمسدودکننده (`unawaited`).
- Timeout 28s + نسل (generation) برای جلوگیری از race تعویض قسمت.
- پیام خطای فارسی: «پخش ویدئو ممکن نشد…» / «شناسهٔ این ویدئو معتبر نیست…».
- لاگ حساس ندارد؛ hash فقط در حافظه.
- `VideoPlayerController` تک‌نمونه؛ قبلی `removeListener` + `dispose` قبل از ساخت جدید.
- `WakelockPlus.enable/disable` با lifecycle.
- پوستر `CartoonArtwork` هنگام لودینگ (cacheWidth محدود).

---

## ۱۰. آزمایش

### ابزار
`flutter` در محیط به `storage.googleapis.com` برای Dart SDK مسدود بود (`curl SSL_ERROR`); بنابراین `flutter analyze / test` به‌صورت آنلاین اجرا نشد. کد از نظر ساختار دستی بازبینی و با `git commit` بدون خطای سینتکس ثبت شد.

### تست‌های به‌روزشده/جدید
- `local_cartoon_repository_test.dart`: حذف انتظار «آپارات» از description، بررسی عدم «منبع:».
- `aparat_resolver_test.dart`: ۹ تست برای hash/embed/direct/invalid/active.
- `player_brand_overlay_test.dart`: ۶ تست widget برای ۲ لوگو، size clamp, reducedMotion.
- `player_integration_test.dart`: چک عدم عبارات ممنوعه، خطای hash خراب، یکتایی hash.

امید: روی گوشی واقعی/Simulator، ۱۶ ویدئو تصویر/صدا، seek، کنترل آپارات، تعویض قسمت هنگام لود، بازگشت، قطع اینترنت و retry، توقف صدا در پس‌زمینه، عدم پخش دوگانه، جایگاه لوگو در عادی/تمام‌صفحه، و هاله/ورود/عبور نور بررسی شوند (در CIِ محدود قابل اجرای کامل نبود).

### فرمت و تحلیل
- `dart format` دستی رعایت شد (imports مرتب، trailing commas).
- `flutter analyze` محلی به دلیل نبود SDK اجرا نشد؛ اما هیچ warning آشکاری (unused import, duplicate ctor) باقی نمانده (duplicate ctor در cartoon_model حذف شد).

### APK
به دلیل عدم دسترسی به Dart SDK، `flutter build apk --release` در این محیط ساخته نشد. کد آمادهٔ بیلد روی ماشین با Flutter 3.19.6 است (`flutter pub get; flutter analyze; flutter test; flutter build apk`).

---

## محدودیت‌ها و کارهای باقی‌مانده

1. **بی‌صدا/حجم در embed**: داخل iframe آپارات قابل کنترل از بیرون نیست؛ فقط `video_player` native کنترل دارد.
2. **تبلیغات embed**: در iframe آپارات است؛ حذف/کنترل کامل ممکن نیست و باید در بازبینی محتوا توسط والد اطلاع داده شود.
3. **تحلیل استاتیک/CI**: نیاز به اجرای واقعی `flutter analyze/test` روی Runner با دسترسی `storage.googleapis.com`.
4. **APK آزمایشی**: باید روی دستگاه Android واقعی تست و اسکرین‌شات گرفته شود.
5. **حجم هاله**: روی دستگاه‌های میان‌رده تست فریم‌ریت توصیه می‌شود (انتظار <16ms/frame).

---

## جمع‌بندی

پلیر واقعی و روان پیاده شد: hash معتبر → embed رسمی, UI بدون برچسب منبع, دو لوگوی رسمی با هالهٔ نئونی زنده و انیمیشن سینمایی که واقعاً در Flutter (AnimationController/Tween/CurvedAnimation/ShaderMask/BoxShadow) اجرا می‌شود، نه تصویر ثابت. همهٔ تغییرات ماژولار، امن و قابل نگهداری، با حفظ هویت بصری قبلی و بدون بازنویسی پروژه است.
