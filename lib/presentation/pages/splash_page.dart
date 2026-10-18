import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/cartoons_provider.dart';
import '../widgets/aurora_background.dart';
import '../widgets/kartoniya_logo.dart';
import 'home_page.dart';
import 'onboarding_page.dart';

/// اسپلش برند کارتونیا: لوگو با پاپ ورودی، حباب‌های شناور و نقطه‌های
/// بارگذاری. فقط تصمیم مسیر اولیه را می‌گیرد و دادهٔ شبکه‌ای دریافت نمی‌کند
/// تا شروع برنامه کوتاه بماند.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _drift;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _drift = AnimationController(vsync: this, duration: const Duration(seconds: 9));
    if (context.motion.enabled) _drift.repeat();
    unawaited(_openNextPage());
  }

  @override
  void dispose() {
    _enter.dispose();
    _drift.dispose();
    super.dispose();
  }

  Future<void> _openNextPage() async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final completedOnboarding = ref.read(onboardingProvider);
    final destination =
        completedOnboarding ? const HomePage() : const OnboardingPage();
    // انتقال محو‌محو به صفحهٔ مقصد؛ مسیر اسپلش از پشته حذف می‌شود تا
    // دکمهٔ بازگشت کاربر را به اسپلش برندارد.
    Navigator.of(context).pushReplacement(
      kartoniyaPageRoute<void>(page: destination, fadeOnly: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _drift,
              builder: (context, child) {
                final t = _drift.value;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: MediaQuery.sizeOf(context).height * .18 +
                          math.sin(t * 2 * math.pi) * 10,
                      right: -42 + math.cos(t * 2 * math.pi) * 8,
                      child: const _SplashBubble(size: 150, color: AppColors.skyLight),
                    ),
                    Positioned(
                      bottom: MediaQuery.sizeOf(context).height * .16 -
                          math.sin(t * 2 * math.pi + 1.4) * 12,
                      left: -50 + math.sin(t * 2 * math.pi + 2.8) * 9,
                      child: const _SplashBubble(
                        size: 180,
                        color: AppColors.tealLight,
                      ),
                    ),
                    child!,
                  ],
                );
              },
              child: Center(child: _buildMark()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMark() {
    if (!context.motion.enabled) {
      return const _SplashContents(still: true);
    }
    return FadeTransition(
      opacity: CurvedAnimation(parent: _enter, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _enter, curve: Curves.easeOutBack),
        child: const _SplashContents(still: false),
      ),
    );
  }
}

class _SplashContents extends StatelessWidget {
  const _SplashContents({required this.still});

  final bool still;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const KartoniyaLogoMark(size: 118, showOrbit: true),
        const SizedBox(height: 24),
        Text(
          'کارتونیا',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: context.isDarkMode ? AppColors.skyLight : AppColors.skyDeep,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'دنیای شاد و امن کودکان',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.secondaryTextColor,
              ),
        ),
        const SizedBox(height: 38),
        _LoadingDots(still: still),
      ],
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots({required this.still});

  final bool still;

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _colors = [AppColors.coral, AppColors.gold, AppColors.teal];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (!widget.still && context.motion.enabled) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Builder(
                  builder: (context) {
                    final phase = (_controller.value + i * .28) % 1;
                    final lift = math.sin(phase * math.pi) * -7;
                    return Transform.translate(
                      offset: Offset(0, lift),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3.5),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _colors[i],
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _colors[i].withOpacity(.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SplashBubble extends StatelessWidget {
  const _SplashBubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [color.withOpacity(.28), color.withOpacity(.05)],
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}
