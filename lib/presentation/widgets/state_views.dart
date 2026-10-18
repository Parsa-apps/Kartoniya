import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import 'kartoniya_mascot.dart';

/// نمای حالت خالی استاندارد با ماسکٔ رابط و ورود نرم.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.title,
    required this.message,
    super.key,
    this.action,
    this.mascot = MascotMood.sleepy,
    this.accent,
  });

  final String title;
  final String message;
  final Widget? action;
  final MascotMood mascot;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.sky;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StaggeredReveal(
              index: 0,
              child: KartoniyaMascot(mood: mascot, size: 118, accent: color),
            ),
            const SizedBox(height: 20),
            StaggeredReveal(
              index: 1,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 8),
            StaggeredReveal(
              index: 2,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.secondaryTextColor,
                    ),
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 20),
              StaggeredReveal(index: 3, child: action!),
            ],
          ],
        ),
      ),
    );
  }
}

/// نمای خطا با توضیح صادقانه و دکمهٔ تلاش دوباره.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    required this.title,
    required this.message,
    required this.onRetry,
    super.key,
    this.compact = false,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact)
          const KartoniyaMascot(
            mood: MascotMood.confused,
            size: 96,
            accent: AppColors.coral,
            float: false,
          ),
        if (!compact) const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.secondaryTextColor,
              ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 20),
          label: const Text('تلاش دوباره'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.skyDeep,
            side: BorderSide(
              color: AppColors.sky.withOpacity(.5),
            ),
          ),
        ),
      ],
    );

    if (compact) {
      return Center(child: Padding(padding: const EdgeInsets.all(16), child: content));
    }
    return Center(
      child: Padding(padding: const EdgeInsets.all(24), child: content),
    );
  }
}
