import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../global_widgets/parental_gate_widget.dart';
import '../widgets/kartoniya_logo.dart';
import 'privacy_information_page.dart';

/// صفحهٔ رسمی Parsa Apps؛ هویت سازنده با هالهٔ طلایی سبک و بدون asset سنگین.
/// فقط لینک رسمی پشتیبانی موجود نمایش داده می‌شود و اطلاعات تماس تازه‌ای
/// ساخته نمی‌شود.
class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with SingleTickerProviderStateMixin {
  static const _telegramUri = 'https://t.me/Parsaappsadmin';

  late final AnimationController _glowController;
  late bool _motionEnabled;

  @override
  void initState() {
    super.initState();
    _motionEnabled = !MotionScope.reducedGlobally;
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (_motionEnabled) _glowController.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = context.motion.enabled;
    if (enabled == _motionEnabled) return;
    _motionEnabled = enabled;
    if (enabled) {
      _glowController.repeat(reverse: true);
    } else {
      _glowController.stop();
      _glowController.value = 0;
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _openTelegram() async {
    try {
      final opened = await launchUrl(
        Uri.parse(_telegramUri),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) _showTelegramError();
    } catch (_) {
      if (mounted) _showTelegramError();
    }
  }

  void _showTelegramError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('باز کردن تلگرام ممکن نشد.')),
    );
  }

  Future<void> _confirmAndOpenTelegram() async {
    final allowed = await showParentalGate(
      context,
      reason: 'ارتباط با پشتیبانی',
    );
    if (allowed && mounted) await _openTelegram();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دربارهٔ ما'),
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
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
              child: Column(
                children: [
                  StaggeredReveal(
                    index: 0,
                    child: Column(
                      children: [
                        _GoldenGlowFrame(
                          animation: _glowController,
                          circular: true,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: KartoniyaLogoMark(
                              size: MediaQuery.sizeOf(context).width > 480 ? 110 : 92,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'کارتونیا',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: context.isDarkMode
                                    ? AppColors.skyLight
                                    : AppColors.skyDeep,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ساختهٔ گروه برنامه‌نویسی Parsa Apps',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: context.secondaryTextColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  StaggeredReveal(
                    index: 1,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            _GoldenGlowFrame(
                              animation: _glowController,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 17,
                                  vertical: 9,
                                ),
                                child: Text(
                                  'فرشاد پارسا',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            color: context.isDarkMode
                                                ? AppColors.goldLight
                                                : AppColors.goldDark,
                                          ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'مدیریت، طراحی و توسعهٔ کارتونیا',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.secondaryTextColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  StaggeredReveal(
                    index: 2,
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _confirmAndOpenTelegram();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF229ED9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'پشتیبانی تلگرام',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '@Parsaappsadmin',
                                      style:
                                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: context.secondaryTextColor,
                                              ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.open_in_new_rounded,
                                color: context.secondaryTextColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  StaggeredReveal(
                    index: 3,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              'دربارهٔ کارتونیا',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'نام و آواتار نمایشی، تنظیمات، علاقه‌مندی‌ها و پیشرفتِ پخش '
                              'بومی روی همین دستگاه ذخیره می‌شوند. ویدئوهای فهرست فعلی '
                              'در میزبان بیرونی باز می‌شوند؛ سیاست داده و تبلیغات آن '
                              'سرویس جداست. والدین پیش از پخش، محتوا و صفحهٔ میزبان را '
                              'بررسی کنند.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.secondaryTextColor,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            const Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _ValueChip(
                                  icon: Icons.save_rounded,
                                  label: 'تنظیمات محلی',
                                  color: AppColors.teal,
                                ),
                                _ValueChip(
                                  icon: Icons.open_in_new_rounded,
                                  label: 'پخش با میزبان بیرونی',
                                  color: AppColors.violet,
                                ),
                                _ValueChip(
                                  icon: Icons.lock_rounded,
                                  label: 'قفل والدین',
                                  color: AppColors.pink,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => pushAppPage<void>(
                                context,
                                const PrivacyInformationPage(),
                              ),
                              icon: const Icon(Icons.privacy_tip_outlined),
                              label: const Text('جزئیات حریم خصوصی'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  StaggeredReveal(
                    index: 4,
                    child: Column(
                      children: [
                        Text(
                          'نسخهٔ ۱.۲.۱ • بیلد ۴',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.secondaryTextColor,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '© Parsa Apps — ساخته‌شده با ❤️ برای کودکان ایران',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.secondaryTextColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final accent = context.isDarkMode
        ? color
        : AppColors.readableOnLightSurface(color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
        border: Border.all(color: color.withOpacity(.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _GoldenGlowFrame extends StatelessWidget {
  const _GoldenGlowFrame({
    required this.animation,
    required this.child,
    this.circular = false,
  });

  final Animation<double> animation;
  final Widget child;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = Curves.easeInOut.transform(animation.value);
        final radius = circular ? 999.0 : AppTheme.radiusLarge;
        return Transform.scale(
          scale: 1 + (value * .014),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: SweepGradient(
                transform: GradientRotation(value * 6.28),
                colors: const [
                  AppColors.goldDark,
                  AppColors.gold,
                  Colors.white,
                  AppColors.goldDark,
                ],
              ),
              shape: circular ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: circular ? null : BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(.22 + (value * .30)),
                  blurRadius: 18 + (value * 15),
                  spreadRadius: 1 + (value * 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: ColoredBox(
                color: context.surfaceColor,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
