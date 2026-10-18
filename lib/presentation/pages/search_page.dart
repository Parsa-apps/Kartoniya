import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../data/models/cartoon_model.dart';
import '../../data/providers/cartoons_provider.dart';
import '../widgets/cartoon_card.dart';
import '../widgets/kartoniya_mascot.dart';
import '../widgets/motion_progress_indicator.dart';
import '../widgets/state_views.dart';
import 'cartoon_detail_page.dart';

/// جست‌وجوی فارسی با debounce، فیلتر دسته واقعی و حالت بدون نتیجهٔ راهنما.
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

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      _query = value;
      _waitingForQuery = value.trim().isNotEmpty;
    });
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      ref.read(searchQueryProvider.notifier).state = '';
      setState(() => _waitingForQuery = false);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 240), () {
      if (!mounted) return;
      ref.read(searchQueryProvider.notifier).state = value;
      setState(() => _waitingForQuery = false);
    });
  }

  void _submitImmediately(String value) {
    _debounce?.cancel();
    ref.read(searchQueryProvider.notifier).state = value;
    setState(() => _waitingForQuery = false);
  }

  void _selectSuggestion(String value) {
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _submitImmediately(value);
  }

  void _openDetail(CartoonModel cartoon) {
    pushAppPage<void>(context, CartoonDetailPage(cartoon: cartoon));
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(searchResultsProvider);
    final categories = ref.watch(categoriesProvider);
    final showSuggestions = _query.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.pageMargin,
            18,
            AppTheme.pageMargin,
            12,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'جست‌وجو',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      'نام، موضوع یا دستهٔ کارتون را بنویس',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.secondaryTextColor,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: AppColors.coolGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Icon(
                  Icons.search_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageMargin),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onChanged: _onChanged,
            onSubmitted: _submitImmediately,
            decoration: InputDecoration(
              hintText: 'مثلاً فِلَک، ریاضی یا خواب…',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'پاک کردن جست‌وجو',
                      onPressed: () {
                        _controller.clear();
                        _onChanged('');
                        _focusNode.requestFocus();
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // فیلتر دسته فقط وقتی معنا دارد که جست‌وجویی انجام شده باشد.
        if (!showSuggestions)
          categories.maybeWhen(
            data: (items) => SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.pageMargin,
                ),
                children: [
                  _SearchFilterChip(
                    label: 'همه',
                    emoji: '✨',
                    selected: _categoryFilter == null,
                    color: AppColors.sky,
                    onTap: () => setState(() => _categoryFilter = null),
                  ),
                  for (final category in items.where((c) => c.id != 'all'))
                    _SearchFilterChip(
                      label: category.name,
                      emoji: category.emoji,
                      selected: _categoryFilter == category.name,
                      color: category.color,
                      onTap: () => setState(
                        () => _categoryFilter = category.name,
                      ),
                    ),
                ],
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        const SizedBox(height: 10),
        Expanded(
          child: showSuggestions
              ? _SearchSuggestions(onSelected: _selectSuggestion)
              : _waitingForQuery
                  ? const Center(
                      child: MotionProgressIndicator(
                        size: 26,
                        strokeWidth: 2.6,
                      ),
                    )
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
                            message:
                                'املای کلمه را بررسی کن، فیلتر دسته را بردار یا یک دستهٔ دیگر را امتحان کن.',
                            mascot: MascotMood.confused,
                            accent: AppColors.coral,
                            action: OutlinedButton.icon(
                              onPressed: () => setState(
                                () => _categoryFilter = null,
                              ),
                              icon: const Icon(Icons.filter_alt_off_rounded),
                              label: const Text('حذف فیلتر دسته'),
                            ),
                          );
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.pageMargin,
                              ),
                              child: Text(
                                '${toFaDigits('${filtered.length}')} نتیجه',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: context.secondaryTextColor,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: _SearchResultGrid(
                                cartoons: filtered,
                                onTap: _openDetail,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: MotionProgressIndicator(),
                      ),
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

class _SearchFilterChip extends StatelessWidget {
  const _SearchFilterChip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor = AppColors.actionColor(color);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: context.motion.dur(AppMotion.quick),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: selected ? selectedColor : context.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
            border: Border.all(
              color: selected ? selectedColor : color.withOpacity(.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 5),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected ? Colors.white : context.primaryTextColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSuggestions extends ConsumerWidget {
  const _SearchSuggestions({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pageMargin,
        8,
        AppTheme.pageMargin,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              KartoniyaMascot(size: 52, mood: MascotMood.happy, float: false),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'دنبال چه کارتونی می‌گردی؟ یک دسته را انتخاب کن یا نامش را بنویس.',
                  style: TextStyle(height: 1.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'دسته‌ها',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          categories.when(
            data: (items) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .where((category) => category.id != 'all')
                  .map(
                    (category) => ActionChip(
                      avatar: Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 15),
                      ),
                      label: Text(category.name),
                      onPressed: () => onSelected(category.name),
                    ),
                  )
                  .toList(growable: false),
            ),
            loading: () => const LinearProgressIndicator(minHeight: 3),
            error: (_, __) => Text(
              'دسته‌ها در دسترس نیستند.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.secondaryTextColor,
                  ),
            ),
          ),
        ],
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
          AppTheme.pageMargin, 4, AppTheme.pageMargin, 20),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: .74,
      ),
      itemCount: cartoons.length,
      itemBuilder: (context, index) => StaggeredReveal(
        index: index,
        child: CartoonCard(
          cartoon: cartoons[index],
          onTap: () => onTap(cartoons[index]),
        ),
      ),
    );
  }
}
