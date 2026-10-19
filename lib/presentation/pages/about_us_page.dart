// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/services/app_haptics.dart';
import '../../core/services/fandoghi_promotion_metrics.dart';
import '../../core/services/fandoghi_store_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/fandoghi_promotion_card.dart';
import '../widgets/kartoniya_story_banner.dart';
import '../widgets/parsa_brand.dart';
import 'privacy_page.dart';

/// صفحهٔ معرفی کارتونیا و برند Parsa Apps با تصویر از پیش‌رندرشده.
/// راه ارتباطی فقط از اطلاعات موجود پروژه گرفته می‌شود؛ اطلاعات تازه‌ای جعل نمی‌شود.
class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage>
    with SingleTickerProviderStateMixin {
  static const _telegramUri = 'https://t.me/Parsaappsadmin';

  late final AnimationController _glowController;
  final _promotionCardKey = GlobalKey();
  var _promotionImpressionRecorded = false;
  var _visibilityCheckScheduled = false;

  void _schedulePromotionVisibilityCheck() {
    if (_promotionImpressionRecorded || _visibilityCheckScheduled) return;
    _visibilityCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visibilityCheckScheduled = false;
      if (!mounted || _promotionImpressionRecorded) return;
      final renderObject = _promotionCardKey.currentContext?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.hasSize) return;

      final cardRect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
      final screenRect = Offset.zero & MediaQuery.sizeOf(context);
      final visibleRect = cardRect.intersect(screenRect);
      if (visibleRect.isEmpty) return;
      final visibleArea = visibleRect.width * visibleRect.height;
      final cardArea = cardRect.width * cardRect.height;
      if (cardArea > 0 && visibleArea / cardArea >= .5) {
        _promotionImpressionRecorded = true;
        const FandoghiPromotionMetrics()
            .record(FandoghiPromotionEvent.impression);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (context.motionEnabledAtInit) _glowController.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.motion.enabled) {
      if (!_glowController.isAnimating) _glowController.repeat(reverse: true);
    } else {
      _glowController.stop(canceled: false);
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _openTelegram() async {
    final opened = await launchUrl(
      Uri.parse(_telegramUri),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('باز کردن تلگرام ممکن نشد.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _schedulePromotionVisibilityCheck();
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
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) {
                _schedulePromotionVisibilityCheck();
                return false;
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 40),
                child: Column(
                  children: [
                  const StaggeredReveal(
                    index: 0,
                    child: KartoniyaStoryBanner(
                      scene: KartoniyaScene.storybook,
                      height: 206,
                      eyebrow: 'آشنایی با کارتونیا',
                      title: 'قصه‌های خوب، تماشای امن',
                      subtitle: 'ساختهٔ گروه برنامه‌نویسی Parsa Apps',
                      semanticLabel:
                          'فندوقی در باغ داستان کارتونیا؛ تصویر از پیش‌رندرشده',
                    ),
                  ),
                  const SizedBox(height: 26),
                  StaggeredReveal(
                    index: 1,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                        child: Column(
                          children: [
                            const ParsaBrandMark(height: 104),
                            const SizedBox(height: 10),
                            Text(
                              'استودیوی Parsa Apps',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'سازندهٔ کارتونیا؛ طراحی، توسعه و انتشار',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                    child: FandoghiPromotionCard(
                      key: _promotionCardKey,
                      onLaunchStarted: () => const FandoghiPromotionMetrics()
                          .record(FandoghiPromotionEvent.click),
                      onLaunchResult: (result) => const FandoghiPromotionMetrics()
                          .record(
                        result == FandoghiStoreLaunchResult.opened
                            ? FandoghiPromotionEvent.opened
                            : FandoghiPromotionEvent.failed,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  StaggeredReveal(
                    index: 3,
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: AppColors.goldDark,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'مدیریت، طراحی و توسعهٔ کارتونیا',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                    index: 4,
                    child: Card(
                      child: InkWell(
                        onTap: () {
                          AppHaptics.light();
                          _openTelegram();
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '@Parsaappsadmin',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
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
                  const SizedBox(height: 12),
                  StaggeredReveal(
                    index: 5,
                    child: Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.privacy_tip_outlined,
                          color: AppColors.teal,
                        ),
                        title: const Text('حریم خصوصی و داده‌ها'),
                        subtitle: const Text(
                          'ذخیرهٔ محلی و اتصال سرویس پخش، با جزئیات',
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                        ),
                        onTap: () => pushAppPage<void>(
                          context,
                          const PrivacyPage(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  StaggeredReveal(
                    index: 6,
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
                              'کارتونیا محیطی گرم، ساده و مناسب خانواده برای پیدا کردن '
                              'و تماشای محتوای کودک است. تنظیمات و فهرست علاقه‌مندی‌ها '
                              'به‌صورت محلی روی دستگاه نگه‌داری می‌شوند.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
                                  icon: Icons.verified_user_rounded,
                                  label: 'بدون حساب کاربری',
                                  color: AppColors.teal,
                                ),
                                _ValueChip(
                                  icon: Icons.lock_rounded,
                                  label: 'قفل والدین',
                                  color: AppColors.violet,
                                ),
                                _ValueChip(
                                  icon: Icons.favorite_rounded,
                                  label: 'متن متناسب با کودک',
                                  color: AppColors.pink,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  StaggeredReveal(
                    index: 7,
                    child: Column(
                      children: [
                        Text(
                          'نسخهٔ ۱.۳.۰',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: context.secondaryTextColor,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '© Parsa Apps — ساخته‌شده با ❤️ برای کودکان ایران',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
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
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value = Curves.easeInOut.transform(animation.value);
        const radius = AppTheme.radiusLarge;
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
              borderRadius: BorderRadius.circular(radius),
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
