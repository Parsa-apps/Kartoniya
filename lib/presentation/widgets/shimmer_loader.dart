import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_theme.dart';

/// اسکلتون‌های هماهنگ با کارت‌های واقعی؛ ابعاد آن‌ها با CartoonCard هم‌اندازه
/// است تا هنگام بارگذاری، layout جابه‌جا نشود (بدون افت کیفیت ورود اطلاعات).
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: compact ? 1.55 : 1.42,
              child: const _Block(radius: 0),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Block(width: double.infinity, height: 14),
                    Row(
                      children: [
                        _Block(width: 56, height: 11),
                        Spacer(),
                        _Block(width: 30, height: 11),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// اسکلت بنر ویژه (کاروسل).
class ShimmerHeroBanner extends StatelessWidget {
  const ShimmerHeroBanner({super.key, this.height = 200});

  final double height;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageMargin),
        child: _Block(radius: AppTheme.radiusXLarge, height: height),
      ),
    );
  }
}

/// اسکلت ردیف افقی کارت‌های جمع‌وجور.
class ShimmerCompactRow extends StatelessWidget {
  const ShimmerCompactRow(
      {super.key, this.itemCount = 3, this.itemWidth = 210});

  final int itemCount;
  final double itemWidth;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageMargin),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, __) => SizedBox(
        width: itemWidth,
        child: const ShimmerCard(compact: true),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceVariant,
      highlightColor: scheme.surface,
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({this.width, this.height, this.radius = 10});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
