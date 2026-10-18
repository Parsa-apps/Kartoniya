import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/cartoon_model.dart';
import 'cartoon_artwork.dart';
import 'favorite_button.dart';

/// «منتخب این هفته»: مهم‌ترین ورودی کودک به کارتونیا.
///
/// یک کاروسل تمام‌عرض با پوستر واقعی محتوا، پردهٔ خوانایی، برچسب دسته،
/// علاقه‌مندی، متادیتا و دکمهٔ پخش. کارت‌های کناری کمی کوچک‌تر و محوتر
/// دیده می‌شوند تا عمق ایجاد شود. چرخش خودکار فقط با حرکت مجاز، در
/// foreground و زمانی فعال است که کاربر در حال کشیدن نیست؛ با کاهش حرکت
/// کاملاً خاموش می‌شود.
class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({
    required this.cartoons,
    required this.onOpen,
    required this.onPlay,
    required this.isFavorite,
    required this.onToggleFavorite,
    super.key,
    this.height = 258,
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
  static const _autoAdvance = Duration(milliseconds: 7000);

  final PageController _controller = PageController(viewportFraction: .92);
  Timer? _autoTimer;
  int _page = 0;

  bool get _autoAllowed =>
      context.motion.enabled &&
      TickerMode.of(context) &&
      widget.cartoons.length > 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restartAutoAdvance();
  }

  @override
  void didUpdateWidget(covariant FeaturedCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cartoons.length != widget.cartoons.length) {
      if (mounted) setState(() => _page = 0);
      _restartAutoAdvance();
    }
  }

  void _restartAutoAdvance() {
    _autoTimer?.cancel();
    _autoTimer = null;
    if (!mounted || !_autoAllowed) return;
    _autoTimer = Timer.periodic(_autoAdvance, (_) {
      if (!mounted || !_controller.hasClients) return;
      // TickerMode وضعیت foreground را منعکس می‌کند؛ در پس‌زمینه هیچ
      // صفحه‌ای جابه‌جا نمی‌شود.
      if (!TickerMode.of(context)) return;
      final next = (_page + 1) % widget.cartoons.length;
      _controller.animateToPage(
        next,
        duration: AppMotion.soft,
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
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _autoTimer?.cancel();
    } else if (notification is ScrollEndNotification) {
      _restartAutoAdvance();
    }
    return false;
  }

  void _goTo(int index) {
    if (index == _page || !_controller.hasClients) return;
    _controller.animateToPage(
      index,
      duration: AppMotion.soft,
      curve: AppMotion.curveStandard,
    );
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
                onPageChanged: (index) {
                  if (index != _page) setState(() => _page = index);
                },
                itemBuilder: (context, index) {
                  final cartoon = widget.cartoons[index];
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      double delta = 0;
                      if (_controller.hasClients &&
                          _controller.position.hasContentDimensions) {
                        final page = _controller.page ??
                            _controller.initialPage.toDouble();
                        delta = (page - index).clamp(-1.0, 1.0).abs();
                      }
                      final reduced = !context.motion.enabled;
                      return Opacity(
                        opacity: reduced ? 1 : 1 - .26 * delta,
                        child: Transform.scale(
                          scale: reduced ? 1 : 1 - .055 * delta,
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: _SpotlightCard(
                        cartoon: cartoon,
                        onOpen: () => widget.onOpen(cartoon),
                        onPlay: () => widget.onPlay(cartoon),
                        isFavorite: widget.isFavorite(cartoon),
                        onToggleFavorite: () =>
                            widget.onToggleFavorite(cartoon),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            _CarouselDots(
              count: widget.cartoons.length,
              active: _page,
              onSelected: _goTo,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({
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
    return Semantics(
      container: true,
      label: '${cartoon.title}، ${cartoon.category}، '
          'امتیاز ${toFaDigits(cartoon.rating.toStringAsFixed(1))}',
      child: PressableScale(
        onTap: onOpen,
        pressedScale: .985,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge - 4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: CartoonArtwork.heroTagFor(cartoon),
                child: CartoonArtwork(
                  cartoon: cartoon,
                  borderRadius: 0,
                  showPlayAffordance: false,
                  showTitle: false,
                  emphasis: true,
                ),
              ),
              // پردهٔ بالا برای خوانایی برچسب‌ها.
              PositionedDirectional(
                start: 0,
                end: 0,
                top: 0,
                height: 86,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(.34),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // پردهٔ پایین برای عنوان، متادیتا و اکشن‌ها.
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 0,
                height: 158,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(.82),
                          Colors.black.withOpacity(.34),
                          Colors.transparent,
                        ],
                        stops: const [0, .55, 1],
                      ),
                    ),
                  ),
                ),
              ),
              // برچسب رده/دسته در بالا-شروع (سمت راست در RTL).
              PositionedDirectional(
                top: 12,
                start: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _GlassPill(
                      icon: Icons.auto_awesome_rounded,
                      label: 'منتخب این هفته',
                      color: AppColors.goldLight,
                    ),
                    if (cartoon.isNew) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.coral,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusCircular),
                          boxShadow:
                              AppTheme.glow(AppColors.coral, opacity: .4),
                        ),
                        child: Text(
                          'تازه',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PositionedDirectional(
                top: 8,
                end: 8,
                child: FavoriteButton(
                  isFavorite: isFavorite,
                  size: 38,
                  iconSize: 20,
                  tooltip: 'افزودن به علاقه‌مندی‌ها',
                  onPressed: onToggleFavorite,
                ),
              ),
              PositionedDirectional(
                start: 14,
                end: 14,
                bottom: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartoon.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        shadows: const [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _MetaChip(
                          icon: Icons.star_rounded,
                          iconColor: AppColors.goldLight,
                          label: toFaDigits(
                            cartoon.rating.toStringAsFixed(1),
                          ),
                        ),
                        _MetaChip(
                          icon: Icons.movie_outlined,
                          label:
                              '${toFaDigits('${cartoon.episodeCount}')} قسمت',
                        ),
                        if (cartoon.ageRange.trim().isNotEmpty)
                          _MetaChip(
                            icon: Icons.child_care_rounded,
                            label: 'سن ${toFaDigits(cartoon.ageRange)}',
                          ),
                        _MetaChip(
                          icon: Icons.sell_outlined,
                          label: cartoon.category,
                          tint: accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _PlayButton(
                          accent: accent,
                          onPlay: onPlay,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onOpen,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'جزئیات و قسمت‌ها',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(.9),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.chevron_left_rounded,
                                  size: 18,
                                  color: Colors.white.withOpacity(.9),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.accent, required this.onPlay});

  final Color accent;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'پخش',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPlay,
        child: Container(
          height: 38,
          padding: const EdgeInsetsDirectional.only(start: 12, end: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(accent, Colors.white, .18)!,
                accent,
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
            boxShadow: AppTheme.glow(accent, opacity: .42, lift: 6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 21,
              ),
              const SizedBox(width: 3),
              Text(
                'تماشا',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.92),
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color ?? AppColors.coral),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF26364E),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.iconColor,
    this.tint,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (tint ?? Colors.white).withOpacity(tint == null ? .16 : .30),
        borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
        border: Border.all(
          color: Colors.white.withOpacity(.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor ?? Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _CarouselDots extends StatelessWidget {
  const _CarouselDots({
    required this.count,
    required this.active,
    required this.onSelected,
  });

  final int count;
  final int active;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    if (count < 2) {
      return const SizedBox(height: 14);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: context.surfaceColor.withOpacity(.72),
            borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
            border: Border.all(color: context.softBorderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < count; i++)
                Semantics(
                  button: true,
                  selected: i == active,
                  label: 'اسلاید ${toFaDigits('${i + 1}')}',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelected(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 6,
                      ),
                      child: AnimatedContainer(
                        duration: context.motion.dur(AppMotion.quick),
                        curve: AppMotion.curveStandard,
                        width: i == active ? 20 : 7,
                        height: 6,
                        decoration: BoxDecoration(
                          gradient:
                              i == active ? AppColors.primaryGradient : null,
                          color: i == active
                              ? null
                              : context.secondaryTextColor.withOpacity(.30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
