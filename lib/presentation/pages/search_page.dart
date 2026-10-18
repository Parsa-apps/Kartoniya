import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/cartoon_model.dart';
import '../../data/providers/cartoons_provider.dart';
import '../widgets/cartoon_card.dart';
import '../widgets/category_tile.dart';
import '../widgets/kartoniya_mascot.dart';
import '../widgets/page_intro.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/state_views.dart';
import 'cartoon_detail_page.dart';

/// جست‌وجوی فارسی با debounce، فیلتر دستهٔ واقعی، پیشنهادهای برگرفته از
/// کاتالوگ و حالت بدون نتیجهٔ راهنما.
///
/// منطق جست‌وجو در [searchResultsProvider] است (نرمال‌سازی حروف، رتبه‌بندی
/// مرتبط‌بودن). این صفحه فقط ورودی، فیلتر و نمایش را مدیریت می‌کند تا مسیر
/// داده و پخش دست‌نخورده بماند.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  String _query = '';
  String? _categoryFilter;
  bool _waitingForQuery = false;

  bool get _showSuggestions => _query.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(searchQueryProvider);
    _query = existing;
    if (existing.isNotEmpty) {
      _controller.value = TextEditingValue(
        text: existing,
        selection: TextSelection.collapsed(offset: existing.length),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _query = value;
      _waitingForQuery = value.trim().isNotEmpty;
      if (value.trim().isEmpty) _categoryFilter = null;
    });
    if (value.trim().isEmpty) {
      ref.read(searchQueryProvider.notifier).state = '';
      setState(() => _waitingForQuery = false);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      ref.read(searchQueryProvider.notifier).state = value;
      setState(() => _waitingForQuery = false);
    });
  }

  void _submitImmediately(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    ref.read(searchQueryProvider.notifier).state = trimmed;
    setState(() {
      _query = value;
      _waitingForQuery = false;
      if (trimmed.isEmpty) _categoryFilter = null;
    });
  }

  void _selectSuggestion(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _submitImmediately(value);
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    setState(() {
      _query = '';
      _waitingForQuery = false;
      _categoryFilter = null;
    });
    _focusNode.requestFocus();
  }

  void _requestFocus() {
    if (_focusNode.hasFocus) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNode.canRequestFocus) _focusNode.requestFocus();
    });
  }

  void _openDetail(CartoonModel cartoon) {
    pushAppPage<void>(context, CartoonDetailPage(cartoon: cartoon));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(searchFocusRequestProvider, (previous, next) {
      if (previous != null && next > previous) _requestFocus();
    });

    final result = ref.watch(searchResultsProvider);
    final categories = ref.watch(categoriesProvider);
    final catalogue =
        ref.watch(cartoonsProvider).valueOrNull ?? const <CartoonModel>[];
    final activeQuery = ref.watch(searchQueryProvider).trim();
    final hasQuery = _query.trim().isNotEmpty;
    final categoryCounts = <String, int>{
      for (final item in catalogue)
        item.category: (catalogue
            .where((cartoon) => cartoon.category == item.category)
            .length),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'جست‌وجو',
          subtitle: 'نام، موضوع یا دستهٔ کارتون را بنویس',
          icon: Icons.search_rounded,
          gradient: AppColors.skyGradient,
          trailing: hasQuery
              ? IconButton.filledTonal(
                  tooltip: 'پاک کردن جست‌وجو',
                  onPressed: _clear,
                  icon: const Icon(Icons.backspace_outlined, size: 20),
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.pageMargin,
            0,
            AppTheme.pageMargin,
            10,
          ),
          child: _SearchField(
            controller: _controller,
            focusNode: _focusNode,
            showClear: _query.isNotEmpty,
            onChanged: _onChanged,
            onSubmitted: _submitImmediately,
            onClear: _clear,
          ),
        ),
        if (hasQuery && !_showSuggestions)
          categories.maybeWhen(
            data: (items) => SizedBox(
              height: 42,
              child: CategoryPillRow(
                categories: items,
                selectedName: _categoryFilter,
                includeAll: true,
                compact: true,
                counts: categoryCounts,
                onSelected: (category) =>
                    setState(() => _categoryFilter = category?.name),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        const SizedBox(height: 4),
        Expanded(
          child: _showSuggestions
              ? _SearchLanding(
                  catalogue: catalogue,
                  categories: categories,
                  categoryCounts: categoryCounts,
                  onSuggestion: _selectSuggestion,
                  onTapPrompt: _requestFocus,
                  onCategorySelected: (category) {
                    setState(() => _categoryFilter = category?.name);
                    if (category != null) {
                      _selectSuggestion(category.name);
                    }
                  },
                )
              : _waitingForQuery
                  ? const _SearchGridLoading()
                  : result.when(
                      data: (items) {
                        final filtered = _categoryFilter == null
                            ? items
                            : items
                                .where(
                                  (cartoon) =>
                                      cartoon.category == _categoryFilter,
                                )
                                .toList(growable: false);
                        if (filtered.isEmpty) {
                          return EmptyStateView(
                            title: 'چیزی پیدا نشد',
                            message: _categoryFilter == null
                                ? 'املای کلمه را بررسی کن یا یک موضوع دیگر را '
                                    'امتحان کن؛ مثلاً «الفبا» یا «حیوانات».'
                                : 'در دستهٔ «$_categoryFilter» نتیجه‌ای برای '
                                    'این عبارت نیست. فیلتر دسته را بردار.',
                            mascot: MascotMood.confused,
                            accent: AppColors.coral,
                            action: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _clear,
                                  icon: const Icon(Icons.close_rounded),
                                  label: const Text('پاک کردن جست‌وجو'),
                                ),
                                if (_categoryFilter != null)
                                  FilledButton.icon(
                                    onPressed: () => setState(
                                      () => _categoryFilter = null,
                                    ),
                                    icon: const Icon(
                                      Icons.filter_alt_off_rounded,
                                    ),
                                    label: const Text('حذف فیلتر دسته'),
                                  ),
                              ],
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppTheme.pageMargin,
                                2,
                                AppTheme.pageMargin,
                                8,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 15,
                                    color: AppColors.skyDeep,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      '${toFaDigits('${filtered.length}')} نتیجه '
                                      'برای «${activeQuery.isEmpty ? _query : activeQuery}»',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: context.secondaryTextColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: _SearchResultGrid(
                                cartoons: filtered,
                                onTap: _openDetail,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const _SearchGridLoading(),
                      error: (_, __) => ErrorStateView(
                        title: 'جست‌وجو انجام نشد',
                        message: 'کاتالوگ در دسترس نیست؛ دوباره تلاش کن.',
                        onRetry: () => ref.invalidate(searchResultsProvider),
                        compact: true,
                      ),
                    ),
        ),
      ],
    );
  }
}

/// فیلد جست‌وجوی فارسی با آیکون، دکمهٔ پاک کردن و حالت فوکوس گرادیانی.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.showClear,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showClear;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) => AnimatedContainer(
        duration: context.motion.dur(AppMotion.quick),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge - 4),
          boxShadow: [
            BoxShadow(
              color: focusNode.hasFocus
                  ? AppColors.sky.withOpacity(.24)
                  : Colors.black.withOpacity(
                      context.isDarkMode ? .22 : .06,
                    ),
              blurRadius: focusNode.hasFocus ? 22 : 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textInputAction: TextInputAction.search,
          textDirection: TextDirection.rtl,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onTapOutside: (_) => focusNode.unfocus(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 14.5,
              ),
          decoration: InputDecoration(
            hintText: 'مثلاً اسکار، الفبا، حیوانات…',
            filled: true,
            fillColor: context.surfaceColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 10, end: 8),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 52,
              minHeight: 40,
            ),
            suffixIcon: showClear
                ? IconButton(
                    tooltip: 'پاک کردن جست‌وجو',
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 20),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge - 4),
              borderSide: BorderSide(color: context.softBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge - 4),
              borderSide: BorderSide(color: context.softBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge - 4),
              borderSide: const BorderSide(color: AppColors.sky, width: 1.8),
            ),
          ),
        ),
      ),
    );
  }
}

/// صفحهٔ شروع جست‌وجو: پیشنهادهای واقعی کاتالوگ + دعوت فندوقی.
class _SearchLanding extends StatelessWidget {
  const _SearchLanding({
    required this.catalogue,
    required this.categories,
    required this.categoryCounts,
    required this.onSuggestion,
    required this.onCategorySelected,
    required this.onTapPrompt,
  });

  final List<CartoonModel> catalogue;
  final AsyncValue<List<CategoryModel>> categories;
  final Map<String, int> categoryCounts;
  final ValueChanged<String> onSuggestion;
  final ValueChanged<CategoryModel?> onCategorySelected;
  final VoidCallback onTapPrompt;

  @override
  Widget build(BuildContext context) {
    // برچسب‌ها از دادهٔ واقعی; حذف تکراری‌ها با LinkedHashSet ترتیب را نگه
    // می‌دارد و هیچ دادهٔ نمایشیِ ساختگی اضافه نمی‌شود.
    final tags = <String>{};
    for (final cartoon in catalogue) {
      for (final tag in cartoon.tags) {
        if (tag.trim().isNotEmpty) tags.add(tag.trim());
      }
      if (tags.length >= 12) break;
    }
    final featuredTitles = catalogue
        .where((cartoon) => cartoon.isFeatured || cartoon.isNew)
        .map((cartoon) => cartoon.title)
        .take(4)
        .toList(growable: false);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pageMargin,
        6,
        AppTheme.pageMargin,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FelakSearchPrompt(onTap: onTapPrompt),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 17,
                color: AppColors.coral,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'از دسته‌ها شروع کن',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          categories.when(
            data: (items) => SizedBox(
              height: 42,
              child: CategoryPillRow(
                categories: items,
                selectedName: null,
                includeAll: false,
                compact: true,
                counts: categoryCounts,
                onSelected: onCategorySelected,
              ),
            ),
            loading: () => const LinearProgressIndicator(minHeight: 3),
            error: (_, __) => Text(
              'دسته‌ها در دسترس نیستند.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.secondaryTextColor,
                  ),
            ),
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.tag_rounded,
                  size: 17,
                  color: AppColors.violet,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'موضوع‌های پرطرفدار',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in tags)
                  // آیکون تکراری روی هر برچسب حذف شد؛ یک آیکون در تیتر
                  // کافی است و ردیف برچسب‌ها آرام‌تر دیده می‌شود.
                  _SuggestionChip(
                    label: tag,
                    color: AppColors.violet,
                    onTap: () => onSuggestion(tag),
                  ),
              ],
            ),
          ],
          if (featuredTitles.isNotEmpty) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.playlist_play_rounded,
                  size: 19,
                  color: AppColors.teal,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'پیشنهادهای کارتونیا',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Column(
              children: [
                for (final title in featuredTitles)
                  _SuggestionRow(
                    title: title,
                    onTap: () => onSuggestion(title),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FelakSearchPrompt extends StatelessWidget {
  const _FelakSearchPrompt({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: .99,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 16, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
            colors: [
              AppColors.sky.withOpacity(context.isDarkMode ? .18 : .12),
              context.surfaceColor,
            ],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: AppColors.sky.withOpacity(.18)),
        ),
        child: Row(
          children: [
            // خود شخصیت (لایه‌ای) به‌جای عکس ثابت: در صفحهٔ جست‌وجو هم
            // فندوقی زنده و هم‌هویت با بقیهٔ برنامه دیده می‌شود. لمس خودش
            // هم همان «برو به جست‌وجو» را اجرا می‌کند تا هیچ لمسی بی‌پاسخ
            // نماند؛ کارتِ پشتش هم همین اکشن را دارد.
            SizedBox(
              width: 82,
              height: 80,
              child: KartoniyaMascot(
                width: 82,
                height: 92,
                float: false,
                greet: true,
                onTap: onTap,
                semanticLabel: 'از فندوقی بپرس و جست‌وجو کن',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'از فندوقی بپرس',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'نام کارتون یا موضوعی که دوست داری بنویس؛ '
                    'فندوقی بهترین نتیجه‌ها را پیدا می‌کند.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.secondaryTextColor,
                          height: 1.6,
                        ),
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

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.onTap,
    this.color = AppColors.sky,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: .95,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
          border: Border.all(color: color.withOpacity(.24)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 12,
                color: context.primaryTextColor,
              ),
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: PressableScale(
        onTap: onTap,
        pressedScale: .985,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(color: context.softBorderColor),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                size: 17,
                color: context.secondaryTextColor,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                size: 18,
                color: context.secondaryTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultGrid extends StatelessWidget {
  const _SearchResultGrid({required this.cartoons, required this.onTap});

  final List<CartoonModel> cartoons;
  final ValueChanged<CartoonModel> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pageMargin,
        4,
        AppTheme.pageMargin,
        100,
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 210,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: cartoonGridAspectRatio(context),
      ),
      itemCount: cartoons.length,
      itemBuilder: (context, index) => StaggeredReveal(
        index: index,
        child: CartoonCard(
          key: ValueKey(cartoons[index].id),
          cartoon: cartoons[index],
          onTap: () => onTap(cartoons[index]),
        ),
      ),
    );
  }
}

class _SearchGridLoading extends StatelessWidget {
  const _SearchGridLoading();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pageMargin,
        6,
        AppTheme.pageMargin,
        20,
      ),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 210,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: cartoonGridAspectRatio(context),
      ),
      itemCount: 4,
      itemBuilder: (_, __) => const ShimmerCard(),
    );
  }
}
