import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/cartoon_model.dart';

/// Official Aparat player. We do not scrape signed CDN URLs or pretend that
/// native-player seek/history/autoplay controls work with a third-party iframe.
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

  @override
  void initState() {
    super.initState();
    _episode = widget.initialEpisode;
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load(_episode));
  }

  Future<void> _pause() async {
    try {
      await _controller?.runJavaScript(
        'document.querySelectorAll("video,audio").forEach(function(v){v.pause();});',
      );
    } catch (_) {
      // The page may already have been disposed or be offline.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(_pause());
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
      // Replacing the WebView also stops the previous episode.
      _controller = null;
    });
    final uri = episode.aparatEmbedUri;
    if (uri == null) {
      _fail(generation);
      return;
    }
    _timeout = Timer(const Duration(seconds: 30), () => _fail(generation));
    try {
      final controller = WebViewController();
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(Colors.black);
      await controller.setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          // Keep the child in this selected video, not publisher pages, ads,
          // deep links, other videos, or an external browser. CDN subresource
          // requests are not top-level navigations and are unaffected.
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
          // Page loaded, not a claim that playback or the CDN was verified.
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

  void _fail(int generation) {
    if (!mounted || generation != _generation) return;
    _timeout?.cancel();
    setState(() {
      _loading = false;
      _error = 'پخش‌کنندهٔ آپارات باز نشد. اینترنت، دسترسی به آپارات و '
          'به‌روز بودن Android System WebView را بررسی کنید.';
    });
  }

  @override
  void dispose() {
    ++_generation;
    WidgetsBinding.instance.removeObserver(this);
    _timeout?.cancel();
    unawaited(_pause());
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _episode.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                          Text(
                            'پخش رسمی در آپارات',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white60,
                                    ),
                          ),
                        ],
                      ),
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
                                if (controller != null && _error == null)
                                  WebViewWidget(
                                    key: ValueKey(controller),
                                    controller: controller,
                                  ),
                                if (_loading)
                                  DecoratedBox(
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
                                            'در حال اتصال به آپارات…',
                                            style: TextStyle(
                                                color: Colors.white70),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (_error != null)
                                  ColoredBox(
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
                                              _error!,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                height: 1.55,
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                            FilledButton.icon(
                                              onPressed: () =>
                                                  unawaited(_load(_episode)),
                                              style: FilledButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.coral,
                                              ),
                                              icon: const Icon(
                                                  Icons.refresh_rounded),
                                              label: const Text('تلاش دوباره'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.06),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: Colors.white.withOpacity(.10)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.goldLight,
                      size: 18,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        '${_episode.description} · شروع پخش با لمس ویدیوست. '
                        'تبلیغات احتمالی با آپارات است؛ ادامهٔ تماشا و پخش خودکار '
                        'برنامه در این حالت فعال نیست.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              height: 1.45,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
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
