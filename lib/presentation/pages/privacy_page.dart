import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/kartoniya_story_banner.dart';

/// In-product privacy explanation. It distinguishes on-device preferences
/// from the network connection required by third-party video providers.
class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حریم خصوصی'),
        leading: IconButton(
          tooltip: 'بازگشت',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
              children: [
                const KartoniyaStoryBanner(
                  scene: KartoniyaScene.twilight,
                  height: 176,
                  eyebrow: 'برای والدین، با شفافیت',
                  title: 'اطلاعات خانواده مهم است',
                  subtitle: 'تنظیمات کارتونیا روی دستگاه شما می‌ماند.',
                  semanticLabel: 'فندوقی در کتابخانهٔ مهتابی',
                ),
                const SizedBox(height: 18),
                Text(
                  'کارتونیا در این نسخه حساب کاربری یا همگام‌سازی ابری ندارد. '
                  'جست‌وجوی کاتالوگ محلی است؛ برای پخش ویدئو، اتصال اینترنت و '
                  'سرویس میزبان ویدئو لازم است.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                const _PrivacyCard(
                  icon: Icons.phone_android_rounded,
                  color: AppColors.sky,
                  title: 'چه چیزهایی روی همین دستگاه می‌ماند؟',
                  body: 'نام نمایشی کودک، سن به سال (نه تاریخ تولد)، شمارهٔ '
                      'آواتار برداری، حالت روشن/تاریک، پخش خودکار، وضعیت '
                      'آشنایی اولیه، علاقه‌مندی‌ها، موقعیت ادامهٔ تماشا و بهترین '
                      'رکورد بازی‌ها فقط در حافظهٔ محلی برنامه ذخیره می‌شوند. '
                      'نشان‌های «دستاورد» ذخیره نمی‌شوند و در همان لحظه از همین '
                      'رکوردها محاسبه می‌شوند. انیمیشن‌ها از تنظیم دسترس‌پذیری '
                      'سیستم پیروی می‌کنند. نام والد، عکس، شناسه یا تاریخ تولد '
                      'درخواست یا ذخیره نمی‌شود.',
                ),
                const SizedBox(height: 12),
                const _PrivacyCard(
                  icon: Icons.play_circle_outline_rounded,
                  color: AppColors.coral,
                  title: 'هنگام پخش چه ارتباطی برقرار می‌شود؟',
                  body:
                      'ویدئوهای این کاتالوگ از آپارات پخش می‌شوند. برای نمایش '
                      'آن‌ها، اپ WebView اندروید را به صفحهٔ رسمی ویدئو متصل '
                      'می‌کند؛ سرویس میزبان ممکن است نشانی IP و داده‌های فنی '
                      'معمول درخواست را دریافت کند و سیاست کوکی یا تبلیغات خودش '
                      'را اعمال کند. این رفتار در اختیار کارتونیا نیست. اپ برای '
                      'پخش آپارات نشانی‌های موقت CDN را استخراج نمی‌کند.',
                ),
                const SizedBox(height: 12),
                const _PrivacyCard(
                  icon: Icons.shield_outlined,
                  color: AppColors.teal,
                  title: 'حفاظت و حذف داده‌ها',
                  body:
                      'تنظیمات والدین با قفل محلی محافظت می‌شود؛ این قفل، حساب '
                      'کاربری یا رمزگذاری ابری نیست. از صفحهٔ تنظیمات والدین '
                      'می‌توانید سابقهٔ تماشا و علاقه‌مندی‌ها را پاک کنید. با '
                      'پاک‌کردن داده‌های برنامه یا حذف آن از Android، تنظیمات '
                      'باقی‌ماندهٔ محلی نیز حذف می‌شوند.',
                ),
                const SizedBox(height: 12),
                const _PrivacyCard(
                  icon: Icons.visibility_outlined,
                  color: AppColors.violet,
                  title: 'ردیابی و تبلیغات در خود برنامه',
                  body: 'در این نسخه حساب کاربری، تبلیغ‌افزار، شناسهٔ کاربر یا '
                      'تحلیل‌گر آنلاین وجود ندارد. شمارنده‌های کلی نمایش کارت '
                      'معرفی جزیره فندقی و تلاش/نتیجهٔ بازکردن لینک فقط روی همین '
                      'دستگاه ذخیره می‌شوند و به سرور فرستاده نمی‌شوند؛ بازشدن '
                      'صفحه یا کلیک، نصب برنامه را اثبات نمی‌کند. این توضیح شامل '
                      'سرویس بیرونی پخش ویدئو نیست؛ سیاست دادهٔ آن سرویس جداگانه '
                      'اعمال می‌شود.',
                ),
                const SizedBox(height: 18),
                Text(
                  'این توضیح مربوط به رفتار همین نسخهٔ کارتونیاست؛ شرایط سرویس '
                  'میزبان ویدئو جداگانه اعمال می‌شود.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.secondaryTextColor,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(context.isDarkMode ? .18 : .12),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 5),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.secondaryTextColor,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
