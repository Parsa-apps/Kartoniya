// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/full_screen_utils.dart';
import '../../data/models/cartoon_model.dart';
import 'cartoon_artwork.dart';
import 'player_brand_overlay.dart';

/// پخش‌کنندهٔ رسمی مبتنی بر WebView.
/// فقط endpoint مجاز embed آپارات را باز می‌کند؛ هیچ استخراج CDN،
/// جعل User-Agent یا دور زدن محدودیت انجام نمی‌شود.
/// هر hash دقیقاً به همان ویدئوی تأیید‌شده می‌رسد.
class AparatPlayer extends StatefulWidget {
  const AparatPlayer({
    required this.cartoon,
    required this.initialEpisode,
    super.key,
  });

  final CartoonModel cartoon;
  final EpisodeModel initialEpisode;

  @override
  State<AparatPlayer> createState() => _AparatPlayerState();
}

class _AparatPlayerState extends State<AparatPlayer>
    with WidgetsBindingObserver {
  WebViewController? _controller;
  late EpisodeModel _episode;
  Timer? _timeout;
  bool _loading = true;
  String? _error;
  int _generation = 0;
  bool _landscapeLock = true;
  Brightness _returnBrightness = Brightness.light;

  @override
  void initState() {
    super.initState();
    _episode = widget.initialEpisode;
    WidgetsBinding.instance.addObserver(this);
    unawaited(FullScreenUtils.enablePlayerMode());
    unawaited(WakelockPlus.enable());
    unawaited(_load(_episode));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _returnBrightness = Theme.of(context).brightness;
  }

  Future<void> _pause() async {
    try {
      await _controller?.runJavaScript(
        'document.querySelectorAll("video,audio").forEach(function(v){v.pause();});',
      );
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(_pause());
      unawaited(WakelockPlus.disable());
    } else {
      unawaited(WakelockPlus.enable());
    }
  }

  Future<void> _load(EpisodeModel episode) async {
    final generation = ++_generation;
    _timeout?.cancel();
    await _pause();
    if (!mounted || generation != _generation) return;
    setState(() {
      _episode = episode;
      _loading = true;
      _error = null;
      _controller = null;
    });
    final uri = episode.aparatEmbedUri;
    if (uri == null) {
      _fail(generation,
          message:
              'شناسهٔ این ویدئو معتبر نیست یا حذف شده است. لطفاً قسمت دیگری را امتحان کن.');
      return;
    }
    // Timeout واقعی برای وضعیت بارگذاری
    _timeout = Timer(const Duration(seconds: 28), () => _fail(generation));
    try {
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(Colors.black);
      await controller.setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          if (!request.isMainFrame) return NavigationDecision.navigate;
          final target = Uri.tryParse(request.url);
          return target?.scheme == 'https' &&
                  target?.host == uri.host &&
                  target?.path == uri.path &&
                  target?.userInfo == '' &&
                  !(target?.hasPort ?? true)
              ? NavigationDecision.navigate
              : NavigationDecision.prevent;
        },
        onPageFinished: (_) {
          if (!mounted || generation != _generation) return;
          _timeout?.cancel();
          setState(() => _loading = false);
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame == true) _fail(generation);
        },
      ));
      if (!mounted || generation != _generation) return;
      setState(() => _controller = controller);
      await controller.loadRequest(uri);
    } catch (_) {
      _fail(generation);
    }
  }

  void _fail(int generation, {String? message}) {
    if (!mounted || generation != _generation) return;
    _timeout?.cancel();
    setState(() {
      _loading = false;
      _error = message ??
          'پخش ویدئو ممکن نشد. اتصال اینترنت را بررسی کن و دوباره تلاش کن.';
    });
  }

  Future<void> _toggleOrientationLock() async {
    final lockLandscape = !_landscapeLock;
    setState(() => _landscapeLock = lockLandscape);
    await SystemChrome.setPreferredOrientations(
      lockLandscape
          ? const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ]
          : DeviceOrientation.values,
    );
  }

  @override
  void dispose() {
    ++_generation;
    WidgetsBinding.instance.removeObserver(this);
    _timeout?.cancel();
    unawaited(_pause());
    unawaited(WakelockPlus.disable());
    unawaited(FullScreenUtils.restoreAppMode(_returnBrightness));
    // Restore portrait if we forced landscape
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1424),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF1D2A43), Color(0xFF0D1424), Color(0xFF090E19)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // هدر تمیز: فقط عنوان، بدون معرفی منبع
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'بستن پخش‌کننده',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      color: Colors.white,
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.coral.withOpacity(.18),
                        borderRadius: BorderRadius.circular(13),
                        border:
                            Border.all(color: AppColors.coral.withOpacity(.32)),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.coralLight,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.cartoon.title} · ${_episode.title}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                    IconButton(
                      tooltip: _landscapeLock
                          ? 'چرخش آزاد: روشن'
                          : 'چرخش آزاد: خاموش',
                      onPressed: () => unawaited(_toggleOrientationLock()),
                      icon: Icon(_landscapeLock
                          ? Icons.screen_lock_rotation_rounded
                          : Icons.screen_rotation_rounded),
                      color: Colors.white70,
                    ),
                    IconButton(
                      tooltip: 'بارگذاری دوباره',
                      onPressed: () => unawaited(_load(_episode)),
                      icon: const Icon(Icons.refresh_rounded),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLarge),
                          child: ColoredBox(
                            color: Colors.black,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // WebView ویدئو
                                if (controller != null && _error == null)
                                  WebViewWidget(
                                    key: ValueKey(controller),
                                    controller: controller,
                                  ),
                                // لوگوی برند با هالهٔ نئونی - فقط وقتی ویدئو آماده یا در حال پخش
                                if (!_loading && _error == null)
                                  const Positioned.fill(
                                    child: PlayerBrandOverlay(),
                                  )
                                else if (_loading && controller == null)
                                  // پوستر هنگام آماده‌سازی (بدون لود شبکه)
                                  Positioned.fill(
                                    child: _LoadingPoster(
                                      cartoon: widget.cartoon,
                                      episode: _episode,
                                    ),
                                  ),
                                if (_loading && controller != null)
                                  // لودینگ سبک روی WebView در حال اتصال
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(.32),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 28,
                                        height: 28,
                                        child: CircularProgressIndicator(
                                          color: AppColors.skyLight,
                                          strokeWidth: 2.8,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (_loading && controller == null)
                                  // لودینگ اصلی هنگام ساخت کنترلر
                                  const _CenterLoading(),
                                if (_error != null)
                                  _ErrorView(
                                    message: _error!,
                                    onRetry: () => unawaited(_load(_episode)),
                                    onBack: () =>
                                        Navigator.of(context).maybePop(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // فهرست قسمت‌ها - فقط عنوان فارسی، بدون توضیح منبع
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: widget.cartoon.episodes.length,
                  itemBuilder: (context, index) {
                    final episode = widget.cartoon.episodes[index];
                    final selected = _episode.id == episode.id;
                    return ChoiceChip(
                      label: Text(episode.title),
                      selected: selected,
                      backgroundColor: Colors.white.withOpacity(.07),
                      selectedColor: AppColors.sky,
                      side: BorderSide(
                        color: selected ? AppColors.skyLight : Colors.white24,
                      ),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      onSelected: (_) => unawaited(_load(episode)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingPoster extends StatelessWidget {
  const _LoadingPoster({required this.cartoon, required this.episode});

  final CartoonModel cartoon;
  final EpisodeModel episode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // پوستر کارتون به‌عنوان placeholder تا ویدئو بیاید
        CartoonArtwork(
          cartoon: cartoon,
          borderRadius: 0,
          showPlayAffordance: false,
          showTitle: false,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.42),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                episode.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'در حال آماده‌سازی ویدئو…',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CenterLoading extends StatelessWidget {
  const _CenterLoading();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.88),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.skyLight,
              strokeWidth: 3,
            ),
            SizedBox(height: 14),
            Text(
              'در حال آماده‌سازی ویدئو…',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onBack,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF111A2B),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 38,
                color: AppColors.coralLight,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.coral,
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('تلاش دوباره'),
              ),
              TextButton(
                onPressed: onBack,
                child: const Text(
                  'بازگشت',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
