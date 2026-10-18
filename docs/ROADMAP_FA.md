# نقشهٔ راه صدمرحله‌ای کارتونیا

## جایگاه فعلی

در شاخهٔ فعلی، پایهٔ محصول تا **فاز ۵۵** پیاده‌سازی شده است و بازطراحی UI فاز ۶ (اسپلش، خانه، دسته‌ها، جست‌وجو، کارت/بنر مشترک، پوسترهای واقعی) روی آن اضافه شده است. اسکرین‌شات‌های رندر‌شده و نتیجهٔ `flutter analyze`/`flutter test` در GitHub Actions گزارش می‌شوند، اما جای آزمون دستگاه واقعی را نمی‌گیرند:  ساختار لایه‌ای، design system، RTL، onboarding، صفحات اصلی، persistence محلی، قفل والدین، player واقعی و motion اصلی وجود دارند. فازهای ۵۶ تا ۱۰۰ برنامهٔ تکمیل، QA و انتشارند. «پیاده‌سازی‌شده» به معنی جایگزین‌شدن با تست release روی دستگاه واقعی نیست؛ آن بخش در فازهای QA باقی مانده است.

| فاز | عنوان و هدف کوتاه | Task List | Deliverable | Definition of Done | وضعیت |
|---:|---|---|---|---|---|
| ۱ | تعیین Scope | مشخص‌کردن کارتونیا، مخاطب کودک/والد و نسخهٔ اول | Scope v1 | قابلیت‌های خارج از Scope ثبت شده باشند | انجام شد |
| ۲ | پرسونای کاربر | سن کودک، نقش والد و نیازهای هرکدام را بنویس | ۲ Persona | هر flow به یک persona وصل باشد | انجام شد |
| ۳ | تحلیل رقبا | الگوهای امن/کودکانهٔ بازار را مقایسه کن | یادداشت رقبا | ۳ فرصت طراحی استخراج شده باشد | انجام شد |
| ۴ | نیازمندی عملکردی | فهرست خانه، جست‌وجو، پخش و تنظیمات | backlog v1 | هر قابلیت معیار پذیرش داشته باشد | انجام شد |
| ۵ | نیازمندی غیرفرعملکردی | RTL، سرعت، حریم خصوصی و دسترس‌پذیری را تعریف کن | NFR checklist | معیارها قابل تست باشند | انجام شد |
| ۶ | حریم خصوصی کودک | حداقل‌سازی داده و نبود حساب را تأیید کن | privacy decision | دادهٔ ذخیره‌شده مستند باشد | انجام شد |
| ۷ | تحلیل ریسک محتوا | ریسک حق پخش، URL و ردهٔ سنی را ثبت کن | risk register | برای هر ریسک راهکار باشد | انجام شد |
| ۸ | معیارهای محصول | retention و کیفیت پخش را برای آینده تعریف کن | metrics draft | بدون SDK اضافی مستند شده باشد | انجام شد |
| ۹ | انتخاب استک | Flutter، Riverpod و repository pattern را تثبیت کن | ADR استک | دلیل انتخاب در معماری باشد | انجام شد |
| ۱۰ | نسخه‌بندی و Git | version و قواعد commit/release را تعیین کن | v1.1.0 config | نسخه در pubspec و Android هماهنگ باشد | انجام شد |
| ۱۱ | پالت رنگ | رنگ برند و accentهای قابل‌دسترسی تعریف کن | AppColors | رنگ‌ها در یک فایل مرکزی باشند | انجام شد |
| ۱۲ | تایپوگرافی | Vazirmatn و scale متن را تنظیم کن | TextTheme | عنوان/بدنه/label مشخص باشند | انجام شد |
| ۱۳ | spacing و radius | توکن فاصله و radius مشترک بساز | AppTheme tokens | کامپوننت‌ها از token استفاده کنند | انجام شد |
| ۱۴ | تم روشن/تاریک | ColorScheme دو حالت را طراحی کن | Light/Dark Theme | تغییر ThemeMode ظاهر را عوض کند | انجام شد |
| ۱۵ | RTL کامل | Directionality، locale و جهت آیکون‌ها را بررسی کن | RTL foundation | متن فارسی و navigation درست باشد | انجام شد |
| ۱۶ | دکمه‌ها | Filled/Outlined و حالت فشردن را یکپارچه کن | Button themes | CTAها style خام نداشته باشند | انجام شد |
| ۱۷ | کارت‌ها | Card و artwork استاندارد بساز | CartoonCard | کارت در grid و list کار کند | انجام شد |
| ۱۸ | فرم‌ها | Input و error state فارسی را بساز | Input theme | focus/error خوانا باشد | انجام شد |
| ۱۹ | stateهای UI | loading، empty و error را استاندارد کن | state components | صفحه‌های اصلی هر سه حالت داشته باشند | انجام شد |
| ۲۰ | دسترس‌پذیری پایه | semantic label، اندازه لمس و contrast را اعمال کن | a11y baseline | کنترل‌های کلیدی label داشته باشند | انجام شد |
| ۲۱ | Splash | شروع سبک و مسیر اولیه بساز | SplashPage | پس از زمان کوتاه به مسیر صحیح برود | انجام شد |
| ۲۲ | Onboarding | ارزش محصول و حریم خصوصی را معرفی کن | OnboardingPage | فقط یک‌بار نمایش داده شود | انجام شد |
| ۲۳ | App shell | NavigationBar و حفظ state برگه‌ها | HomePage shell | تغییر tab state را از بین نبرد | انجام شد |
| ۲۴ | Home dashboard | header، banner و بخش‌های کاتالوگ را بساز | Discover tab | featured و همهٔ محتوا نمایش یابد | انجام شد |
| ۲۵ | دسته‌بندی | filter قابل‌لمس و grid واکنش‌گرا | CategoriesPage | همه/هر دسته درست فیلتر شود | انجام شد |
| ۲۶ | جست‌وجو | debounce و نتایج قابل‌خواندن فارسی | SearchPage | query فارسی/عربی نتیجه صحیح دهد | انجام شد |
| ۲۷ | علاقه‌مندی | افزودن/حذف و empty state | FavoritesPage | تغییر کارت فوراً بازتاب یابد | انجام شد |
| ۲۸ | پروفایل والد | نام محلی و آمار مختصر را بساز | ProfilePage | نام ذخیره و بازخوانی شود | انجام شد |
| ۲۹ | تنظیمات | تم، autoplay و حذف دادهٔ محلی | SettingsPage | تغییرها پایدار و قابل‌برگشت باشند | انجام شد |
| ۳۰ | درباره ما | اطلاعات Parsa Apps و تلگرام | AboutUsPage | لینک تلگرام قابل کلیک باشد | انجام شد |
| ۳۱ | قرارداد domain | CartoonRepository را تعریف کن | interface | UI مستقیم به data source وصل نباشد | انجام شد |
| ۳۲ | مدل داده | Cartoon/Episode/Category را مدل‌سازی کن | models | null و metadata نامعتبر نداشته باشیم | انجام شد |
| ۳۳ | repository محلی | کاتالوگ محلی قابل تعویض بساز | LocalCartoonRepository | fetch قرارداد را رعایت کند | انجام شد |
| ۳۴ | composition Riverpod | repository و serviceها را inject کن | providers | source قابل override باشد | انجام شد |
| ۳۵ | preference service | wrapper واحد برای SharedPreferences | AppPreferences | keyها خارج از UI باشند | انجام شد |
| ۳۶ | persistence تم | ThemeMode را ذخیره کن | ThemeModeNotifier | بعد از restart بازیابی شود | انجام شد |
| ۳۷ | persistence علاقه‌مندی | شناسه‌ها را ذخیره کن | FavoritesNotifier | افزودن/حذف پایدار باشد | انجام شد |
| ۳۸ | persistence progress | درصد ادامهٔ تماشا ذخیره کن | WatchHistoryNotifier | مقدار ۰ تا ۱ معتبر باشد | انجام شد |
| ۳۹ | strategy آفلاین | رفتار کاتالوگ محلی و خطای stream را تعریف کن | offline behavior | UI crash نکند | انجام شد |
| ۴۰ | API-ready design | محل جایگزینی CMS/API را مشخص کن | repository seam | صفحه‌ها بدون تغییر قابل اتصال باشند | انجام شد |
| ۴۱ | metadata محتوا | عنوان، سن، تگ و دسته را ثبت کن | sample catalog | هر عنوان metadata کامل داشته باشد | انجام شد |
| ۴۲ | مجوز محتوا | منبع نمونه را از محتوای تجاری جدا کن | licensing note | URL نهایی دارای حق پخش باشد | در انتظار محتوا |
| ۴۳ | مسیر category | Chip خانه به فیلتر دسته وصل شود | category flow | انتخاب کاربر به grid منتقل شود | انجام شد |
| ۴۴ | نرمال‌سازی فارسی | ي/ی، ك/ک و فاصله را normalize کن | utility + test | جست‌وجوی نمونه پاس شود | انجام شد |
| ۴۵ | جزئیات عنوان | metadata، توضیح و tags را نمایش بده | CartoonDetailPage | عنوان قابل مشاهده و قابل پخش باشد | انجام شد |
| ۴۶ | فهرست قسمت‌ها | episode tile و progress را بساز | episode list | هر قسمت CTA مستقل داشته باشد | انجام شد |
| ۴۷ | player واقعی | video_player و init/error state | PlayerPage | URL HTTPS واقعاً به player داده شود | انجام شد |
| ۴۸ | ادامهٔ تماشا | seek از درصد ذخیره‌شده | resume logic | بازگشت به قسمت از موقعیت سابق باشد | انجام شد |
| ۴۹ | autoplay | preference پخش خودکار | autoplay setting | setting در player اعمال شود | انجام شد |
| ۵۰ | خطای محتوا | retry و پیام امن برای stream خطادار | player error state | URL خطادار crash ندهد | انجام شد |
| ۵۱ | transition صفحه‌ها | routeهای Material و motion نرم را یکپارچه کن | navigation motion | انتقال ناگهانی/خراب نباشد | انجام شد |
| ۵۲ | feedback تعامل | ink، ripple و haptic سبک | micro-interactions | tapهای مهم feedback داشته باشند | انجام شد |
| ۵۳ | skeleton loading | shimmer برای کارت/بنر | Shimmer widgets | loading بدون spinner خام باشد | انجام شد |
| ۵۴ | motion splash | ورود لوگو و background ملایم | splash motion | animation سبک و کوتاه باشد | انجام شد |
| ۵۵ | هاله طلایی | glow/shimmer لوگو و نام سازنده | GoldenGlowFrame | چرخه ۲٫۴ ثانیه و بدون asset سنگین باشد | انجام شد |
| ۵۶ | preference کاهش motion | گزینه احترام به Reduce Motion دستگاه + سوئیچ والدین | motion setting + MotionScope | animationها در حالت کاهش‌یافته کوتاه شوند | انجام شد |
| ۵۷ | پروفایل player | frame/drop و rebuild player را اندازه بگیر | performance report | روی دستگاه ضعیف افت محسوس نداشته باشد | برنامه‌ریزی‌شده |
| ۵۸ | layout تبلت | تمام breakpoints را روی تبلت تست کن | responsive matrix | grid و dialog overflow ندهند | برنامه‌ریزی‌شده |
| ۵۹ | اندازه فونت | textScale 0.8 تا 1.5 را بررسی کن | typography QA | CTA و title قطع نشوند | برنامه‌ریزی‌شده |
| ۶۰ | audit motion | رفتار tap/back/rotate را مرور کن | motion QA list | انیمیشن مزاحم یا loop سنگین نباشد | برنامه‌ریزی‌شده |
| ۶۱ | تصمیم monetization | رایگان/اشتراک/خرید را با مالک محصول نهایی کن | monetization ADR | هیچ SDK قبل از تأیید اضافه نشود | برنامه‌ریزی‌شده |
| ۶۲ | مدل entitlement | اگر پولی شد، free/premium را مدل کن | entitlement model | وضعیت کاربر قابل بازیابی باشد | وابسته به ۶۱ |
| ۶۳ | gate پرداخت | Parental Gate را پیش از خرید قرار بده | purchase gate | کودک به خرید دسترسی مستقیم نداشته باشد | وابسته به ۶۱ |
| ۶۴ | صفحه خرید | قیمت، مزیت و خطای خرید را طراحی کن | paywall UI | loading/cancel/error کامل باشد | وابسته به ۶۱ |
| ۶۵ | Poolakey | SDK رسمی و lifecycle امن را اضافه کن | billing integration | اتصال/قطع race condition نداشته باشد | وابسته به ۶۱ |
| ۶۶ | سناریو خرید | موفق، ناموفق، لغو و restore را تست کن | purchase test report | همهٔ سناریوها پاس شوند | وابسته به ۶۵ |
| ۶۷ | بازیابی خرید | restore پس از نصب مجدد | restore flow | entitlement درست برگردد | وابسته به ۶۵ |
| ۶۸ | قفل premium | محتوای premium را فقط با entitlement باز کن | gating rules | bypass در navigation نباشد | وابسته به ۶۲ |
| ۶۹ | متن قانونی | شرایط خرید/استرداد و حمایت والدین | legal copy | با قوانین فروشگاه هماهنگ باشد | وابسته به ۶۱ |
| ۷۰ | Go/No-Go درآمد | تصمیم انتشار درآمدی را تأیید کن | approval | QA billing و حقوقی تأیید شود | وابسته به ۶۹ |
| ۷۱ | secure config | secretها و key.properties را از Git خارج کن | .gitignore + Gradle | `git ls-files` secret نشان ندهد | انجام شد |
| ۷۲ | HTTPS enforcement | CDN/endpointهای نهایی را بررسی کن | endpoint checklist | HTTP plain در production نباشد | در انتظار backend |
| ۷۳ | token policy | secure storage و refresh token برای API آینده | auth ADR | token در log/prefs نباشد | برنامه‌ریزی‌شده |
| ۷۴ | Android permission audit | فقط permission ضروری را نگه‌دار | manifest audit | Storage/legacy permission نباشد | انجام شد |
| ۷۵ | storage migration | اگر download اضافه شد، Scoped Storage را طراحی کن | download ADR | permission flow قبل از درخواست داشته باشد | برنامه‌ریزی‌شده |
| ۷۶ | RAM و cache | cache artwork/video و memory pressure را تست کن | memory report | باز/بسته شدن player leak نداشته باشد | برنامه‌ریزی‌شده |
| ۷۷ | asset optimization | artwork/asset نهایی را WebP/vector کن | asset report | فایل بلااستفاده صفر باشد | برنامه‌ریزی‌شده |
| ۷۸ | startup profiling | زمان cold start را اندازه بگیر | startup metric | splash سنگین نباشد | برنامه‌ریزی‌شده |
| ۷۹ | accessibility audit | TalkBack، focus order و contrast | a11y report | navigation اصلی قابل استفاده باشد | برنامه‌ریزی‌شده |
| ۸۰ | child-safety audit | محتوا، link خارجی و parental flow را بازبینی کن | safety checklist | تایید مسئول محتوا/والد حاصل شود | برنامه‌ریزی‌شده |
| ۸۱ | Unit test گسترش | providerها، preference و repository API را تست کن | unit suite | منطق حیاتی پوشش داشته باشد | انجام شد (اولیه) |
| ۸۲ | Widget test | onboarding، favorite، parental gate و مسیر اولین اجرا | widget suite | flowهای کلیدی با test پاس شوند | انجام شد (اولیه) |
| ۸۳ | تست player واقعی | streamهای معتبر/نامعتبر و resume را دستی تست کن | player test matrix | retry و back بی‌نقص باشند | برنامه‌ریزی‌شده |
| ۸۴ | حالت خطا | قطع اینترنت، DNS بد و URL منقضی را تست کن | error matrix | پیام مناسب و recovery باشد | برنامه‌ریزی‌شده |
| ۸۵ | Android matrix | API 21 تا جدیدترین نسخه را بررسی کن | device matrix | نصب و launch روی همه پاس شود | برنامه‌ریزی‌شده |
| ۸۶ | lifecycle | rotation، background/foreground و Back را تست کن | lifecycle report | orientation/player restore درست باشد | برنامه‌ریزی‌شده |
| ۸۷ | شبکه ضعیف | 2G/قطع/بازگشت شبکه را شبیه‌سازی کن | network report | ANR یا crash نباشد | برنامه‌ریزی‌شده |
| ۸۸ | profile performance | DevTools و rebuild analysis اجرا کن | profiling report | hotspotهای اصلی رفع شوند | برنامه‌ریزی‌شده |
| ۸۹ | regression | پس از هر fix، suite دستی/خودکار را اجرا کن | regression log | bug بسته‌شده برنگردد | برنامه‌ریزی‌شده |
| ۹۰ | QA sign-off | چک‌لیست نهایی UI، امنیت و flow را امضا کن | QA sign-off | blocker باز صفر باشد | برنامه‌ریزی‌شده |
| ۹۱ | هویت فروشگاهی | آیکون نهایی، feature graphic و screenshot بساز | visual package | ابعاد فروشگاه درست باشد | برنامه‌ریزی‌شده |
| ۹۲ | اسکرین‌شات | خانه، جست‌وجو، player و parent flow را capture کن | screenshots | بدون داده/محتوای غیرمجاز باشند | برنامه‌ریزی‌شده |
| ۹۳ | ASO و توضیحات | نام، کوتاه/بلند، keywords و FAQ بنویس | store copy | ادعاها با قابلیت واقعی هم‌خوان باشد | برنامه‌ریزی‌شده |
| ۹۴ | سیاست حریم خصوصی | صفحه وب/URL حریم خصوصی منتشر کن | privacy policy URL | Data Safety با آن سازگار باشد | برنامه‌ریزی‌شده |
| ۹۵ | امضای release | keystore امن و CI secretها را تنظیم کن | signed config | کلید در Git/لاگ نباشد | برنامه‌ریزی‌شده |
| ۹۶ | build release | analyze، test، APK و AAB بساز | artifacts | فرمان‌ها بدون خطا تمام شوند | برنامه‌ریزی‌شده |
| ۹۷ | نصب واقعی | AAB/APK را روی دستگاه واقعی نصب کن | installation evidence | update/install/launch موفق باشد | برنامه‌ریزی‌شده |
| ۹۸ | انتشار مرحله‌ای | internal test سپس درصد کم release | rollout plan | معیار rollback مشخص باشد | برنامه‌ریزی‌شده |
| ۹۹ | مانیتورینگ | crash و بازخورد بدون نقض privacy تنظیم کن | monitoring plan | alert و owner مشخص باشد | برنامه‌ریزی‌شده |
| ۱۰۰ | v1.2 و رشد | بازخورد را به roadmap بعدی تبدیل کن | v1.2 backlog | اولویت، تخمین و معیار موفقیت داشته باشد | برنامه‌ریزی‌شده |

## Definition of Done انتشار

- `flutter analyze` بدون error اجرا شود.
- `flutter test` پاس شود.
- APK و AAB release با کلید امن ساخته شوند.
- محتوای واقعی دارای مجوز و HTTPS جایگزین demo URL شده باشد.
- تمام flowهای کودک و والد روی دستگاه واقعی آزمایش شده باشند.
- هیچ token، keystore، URL خصوصی یا دادهٔ کودک در Git و log وجود نداشته باشد.
