import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/cartoons_provider.dart';
import '../widgets/app_feedback.dart';
import '../widgets/kartoniya_story_banner.dart';

/// تنظیمات والدین: ظاهر، حرکت، پخش و داده‌های محلی.
/// رسیدن به این صفحه خودش از قفل والدین می‌گذرد و عملیات حساس
/// (پاک‌سازی داده) یک بار دیگر تأیید صریح می‌خواهد.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final autoplay = ref.watch(autoplayProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات والدین'),
        leading: IconButton(
          tooltip: 'بازگشت',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pageMargin,
                20,
                AppTheme.pageMargin,
                40,
              ),
              children: [
                const StaggeredReveal(
                  index: 0,
                  child: KartoniyaStoryBanner(
                    scene: KartoniyaScene.cloudworld,
                    height: 164,
                    eyebrow: 'تنظیمات خانواده',
                    title: 'تماشا به سبک خانهٔ شما',
                    subtitle: 'همه‌چیز از همین دستگاه و در اختیار والدین',
                    semanticLabel: 'فندوقی در دنیای ابری',
                  ),
                ),
                const SizedBox(height: 18),
                const StaggeredReveal(
                  index: 1,
                  child: _SectionLabel(label: 'ظاهر برنامه'),
                ),
                StaggeredReveal(
                  index: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: _ThemeSegments(
                        current: themeMode,
                        onChanged: (mode) =>
                            ref.read(themeModeProvider.notifier).setMode(mode),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const StaggeredReveal(
                  index: 2,
                  child: _SectionLabel(label: 'حرکت و انیمیشن'),
                ),
                StaggeredReveal(
                  index: 3,
                  child: Card(
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          value: reduceMotion,
                          onChanged: (value) => ref
                              .read(reduceMotionProvider.notifier)
                              .setEnabled(value),
                          secondary:
                              const Icon(Icons.motion_photos_on_outlined),
                          title: const Text('کاهش حرکت'),
                          subtitle: const Text(
                            'انیمیشن‌های تزئینی خاموش یا خیلی کوتاه می‌شوند؛ '
                            'مناسب گوشی‌های ضعیف‌تر یا کودکان حساس به حرکت',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const StaggeredReveal(
                  index: 4,
                  child: _SectionLabel(label: 'پخش ویدئو'),
                ),
                StaggeredReveal(
                  index: 5,
                  child: Card(
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          value: autoplay,
                          onChanged: (value) => ref
                              .read(autoplayProvider.notifier)
                              .setEnabled(value),
                          secondary:
                              const Icon(Icons.play_circle_outline_rounded),
                          title: const Text('پخش خودکار'),
                          subtitle: const Text(
                            'شروع خودکار ویدئو و رفتن به قسمت بعد پس از پایان',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const StaggeredReveal(
                  index: 6,
                  child: _SectionLabel(label: 'داده‌های این دستگاه'),
                ),
                StaggeredReveal(
                  index: 7,
                  child: Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.history_toggle_off_rounded),
                          title: const Text('پاک کردن ادامهٔ تماشا'),
                          subtitle: const Text(
                              'موقعیت قسمت‌های نیمه‌تمام پاک می‌شود'),
                          trailing: const Icon(Icons.delete_outline_rounded),
                          onTap: () => _clearHistory(context, ref),
                        ),
                        const Divider(indent: 72, endIndent: 16),
                        ListTile(
                          leading: const Icon(Icons.favorite_border_rounded),
                          title: const Text('پاک کردن علاقه‌مندی‌ها'),
                          subtitle: const Text(
                            'فهرست ذخیره‌شده فقط از این دستگاه حذف می‌شود',
                          ),
                          trailing: const Icon(Icons.delete_outline_rounded),
                          onTap: () => _clearFavorites(context, ref),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                StaggeredReveal(
                  index: 8,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(
                        context.isDarkMode ? .10 : .08,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: AppColors.teal.withOpacity(.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.tealDeep,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'تغییرات بلافاصله و فقط به‌صورت محلی ذخیره می‌شوند. '
                            'این نسخه دادهٔ کودک را به سرور ارسال نمی‌کند.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: context.secondaryTextColor,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _clearHistory(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmParentAction(
      context,
      title: 'پاک کردن ادامهٔ تماشا؟',
      body: 'این کار موقعیت همهٔ قسمت‌های نیمه‌تمام را پاک می‌کند.',
    );
    if (!confirmed) return;
    await ref.read(watchHistoryProvider.notifier).clear();
    if (context.mounted) {
      showKartoniyaFeedback(
        context,
        message: 'ادامهٔ تماشا پاک شد.',
        icon: Icons.delete_sweep_rounded,
      );
    }
  }

  Future<void> _clearFavorites(BuildContext context, WidgetRef ref) async {
    final confirmed = await confirmParentAction(
      context,
      title: 'پاک کردن علاقه‌مندی‌ها؟',
      body: 'این کار فقط فهرست ذخیره‌شدهٔ این دستگاه را پاک می‌کند.',
    );
    if (!confirmed) return;
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

/// انتخاب تم با سه بخش کشوییِ متحرک (جایگزین RadioListTileهای ساده).
class _ThemeSegments extends StatefulWidget {
  const _ThemeSegments({required this.current, required this.onChanged});

  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  @override
  State<_ThemeSegments> createState() => _ThemeSegmentsState();
}

class _ThemeSegmentsState extends State<_ThemeSegments> {
  static const _options = <(ThemeMode, String, IconData)>[
    (ThemeMode.system, 'خودکار', Icons.brightness_auto_rounded),
    (ThemeMode.light, 'روشن', Icons.light_mode_outlined),
    (ThemeMode.dark, 'تاریک', Icons.dark_mode_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final index = _options.indexWhere((o) => o.$1 == widget.current);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth / _options.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AnimatedPositionedDirectional(
                  duration: context.motion.dur(AppMotion.soft),
                  curve: AppMotion.curvePop,
                  start: width * index,
                  top: 0,
                  bottom: 0,
                  width: width,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      // متن/آیکون انتخاب‌شده سفید است؛ گرادیان باید خوانا باشد.
                      gradient: AppColors.readableGradient(
                        AppColors.primaryGradient,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: AppTheme.glow(AppColors.sky, opacity: .3),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final option in _options)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: option.$1 == widget.current,
                          label: option.$2,
                          excludeSemantics: true,
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onChanged(option.$1);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Column(
                                children: [
                                  Icon(
                                    option.$3,
                                    size: 22,
                                    color: option.$1 == widget.current
                                        ? Colors.white
                                        : context.secondaryTextColor,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.$2,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: option.$1 == widget.current
                                              ? Colors.white
                                              : context.secondaryTextColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                index == 0
                    ? 'روشن یا تاریک براساس تنظیم گوشی'
                    : 'همیشه یک حالت ثابت بماند',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.secondaryTextColor,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(label, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
