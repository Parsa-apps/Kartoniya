import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import 'kartoniya_logo.dart';

/// هالهٔ نئونی و انیمیشن سینمایی لوگوی کارتونیا روی پلیر.
///
/// دو لوگو در گوشه‌های بالای کادر ویدئو با:
/// - ورود سینمایی (fade + scale + halo)
/// - پالس آرام هاله
/// - عبور نور باریک (sheen) محدود به خود لوگو
/// - هماهنگی با stagger بین چپ و راست
///
/// همه با AnimationController واقعی، بدون بازسازی کل صفحه در هر فریم.
class PlayerBrandOverlay extends StatefulWidget {
  const PlayerBrandOverlay({super.key});

  /// اندازهٔ لوگو به‌صورت کسری از عرض ویدئو (۵ تا ۸ درصد)
  static const double logoFraction = 0.065;

  /// حاشیهٔ امن از لبه‌ها
  static const double safePadding = 10;

  /// کمینه و بیشینهٔ اندازهٔ لوگو برای خوانایی
  static const double minLogoSize = 28;
  static const double maxLogoSize = 52;

  @override
  State<PlayerBrandOverlay> createState() => _PlayerBrandOverlayState();
}

class _PlayerBrandOverlayState extends State<PlayerBrandOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _pulse;
  late final AnimationController _sheen;
  late final Animation<double> _entranceOpacity;
  late final Animation<double> _entranceScale;
  late final Animation<double> _entranceHalo;
  Timer? _sheenTimer;

  @override
  void initState() {
    super.initState();
    final reduced = MotionScope.reducedGlobally;
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 640),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    _sheen = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );

    _entranceOpacity = CurvedAnimation(
      parent: _entrance,
      curve: Curves.easeOutCubic,
    );
    _entranceScale = Tween<double>(begin: 0.78, end: 1).animate(
      CurvedAnimation(parent: _entrance, curve: AppMotion.curvePop),
    );
    _entranceHalo = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.15, 1, curve: Curves.easeOut),
    );

    if (reduced) {
      _entrance.value = 1;
      _pulse.value = 0.5;
    } else {
      // entrance with slight delay for cinematic feel
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) _entrance.forward();
      });
      _pulse.repeat(reverse: true);
      // sheen every ~6 seconds, staggered
      _sheenTimer = Timer.periodic(const Duration(milliseconds: 6200), (_) {
        if (!mounted) return;
        if (_sheen.isAnimating) return;
        _sheen.forward(from: 0).then((_) {
          if (mounted) _sheen.value = 0;
        });
      });
      // first sheen after 2.8s
      Future.delayed(const Duration(milliseconds: 2800), () {
        if (mounted && !_sheen.isAnimating) {
          _sheen.forward(from: 0).then((_) {
            if (mounted) _sheen.value = 0;
          });
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = !context.motion.enabled;
    if (reduce) {
      _pulse.stop();
      _sheen.stop();
      if (_entrance.value < 1) _entrance.value = 1;
    } else {
      if (!_pulse.isAnimating && mounted) _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _sheenTimer?.cancel();
    _entrance.dispose();
    _pulse.dispose();
    _sheen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width <= 0 || !width.isFinite) return const SizedBox.shrink();
        final rawSize = width * PlayerBrandOverlay.logoFraction;
        final logoSize = rawSize
            .clamp(
              PlayerBrandOverlay.minLogoSize,
              PlayerBrandOverlay.maxLogoSize,
            )
            .toDouble();

        // Safe padding scales slightly with logo size
        final pad = (PlayerBrandOverlay.safePadding + logoSize * 0.08)
            .clamp(8.0, 14.0);

        return IgnorePointer(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Top-right logo (stagger 0)
              PositionedDirectional(
                top: pad,
                end: pad,
                child: _NeonLogo(
                  size: logoSize,
                  entranceOpacity: _entranceOpacity,
                  entranceScale: _entranceScale,
                  entranceHalo: _entranceHalo,
                  pulse: _pulse,
                  sheen: _sheen,
                  delayFraction: 0,
                  isRight: true,
                ),
              ),
              // Top-left logo (stagger 0.12)
              PositionedDirectional(
                top: pad,
                start: pad,
                child: _NeonLogo(
                  size: logoSize,
                  entranceOpacity: _entranceOpacity,
                  entranceScale: _entranceScale,
                  entranceHalo: _entranceHalo,
                  pulse: _pulse,
                  sheen: _sheen,
                  delayFraction: 0.14,
                  isRight: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// یک لوگوی نئونی با هالهٔ چندلایه و انعکاس نور
class _NeonLogo extends StatelessWidget {
  const _NeonLogo({
    required this.size,
    required this.entranceOpacity,
    required this.entranceScale,
    required this.entranceHalo,
    required this.pulse,
    required this.sheen,
    required this.delayFraction,
    required this.isRight,
  });

  final double size;
  final Animation<double> entranceOpacity;
  final Animation<double> entranceScale;
  final Animation<double> entranceHalo;
  final Animation<double> pulse;
  final Animation<double> sheen;
  final double delayFraction;
  final bool isRight;

  @override
  Widget build(BuildContext context) {
    final reduced = !context.motion.enabled;

    // Staggered entrance via Interval
    final delayedOpacity = reduced
        ? entranceOpacity
        : CurvedAnimation(
            parent: entranceOpacity,
            curve: Interval(
              delayFraction,
              1,
              curve: Curves.easeOutCubic,
            ),
          );
    final delayedScale = reduced
        ? entranceScale
        : Tween<double>(begin: 0.78, end: 1).animate(
            CurvedAnimation(
              parent: entranceHalo,
              curve: Interval(delayFraction, 1, curve: AppMotion.curvePop),
            ),
          );
    final delayedHalo = reduced
        ? entranceHalo
        : CurvedAnimation(
            parent: entranceHalo,
            curve: Interval(delayFraction * 0.5, 1, curve: Curves.easeOut),
          );

    // Sheen delayed for left logo
    final sheenAnim = reduced
        ? const AlwaysStoppedAnimation<double>(0)
        : CurvedAnimation(
            parent: sheen,
            curve: Interval(
              isRight ? 0 : 0.18,
              isRight ? 0.82 : 1,
              curve: Curves.easeInOut,
            ),
          );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([
          delayedOpacity,
          delayedScale,
          delayedHalo,
          pulse,
          sheenAnim,
        ]),
        builder: (context, child) {
          final opacity = delayedOpacity.value.clamp(0.0, 1.0);
          final scale = delayedScale.value;
          final haloIn = delayedHalo.value;
          // Pulse breathes 0.72 -> 1.0
          final pulseValue = reduced
              ? 0.85
              : 0.72 + (pulse.value * 0.28);

          // Combined halo intensity: entrance * pulse
          final haloIntensity = haloIn * pulseValue;

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.center,
              child: _buildLogoWithHalo(
                context,
                haloIntensity: haloIntensity,
                sheenValue: sheenAnim.value,
                pulseValue: pulseValue,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoWithHalo(
    BuildContext context, {
    required double haloIntensity,
    required double sheenValue,
    required double pulseValue,
  }) {
    // Colors for neon - matching Kartoniya sky brand
    // Outer glow: soft sky, mid: skyLight, inner: white core
    final outerOpacity = (0.22 * haloIntensity).clamp(0.0, 0.32);
    final midOpacity = (0.42 * haloIntensity).clamp(0.0, 0.55);
    final innerOpacity = (0.65 * haloIntensity).clamp(0.0, 0.75);

    // Slight pulse scaling for halo
    final haloScale = 0.96 + (pulseValue * 0.08);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Subtle backdrop for readability on bright scenes - NOT a heavy card
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.10 * haloIntensity),
                borderRadius: BorderRadius.circular(size * 0.30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.09 * haloIntensity),
                  width: 0.8,
                ),
              ),
            ),
          ),
          // Outer halo layers - multi-layer depth
          Transform.scale(
            scale: haloScale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.30),
                boxShadow: [
                  // Outer soft ambient
                  BoxShadow(
                    color: AppColors.sky.withOpacity(outerOpacity * 0.9),
                    blurRadius: size * 0.95,
                    spreadRadius: size * 0.04,
                  ),
                  // Mid glow - skyLight
                  BoxShadow(
                    color: AppColors.skyLight.withOpacity(midOpacity * 0.85),
                    blurRadius: size * 0.52,
                    spreadRadius: size * 0.02,
                  ),
                  // Inner core - white/coral for warmth
                  BoxShadow(
                    color: Colors.white.withOpacity(innerOpacity * 0.55),
                    blurRadius: size * 0.18,
                    spreadRadius: size * 0.01,
                  ),
                  // Separation shadow for contrast on light backgrounds
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22 * haloIntensity),
                    blurRadius: size * 0.22,
                    offset: Offset(0, size * 0.07),
                  ),
                ],
              ),
            ),
          ),
          // Second halo ring for depth - slightly larger
          Transform.scale(
            scale: haloScale * 1.08,
            child: Container(
              width: size * 0.92,
              height: size * 0.92,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.30 * 0.92),
                border: Border.all(
                  color: AppColors.skyLight.withOpacity(0.18 * haloIntensity),
                  width: size * 0.015,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.skyLight.withOpacity(0.15 * haloIntensity),
                    blurRadius: size * 0.7,
                    spreadRadius: -size * 0.05,
                  ),
                ],
              ),
            ),
          ),
          // The actual brand mark - crisp, no blur on itself
          _LogoWithSheen(
            size: size,
            sheenValue: sheenValue,
          ),
          // Subtle particle twinkles (only if not reduced)
          if (!MotionScope.reducedGlobally && haloIntensity > 0.6) ...[
            // Top sparkle
            Positioned(
              top: -size * 0.04,
              end: -size * 0.06,
              child: _TwinkleDot(
                size: size * 0.09,
                opacity: (0.55 + pulseValue * 0.35) * haloIntensity,
                pulse: pulseValue,
              ),
            ),
            // Bottom sparkle opposite
            Positioned(
              bottom: -size * 0.02,
              start: -size * 0.05,
              child: _TwinkleDot(
                size: size * 0.07,
                opacity: (0.45 + pulseValue * 0.30) * haloIntensity * 0.85,
                pulse: pulseValue,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// لوگو با انعکاس نور که فقط روی خود لوگو می‌لغزد
class _LogoWithSheen extends StatelessWidget {
  const _LogoWithSheen({required this.size, required this.sheenValue});

  final double size;
  final double sheenValue;

  @override
  Widget build(BuildContext context) {
    final logo = KartoniyaLogoMark(
      size: size,
      showOrbit: false,
      showFace: true,
    );

    if (sheenValue <= 0.01 || sheenValue >= 0.99) {
      // No sheen active - just logo
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.30),
        child: logo,
      );
    }

    // Active sheen - masked to logo shape
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.30),
      child: Stack(
        alignment: Alignment.center,
        children: [
          logo,
          // Sheen overlay masked to logo
          Positioned.fill(
            child: ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (rect) {
                // Diagonal narrow beam sliding across
                // t 0->1 maps to -1.5*width to 1.5*width
                final shift = (sheenValue * 2.4 - 0.7) * rect.width;
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: const [
                    Color(0x00FFFFFF),
                    Color(0x00FFFFFF),
                    Color(0xBFFFFFFF),
                    Color(0xFFFFFFFF),
                    Color(0xBFFFFFFF),
                    Color(0x00FFFFFF),
                    Color(0x00FFFFFF),
                  ],
                  stops: const [0.0, 0.32, 0.43, 0.50, 0.57, 0.68, 1.0],
                ).createShader(
                  Rect.fromLTWH(
                    rect.left + shift - rect.width * 0.5,
                    rect.top,
                    rect.width * 0.6,
                    rect.height,
                  ),
                );
              },
              child: Container(
                color: Colors.white.withOpacity(0.85 * _sheenIntensity(sheenValue)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _sheenIntensity(double t) {
    // Ease in/out, peak at middle
    if (t < 0.15) return (t / 0.15) * 0.7;
    if (t > 0.85) return ((1 - t) / 0.15) * 0.7;
    return math.sin((t - 0.15) / 0.7 * math.pi) * 0.9 + 0.2;
  }
}

/// نقطهٔ نوری کوچک کنار لوگو - subtle, not cartoonish
class _TwinkleDot extends StatelessWidget {
  const _TwinkleDot({
    required this.size,
    required this.opacity,
    required this.pulse,
  });

  final double size;
  final double opacity;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final scale = 0.85 + pulse * 0.22;
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity * 0.95),
          boxShadow: [
            BoxShadow(
              color: AppColors.skyLight.withOpacity(opacity * 0.55),
              blurRadius: size * 1.1,
              spreadRadius: size * 0.2,
            ),
            BoxShadow(
              color: AppColors.goldLight.withOpacity(opacity * 0.35),
              blurRadius: size * 1.8,
            ),
          ],
        ),
      ),
    );
  }
}
