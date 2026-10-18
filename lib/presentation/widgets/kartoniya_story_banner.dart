import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import 'kartoniya_mascot.dart';

/// Original Kartoniya scene illustrations. These are pre-rendered 3D stills;
/// they are not a live scene or a 3D model viewer.
enum KartoniyaScene {
  cloudworld,
  storybook,
  twilight,
  reading,
  fandaqReading,
  fandaqNight,
}

extension KartoniyaSceneAssets on KartoniyaScene {
  String get assetPath => switch (this) {
        KartoniyaScene.cloudworld => 'asset/images/cloudworld_hero.webp',
        KartoniyaScene.storybook => 'asset/images/storybook_garden.webp',
        KartoniyaScene.twilight => 'asset/images/twilight_library.webp',
        KartoniyaScene.reading => 'asset/images/flak_reading_scene.webp',
        KartoniyaScene.fandaqReading =>
          'asset/images/fandaq_scene_reading.webp',
        KartoniyaScene.fandaqNight => 'asset/images/fandaq_scene_night.webp',
      };
}

/// تصویر «فندوقی» با اندازهٔ دلخواه.
///
/// به‌جای یک PNG ثابت، همان شخصیت لایه‌ای و متحرک نمایش داده می‌شود؛ فقط
/// بدون لمس و شناوری تا در بنرها/آواتارها آرام بماند. تصویر کامل
/// ([assetPath]) برای پیش‌بارگذاری و تست‌ها نگه داشته شده است.
class PreRenderedFlak extends StatelessWidget {
  const PreRenderedFlak({
    super.key,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.semanticLabel = 'فندوقی، شخصیت کارتونی کارتونیا',
    this.animate = true,
    this.mood = MascotMood.happy,
    this.greet = false,
  });

  final double? width;
  final double? height;
  final AlignmentGeometry alignment;
  final String semanticLabel;

  /// حرکت آرام (پلک/تاب)؛ برای آواتارهای کوچک خاموش شود.
  final bool animate;

  /// چهرهٔ شخصیت؛ حالت‌های خالی/خطا چهرهٔ متفاوت می‌گیرند.
  final MascotMood mood;

  /// سلام کوتاه (تکان دست) پس از ورود.
  final bool greet;

  static const assetPath = FandaqAssets.still;

  @override
  Widget build(BuildContext context) {
    final w = width ?? 96;
    final h = height ?? 96;
    return SizedBox(
      width: w,
      height: h,
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: alignment,
        child: KartoniyaMascot(
          width: 240,
          height: 240 * 651 / 599,
          animate: animate,
          mood: mood,
          greet: greet,
          float: false,
          interactive: false,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }
}

/// Layered storybook banner using real bundled art and a light-touch pointer
/// parallax. No continuously running ticker: movement is driven only by touch
/// or pointer input, is muted outside the foreground, and disappears under
/// Reduce Motion.
class KartoniyaStoryBanner extends StatefulWidget {
  const KartoniyaStoryBanner({
    required this.title,
    required this.subtitle,
    super.key,
    this.eyebrow,
    this.scene = KartoniyaScene.cloudworld,
    this.height = 194,
    this.actionLabel,
    this.onAction,
    this.showMascot = true,
    this.semanticLabel,
    this.mood = MascotMood.happy,
    this.greet = false,
  });

  final String title;
  final String subtitle;
  final String? eyebrow;
  final KartoniyaScene scene;
  final double height;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showMascot;
  final String? semanticLabel;

  /// چهرهٔ فندوقی در بنر؛ بنر شب خواب‌آلود و بنر روز خندان است.
  final MascotMood mood;

  /// یک سلام کوتاه (تکان دست) وقتی بنر ساخته می‌شود.
  final bool greet;

  @override
  State<KartoniyaStoryBanner> createState() => _KartoniyaStoryBannerState();
}

class _KartoniyaStoryBannerState extends State<KartoniyaStoryBanner> {
  Offset _parallax = Offset.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!context.motion.enabled) _parallax = Offset.zero;
  }

  void _move(PointerEvent event, Size size) {
    if (!context.motion.enabled ||
        !TickerMode.of(context) ||
        size.width <= 0 ||
        size.height <= 0) {
      return;
    }
    final target = Offset(
      (((event.localPosition.dx / size.width) - .5) * 2)
          .clamp(-1.0, 1.0)
          .toDouble(),
      (((event.localPosition.dy / size.height) - .5) * 2)
          .clamp(-1.0, 1.0)
          .toDouble(),
    );
    if ((target - _parallax).distance < .07) return;
    setState(() => _parallax = target);
  }

  void _reset() {
    if (_parallax == Offset.zero) return;
    setState(() => _parallax = Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final coralAction = AppColors.fillAndText(AppColors.coral);
    // در ارتفاع کم (مثل بنر خانه روی گوشی ۳۲۰px) متن باید یک‌خطی و جمع‌وجور
    // بماند تا کارت ثابت‌ارتفاع سرریز نکند.
    final compact = widget.height < 180;
    final motion = context.motion;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final double mascotWidth = widget.showMascot
            ? math.min(widget.height * .79, width * .38).toDouble()
            : 0.0;
        final double textEndInset =
            widget.showMascot ? mascotWidth * .68 + 7 : 14.0;

        return Semantics(
          container: true,
          explicitChildNodes: true,
          label: widget.semanticLabel,
          child: Listener(
            onPointerMove: (event) => _move(event, Size(width, widget.height)),
            onPointerUp: (_) => _reset(),
            onPointerCancel: (_) => _reset(),
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                child: SizedBox(
                  width: double.infinity,
                  height: widget.height,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    fit: StackFit.expand,
                    children: [
                      IgnorePointer(
                        child: AnimatedContainer(
                          duration: motion.dur(AppMotion.quick),
                          curve: AppMotion.curveStandard,
                          transform: Matrix4.translationValues(
                            _parallax.dx * 5,
                            _parallax.dy * 4,
                            0,
                          ),
                          child: Transform.scale(
                            scale: 1.06,
                            child: Image.asset(
                              widget.scene.assetPath,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (context, error, stackTrace) =>
                                  const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: AppColors.skyGradient,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: AlignmentDirectional.centerStart,
                              end: AlignmentDirectional.centerEnd,
                              colors: [
                                Colors.white.withOpacity(.08),
                                Colors.white.withOpacity(.02),
                                AppColors.skyDeep.withOpacity(.08),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (widget.showMascot)
                        PositionedDirectional(
                          end: -8,
                          bottom:
                              -math.max(8.0, widget.height * .06).toDouble(),
                          child: IgnorePointer(
                            child: AnimatedContainer(
                              duration: motion.dur(AppMotion.quick),
                              curve: AppMotion.curveStandard,
                              transform: Matrix4.translationValues(
                                -_parallax.dx * 11,
                                -_parallax.dy * 7,
                                0,
                              ),
                              child: Transform.rotate(
                                angle: motion.enabled ? _parallax.dx * .035 : 0,
                                child: PreRenderedFlak(
                                  width: mascotWidth,
                                  height: widget.height * .99,
                                  mood: widget.mood,
                                  greet: widget.greet,
                                  semanticLabel:
                                      'فندوقی، شخصیت کارتونی کارتونیا',
                                ),
                              ),
                            ),
                          ),
                        ),
                      PositionedDirectional(
                        start: 12,
                        end: textEndInset,
                        top: 12,
                        bottom: 12,
                        child: Align(
                          alignment: AlignmentDirectional.topStart,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: widget.showMascot
                                  ? math
                                      .max(150.0, width - textEndInset - 20)
                                      .toDouble()
                                  : width - 40,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 13 : 15,
                                vertical: compact ? 8 : 11,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.84),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusLarge,
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(.78),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.skyDeep.withOpacity(.10),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.eyebrow != null) ...[
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.auto_awesome_rounded,
                                          color: AppColors.coral,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            widget.eyebrow!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  color: AppColors.skyDeep,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                  ],
                                  Text(
                                    widget.title,
                                    maxLines: compact ? 1 : 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: const Color(0xFF18324B),
                                          height: 1.28,
                                        ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.subtitle,
                                    maxLines:
                                        widget.actionLabel == null ? 2 : 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: const Color(0xFF425970),
                                          height: 1.45,
                                        ),
                                  ),
                                  if (widget.actionLabel != null &&
                                      widget.onAction != null) ...[
                                    SizedBox(height: compact ? 4 : 6),
                                    SizedBox(
                                      height: compact ? 32 : 36,
                                      child: FilledButton.icon(
                                        onPressed: widget.onAction,
                                        style: FilledButton.styleFrom(
                                          minimumSize:
                                              Size(0, compact ? 32 : 36),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          backgroundColor: coralAction.fill,
                                          foregroundColor:
                                              coralAction.foreground,
                                          visualDensity: VisualDensity.compact,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.radiusCircular,
                                            ),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.arrow_back_rounded,
                                          size: 17,
                                        ),
                                        label: Text(widget.actionLabel!),
                                      ),
                                    ),
                                  ],
                                ],
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
          ),
        );
      },
    );
  }
}
