import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/kartoniya_mascot.dart';

/// Parent-only status/connection point. This page deliberately does not
/// contain a purchase button, price, product identifier, or simulated state.
class PremiumReadinessPage extends StatelessWidget {
  const PremiumReadinessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('کارتونیا ویژه'),
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
                12,
                AppTheme.pageMargin,
                32,
              ),
              children: [
                _StatusCard(),
                const SizedBox(height: 20),
                Text(
                  'پیش از فعال‌سازی خرید',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                const _RequirementTile(
                  icon: Icons.store_outlined,
                  title: 'انتخاب فروشگاه مقصد',
                  detail:
                      'کافه‌بازار، مایکت یا فروشگاه‌های موردنظر باید مشخص شوند.',
                ),
                const _RequirementTile(
                  icon: Icons.sell_outlined,
                  title: 'تعریف محصول و قیمت',
                  detail:
                      'شناسهٔ واقعی محصول، نوع خرید و قیمت تأییدشده هنوز ارائه نشده‌اند.',
                ),
                const _RequirementTile(
                  icon: Icons.verified_user_outlined,
                  title: 'اعتبارسنجی و بازیابی',
                  detail:
                      'اتصال SDK، تأیید رسید و بازیابی خرید باید طراحی و آزمایش شوند.',
                ),
                const _RequirementTile(
                  icon: Icons.video_library_outlined,
                  title: 'مجوز و مزایای محصول',
                  detail:
                      'حقوق انتشار محتوا و مزایای پولی باید پیش از فروش روشن شوند.',
                ),
                const SizedBox(height: 16),
                Text(
                  'تا آن زمان، همهٔ قابلیت‌های فعلی بدون نمایش قیمت یا ادعای عضویت '
                  'پولی باقی می‌مانند. این صفحه فقط وضعیت آماده‌سازی را نشان می‌دهد.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.secondaryTextColor,
                      ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('بازگشت به فضای والدین'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.gold.withOpacity(context.isDarkMode ? .24 : .18),
            context.surfaceColor,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppColors.gold.withOpacity(.55)),
        boxShadow: AppTheme.softShadow(context),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const KartoniyaMascot(
            size: 62,
            mood: MascotMood.sleepy,
            float: false,
            accent: AppColors.gold,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خرید هنوز فعال نیست',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.isDarkMode
                            ? AppColors.gold
                            : AppColors.goldDark,
                      ),
                ),
                const SizedBox(height: 5),
                Text(
                  'در این نسخه تراکنش یا اشتراک پولی انجام نمی‌شود.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.secondaryTextColor,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(.16),
              borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                'آماده‌سازی',
                style: TextStyle(
                  color: context.isDarkMode
                      ? AppColors.goldLight
                      : AppColors.goldDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementTile extends StatelessWidget {
  const _RequirementTile({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: Icon(
          icon,
          color: context.isDarkMode ? AppColors.goldLight : AppColors.goldDark,
        ),
        title: Text(title),
        subtitle: Text(detail),
      ),
    );
  }
}
