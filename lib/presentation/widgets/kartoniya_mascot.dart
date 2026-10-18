import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/services/app_haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';

/// حالت‌های احساسی شخصیت «فندوقی».
///
/// هر حالت چهرهٔ اختصاصی خودش را دارد (چشم/ابرو + دهان) و поз بدن هم
/// متناسب با همان حالت کمی تغییر می‌کند؛ حالت `happy` چهرهٔ پایهٔ تصویر
/// اصلی است و لایهٔ اضافه‌ای نمی‌خواهد.
enum MascotMood { happy, sleepy, confused, cheering, sad }

/// دارایی‌های ریگ‌شدهٔ «فندوقی»، شخصیت اصلی کارتونیا.
///
/// تصویر اصلی توسط مالک پروژه ارائه شده و پس‌زمینه‌اش حذف شده است. بدن،
/// دست‌ها، پاها و برگ به‌صورت لایه‌های جدا برش خورده‌اند تا در Flutter
/// واقعاً حرکت کنند (نه یک تصویر ثابت با افکت). این یک رندر از پیش ساخته
/// است؛ مدل سه‌بعدی بلادرنگ یا فایل glTF در پروژه وجود ندارد و ادعای 3D
/// زنده نمی‌شود.
abstract final class FandaqAssets {
  static const _dir = 'asset/images/fandaq';

  static const body = '$_dir/body.webp';
  static const leaf = '$_dir/leaf.webp';
  static const armLeft = '$_dir/arm_left.webp';
  static const armWave = '$_dir/arm_wave.webp';
  static const legLeft = '$_dir/leg_left.webp';
  static const legRight = '$_dir/leg_right.webp';
  static const eyesClosed = '$_dir/eyes_closed.webp';

  // چهره‌های چهار حالت؛ از فریم‌های هم‌قابِ ساخته‌شده از تصویر اصلی برش
  // خورده‌اند تا ابرو/چشم/دهان هر حالت جدا و هم‌تراز باشد.
  static const eyesLaugh = '$_dir/eyes_laugh.webp';
  static const mouthLaugh = '$_dir/mouth_laugh.webp';
  static const eyesSad = '$_dir/eyes_sad.webp';
  static const mouthSad = '$_dir/mouth_sad.webp';
  static const eyesCurious = '$_dir/eyes_curious.webp';
  static const mouthCurious = '$_dir/mouth_curious.webp';
  static const eyesSleepy = '$_dir/eyes_sleepy.webp';
  static const mouthSleepy = '$_dir/mouth_sleepy.webp';

  /// تصویر کامل برای جاهایی که فقط یک تصویر ثابت لازم است.
  static const still = '$_dir/pose.webp';

  /// پرترهٔ برند: چهرهٔ شاد فندوقی با لبهٔ نرم برای کاشی لوگو.
  /// عمداً در [all] نیست؛ ریگ شخصیت و نشان برند دو مصرف جدا دارند و
  /// بودجهٔ حافظهٔ ریگ نباید به‌خاطر لوگو بزرگ‌تر شود.
  static const faceMark = '$_dir/face_mark.webp';

  /// همهٔ لایه‌ها با هم پیش‌بارگذاری می‌شوند تا اولین ورود پرش نداشته باشد.
  static const all = [
    body,
    leaf,
    armLeft,
    armWave,
    legLeft,
    legRight,
    eyesClosed,
    eyesLaugh,
    mouthLaugh,
    eyesSad,
    mouthSad,
    eyesCurious,
    mouthCurious,
    eyesSleepy,
    mouthSleepy,
  ];
}

/// هندسهٔ یک لایه روی بوم اصلی (۵۹۹×۶۵۱).
class _Part {
  const _Part(this.asset, this.x, this.y, this.width, this.height, this.pivot);

  final String asset;
  final double x;
  final double y;
  final double width;
  final double height;

  /// نقطهٔ لولا به‌صورت کسری از خود اسپرایت (۰..۱).
  final Alignment pivot;
}

abstract final class _Rig {
  static const frameWidth = 599.0;
  static const frameHeight = 651.0;

  static const legLeft = _Part(
    FandaqAssets.legLeft,
    92,
    487,
    196,
    164,
    Alignment(.061, -.78),
  );
  static const legRight = _Part(
    FandaqAssets.legRight,
    254,
    521,
    180,
    130,
    Alignment(0, -.862),
  );
  static const armLeft = _Part(
    FandaqAssets.armLeft,
    0,
    339,
    114,
    204,
    Alignment(-.035, -.402),
  );
  static const armWave = _Part(
    FandaqAssets.armWave,
    512,
    249,
    87,
    152,
    Alignment(-1, .987),
  );
  static const body =
      _Part(FandaqAssets.body, 38, 0, 504, 598, Alignment.center);
  static const leaf = _Part(
    FandaqAssets.leaf,
    273,
    0,
    250,
    138,
    Alignment(-.784, .043),
  );
  static const eyesClosed = _Part(
    FandaqAssets.eyesClosed,
    93,
    227,
    352,
    130,
    Alignment.center,
  );
  // چهره‌های حالت‌ها؛ اعداد از همین اسپرایت‌های برش‌خورده آمده‌اند
  // (manifest در flakwork ساختهٔ ابزار است و در زمان اجرا لازم نیست).
  static const eyesLaugh = _Part(
    FandaqAssets.eyesLaugh,
    39,
    119,
    460,
    284,
    Alignment.center,
  );
  static const mouthLaugh = _Part(
    FandaqAssets.mouthLaugh,
    181,
    291,
    246,
    196,
    Alignment.center,
  );
  static const eyesSad = _Part(
    FandaqAssets.eyesSad,
    40,
    119,
    458,
    284,
    Alignment.center,
  );
  static const mouthSad = _Part(
    FandaqAssets.mouthSad,
    181,
    291,
    246,
    196,
    Alignment.center,
  );
  static const eyesCurious = _Part(
    FandaqAssets.eyesCurious,
    39,
    119,
    460,
    284,
    Alignment.center,
  );
  static const mouthCurious = _Part(
    FandaqAssets.mouthCurious,
    181,
    291,
    246,
    196,
    Alignment.center,
  );
  static const eyesSleepy = _Part(
    FandaqAssets.eyesSleepy,
    39,
    119,
    460,
    284,
    Alignment.center,
  );
  static const mouthSleepy = _Part(
    FandaqAssets.mouthSleepy,
    181,
    291,
    246,
    196,
    Alignment.center,
  );
}

/// «فندوقی» — شخصیت اصلی و راهنمای کارتونیا.
///
/// رفتارها:
/// * تنفس و شناوری آرام، تاب خوردن برگ و دست‌ها، پلک‌زدن نامنظم.
/// * لمس: پرش کوتاه، تکان دست و چهرهٔ خندان؛ با بازخورد لمسیِ قابل‌خاموش‌کردن.
/// * حالت‌ها: شاد، خواب‌آلود (پلک سنگین + خمیازه)، کنجکاو (ابروی بالا +
///   دهان گرد)، هیجان‌زده (چشم بستهٔ خندان + دهان باز) و غمگین/همدل
///   (ابروی افتاده + لب پایین). هر چهره از تصویر اصلی برش خورده است.
/// * با «کاهش حرکت» همهٔ کنترلرها و تایمرها می‌ایستند و یک فریم ثابت
///   آرام نمایش داده می‌شود (چهرهٔ همان حالت).
///
/// همهٔ کنترلرها و تایمرها در [dispose] آزاد می‌شوند و هیچ ticker در پس‌زمینه
/// با از دست رفتن فوکوس اجرا نمی‌شود (TickerMode خود Flutter متوقف می‌کند).
class KartoniyaMascot extends StatefulWidget {
  const KartoniyaMascot({
    super.key,
    this.mood = MascotMood.happy,
    this.size = 96,
    this.width,
    this.height,
    this.accent = AppColors.sky,
    this.float = true,
    this.onTap,
    this.semanticLabel = 'فندوقی، شخصیت کارتونی کارتونیا',
    this.interactive = true,
    this.entrance = false,
    this.greet = false,
    this.animate = true,
  });

  final MascotMood mood;

  /// عرض بوم؛ اگر [width] داده شود اندازهٔ دقیق همان است.
  final double size;
  final double? width;
  final double? height;

  /// رنگ تأکید صحنه (برای هالهٔ بسیار ملایم پشت شخصیت).
  final Color accent;

  /// شناوری عمودی آرام؛ در ردیف‌های کوچک خاموش شود.
  ///
  /// نفس کشیدن، تاب برگ و تکان دست‌ها مستقل از این پرچم همیشه زنده‌اند؛
  /// این پرچم فقط بالا–پایین رفتن کل بدن را روشن/خاموش می‌کند.
  final bool float;

  final VoidCallback? onTap;
  final String semanticLabel;

  /// اگر false باشد لمس و نقش دکمه حذف می‌شود (تصویر تزئینی).
  final bool interactive;

  /// ورود نرم (مقیاس + محو) در اولین نمایش.
  final bool entrance;

  /// یک «سلام» کوتاه پس از ورود: دست تکان می‌خورد و چشم‌ها برق می‌زنند.
  final bool greet;

  /// اگر false باشد کاملاً ثابت می‌ماند (برای آواتارهای کوچک).
  final bool animate;

  @override
  State<KartoniyaMascot> createState() => _KartoniyaMascotState();
}

class _KartoniyaMascotState extends State<KartoniyaMascot>
    with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _blink;
  late final AnimationController _reaction;
  late final AnimationController _intro;

  bool _motion = true;

  /// پلک‌زدن با یک کنترلر تکرارشونده انجام می‌شود (نه Timer) تا در تست‌های
  /// ویجت هیچ تایمر معلقی نماند و TickerMode هنگام رفتن به پس‌زمینه آن را
  /// خودکار متوقف کند.
  static const _blinkCycle = Duration(milliseconds: 4600);

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    _blink = AnimationController(vsync: this, duration: _blinkCycle);
    _reaction = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
    _intro = AnimationController(
      vsync: this,
      duration: AppMotion.entrance,
      value: 1,
    );
    _motion = context.motionEnabledAtInit;

    if (widget.entrance && _motion) {
      _intro.value = 0;
      _intro.forward();
    }
    if (widget.greet) {
      if (!_motion) {
        // با کاهش حرکت، سلام به‌صورت یک فریم ایستا دیده می‌شود.
        _reaction.value = 1;
      } else if (widget.entrance) {
        _intro.addStatusListener(_onIntroStatus);
      } else {
        _reaction.forward();
      }
    }
    _applyMotion();
    // تصاویر پس از اولین فریم در کش می‌نشینند تا تعویض حالت‌ها پرش نداشته باشد.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final asset in FandaqAssets.all) {
        precacheImage(AssetImage(asset), context);
      }
    });
  }

  void _onIntroStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _intro.removeStatusListener(_onIntroStatus);
      if (!mounted || !_motion) return;
      if (widget.greet) _reaction.forward();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final enabled = widget.animate && context.motion.enabled;
    if (enabled != _motion) {
      _motion = enabled;
      _applyMotion();
    }
  }

  void _applyMotion() {
    if (!mounted) return;
    if (_motion) {
      // چرخهٔ آیدل همیشه می‌چرخد تا آواتارهای کوچک هم «زنده» باشند؛
      // فقط شناوری عمودی بدن به [widget.float] گره خورده است.
      if (!_idle.isAnimating) _idle.repeat(reverse: true);
      if (!_blink.isAnimating) _blink.repeat();
    } else {
      _idle.stop();
      _blink.stop();
      if (!widget.greet) _reaction.stop();
      if (_idle.value != 0) _idle.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant KartoniyaMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) _applyMotion();
  }

  void _react() {
    if (_motion) {
      AppHaptics.selection();
      _reaction.forward(from: 0);
    }
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _intro.removeStatusListener(_onIntroStatus);
    _idle.dispose();
    _blink.dispose();
    _reaction.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? widget.size;
    final height =
        widget.height ?? widget.size * _Rig.frameHeight / _Rig.frameWidth;
    final mood = widget.mood;

    return Semantics(
      container: true,
      image: true,
      button: widget.interactive,
      enabled: widget.interactive,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.interactive ? _react : null,
        child: SizedBox(
          width: width,
          height: height,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_idle, _blink, _reaction, _intro]),
              builder: (context, _) {
                final t = _idle.value;
                final tap = Curves.easeOutCubic.transform(_reaction.value);
                // پلک: یک پنجرهٔ کوتاه در هر چرخه، دو نیم‌پلک برای حس طبیعی.
                final blinkPhase = _blink.value;
                final blinking = blinkPhase > .86 && blinkPhase < .93;
                final intro = Curves.easeOutBack.transform(
                  Curves.easeOutCubic.transform(_intro.value),
                );

                // ——— نفس و شناوری ———
                final bob = widget.float && _motion
                    ? math.sin(t * math.pi) * height * .012
                    : 0.0;
                final jump = -math.sin(math.pi * tap) * height * .05;

                // ——— حالت‌ها ———
                final sleepy = mood == MascotMood.sleepy;
                final sad = mood == MascotMood.sad;
                final waving = mood == MascotMood.cheering || (tap > 0 && !sad);

                final bodyTilt = sad
                    ? -.026
                    : sleepy
                        ? .018 * math.sin(t * math.pi * 2)
                        : mood == MascotMood.confused
                            ? .045
                            : .012 * math.sin(t * math.pi * 2 + .6);

                final leafSwing = sad
                    ? -.075 + .025 * math.sin(t * math.pi * 2)
                    : sleepy
                        ? .035 * math.sin(t * math.pi * 2) - .05
                        : .055 * math.sin(t * math.pi * 2 + .4);

                final waveSwing = waving
                    ? .20 * math.sin(t * math.pi * 4) + .10
                    : .05 * math.sin(t * math.pi * 2 + 1.2) - .02;
                // چرخش مثبت دستِ بالا را کمی پایین می‌آورد؛ بیش از این
                // مقدار، شانه از بدن جدا می‌شود.
                final armWave = waveSwing +
                    tap * .35 +
                    (sleepy ? .12 : 0) +
                    (sad ? .20 : 0);

                final armLeft = .045 * math.sin(t * math.pi * 2 + 2.2) +
                    (sleepy ? .12 : 0) +
                    (sad ? .10 : 0);
                final legSwing = sad
                    ? .006 * math.sin(t * math.pi * 2 + .9)
                    : .022 * math.sin(t * math.pi * 2 + .9);

                // چشم‌ها فقط برای پلک یا واکنش لمسی بسته می‌شوند؛ حالت
                // خواب‌آلود چهرهٔ پلک‌سنگین خودش را دارد.
                final closing = (_motion && blinking) || (tap > 0 && tap < .62);

                final (_Part? eyesPatch, _Part? mouthPatch) = switch (mood) {
                  MascotMood.cheering => (_Rig.eyesLaugh, _Rig.mouthLaugh),
                  MascotMood.sad => (_Rig.eyesSad, _Rig.mouthSad),
                  MascotMood.confused => (_Rig.eyesCurious, _Rig.mouthCurious),
                  MascotMood.sleepy => (_Rig.eyesSleepy, _Rig.mouthSleepy),
                  MascotMood.happy => (null, null),
                };

                // اسکواش و استرچ کارتونی هنگام لمس؛ با کاهش حرکت خنثی
                // می‌شود. نفس هم یک کشش بسیار ملایم عمودی دارد.
                final squash = _motion
                    ? math.sin(math.pi * tap) * .06 +
                        math.sin(t * math.pi * 2) * .006
                    : 0.0;

                return Opacity(
                  opacity: _intro.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: .9 + .1 * intro,
                    alignment: Alignment.bottomCenter,
                    child: Transform.translate(
                      offset: Offset(0, bob + jump),
                      child: Transform.scale(
                        scaleX: 1 + squash * .6,
                        scaleY: 1 - squash,
                        alignment: Alignment.bottomCenter,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final scale = math.min(
                              constraints.maxWidth / _Rig.frameWidth,
                              constraints.maxHeight / _Rig.frameHeight,
                            );
                            final dx = (constraints.maxWidth -
                                    _Rig.frameWidth * scale) /
                                2;
                            final dy = (constraints.maxHeight -
                                    _Rig.frameHeight * scale) /
                                2;

                            Widget part(
                              _Part spec, {
                              double angle = 0,
                              Widget? child,
                            }) {
                              final content = child ??
                                  Image.asset(
                                    spec.asset,
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.medium,
                                    gaplessPlayback: true,
                                    excludeFromSemantics: true,
                                  );
                              return Positioned(
                                left: dx + spec.x * scale,
                                top: dy + spec.y * scale,
                                width: spec.width * scale,
                                height: spec.height * scale,
                                child: angle == 0
                                    ? content
                                    : Transform.rotate(
                                        angle: angle,
                                        alignment: spec.pivot,
                                        child: content,
                                      ),
                              );
                            }

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // پاها و دست‌ها پشت بدن می‌نشینند.
                                part(_Rig.legLeft, angle: legSwing),
                                part(_Rig.legRight, angle: -legSwing),
                                part(_Rig.armLeft, angle: armLeft),
                                part(_Rig.armWave, angle: armWave),
                                Transform.rotate(
                                  angle: bodyTilt,
                                  alignment: Alignment.bottomCenter,
                                  child: SizedBox.expand(
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        part(_Rig.body),
                                        // چهره‌ها روی بدن و زیر برگ؛ ابتدا
                                        // چهرهٔ حالت، بعد پلک/واکنش روی چشم‌ها.
                                        if (eyesPatch != null) part(eyesPatch),
                                        if (mouthPatch != null)
                                          part(mouthPatch),
                                        // پلک آخر از همه می‌آید تا لبهٔ دهان/گونه
                                        // روی چشم بسته نیفتد.
                                        if (closing) part(_Rig.eyesClosed),
                                      ],
                                    ),
                                  ),
                                ),
                                part(_Rig.leaf, angle: leafSwing),
                                // ——— افکت‌های حالت (بدون فایل تصویری) ———
                                // خواب: سه «z» کوچک که بالای سر محو می‌شوند.
                                if (sleepy && _motion && width > 64)
                                  for (var i = 0; i < 3; i++)
                                    _DozingZ(
                                      phase: (t + i / 3) % 1,
                                      left: dx + 120 * scale,
                                      top: dy + 96 * scale,
                                      size: (16 * scale + 4)
                                          .clamp(9.0, 22.0)
                                          .toDouble(),
                                      color: AppColors.deepInk,
                                    ),
                                // شادی: دو جرقهٔ کوچک اطراف سر.
                                if (mood == MascotMood.cheering && _motion)
                                  for (var i = 0; i < 2; i++)
                                    _Twinkle(
                                      phase: (t * 2 + i * .5) % 1,
                                      left: dx + (i == 0 ? 96 : 470) * scale,
                                      top: dy + (i == 0 ? 84 : 200) * scale,
                                      size: (13 * scale + 3)
                                          .clamp(8.0, 20.0)
                                          .toDouble(),
                                      color: AppColors.gold,
                                    ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// «z» خواب که به‌آرامی بالا می‌رود و محو می‌شود.
class _DozingZ extends StatelessWidget {
  const _DozingZ({
    required this.phase,
    required this.left,
    required this.top,
    required this.size,
    required this.color,
  });

  final double phase;
  final double left;
  final double top;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fade = math.sin(math.pi * phase).clamp(0.0, 1.0).toDouble();
    return Positioned(
      left: left + phase * size * .9,
      top: top - phase * size * 2.4,
      child: IgnorePointer(
        child: Opacity(
          opacity: fade * .75,
          child: Text(
            'z',
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w800,
              height: 1,
              color: color,
              fontFamily: 'Vazirmatn',
            ),
          ),
        ),
      ),
    );
  }
}

/// جرقهٔ چهارپر کوچک برای حالت هیجان‌زده.
class _Twinkle extends StatelessWidget {
  const _Twinkle({
    required this.phase,
    required this.left,
    required this.top,
    required this.size,
    required this.color,
  });

  final double phase;
  final double left;
  final double top;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pulse = .5 + .5 * math.sin(phase * math.pi * 2);
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Transform.scale(
          scale: .7 + .5 * pulse,
          child: Opacity(
            opacity: .35 + .5 * pulse,
            child: Icon(Icons.auto_awesome_rounded, size: size, color: color),
          ),
        ),
      ),
    );
  }
}
