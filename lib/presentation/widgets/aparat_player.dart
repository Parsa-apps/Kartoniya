import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/cartoon_model.dart';
import 'motion_progress_indicator.dart';

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
  bool _suspended = false;
  String? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _episode = widget.initialEpisode;
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load(_episode));
  }

  Future<void> _pause([WebViewController? target]) async {
    final controller = target ?? _controller;
    try {
      await controller?.runJavaScript(
        'document.querySelectorAll("video,audio").forEach(function(v){v.pause();});',
      );
    } catch (_) {
      // The page may already have been disposed or be offline.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_suspended) return;
      _suspended = false;
      unawaited(_load(_episode));
      return;
    }

    if (state == AppLifecycleState.inactive) {
      unawaited(_pause());
      return;
    }

    if (_suspended) return;
    _suspended = true;
    ++_generation;
    _timeout?.cancel();
    final controller = _controller;
    // Remove the platform view as well as requesting a pause. A cross-origin
    // media frame may not be script-accessible; destroying its WebView avoids
    // leaving an invisible embed playing audio in the background.
    if (mounted) {
      setState(() {
        _controller = null;
        _loading = false;
        _error = null;
      });
    }
    unawaited(_pause(controller));
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
          return target?.scheme == 'https' && target?.host == uri.host &&
                  target?.path == uri.path && target?.userInfo == '' &&
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
      _error = 'پخش‌کننده باز نشد. اتصال اینترنت و به‌روز بودن '
          'Android System WebView را بررسی کنید.';
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                BackButton(color: Colors.white),
                Expanded(
                  child: Text(
                    _episode.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  tooltip: 'بارگذاری دوباره',
                  onPressed: () => unawaited(_load(_episode)),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (controller != null && _error == null)
                    WebViewWidget(
                      key: ValueKey(controller),
                      controller: controller,
                    ),
                  if (_loading)
                    const Center(child: MotionProgressIndicator()),
                  if (_error != null)
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_error!, textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => unawaited(_load(_episode)),
                              child: const Text('تلاش دوباره'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                'برای شروع، روی ویدئو بزن. از کنترل‌هایی که خود پخش‌کننده '
                'نمایش می‌دهد استفاده کن.',
                textAlign: TextAlign.center,
                maxLines: 2,
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
            SizedBox(
              height: 46,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: widget.cartoon.episodes.length,
                itemBuilder: (context, index) {
                  final episode = widget.cartoon.episodes[index];
                  final selected = _episode.id == episode.id;
                  return ChoiceChip(
                    label: Text(
                      episode.title,
                      style: selected
                          ? const TextStyle(color: Colors.white)
                          : null,
                    ),
                    selected: selected,
                    selectedColor: AppColors.skyDeep,
                    onSelected: (_) => unawaited(_load(episode)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
