import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/cartoons_provider.dart';
import '../widgets/aurora_background.dart';
import '../widgets/kartoniya_story_banner.dart';
import 'home_page.dart';

class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.scene,
    this.overlayMascot = true,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final KartoniyaScene scene;
  final bool overlayMascot;
  final String title;
  final String description;
  final Color color;
}

/// آن‌بوردینگ سه‌مرحله‌ای با پارالاکس ملایم؛ قابل رد کردن و فقط یک‌بار نمایش.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  var _currentPage = 0;
  var _isCompleting = false;

  static const _pages = [
    _OnboardingData(
      icon: Icons.auto_awesome_rounded,
      scene: KartoniyaScene.cloudworld,
      title: 'هر روز یک ماجرای تازه',
      description:
          'کارتون‌های کوتاه و رنگی را براساس علاقه و سن کودک پیدا کنید و همان‌جا تماشا کنید.',
      color: AppColors.sky,
    ),
    _OnboardingData(
      icon: Icons.favorite_rounded,
      scene: KartoniyaScene.reading,
      overlayMascot: false,
      title: 'فضایی آرام برای کودک',
      description:
          'علاقه‌مندی‌ها و ادامهٔ تماشا فقط روی همین دستگاه ذخیره می‌شوند؛ در خود برنامه حساب کاربری ساخته نمی‌شود.',
      color: AppColors.pink,
    ),
    _OnboardingData(
      icon: Icons.family_restroom_rounded,
      scene: KartoniyaScene.twilight,
      title: 'کنترل در دست والدین',
      description:
          'تنظیمات مهم با یک پرسش ریاضی تصادفی محافظت می‌شود تا کودک با خیال راحت تماشا کند.',
      color: AppColors.teal,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    await ref.read(onboardingProvider.notifier).complete();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      kartoniyaPageRoute<void>(page: const HomePage(), fadeOnly: true),
      (route) => false,
    );
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: context.motion.dur(AppMotion.soft),
      curve: AppMotion.curveStandard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        tint: page.color,
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.pageMargin - 10,
                    vertical: 6,
                  ),
                  child: TextButton(
                    onPressed: _isCompleting ? null : _finish,
                    child: const Text('رد کردن'),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _currentPage = value),
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double delta = 0;
                        if (_pageController.hasClients &&
                            _pageController.position.hasContentDimensions &&
                            context.motion.enabled) {
                          final pageValue = _pageController.page ?? index.toDouble();
                          delta = (pageValue - index).clamp(-1.0, 1.0);
                        }
                        return Opacity(
                          opacity: (1 - delta.abs() * .7).clamp(0.3, 1.0),
                          child: Transform.translate(
                            offset: Offset(delta * -26, 0),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _OnboardingHero(item: item),
                            const SizedBox(height: 34),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: context.secondaryTextColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(_pages.length, (index) {
                        final selected = index == _currentPage;
                        return AnimatedContainer(
                          duration: context.motion.dur(AppMotion.quick),
                          curve: AppMotion.curveStandard,
                          margin: const EdgeInsetsDirectional.only(end: 6),
                          width: selected ? 26 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: selected
                                ? page.color
                                : context.softBorderColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: page.color,
                        minimumSize: const Size(150, 54),
                      ),
                      onPressed: _isCompleting ? null : _next,
                      icon: _isCompleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              _currentPage == _pages.length - 1
                                  ? Icons.check_rounded
                                  : Icons.arrow_back_rounded,
                            ),
                      label: Text(
                        _currentPage == _pages.length - 1
                            ? 'شروع کارتونیا'
                            : 'بعدی',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingHero extends StatelessWidget {
  const _OnboardingHero({required this.item});

  final _OnboardingData item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 238,
      width: double.infinity,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                item.scene.assetPath,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(item.color, Colors.white, .55)!,
                        item.color,
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      Colors.white.withOpacity(.16),
                      item.color.withOpacity(.10),
                      item.color.withOpacity(.30),
                    ],
                  ),
                ),
              ),
              if (item.overlayMascot)
                const PositionedDirectional(
                  end: -10,
                  bottom: -25,
                  child: PreRenderedFlak(
                    width: 176,
                    height: 242,
                    semanticLabel: 'فِلَک، راهنمای سه‌بعدی از پیش‌رندرشدهٔ کارتونیا',
                  ),
                ),
              PositionedDirectional(
                start: 18,
                top: 18,
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.90),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(color: Colors.white),
                    boxShadow: AppTheme.softShadow(context),
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
