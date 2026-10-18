import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/providers/cartoons_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/cartoon_card.dart';
import '../widgets/kartoniya_story_banner.dart';
import '../widgets/page_intro.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/state_views.dart';
import 'cartoon_detail_page.dart';

/// علاقه‌مندی‌ها؛ فقط شناسه‌های معتبرِ موجود در کاتالوگ نمایش داده می‌شوند
/// (شناسه‌های نامعتبر هنگام بارگذاری کاتالوگ پاک می‌شوند).
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key, this.onBrowse});

  /// بازگشت به برگهٔ خانه برای پیدا کردن کارتون جدید.
  final VoidCallback? onBrowse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final cartoons = ref.watch(cartoonsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'علاقه‌مندی‌ها',
          subtitle: favorites.isEmpty
              ? 'جایی برای کارتون‌های دوست‌داشتنی'
              : '${toFaDigits('${favorites.length}')} کارتون دوست‌داشتنی',
          icon: Icons.favorite_rounded,
          gradient: AppColors.warmGradient,
          leading: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: context.softBorderColor),
            ),
            child: const PreRenderedFlak(
              width: 42,
              height: 42,
              animate: false,
              semanticLabel: 'بلوطی، شخصیت کارتونی کارتونیا',
            ),
          ),
          trailing: favorites.isEmpty
              ? null
              : IconButton.filledTonal(
                  tooltip: 'پاک کردن همه',
                  onPressed: () => _confirmClear(context, ref),
                  icon: const Icon(Icons.delete_outline_rounded, size: 21),
                ),
        ),
        Expanded(
          child: cartoons.when(
            data: (items) {
              final selected = items
                  .where((cartoon) => favorites.contains(cartoon.id))
                  .toList(growable: false);
              if (selected.isEmpty) {
                final pinkAction = AppColors.fillAndText(AppColors.pink);
                return EmptyStateView(
                  title: 'هنوز چیزی اینجا نیست',
                  message: 'روی قلب هر کارتون بزن تا بعداً سریع‌تر پیدایش کنی.',
                  accent: AppColors.pink,
                  action: onBrowse == null
                      ? null
                      : FilledButton.icon(
                          onPressed: onBrowse,
                          icon: const Icon(Icons.explore_rounded),
                          label: const Text('گشتن در کارتون‌ها'),
                          style: FilledButton.styleFrom(
                            backgroundColor: pinkAction.fill,
                            foregroundColor: pinkAction.foreground,
                          ),
                        ),
                );
              }
              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.pageMargin,
                  10,
                  AppTheme.pageMargin,
                  100,
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: cartoonGridAspectRatio(context),
                ),
                itemCount: selected.length,
                itemBuilder: (context, index) => CartoonCard(
                  key: ValueKey(selected[index].id),
                  cartoon: selected[index],
                  onTap: () => pushAppPage<void>(
                    context,
                    CartoonDetailPage(cartoon: selected[index]),
                  ),
                ),
              );
            },
            loading: () => const _FavoritesLoading(),
            error: (_, __) => ErrorStateView(
              title: 'فهرست باز نشد',
              message: 'چیزی جور نشد؛ دوباره تلاش کن.',
              onRetry: () => ref.invalidate(cartoonsProvider),
              compact: true,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmParentAction(
      context,
      title: 'پاک کردن علاقه‌مندی‌ها؟',
      body: 'این فهرست فقط از همین دستگاه پاک می‌شود و قابل بازگردانی نیست.',
      confirmLabel: 'پاک کردن',
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(favoritesProvider.notifier).clear();
    if (context.mounted) {
      showKartoniyaFeedback(
        context,
        message: 'علاقه‌مندی‌ها پاک شد.',
        icon: Icons.delete_sweep_rounded,
      );
    }
  }
}

class _FavoritesLoading extends StatelessWidget {
  const _FavoritesLoading();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.pageMargin, 18, AppTheme.pageMargin, 20),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: cartoonGridAspectRatio(context),
      ),
      itemCount: 4,
      itemBuilder: (_, __) => const ShimmerCard(),
    );
  }
}
