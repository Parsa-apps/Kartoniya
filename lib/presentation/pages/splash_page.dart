import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/cartoons_provider.dart';
import '../widgets/kartoniya_logo.dart';
import '../widgets/kartoniya_mascot.dart';
import 'home_page.dart';
import 'onboarding_page.dart';

/// اسپلش برند کارتونیا.
///
/// یک صحنهٔ شبانهٔ اختصاصی (ابرهای نرم، جزیرهٔ قصه و ماه)، ستاره‌های چشمک‌زن،
/// ورود مرحله‌ای نشان/نام/بلوطی و خروج نرم به صفحهٔ بعد. هیچ تأخیر تزئینیِ
/// ثابتی اعمال نمی‌شود: خروج زمانی رخ می‌دهد که انیمیشن ورود تمام شده باشد
/// **و** کاتالوگ محلی آماده باشد (با سقف زمانی ۱٫۴ ثانیه)، تا خانه بدون
/// پرش و با دادهٔ حاضر باز شود.
///
/// هر حرکت با «کاهش حرکت» (تنظیم سیستم یا والد) به وضعیت نهایی می‌رسد و
/// با لمس پس از شروع، کاربر می‌تواند بی‌درنگ وارد شود.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _ambient;
  late final AnimationController _exit;

  late final Animation<double> _exitOpacity;
  late final Animation<double> _exitScale;

  Timer? _tapEnableTimer;
  bool _leaving = false;
  bool _canSkip = false;

  /// کمینهٔ نمایش برند؛ برای دیده‌شدن ورود پلکانی، نه معطل‌کردن کاربر.
  static const _brandBeat = Duration(milliseconds: 900);
  static const _brandBeatReduced = Duration(milliseconds: 380);
  static const _exitDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
    _exit = AnimationController(vsync: this, duration: _exitDuration);
    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exit, curve: Curves.easeInCubic),
    );
    // خروج با «بالا رفتن» آرام صحنه انجام می‌شود تا حس بازشدن در باشد و به
    // ورود پلکانی خانه گره بخورد.
    _exitScale = Tween<double>(begin: 1, end: 1.045).animate(
      CurvedAnimation(parent: _exit, curve: Curves.easeInCubic),
    );

    if (context.motionEnabledAtInit) {
      _ambient.repeat();
      _tapEnableTimer = Timer(
        const Duration(milliseconds: 450),
        () {
          if (mounted) setState(() => _canSkip = true);
        },
      );
    } else {
      _entrance.value = 1;
      _canSkip = true;
    }
    unawaited(_bootstrap());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // اگر «کاهش حرکت» در میانهٔ اسپلش فعال شود، صحنه بی‌درنگ ثابت می‌شود.
    if (!context.motion.enabled) {
      _ambient.stop(canceled: false);
      if (_entrance.value < 1) _entrance.value = 1;
      _canSkip = true;
    } else if (!_ambient.isAnimating && !_leaving) {
      _ambient.repeat();
    }
  }

  @override
  void dispose() {
    _tapEnableTimer?.cancel();
    _entrance.dispose();
    _ambient.dispose();
    _exit.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final motion = context.motionEnabledAtInit;
    final beat = motion ? _brandBeat : _brandBeatReduced;

    // کاتالوگ موازی با انیمیشن آماده می‌شود؛ خطا مسیر را قفل نمی‌کند و در
    // خانهٔ مقصد با ErrorStateView و «تلاش دوباره» مدیریت می‌شود.
    final ready = ref
        .read(cartoonsProvider.future)
        .then<void>((_) {}, onError: (Object _) {})
        .timeout(const Duration(milliseconds: 1400), onTimeout: () {})
        .catchError((Object _) {});
    final entranceDone = motion
        ? _entrance.forward().orCancel.catchError((_) {})
        : Future<void>.value();

    await Future.wait<void>([
      Future<void>.delayed(beat),
      entranceDone,
      ready,
    ]);
    if (!mounted || _leaving) return;

    // مکث کوتاه برای دیده‌شدن وضعیت نهایی، سپس خروج.
    await Future<void>.delayed(const Duration(milliseconds: 170));
    if (!mounted || _leaving) return;
    await _leave();
  }

  Future<void> _leave() async {
    if (_leaving || !mounted) return;
    setState(() => _leaving = true);
    _ambient.stop(canceled: false);
    if (context.motion.enabled) {
      await _exit.forward().orCancel.catchError((_) {});
    }
    if (!mounted) return;
    final completedOnboarding = ref.read(onboardingProvider);
    final destination =
        completedOnboarding ? const HomePage() : const OnboardingPage();
    // انتقال محو‌محو به مقصد؛ اسپلش از پشته حذف می‌شود تا دکمهٔ بازگشت
    // کاربر را به اسپلش برنگرداند.
    Navigator.of(context).pushReplacement(
      kartoniyaPageRoute<void>(page: destination, fadeOnly: true),
    );
  }

  void _handleSkip() {
    if (!_canSkip || _leaving) return;
    unawaited(_leave());
  }

  @override
  Widget build(BuildContext context) {
    // صحنهٔ شبانه در هر دو تم روشن/تاریک است؛ آیکون‌های سیستم روشن می‌مانند.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handleSkip,
        child: Scaffold(
          backgroundColor: const Color(0xFF0B2A3D),
          body: Semantics(
            label: 'کارتونیا، دنیای شاد و امن کودکان',
            hint: 'برای ورود ضربه بزن',
            child: FadeTransition(
              opacity: _exitOpacity,
              child: ScaleTransition(
                scale: _exitScale,
                child: _SplashScene(
                  entrance: _entrance,
                  ambient: _ambient,
                  exiting: _leaving,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SplashScene extends StatelessWidget {
  const _SplashScene({
    required this.entrance,
    required this.ambient,
    required this.exiting,
  });

  final Animation<double> entrance;
  final Animation<double> ambient;
  final bool exiting;

  @override
  Widget build(BuildContext context) {
    final reduced = !context.motion.enabled;
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final w = constraints.maxWidth;
        final compact = h < 660;
        final safeTop = MediaQuery.maybeOf(context)?.padding.top ?? 0;
        final safeBottom = MediaQuery.maybeOf(context)?.padding.bottom ?? 0;

        // ترکیب صحنه: ماه بالا-راست، نشان و نام روی باند آرام آسمان،
        // بلوطی نشسته روی تخت ابر پایین کادر. اندازه‌ها نسبی‌اند تا روی
        // گوشی کوتاه، تبلت و صفحهٔ بلند یکسان درست بنشیند.
        final logoSize = math.min(
          compact ? 62.0 : 78.0,
          math.min(w * .21, h * .115),
        );
        final brandTop = math.max(safeTop + (compact ? 22 : 40), h * .17);
        final characterHeight = math.min(h * (compact ? .30 : .32), w * .60);
        final characterWidth = characterHeight * .92;
        final characterBottom = math.max(safeBottom + 8, h * .045);

        return Stack(
          fit: StackFit.expand,
          children: [
            _SplashBackdrop(ambient: ambient, reduced: reduced),
            // پردهٔ آرام برای خوانایی متن روی آسمان.
            const IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x44061B2C),
                      Color(0x00061B2C),
                      Color(0x00061B2C),
                      Color(0x33081B2A),
                    ],
                    stops: [0, .28, .62, 1],
                  ),
                ),
              ),
            ),
            if (!reduced)
              IgnorePointer(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: ambient,
                    builder: (context, _) => CustomPaint(
                      painter: _SplashAtmospherePainter(t: ambient.value),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: brandTop,
              left: 24,
              right: 24,
              child: _BrandBlock(
                entrance: entrance,
                ambient: ambient,
                reduced: reduced,
                compact: compact,
                logoSize: logoSize,
                trailing: _SplashLoader(exiting: exiting),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: characterBottom,
              child: IgnorePointer(
                child: Center(
                  child: _CharacterStage(
                    entrance: entrance,
                    ambient: ambient,
                    reduced: reduced,
                    width: characterWidth,
                    height: characterHeight,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// پس‌زمینهٔ اختصاصی با حرکت بسیار آرام دوربین؛ فقط پوستهٔ تصویر بازسازی
/// می‌شود و متن‌ها در هر فریم layout نمی‌شوند.
class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop({required this.ambient, required this.reduced});

  final Animation<double> ambient;
  final bool reduced;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 2;
    final width = MediaQuery.maybeOf(context)?.size.width ?? 400;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: ambient,
        builder: (context, child) => Transform.scale(
          scale: reduced
              ? 1
              : 1.025 + math.sin(ambient.value * 2 * math.pi) * .012,
          child: child,
        ),
        child: Image.asset(
          'asset/images/fandaq_splash_night.webp',
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.medium,
          excludeFromSemantics: true,
          cacheWidth: (width * dpr).clamp(360, 1080).round(),
          errorBuilder: (context, error, stackTrace) => const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0B2438),
                  Color(0xFF123C53),
                  Color(0xFF2A4A5E),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// بلوطی روی لبهٔ صحنهٔ ابری: نور گرم پشت، ورود از پایین و «سلام» کوتاه.
///
/// شخصیت خودش لایه‌ای و متحرک است؛ این ویجت فقط چیدمان ورود/شناوری و
/// هالهٔ نور پشت او را می‌سازد.
class _CharacterStage extends StatelessWidget {
  const _CharacterStage({
    required this.entrance,
    required this.ambient,
    required this.reduced,
    required this.width,
    required this.height,
  });

  final Animation<double> entrance;
  final Animation<double> ambient;
  final bool reduced;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final stageWidth = width * 1.45;
    final stageHeight = height * 1.16;
    return SizedBox(
      width: stageWidth,
      height: stageHeight,
      child: AnimatedBuilder(
        animation: Listenable.merge([entrance, ambient]),
        builder: (context, child) {
          final t = ((entrance.value - .30) / .64).clamp(0.0, 1.0);
          final eased = AppMotion.curveEntrance.transform(t);
          final bob = reduced
              ? 0.0
              : math.sin(ambient.value * 2 * math.pi * 1.5) * height * .016;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // هالهٔ گرم پشت شخصیت، هم‌زمان با ورود روشن می‌شود.
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      width: width * 2.0,
                      height: height * .92,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppColors.goldLight.withOpacity(.26 * eased),
                            AppColors.coral.withOpacity(.07 * eased),
                            Colors.transparent,
                          ],
                          stops: const [0, .5, 1],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: (stageWidth - width) / 2,
                bottom: bob + (1 - eased) * height * .20,
                width: width,
                height: height,
                // ورود نرم (محو + مقیاس) کار خود شخصیت است؛ اینجا فقط
                // بالا آمدن از لبهٔ ابر اضافه می‌شود تا دو محو روی هم نیفتد.
                child: child!,
              ),
            ],
          );
        },
        child: KartoniyaMascot(
          width: width,
          height: height,
          float: false,
          interactive: false,
          entrance: true,
          greet: true,
          semanticLabel: 'بلوطی، شخصیت کارتونی کارتونیا',
        ),
      ),
    );
  }
}

/// نشان، نام برند و شعار با ورود سه‌پله و هالهٔ نبض‌دار.
class _BrandBlock extends StatelessWidget {
  const _BrandBlock({
    required this.entrance,
    required this.ambient,
    required this.reduced,
    required this.compact,
    required this.logoSize,
    this.trailing,
  });

  final Animation<double> entrance;
  final Animation<double> ambient;
  final bool reduced;
  final bool compact;
  final double logoSize;
  final Widget? trailing;

  double _phase(double start, double end,
      {Curve curve = AppMotion.curveEntrance}) {
    return curve.transform(
      ((entrance.value - start) / (end - start)).clamp(0.0, 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoIn = reduced ? 1.0 : _phase(0, .46, curve: AppMotion.curvePop);
    final wordIn = reduced ? 1.0 : _phase(.16, .62);
    final taglineIn = reduced ? 1.0 : _phase(.30, .78);
    final titleSize = compact ? 27.0 : 33.0;

    return AnimatedBuilder(
      animation: entrance,
      builder: (context, _) {
        return Column(
          children: [
            SizedBox(
              width: logoSize * 2.1,
              height: logoSize * 2.1,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: ambient,
                    builder: (context, _) {
                      final halo = reduced
                          ? .62
                          : .48 + math.sin(ambient.value * 2 * math.pi) * .10;
                      return Opacity(
                        opacity: halo * logoIn,
                        child: Container(
                          width: logoSize * 2.1,
                          height: logoSize * 2.1,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.skyLight.withOpacity(.40),
                                AppColors.goldLight.withOpacity(.12),
                                Colors.transparent,
                              ],
                              stops: const [0, .45, 1],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Opacity(
                    opacity: logoIn.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: .58 + logoIn * .42,
                      child: Transform.rotate(
                        angle: (1 - logoIn) * -.16,
                        child: KartoniyaLogoMark(
                          size: logoSize,
                          showOrbit: !reduced,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: compact ? 2 : 6),
            Opacity(
              opacity: wordIn,
              child: Transform.translate(
                offset: Offset(0, (1 - wordIn) * 16),
                child: Text(
                  'کارتونیا',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: titleSize,
                    color: Colors.white,
                    letterSpacing: -.4,
                    shadows: const [
                      Shadow(
                        color: Color(0x99000000),
                        blurRadius: 18,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Opacity(
              opacity: taglineIn,
              child: Transform.translate(
                offset: Offset(0, (1 - taglineIn) * 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TaglineRule(color: AppColors.goldLight.withOpacity(.7)),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        'دنیای شاد و امن کودکان',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFFDCEBFA),
                                  fontWeight: FontWeight.w500,
                                  fontSize: compact ? 12.5 : 14,
                                ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    _TaglineRule(color: AppColors.goldLight.withOpacity(.7)),
                  ],
                ),
              ),
            ),
            if (trailing != null) ...[
              SizedBox(height: compact ? 18 : 24),
              Opacity(
                opacity: taglineIn.clamp(0.0, 1.0),
                child: trailing,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TaglineRule extends StatelessWidget {
  const _TaglineRule({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 2,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// ستاره‌های چشمک‌زن و ذرات نور؛ یک CustomPaint ساده، بدون blur و بدون
/// allocation سنگین در هر فریم.
class _SplashAtmospherePainter extends CustomPainter {
  const _SplashAtmospherePainter({required this.t});

  final double t;

  static const _stars = <(double, double, double, double)>[
    (.08, .10, 1.6, .10),
    (.18, .19, 1.1, .45),
    (.31, .07, 1.9, .72),
    (.44, .14, 1.0, .20),
    (.58, .06, 1.4, .88),
    (.72, .11, 1.8, .33),
    (.86, .07, 1.1, .61),
    (.93, .18, 1.5, .05),
    (.12, .32, 1.2, .52),
    (.26, .27, .9, .81),
    (.50, .24, 1.2, .14),
    (.68, .30, 1.6, .66),
    (.82, .26, 1.0, .28),
    (.90, .38, 1.4, .74),
    (.06, .48, 1.0, .37),
    (.36, .40, 1.3, .94),
    (.62, .43, 1.1, .17),
    (.76, .48, .9, .58),
    (.20, .60, 1.2, .69),
    (.88, .58, 1.1, .41),
  ];

  static const _motes = <(double, double, double, double)>[
    (.15, .66, .06, .2),
    (.84, .70, .05, .7),
    (.70, .60, .035, .35),
    (.28, .52, .025, .85),
    (.52, .74, .03, .5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final angle = t * 2 * math.pi;
    final starPaint = Paint();
    for (final star in _stars) {
      final twinkle =
          .35 + .65 * (.5 + .5 * math.sin(angle * 1.6 + star.$4 * 6.28));
      starPaint.color = Colors.white.withOpacity(.16 + .5 * twinkle);
      final position = Offset(star.$1 * size.width, star.$2 * size.height);
      canvas.drawCircle(position, star.$3 * (.8 + twinkle * .5), starPaint);
      if (star.$3 > 1.5) {
        _drawSparkle(
          canvas,
          position,
          star.$3 * 2.6 * twinkle,
          Paint()..color = AppColors.goldLight.withOpacity(.10 + twinkle * .35),
        );
      }
    }

    for (final mote in _motes) {
      final drift = math.sin(angle + mote.$4 * 6.28);
      final position = Offset(
        (mote.$1 + drift * .025) * size.width,
        (mote.$2 + math.cos(angle * .8 + mote.$4 * 6.28) * .02) * size.height,
      );
      final radius = mote.$3 * size.shortestSide;
      final rect = Rect.fromCircle(center: position, radius: radius);
      canvas.drawCircle(
        position,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.goldLight.withOpacity(.30),
              AppColors.goldLight.withOpacity(0),
            ],
          ).createShader(rect),
      );
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (var point = 0; point < 8; point++) {
      final a = point * math.pi / 4;
      final r = point.isEven ? radius : radius * .22;
      final p =
          Offset(center.dx + r * math.cos(a), center.dy + r * math.sin(a));
      if (point == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SplashAtmospherePainter oldDelegate) =>
      oldDelegate.t != t;
}

/// نشانگر آماده‌سازیِ برند: سه نقطه در یک کپسول شیشه‌ای.
class _SplashLoader extends StatefulWidget {
  const _SplashLoader({required this.exiting});

  final bool exiting;

  @override
  State<_SplashLoader> createState() => _SplashLoaderState();
}

class _SplashLoaderState extends State<_SplashLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _colors = [AppColors.coral, AppColors.gold, AppColors.tealLight];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );
    if (context.motionEnabledAtInit) _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.motion.enabled) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop(canceled: false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.exiting ? 0 : 1,
      duration: context.motion.dur(AppMotion.quick),
      child: Semantics(
        label: 'در حال آماده‌سازی کارتونیا',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.10),
            borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
            border: Border.all(color: Colors.white.withOpacity(.18)),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.5),
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          -math.sin((_controller.value + i * .22) * math.pi) *
                              4,
                        ),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _colors[i],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _colors[i].withOpacity(.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
