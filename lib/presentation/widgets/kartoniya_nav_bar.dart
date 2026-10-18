import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';

class KartoniyaNavItem {
  const KartoniyaNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// نوار پیمایش پایین اختصاصی کارتونیا: شناور، کاملاً گرد، با نشانگر
/// کشویی نرم و تعویض انیمیشنی آیکون‌ها.
class KartoniyaNavBar extends StatelessWidget {
  const KartoniyaNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<KartoniyaNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final duration = context.motion.dur(AppMotion.soft);

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceAlt : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            border: Border.all(color: context.softBorderColor),
            boxShadow: AppTheme.mediumShadow(context),
          ),
          height: 66,
          padding: const EdgeInsets.all(7),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / items.length;
              return Stack(
                children: [
                  AnimatedPositionedDirectional(
                    duration: duration,
                    curve: AppMotion.curvePop,
                    start: itemWidth * selectedIndex + 2,
                    top: 0,
                    bottom: 0,
                    width: itemWidth - 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLarge),
                        boxShadow: AppTheme.glow(AppColors.sky, opacity: .38),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < items.length; i++)
                        Expanded(
                          child: _NavButton(
                            item: items[i],
                            selected: i == selectedIndex,
                            duration: duration,
                            onTap: () {
                              if (i == selectedIndex) return;
                              HapticFeedback.lightImpact();
                              onSelected(i);
                            },
                          ),
                        ),
                    ],
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

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final KartoniyaNavItem item;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Colors.white;
    final idleColor = context.secondaryTextColor;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: duration,
                switchInCurve: AppMotion.curvePop,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: Tween<double>(begin: .4, end: 1).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: const Interval(.55, 1),
                    ),
                  ),
                  child: Icon(
                    selected ? item.activeIcon : item.icon,
                    key: ValueKey(selected),
                    size: 23,
                    color: selected ? activeColor : idleColor,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: duration,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      fontSize: 10,
                      color: selected ? activeColor : idleColor,
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
