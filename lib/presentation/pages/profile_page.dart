import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/child_profile_model.dart';
import '../../data/providers/cartoons_provider.dart';
import '../global_widgets/parental_gate_widget.dart';
import '../widgets/kartoniya_story_banner.dart';
import 'about_us_page.dart';
import 'privacy_page.dart';
import 'settings_page.dart';

/// فضای والدین؛ ورود به تنظیمات حساس با قفل والدین محافظت می‌شود.
/// کارت کودک فقط نام نمایشی و آواتار نگه می‌دارد و بدون قفل قابل ویرایش است.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentName = ref.watch(profileNameProvider);
    final child = ref.watch(childProfileProvider);
    final favorites = ref.watch(favoritesProvider);
    final history = ref.watch(watchHistoryProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: KartoniyaStoryBanner(
                  scene: KartoniyaScene.twilight,
                  height: 172,
                  eyebrow: 'فضای والدین',
                  title: 'سلام $parentName!',
                  subtitle: 'کنترل‌های امن و آرام برای خانواده',
                  actionLabel: 'ویرایش نام',
                  onAction: () => _editParentName(context, ref, parentName),
                  semanticLabel: 'فضای والدین، تصویر سه‌بعدی از پیش‌رندرشده',
                ),
              ),
            ),
            // ——— کارت کودک ———
            SliverToBoxAdapter(
              child: StaggeredReveal(
                index: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.pageMargin,
                    8,
                    AppTheme.pageMargin,
                    0,
                  ),
                  child: _ChildCard(
                    child: child,
                    onEdit: () => _editChild(context, ref, child),
                  ),
                ),
              ),
            ),
            // ——— آمار ———
            SliverToBoxAdapter(
              child: StaggeredReveal(
                index: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.pageMargin,
                    12,
                    AppTheme.pageMargin,
                    0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.favorite_rounded,
                          color: AppColors.pink,
                          value: favorites.length,
                          label: 'علاقه‌مندی',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.play_circle_fill_rounded,
                          color: AppColors.sky,
                          value: history.length,
                          label: 'ادامهٔ تماشا',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ——— کنترل و تنظیمات ———
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.pageMargin,
                  22,
                  AppTheme.pageMargin,
                  10,
                ),
                child: Text(
                  'کنترل و تنظیمات',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: StaggeredReveal(
                index: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.pageMargin,
                  ),
                  child: Card(
                    child: Column(
                      children: [
                        _ActionTile(
                          icon: Icons.lock_outline_rounded,
                          color: AppColors.sky,
                          title: 'تنظیمات والدین',
                          subtitle: 'ظاهر، پخش، کاهش حرکت و داده‌های محلی',
                          onTap: () => _openSettings(context),
                        ),
                        const Divider(indent: 72, endIndent: 16),
                        SwitchListTile.adaptive(
                          value: themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            ref
                                .read(themeModeProvider.notifier)
                                .setMode(value ? ThemeMode.dark : ThemeMode.light);
                          },
                          secondary: const Icon(Icons.dark_mode_outlined),
                          title: const Text('حالت تاریک'),
                          subtitle: const Text('برای تماشای راحت‌تر در شب'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ——— پشتیبانی ———
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.pageMargin,
                  22,
                  AppTheme.pageMargin,
                  10,
                ),
                child: Text(
                  'درباره و پشتیبانی',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: StaggeredReveal(
                index: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.pageMargin,
                  ),
                  child: Card(
                    child: _ActionTile(
                      icon: Icons.auto_awesome_rounded,
                      color: AppColors.goldDark,
                      title: 'Parsa Apps',
                      subtitle: 'دربارهٔ سازنده و پشتیبانی تلگرام',
                      onTap: () => pushAppPage<void>(
                        context,
                        const AboutUsPage(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.pageMargin,
                  22,
                  AppTheme.pageMargin,
                  110,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    onTap: () => pushAppPage<void>(
                      context,
                      const PrivacyPage(),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.tealSoft.withOpacity(
                          context.isDarkMode ? .10 : 1,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        border: Border.all(
                          color: AppColors.teal.withOpacity(.25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.privacy_tip_outlined,
                            color: AppColors.tealDeep,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'حریم خصوصی و داده‌ها',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'تنظیمات روی دستگاه می‌ماند؛ پخش ویدئو به سرویس میزبان متصل می‌شود.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: context.secondaryTextColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: AppColors.tealDeep,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    final allowed = await showParentalGate(context);
    if (!allowed || !context.mounted) return;
    await pushAppPage<void>(context, const SettingsPage());
  }

  Future<void> _editParentName(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('نام نمایشی والد'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 28,
          textInputAction: TextInputAction.done,
          onSubmitted: (value) =>
              Navigator.of(dialogContext).pop(value),
          decoration: const InputDecoration(
            hintText: 'مثلاً مامان یا بابا',
            counterText: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && context.mounted) {
      await ref.read(profileNameProvider.notifier).update(result);
    }
  }

  Future<void> _editChild(
    BuildContext context,
    WidgetRef ref,
    ChildProfileModel child,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      builder: (_) => _ChildEditorSheet(child: child),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, required this.onEdit});

  final ChildProfileModel child;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final (emoji, colorValue) = child.avatar;
    final color = Color(colorValue);
    final displayName =
        child.hasName ? child.name : 'کودک من';
    return PressableScale(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(.14),
              context.surfaceColor,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: color.withOpacity(.35)),
          boxShadow: AppTheme.softShadow(context),
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.lerp(color, Colors.white, .4)!,
                    color,
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                shape: BoxShape.circle,
                boxShadow: AppTheme.glow(color, opacity: .35),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    child.hasName
                        ? 'اینجا قلمروی کوچولوی توست ✨'
                        : 'برای شخصی‌شدن فضا، یک اسم و آواتار انتخاب کن',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.secondaryTextColor,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ChildEditorSheet extends ConsumerStatefulWidget {
  const _ChildEditorSheet({required this.child});

  final ChildProfileModel child;

  @override
  ConsumerState<_ChildEditorSheet> createState() => _ChildEditorSheetState();
}

class _ChildEditorSheetState extends ConsumerState<_ChildEditorSheet> {
  late final TextEditingController _nameController;
  late int _avatarIndex;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child.name);
    _avatarIndex = widget.child.avatarIndex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final notifier = ref.read(childProfileProvider.notifier);
    await notifier.rename(_nameController.text);
    await notifier.setAvatar(_avatarIndex);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppTheme.pageMargin,
        right: AppTheme.pageMargin,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'پروفایل کودک',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'فقط روی همین دستگاه ذخیره می‌شود؛ هیچ اطلاعات واقعی لازم نیست.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.secondaryTextColor,
                  ),
            ),
            const SizedBox(height: 18),
            Text('آواتار', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < ChildProfileModel.avatars.length; i++)
                  _AvatarOption(
                    index: i,
                    selected: _avatarIndex == i,
                    onTap: () => setState(() => _avatarIndex = i),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Text('نام نمایشی', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 16,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              decoration: const InputDecoration(
                hintText: 'مثلاً آرش یا نازگل',
                counterText: '',
                prefixIcon: Icon(Icons.face_retouching_natural_rounded),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('ذخیره'),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('انصراف'),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.index,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (emoji, colorValue) = ChildProfileModel.avatars[index];
    final color = Color(colorValue);
    return Semantics(
      button: true,
      selected: selected,
      label: 'آواتار $emoji',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedScale(
          scale: selected ? 1.08 : 1,
          duration: context.motion.dur(AppMotion.quick),
          curve: AppMotion.curvePop,
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? color.withOpacity(.2)
                  : context.surfaceAltColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? color : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: context.softBorderColor),
        boxShadow: AppTheme.softShadow(context),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: value),
                  duration: context.motion.dur(AppMotion.entrance),
                  curve: AppMotion.curveStandard,
                  builder: (context, animated, _) => Text(
                    toFaDigits('$animated'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.secondaryTextColor,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(.13),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.secondaryTextColor,
        size: 22,
      ),
    );
  }
}
