import 'package:flutter/material.dart';

import '../../core/services/fandoghi_store_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// معرفی غیرمزاحم برنامهٔ دیگر Parsa Apps؛ نشان عمومیِ اپ‌استورها به‌جای
/// آیکون رسمی جزیره فندقی استفاده می‌شود، چون آیکون اختصاصی در assets نیست.
class FandoghiPromotionCard extends StatelessWidget {
  const FandoghiPromotionCard({
    required this.onLaunchStarted,
    required this.onLaunchResult,
    this.launchStore,
    super.key,
  });

  final VoidCallback onLaunchStarted;
  final ValueChanged<FandoghiStoreLaunchResult> onLaunchResult;
  final Future<FandoghiStoreLaunchResult> Function()? launchStore;

  Future<void> _openStore(BuildContext context) async {
    onLaunchStarted();
    final result = await (launchStore ?? FandoghiStoreLauncher().open)();
    onLaunchResult(result);

    if (!context.mounted || result != FandoghiStoreLaunchResult.failed) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('باز کردن صفحهٔ جزیره فندقی ممکن نشد. دوباره تلاش کنید.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? const [Color(0xFF243B4B), Color(0xFF202A3A)]
                : const [Color(0xFFEAF8F8), Color(0xFFF5F1FF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(isDark ? .22 : .14),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: const Icon(
                      Icons.apps_rounded,
                      color: AppColors.tealDeep,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'برنامه‌های دیگر پارسا اپس',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: AppColors.tealDeep),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'جزیره فندقی',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'برنامه‌ای دیگر از Parsa Apps. برای دیدن معرفی و امکانات '
                'تأییدشدهٔ آن، صفحهٔ رسمی برنامه را در مایکت ببینید.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.secondaryTextColor,
                    ),
              ),
              const SizedBox(height: 15),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilledButton.icon(
                  onPressed: () => _openStore(context),
                  icon: const Icon(Icons.open_in_new_rounded, size: 19),
                  label: const Text('مشاهده در مایکت'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
