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
import '../widgets/parsa_brand.dart';
import '../widgets/kartoniya_mascot.dart';
import 'home_page.dart';
import 'onboarding_page.dart';

/// اسپلش برند کارتونیا با پردهٔ آغازین استودیوی Parsa Apps.
///
/// یک توالی پیوسته در یک صفحه: ابتدا هویت سازنده (پس‌زمینهٔ گرافیتی بسیار
/// تیره، خط نور طلایی، ورود لوگوی اصلی Parsa Apps با هاله و بازتاب نور، و
/// نوار پیشرفت طلایی با «در حال آماده‌سازی...») و سپس کراس‌فید نرم به صحنهٔ
/// شبانهٔ کارتونیا (ابرهای نرم، جزیرهٔ قصه، ماه، ستاره‌های چشمک‌زن و ورود
/// پلکانی نشان/نام/فندوقی) و خروج نرم به صفحهٔ بعد.
///
/// هیچ تأخیر تزئینیِ قفل‌کننده وجود ندارد: خروج زمانی رخ می‌دهد که کمینهٔ
/// نمایش برند دیده شده باشد **و** انیمیشن ورود تمام شده باشد **و** کاتالوگ
/// محلی آماده باشد (با سقف زمانی)، تا خانه بدون پرش و با دادهٔ حاضر باز شود.
/// خطای آماده‌سازی مسیر را قفل نمی‌کند و در مقصد مدیریت می‌شود.
///
/// هر حرکت با تنظیم دسترس‌پذیری کاهش حرکت سیستم به وضعیت نهایی می‌رسد و
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

  late final AnimationController _ident;
  late final AnimationController _handoff;
  late final AnimationController _progress;
  late final AnimationController _barSheen;

  late final Animation<double> _identLine;
  late final Animation<double> _identLogo;
  late final Animation<double> _identSheen;
  late final Animation<double> _identHalo;
  late final Animation<double> _loaderIn;

  final Completer<void> _entranceDone = Completer<void>();
  Timer? _tapEnableTimer;
  Timer? _sceneTimer;
  bool _leaving = false;
  bool _canSkip = false;
  bool _identGone = false;

  /// زمان‌بندی مرکزی اسپلش؛ تنها نقطهٔ تنظیم مدت‌ها همین‌جاست:
  /// کمینهٔ نمایش کل هویت بصری، مدت پردهٔ استودیو، لحظهٔ شروع صحنهٔ
  /// کارتونیا، دست‌به‌دستی بین دو پرده، مکث پیش از خروج و سقف آماده‌سازی.
  /// آماده‌سازی واقعی (کاتالوگ) می‌تواند خروج را عقب بیندازد ولی هرگز قفل
  /// نمی‌کند؛ هیچ عملیات شبکه‌ای صرفاً برای طولانی‌کردن اسپلش وجود ندارد.
  static const _minSplashBeat = Duration(milliseconds: 2000);
  static const _minSplashBeatReduced = Duration(milliseconds: 420);
  static const _identDuration = Duration(milliseconds: 1150);
  static const _sceneDelay = Duration(milliseconds: 650);
  static const _sceneDelayReduced = Duration(milliseconds: 260);
  static const _handoffDuration = Duration(milliseconds: 320);
  static const _holdBeforeExit = Duration(milliseconds: 140);
  static const _exitDuration = Duration(milliseconds: 300);
  static const _catalogTimeout = Duration(milliseconds: 1400);

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
    // پردهٔ استودیو: یک کنترل‌کننده و چند Interval تا خط نور، ورود لوگو،
    // بازتاب لبه‌ها و هالهٔ طلایی هم‌زمان ولی پلکانی حرکت کنند.
    _ident = AnimationController(vsync: this, duration: _identDuration);
    _identLine = CurvedAnimation(
      parent: _ident,
      curve: const Interval(.02, .46, curve: Curves.easeOutCubic),
    );
    _identLogo = CurvedAnimation(
      parent: _ident,
      curve: const Interval(.10, .66, curve: Curves.easeOutCubic),
    );
    _identSheen = CurvedAnimation(
      parent: _ident,
      curve: const Interval(.44, .98, curve: Curves.easeInOut),
    );
    _identHalo = CurvedAnimation(
      parent: _ident,
      curve: const Interval(.28, .92, curve: Curves.easeOut),
    );
    _loaderIn = CurvedAnimation(
      parent: _ident,
      curve: const Interval(.34, .78, curve: Curves.easeOut),
    );
    _handoff = AnimationController(vsync: this, duration: _handoffDuration);
    _handoff.addStatusListener((status) {
      // پس از کراس‌فید، پردهٔ استودیو از درخت حذف می‌شود تا بیهوده رنگ
      // نشود؛ بازتاب نوار هم برای همیشه می‌ایستد.
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _identGone = true);
        _barSheen.stop(canceled: false);
      }
    });
    _progress = AnimationController(vsync: this, duration: _minSplashBeat);
    _barSheen = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    // خروج با «بالا رفتن» آرام صحنه انجام می‌شود تا حس بازشدن در باشد و به
    // ورود پلکانی خانه گره بخورد.
    _exitScale = Tween<double>(begin: 1, end: 1.045).animate(
      CurvedAnimation(parent: _exit, curve: Curves.easeInCubic),
    );

    if (context.motionEnabledAtInit) {
      _ambient.repeat();
      _barSheen.repeat();
      _tapEnableTimer = Timer(
        const Duration(milliseconds: 450),
        () {
          if (mounted) setState(() => _canSkip = true);
        },
      );
    } else {
      _ident.value = 1;
      _entrance.value = 1;
      _progress.value = .8;
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
      _barSheen.stop(canceled: false);
      if (_ident.value < 1) _ident.value = 1;
      if (_entrance.value < 1) _entrance.value = 1;
      if (_progress.value < .8) _progress.value = .8;
      _canSkip = true;
    } else if (!_ambient.isAnimating && !_leaving) {
      _ambient.repeat();
      if (!_identGone && !_barSheen.isAnimating) _barSheen.repeat();
    }
  }

  @override
  void dispose() {
    _tapEnableTimer?.cancel();
    _sceneTimer?.cancel();
    _entrance.dispose();
    _ambient.dispose();
    _exit.dispose();
    _ident.dispose();
    _handoff.dispose();
    _progress.dispose();
    _barSheen.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final motion = context.motionEnabledAtInit;
    final beat = motion ? _minSplashBeat : _minSplashBeatReduced;

    // کاتالوگ موازی با انیمیشن آماده می‌شود؛ خطا مسیر را قفل نمی‌کند و در
    // خانهٔ مقصد با ErrorStateView و «تلاش دوباره» مدیریت می‌شود.
    final ready = ref
        .read(cartoonsProvider.future)
        .then<void>((_) {}, onError: (Object _) {})
        .timeout(_catalogTimeout, onTimeout: () {})
        .catchError((Object _) {});

    if (motion) {
      unawaited(_ident.forward());
      // نوار تا ۸۰٪ با همان کمینهٔ نمایش پر می‌شود و فقط با آماده‌شدن
      // واقعی به ۱۰۰٪ می‌رسد؛ پس کاربر معطل تزئین نمی‌ماند.
      unawaited(
        _progress
            .animateTo(.8, duration: beat, curve: Curves.easeOutCubic)
            .orCancel
            .catchError((_) {}),
      );
      _sceneTimer = Timer(_sceneDelay, _startScene);
    } else {
      _sceneTimer = Timer(_sceneDelayReduced, _startScene);
    }

    await Future.wait<void>([
      Future<void>.delayed(beat),
      _entranceDone.future,
      ready,
    ]);
    if (!mounted || _leaving) return;

    // نوار طلایی با آماده‌شدن واقعی کامل می‌شود، نه با تایمر تزئینی.
    if (context.motion.enabled) {
      await _progress
          .animateTo(1, duration: const Duration(milliseconds: 160))
          .orCancel
          .catchError((_) {});
    } else {
      _progress.value = 1;
    }
    if (!mounted || _leaving) return;

    // مکث کوتاه برای دیده‌شدن وضعیت نهایی، سپس خروج.
    await Future<void>.delayed(_holdBeforeExit);
    if (!mounted || _leaving) return;
    await _leave();
  }

  /// آغاز صحنهٔ کارتونیا هم‌زمان با محو پردهٔ استودیو؛ فقط یک‌بار.
  void _startScene() {
    if (!mounted || _leaving) return;
    if (!context.motion.enabled) {
      // کاهش حرکت: بدون انیمیشن، پرده‌ها جابه‌جا می‌شوند.
      _handoff.value = 1;
      _completeEntrance();
      return;
    }
    unawaited(_handoff.forward());
    _entrance.forward().orCancel.then(
          (_) => _completeEntrance(),
          onError: (Object _) => _completeEntrance(),
        );
  }

  void _completeEntrance() {
    if (!_entranceDone.isCompleted) _entranceDone.complete();
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
          // هم‌رنگ با پس‌زمینهٔ پردهٔ استودیو و launch_background بومی تا
          // هیچ پرش رنگی در دست‌به‌دست‌شدن لایه‌ها دیده نشود.
          backgroundColor: const Color(0xFF04060A),
          body: Semantics(
            label: 'کارتونیا، دنیای شاد و امن کودکان',
            hint: 'برای ورود ضربه بزن',
            child: FadeTransition(
              opacity: _exitOpacity,
              child: ScaleTransition(
                scale: _exitScale,
                child: _HandoffStack(
                  handoff: _handoff,
                  identGone: _identGone,
                  ident: _ParsaIdentLayer(
                    line: _identLine,
                    logo: _identLogo,
                    sheen: _identSheen,
                    halo: _identHalo,
                    loaderIn: _loaderIn,
                    progress: _progress,
                    barSheen: _barSheen,
                    ambient: _ambient,
                    reduced: !context.motion.enabled,
                  ),
                  scene: _SplashScene(
                    entrance: _entrance,
                    ambient: _ambient,
                    exiting: _leaving,
                  ),
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
        // فندوقی نشسته روی تخت ابر پایین کادر. اندازه‌ها نسبی‌اند تا روی
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

/// فندوقی روی لبهٔ صحنهٔ ابری: نور گرم پشت، ورود از پایین و «سلام» کوتاه.
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
          semanticLabel: 'فندوقی، شخصیت کارتونی کارتونیا',
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

/// کراس‌فید پیوستهٔ دو پردهٔ اسپلش. فرزندها یک‌بار در `build` ساخته می‌شوند
/// تا در فریم‌های محو فقط opacity دو لایه عوض شود و بازچینی سنگین رخ ندهد.
class _HandoffStack extends StatelessWidget {
  const _HandoffStack({
    required this.handoff,
    required this.identGone,
    required this.ident,
    required this.scene,
  });

  final Animation<double> handoff;
  final bool identGone;
  final Widget ident;
  final Widget scene;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: handoff,
      builder: (context, _) => Stack(
        fit: StackFit.expand,
        children: [
          Opacity(opacity: handoff.value, child: scene),
          if (!identGone) Opacity(opacity: 1 - handoff.value, child: ident),
        ],
      ),
    );
  }
}

/// پردهٔ آغازین استودیوی Parsa Apps: گرافیتی بسیار تیره، ذرات نور اندک،
/// خط نور طلایی، لوگوی اصلی با هاله و بازتاب نور، و نوار پیشرفت طلایی.
/// این لایه فقط «نمایش» است؛ تمام زمان‌بندی از [SplashPage] می‌آید تا یک
/// خط زمانی واحد و قابل تنظیم بماند.
class _ParsaIdentLayer extends StatelessWidget {
  const _ParsaIdentLayer({
    required this.line,
    required this.logo,
    required this.sheen,
    required this.halo,
    required this.loaderIn,
    required this.progress,
    required this.barSheen,
    required this.ambient,
    required this.reduced,
  });

  final Animation<double> line;
  final Animation<double> logo;
  final Animation<double> sheen;
  final Animation<double> halo;
  final Animation<double> loaderIn;
  final Animation<double> progress;
  final Animation<double> barSheen;
  final Animation<double> ambient;
  final bool reduced;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'استودیوی Parsa Apps؛ در حال آماده‌سازی کارتونیا',
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -.14),
            radius: 1.08,
            colors: [Color(0xFF0B101C), Color(0xFF05070C), Color(0xFF030408)],
            stops: [0, .58, 1],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final safe =
                MediaQuery.maybeOf(context)?.padding ?? EdgeInsets.zero;
            // لوگو بزرگ اما هرگز غالب نیست؛ تناسپ اصلی فایل حفظ می‌شود.
            final logoHeight = math.min(h * .42, math.min(w * .66, 460.0));
            final barWidth = math.min(w * .46, 230.0);
            return Stack(
              fit: StackFit.expand,
              children: [
                if (!reduced)
                  IgnorePointer(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: ambient,
                        builder: (context, _) => CustomPaint(
                          painter: _IdentMotesPainter(t: ambient.value),
                        ),
                      ),
                    ),
                  ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      28,
                      safe.top + 12,
                      28,
                      safe.bottom + 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation:
                              Listenable.merge([line, logo, sheen, halo]),
                          builder: (context, _) => _IdentEmblem(
                            line: line.value,
                            logo: logo.value,
                            sheen: sheen.value,
                            halo: halo.value,
                            height: logoHeight,
                            width: w,
                          ),
                        ),
                        SizedBox(height: math.max(18, h * .032)),
                        AnimatedBuilder(
                          animation: loaderIn,
                          builder: (context, _) => Opacity(
                            opacity: loaderIn.value,
                            child: _IdentLoader(
                              progress: progress,
                              barSheen: barSheen,
                              width: barWidth,
                              reduced: reduced,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// نشان استودیو با نورپردازی سینمایی: هالهٔ طلایی تثبیت‌شونده، خط نوری که
/// از مرکز عبور می‌کند و بازتاب نوری که روی لبه‌های خود لوگو می‌لغزد.
class _IdentEmblem extends StatelessWidget {
  const _IdentEmblem({
    required this.line,
    required this.logo,
    required this.sheen,
    required this.halo,
    required this.height,
    required this.width,
  });

  final double line;
  final double logo;
  final double sheen;
  final double halo;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final lineGlow = math.sin(math.pi * line.clamp(0.0, 1.0));
    final sheenGlow = math.sin(math.pi * sheen.clamp(0.0, 1.0));
    return Stack(
      alignment: Alignment.center,
      children: [
        // هالهٔ طلایی نرم؛ با همان لوگو بزرگ می‌شود و آرام تثبیت می‌گردد.
        Transform.scale(
          scale: .88 + .12 * halo,
          child: Container(
            width: height * 1.55,
            height: height * 1.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withOpacity(.26 * halo),
                  AppColors.goldDark.withOpacity(.10 * halo),
                  AppColors.gold.withOpacity(0),
                ],
                stops: const [0, .45, 1],
              ),
            ),
          ),
        ),
        // خط نور طلایی که از بخش مرکزی عبور می‌کند و محو می‌شود.
        Opacity(
          opacity: lineGlow.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset((line * 2 - 1) * width * .16, 0),
            child: Container(
              height: 1.4,
              width: width * .58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withOpacity(0),
                    AppColors.goldLight.withOpacity(.85),
                    AppColors.gold.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: logo.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - logo) * 12),
            child: Transform.scale(
              scale: .94 + .06 * logo,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ParsaBrandMark(height: height),
                  // بازتاب نور فقط روی خود پیکسل‌های لوگو می‌لغزد.
                  if (sheenGlow > .02)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ExcludeSemantics(
                          child: Opacity(
                            opacity: .5 * sheenGlow,
                            child: ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (rect) {
                                final shift = rect.width * 1.5 * (sheen - .5);
                                return const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0x00FFF6DF),
                                    Color(0xCCFFF6DF),
                                    Color(0x00FFF6DF),
                                  ],
                                  stops: [.30, .5, .70],
                                ).createShader(
                                  rect.shift(Offset(-shift, -shift * .55)),
                                );
                              },
                              child: ParsaBrandMark(height: height),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// نوار پیشرفت باریک طلایی با نور متحرک ظریف و متن فارسی آماده‌سازی.
class _IdentLoader extends StatelessWidget {
  const _IdentLoader({
    required this.progress,
    required this.barSheen,
    required this.width,
    required this.reduced,
  });

  final Animation<double> progress;
  final Animation<double> barSheen;
  final double width;
  final bool reduced;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([progress, barSheen]),
      builder: (context, _) {
        final value = progress.value.clamp(0.0, 1.0);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'در حال آماده‌سازی کارتونیا',
              child: SizedBox(
                width: width,
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Color(0x1AFFFFFF)),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: FractionallySizedBox(
                            widthFactor: value,
                            heightFactor: 1,
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: AlignmentDirectional.centerStart,
                                  end: AlignmentDirectional.centerEnd,
                                  colors: [
                                    AppColors.goldDark,
                                    AppColors.gold,
                                    AppColors.goldLight,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!reduced)
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: (barSheen.value * 1.2 - .1) * width,
                          width: 26,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0x00FFFFFF),
                                  Color(0x4DFFFFFF),
                                  Color(0x00FFFFFF),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'در حال آماده‌سازی...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.goldSoft.withOpacity(.8),
                    fontSize: 12.5,
                    letterSpacing: .2,
                    height: 1.6,
                  ),
            ),
          ],
        );
      },
    );
  }
}

/// ذرات نور اندک و بسیار آرام پردهٔ استودیو؛ یک CustomPaint سبک بدون blur.
class _IdentMotesPainter extends CustomPainter {
  const _IdentMotesPainter({required this.t});

  final double t;

  static const _motes = <(double, double, double, double)>[
    (.18, .72, 1.5, .10),
    (.30, .30, 1.1, .55),
    (.52, .80, 1.3, .80),
    (.68, .26, 1.0, .30),
    (.82, .62, 1.6, .65),
    (.44, .18, .9, .45),
    (.12, .48, 1.2, .90),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final angle = t * 2 * math.pi;
    final paint = Paint();
    for (final mote in _motes) {
      final pulse = .5 + .5 * math.sin(angle * 1.3 + mote.$4 * 6.28);
      paint.color = AppColors.goldLight.withOpacity(.05 + .11 * pulse);
      final position = Offset(
        (mote.$1 + math.sin(angle * .9 + mote.$4 * 6.28) * .012) * size.width,
        (mote.$2 + math.cos(angle * .7 + mote.$4 * 6.28) * .014) * size.height,
      );
      canvas.drawCircle(position, mote.$3 * (.85 + pulse * .4), paint);
    }
  }

  @override
  bool shouldRepaint(_IdentMotesPainter oldDelegate) => oldDelegate.t != t;
}
