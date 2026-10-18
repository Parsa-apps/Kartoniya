import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// A code-aligned privacy disclosure. It is not presented as a legally reviewed
/// or externally published store privacy policy.
class PrivacyInformationPage extends StatelessWidget {
  const PrivacyInformationPage({super.key});

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
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pageMargin,
                16,
                AppTheme.pageMargin,
                36,
              ),
              children: const [
                _PrivacyNotice(
                  icon: Icons.phonelink_lock_rounded,
                  title: 'خلاصهٔ حریم خصوصی کارتونیا',
                  body:
                      'این صفحه رفتار فعلی برنامه را توضیح می‌دهد و جایگزین سیاست '
                      'حقوقیِ بازبینی‌شده یا متن موردنیاز فروشگاه نیست. پیش از انتشار '
                      'تجاری باید مالک محصول آن را بررسی و نسخهٔ عمومی سیاست را نهایی کند.',
                  color: AppColors.sky,
                ),
                SizedBox(height: 12),
                _PrivacyNotice(
                  icon: Icons.storage_rounded,
                  title: 'اطلاعات ذخیره‌شده روی دستگاه',
                  body:
                      'نام نمایشی والد و کودک، آواتار کودک، تم، ترجیح کاهش حرکت، '
                      'پخش خودکار، علاقه‌مندی‌ها، وضعیت آن‌بوردینگ و موقعیت پخشِ '
                      'ویدئوهای مستقیمِ پشتیبانی‌شده در حافظهٔ محلی برنامه نگه‌داری '
                      'می‌شوند. حساب کاربری و همگام‌سازی ابری در این نسخه وجود ندارد. '
                      'این تنظیمات در SharedPreferences عادی ذخیره می‌شوند، نه فضای '
                      'رمزگذاری‌شده؛ از نام مستعار استفاده کنید و اطلاعات حساس وارد نکنید. '
                      'رکوردهای پیشرفت قدیمی نیز ممکن است تا پاک‌کردن دستی در تنظیمات بمانند.',
                  color: AppColors.teal,
                ),
                SizedBox(height: 12),
                _PrivacyNotice(
                  icon: Icons.cloud_off_rounded,
                  title: 'رفتار خود برنامه',
                  body: 'در وابستگی‌های فعلی، سرویس اختصاصیِ تحلیل‌گر یا شبکهٔ '
                      'تبلیغاتی وجود ندارد و برنامه backend حساب کاربری ندارد. '
                      'مجوز فضای ذخیره‌سازی درخواست نمی‌شود. برای پاک‌کردن علاقه‌مندی‌ها '
                      'یا پیشرفت پخش از تنظیمات والدین استفاده کنید؛ پاک‌سازی کامل '
                      'دادهٔ برنامه از تنظیمات سیستم Android انجام می‌شود.',
                  color: AppColors.violet,
                ),
                SizedBox(height: 12),
                _PrivacyNotice(
                  icon: Icons.open_in_new_rounded,
                  title: 'پخش و پیوندهای بیرونی',
                  body:
                      'ویدئوهای فهرست فعلی در پخش‌کنندهٔ embed آپارات باز می‌شوند. '
                      'میزبان بیرونی ممکن است اطلاعات فنی اتصال، کوکی یا تبلیغات و '
                      'پیشنهادهای خودش را پردازش یا نمایش دهد؛ این رفتار زیر کنترل '
                      'کارتونیا نیست. پیوند پشتیبانی تلگرام نیز پس از پرسش والدین '
                      'در برنامهٔ بیرونی باز می‌شود. سیاست و تنظیمات حریم خصوصی آن '
                      'سرویس‌ها جداست؛ والدین پیش از پخش یا تماس بررسی کنند.',
                  color: AppColors.coral,
                ),
                SizedBox(height: 12),
                _PrivacyNotice(
                  icon: Icons.family_restroom_rounded,
                  title: 'همراهی والدین',
                  body:
                      'پرسش ریاضی فقط مانع ورود اتفاقی به برخی بخش‌هاست و ابزار '
                      'احراز هویت یا حفاظت قطعی نیست. اطلاعات شخصی کودک را در پیام '
                      'پشتیبانی یا سرویس بیرونی وارد نکنید، مگر با تصمیم آگاهانهٔ '
                      'والد و بررسی سیاست همان سرویس.',
                  color: AppColors.pink,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final accent =
        context.isDarkMode ? color : AppColors.readableOnLightSurface(color);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: accent),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.secondaryTextColor,
                    height: 1.55,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
