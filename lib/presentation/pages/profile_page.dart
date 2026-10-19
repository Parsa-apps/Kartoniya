import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/services/app_haptics.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/child_profile_model.dart';
import '../../data/providers/cartoons_provider.dart';
import '../global_widgets/parental_gate_widget.dart';
import '../widgets/child_avatar.dart';
import '../widgets/kartoniya_story_banner.dart';
import 'about_us_page.dart';
import 'privacy_page.dart';
import 'settings_page.dart';

/// فضای والدین بدون درخواست نام والد؛ پروفایل کودک مستقل و محلی است.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  eyebrow: 'پروفایل کودک',
                  title: child.hasName ? 'سلام ${child.name}!' : 'دنیای کوچولوی شما',
                  subtitle: 'نام، سن و آواتار فقط روی همین دستگاه می‌ماند',
                  semanticLabel: 'پروفایل کودک در کارتونیا',
                ),
              ),
            ),
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
                    onEdit: () => _editChild(context, child),
                  ),
                ),
              ),
            ),
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
                            ref.read(themeModeProvider.notifier).setMode(
                                  value ? ThemeMode.dark : ThemeMode.light,
                                );
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
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLarge),
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'پروفایل کودک روی دستگاه می‌ماند؛ پخش ویدئو به سرویس میزبان متصل می‌شود.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: context.secondaryTextColor,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
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

  Future<void> _editChild(BuildContext context, ChildProfileModel child) async {
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
    final avatar = child.avatar;
    final color = Color(avatar.colorValue);
    final displayName = child.hasName ? child.name : 'کودک من';
    final details = child.ageYears == null
        ? 'نام و سن را برای پروفایل کودک انتخاب کنید'
        : '${toFaDigits('${child.ageYears}')} سال • آواتار ${avatar.label}';

    return Semantics(
      button: true,
      label: 'ویرایش پروفایل کودک، $displayName، $details',
      child: PressableScale(
        onTap: onEdit,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(.14), context.surfaceColor],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: color.withOpacity(.35)),
            boxShadow: AppTheme.softShadow(context),
          ),
          child: Row(
            children: [
              ChildAvatar(index: child.avatarIndex, size: 66),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      details,
                      maxLines: 2,
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
  int? _ageYears;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child.name);
    _avatarIndex = widget.child.avatarIndex;
    _ageYears = widget.child.ageYears;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final age = _ageYears;
    if (name.isEmpty || age == null) return;

    await ref.read(childProfileProvider.notifier).updateProfile(
          name: name,
          ageYears: age,
          avatarIndex: _avatarIndex,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _nameController.text.trim().isNotEmpty && _ageYears != null;
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
              'نام، سن به سال و آواتار فقط روی این دستگاه ذخیره می‌شوند؛ تاریخ تولد لازم نیست.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.secondaryTextColor,
                  ),
            ),
            const SizedBox(height: 18),
            Text(
              'آواتار کودکانه',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              key: const Key('child-avatar-choices'),
              spacing: 8,
              runSpacing: 8,
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
            Text('نام کودک', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              maxLength: 16,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _save(),
              decoration: const InputDecoration(
                hintText: 'نام نمایشی یا یک اسم مستعار',
                counterText: '',
                prefixIcon: Icon(Icons.face_retouching_natural_rounded),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _ageYears,
              decoration: const InputDecoration(
                labelText: 'سن کودک به سال',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              items: [
                for (var age = 1; age <= 18; age++)
                  DropdownMenuItem(
                    value: age,
                    child: Text('${toFaDigits('$age')} سال'),
                  ),
              ],
              onChanged: (age) => setState(() => _ageYears = age),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: canSave ? _save : null,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('ذخیرهٔ پروفایل'),
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
    final avatar = ChildProfileModel.avatars[index];
    final color = Color(avatar.colorValue);
    return Semantics(
      button: true,
      selected: selected,
      label: 'آواتار ${avatar.label}',
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('child-avatar-option-$index'),
        onTap: () {
          AppHaptics.selection();
          onTap();
        },
        child: AnimatedScale(
          scale: selected ? 1.08 : 1,
          duration: context.motion.dur(AppMotion.quick),
          curve: AppMotion.curvePop,
          child: Container(
            width: 68,
            height: 68,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? color.withOpacity(.18) : context.surfaceAltColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? color : context.softBorderColor,
                width: selected ? 2.5 : 1,
              ),
              boxShadow: selected ? AppTheme.glow(color, opacity: .2) : null,
            ),
            child: ChildAvatar(index: index, size: 60),
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
