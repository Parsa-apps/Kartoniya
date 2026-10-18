import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/cartoon_model.dart';
import 'cartoon_artwork.dart';
import 'favorite_button.dart';
import 'gradient_button.dart';

/// بنر محتوای منتخب: مهم‌ترین ورودی کودک به کارتونیا.
///
/// - پوستر تمام‌عرض با پارالاکس و محو ملایم صفحه‌های کناری
/// - حرکت خودکار که هنگام کشیدن انگشت کاربر متوقف و بعد از رهاکردن ادامه می‌یابد
/// - Hero Transition یکپارچه با صفحهٔ جزئیات
/// - با «کاهش حرکت»: بدون چرخش خودکار و بدون پارالاکس
class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({
    required this.cartoons,
    required this.onOpen,
    required this.onPlay,
    required this.isFavorite,
    required this.onToggleFavorite,
    super.key,
    this.height = 240,
  });

  final List<CartoonModel> cartoons;
  final ValueChanged<CartoonModel> onOpen;
  final ValueChanged<CartoonModel> onPlay;
  final bool Function(CartoonModel cartoon) isFavorite;
  final ValueChanged<CartoonModel> onToggleFavorite;
  final double height;

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  static const _autoAdvance = Duration(milliseconds: 6500);

  final PageController _controller = PageController(viewportFraction: .9);
  Timer? _autoTimer;
  int _page = 0;

  bool get _autoAllowed =>
      context.motion.enabled &&
      TickerMode.of(context) &&
      widget.cartoons.length > 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MotionScope and MediaQuery are inherited dependencies: read them only
    // after initState, and restart when reduced-motion settings change.
    _restartAutoAdvance();
  }

  @override
  void didUpdateWidget(covariant FeaturedCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cartoons.length != widget.cartoons.length) {
      setState(() => _page = 0);
      _restartAutoAdvance();
    }
  }

  void _restartAutoAdvance() {
    _autoTimer?.cancel();
    _autoTimer = null;
    if (!mounted || !_autoAllowed) return;
    _autoTimer = Timer.periodic(_autoAdvance, (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % widget.cartoons.length;
      _controller.animateToPage(
        next,
        duration: context.motion.dur(AppMotion.soft),
        curve: AppMotion.curveStandard,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    // کشیدن انگشت کاربر تایمر خودکار را قطع می‌کند؛ پس از توقف، از سر گرفته
    // می‌شود. اسکرول‌های برنامه‌ریزی‌شده (animateToPage) مزاحم نیستند.
    if (notification is ScrollStartNotification && notification.dragDetails != null) {
      _autoTimer?.cancel();
    } else if (notification is ScrollEndNotification) {
      _restartAutoAdvance();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cartoons.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: widget.height,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.cartoons.length,
                allowImplicitScrolling: false,
                onPageChanged: (index) => setState(() => _page = index),
                itemBuilder: (context, index) {
                  final cartoon = widget.cartoons[index];
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      double delta = 0;
                      if (_controller.hasClients &&
                          _controller.position.hasContentDimensions) {
                        final page =
                            _controller.page ?? _controller.initialPage.toDouble();
                        delta = (page - index).clamp(-1.0, 1.0).abs();
                      }
                      final reduced = !context.motion.enabled;
                      return Opacity(
                        opacity: reduced ? 1 : 1 - .3 * delta,
                        child: Transform.translate(
                          offset: Offset(0, reduced ? 0 : delta * 4),
                          child: Transform.scale(
                            scale: reduced ? 1 : 1 - .06 * delta,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: _FeaturedSlide(
                        cartoon: cartoon,
                        onOpen: () => widget.onOpen(cartoon),
                        onPlay: () => widget.onPlay(cartoon),
                        isFavorite: widget.isFavorite(cartoon),
                        onToggleFavorite: () => widget.onToggleFavorite(cartoon),
                      ),
                    ),
                  );
                },
              ),
            ),
            _CarouselDots(
              count: widget.cartoons.length,
              active: _page,
              color: AppColors.sky,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _FeaturedSlide extends StatelessWidget {
  const _FeaturedSlide({
    required this.cartoon,
    required this.onOpen,
    required this.onPlay,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final CartoonModel cartoon;
  final VoidCallback onOpen;
  final VoidCallback onPlay;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final accent = cartoon.artworkColor;
    return PressableScale(
      onTap: onOpen,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Hero(
                tag: CartoonArtwork.heroTagFor(cartoon),
                child: CartoonArtwork(
                  cartoon: cartoon,
                  borderRadius: 0,
                  showPlayAffordance: false,
                  showTitle: false,
                  emphasis: true,
                ),
              ),
            ),
            // پردهٔ پایین برای خوانایی متن روی پوستر.
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 0,
              height: 124,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(.64),
                        Colors.black.withOpacity(.2),
                        Colors.transparent,
                      ],
                      stops: const [0, .55, 1],
                    ),
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: 10,
              end: 10,
              child: FavoriteButton(
                isFavorite: isFavorite,
                size: 36,
                onPressed: onToggleFavorite,
              ),
            ),
            if (cartoon.isFeatured)
              PositionedDirectional(
                top: 12,
                start: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.94),
                    borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 13, color: AppColors.coralDeep),
                      const SizedBox(width: 4),
                      Text(
                        'پیشنهاد کارتونیا',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontSize: 10.5,
                              color: AppColors.coralDeep,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            PositionedDirectional(
              start: 16,
              end: 16,
              bottom: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartoon.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Colors.black38, blurRadius: 6),
                          ],
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${cartoon.category} · ${toFaDigits('${cartoon.episodeCount}')} قسمت',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          label: 'شروع تماشا',
                          icon: Icons.play_arrow_rounded,
                          compact: true,
                          height: 42,
                          gradient: AppColors.actionGradient(accent),
                          glowColor: accent,
                          onPressed: onPlay,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarouselDots extends StatelessWidget {
  const _CarouselDots({
    required this.count,
    required this.active,
    required this.color,
  });

  final int count;
  final int active;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (count < 2) return const SizedBox(height: 10);
    return Semantics(
      label: 'صفحهٔ ${active + 1} از $count',
      child: SizedBox(
        height: 10,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < count; i++)
                AnimatedContainer(
                  duration: context.motion.dur(AppMotion.quick),
                  curve: AppMotion.curveStandard,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == active ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == active ? color : color.withOpacity(.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
