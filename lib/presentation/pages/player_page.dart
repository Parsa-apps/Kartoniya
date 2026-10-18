import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fa_digits.dart';
import '../../core/utils/full_screen_utils.dart';
import '../../data/models/cartoon_model.dart';
import '../../data/providers/cartoons_provider.dart';
import '../widgets/animated_progress.dart';
import '../widgets/aparat_player.dart';
import '../widgets/gradient_button.dart';
import '../widgets/kartoniya_story_banner.dart';

/// پخش‌کنندهٔ واقعی ویدئو کارتونیا.
///
/// - یک کنترلر در هر لحظه؛ هنگام تعویض قسمت، قبلی کاملاً dispose می‌شود تا
///   هیچ‌وقت دو player فعال نماند.
/// - درصد پیشرفت فقط روی دستگاه ذخیره می‌شود (ادامهٔ تماشا).
/// - پایان قسمت + پخش خودکار → شمارش معکوس قسمت بعد.
/// - دابل‌تپ چپ/راست = ۱۰ ثانیه عقب/جلو با بازخورد حبابی.
/// - با pause شدن برنامه، صدا و تصویر متوقف و wakelock آزاد می‌شود.
class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({
    super.key,
    required this.cartoon,
    required this.episode,
  });

  final CartoonModel cartoon;
  final EpisodeModel episode;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage>
    with WidgetsBindingObserver {
  static const _controlsTimeout = Duration(seconds: 4);
  static const _nextEpisodeCountdown = 8;

  VideoPlayerController? _videoController;
  Timer? _controlsTimer;
  Timer? _nextEpisodeTimer;
  DateTime _lastUiUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  double _lastSavedProgress = 0;
  bool _showControls = true;
  bool _isLoading = true;
  bool _landscapeLock = true;
  bool _wasPlayingBeforeBackground = false;
  int _nextCountdown = _nextEpisodeCountdown;
  String? _errorMessage;
  Brightness _returnBrightness = Brightness.light;
  late EpisodeModel _episode;
  late final WatchHistoryNotifier _historyNotifier;

  /// موقعیت «+۱۰/-۱۰» بعد از دابل‌تپ: انیمیشن حبابی موقت.
  final ValueNotifier<_SeekBurst?> _seekBurst =
      ValueNotifier<_SeekBurst?>(null);
  Timer? _seekBurstTimer;

  EpisodeModel get _current => _episode;

  int get _episodeIndex {
    final index =
        widget.cartoon.episodes.indexWhere((e) => e.id == _episode.id);
    return index;
  }

  EpisodeModel? get _nextEpisode {
    final index = _episodeIndex;
    if (index < 0 || index + 1 >= widget.cartoon.episodes.length) return null;
    return widget.cartoon.episodes[index + 1];
  }

  @override
  void initState() {
    super.initState();
    _episode = widget.episode;
    _historyNotifier = ref.read(watchHistoryProvider.notifier);
    WidgetsBinding.instance.addObserver(this);
    unawaited(FullScreenUtils.enablePlayerMode());
    if (_episode.aparatEmbedUri == null) {
      unawaited(_initializePlayer(_episode));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _returnBrightness = Theme.of(context).brightness;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controlsTimer?.cancel();
    _nextEpisodeTimer?.cancel();
    _seekBurstTimer?.cancel();
    _seekBurst.dispose();
    _saveCurrentProgress();
    _videoController?.removeListener(_onVideoChanged);
    _videoController?.dispose();
    unawaited(WakelockPlus.disable());
    unawaited(FullScreenUtils.restoreAppMode(_returnBrightness));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    // if/else به‌جای switch: با هر نسخهٔ Flutter (عضوهای جدید enum) سازگار است.
    if (state == AppLifecycleState.resumed) {
      if (_wasPlayingBeforeBackground && mounted) {
        _wasPlayingBeforeBackground = false;
        unawaited(controller.play());
        unawaited(WakelockPlus.enable());
        _scheduleControlsHide();
      }
      return;
    }
    if (controller.value.isPlaying) {
      _wasPlayingBeforeBackground = true;
      unawaited(controller.pause());
      unawaited(WakelockPlus.disable());
      _saveCurrentProgress();
    }
  }

  /// ذخیرهٔ موقعیت هنگام ترک صفحه یا تعویض قسمت؛ بدون throttle و با آستانهٔ
  /// یک درصد تا نوشتن‌های بی‌فایده انجام نشود.
  void _saveCurrentProgress() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    final duration = controller.value.duration;
    if (duration.inMilliseconds <= 0) return;
    final progress =
        (controller.value.position.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();
    if ((progress - _lastSavedProgress).abs() < .01 && progress < .995) return;
    _lastSavedProgress = progress;
    _historyNotifier.saveProgress(_episode.id, progress);
  }

  Future<void> _initializePlayer(EpisodeModel episode) async {
    final source = episode.videoUrl.trim();
    if (source.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'برای این قسمت هنوز آدرس ویدئوی قابل پخش ثبت نشده است.';
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    VideoPlayerController? controller;
    try {
      controller = VideoPlayerController.networkUrl(Uri.parse(source));
      controller.addListener(_onVideoChanged);
      await controller.initialize();
      if (!mounted) {
        controller.removeListener(_onVideoChanged);
        await controller.dispose();
        return;
      }
      if (controller.value.hasError) {
        throw StateError(
            controller.value.errorDescription ?? 'خطا در آماده‌سازی ویدئو');
      }
      _videoController = controller;

      final savedProgress = ref.read(episodeProgressProvider(episode.id));
      _lastSavedProgress = savedProgress;
      var resumedFrom = Duration.zero;
      if (savedProgress > .01 && savedProgress < .995) {
        final milliseconds =
            (controller.value.duration.inMilliseconds * savedProgress).round();
        resumedFrom = Duration(milliseconds: milliseconds);
        await controller.seekTo(resumedFrom);
      }
      if (ref.read(autoplayProvider)) {
        await controller.play();
        unawaited(WakelockPlus.enable());
        _scheduleControlsHide();
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showControls =
              resumedFrom == Duration.zero || !ref.read(autoplayProvider);
        });
        if (resumedFrom > Duration.zero) {
          _showResumedToast(resumedFrom);
        }
      }
    } catch (_) {
      controller?.removeListener(_onVideoChanged);
      if (controller != null) await controller.dispose();
      if (identical(_videoController, controller)) _videoController = null;
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'ویدئو باز نشد. اتصال اینترنت یا آدرس فایل را بررسی کنید.';
        });
      }
    }
  }

  void _showResumedToast(Duration position) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2100),
        content: Row(
          children: [
            const Icon(Icons.play_circle_fill_rounded,
                color: AppColors.goldLight, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('ادامه از ${_formatDuration(position)}'),
            ),
          ],
        ),
      ),
    );
  }

  void _onVideoChanged() {
    if (!mounted) return;
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    final duration = controller.value.duration;
    if (duration.inMilliseconds <= 0) return;

    final progress =
        (controller.value.position.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();
    if ((progress - _lastSavedProgress).abs() >= .02 || progress >= .995) {
      _lastSavedProgress = progress;
      _historyNotifier.saveProgress(_current.id, progress);
    }

    if (controller.value.isCompleted &&
        _nextEpisodeTimer == null &&
        _errorMessage == null) {
      _startNextEpisodeFlow();
      return;
    }

    // تغییر وضعیت بافر یا پخش بی‌درنگ نمایش داده می‌شود؛ تیک‌تاک position
    // حداکثر هر ۴۵۰ میلی‌ثانیه rebuild می‌کند تا هزینه پایین بماند.
    final now = DateTime.now();
    final bufferingChanged = controller.value.isBuffering != _lastIsBuffering;
    if (bufferingChanged) _lastIsBuffering = controller.value.isBuffering;
    final shouldUpdate =
        now.difference(_lastUiUpdate) >= const Duration(milliseconds: 450);
    if (bufferingChanged || shouldUpdate) {
      _lastUiUpdate = now;
      setState(() {});
    }
  }

  bool _lastIsBuffering = false;

  // ——— ادامهٔ خودکار به قسمت بعد ———

  void _startNextEpisodeFlow() {
    final next = _nextEpisode;
    final autoplay = ref.read(autoplayProvider);
    if (next == null || !autoplay) {
      if (mounted) setState(() {});
      return;
    }
    _nextCountdown = _nextEpisodeCountdown;
    setState(() {});
    _nextEpisodeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_nextCountdown <= 1) {
        timer.cancel();
        _nextEpisodeTimer = null;
        unawaited(_switchEpisode(next));
        return;
      }
      setState(() => _nextCountdown--);
    });
  }

  void _cancelNextEpisodeFlow() {
    _nextEpisodeTimer?.cancel();
    _nextEpisodeTimer = null;
    if (mounted) setState(() {});
  }

  Future<void> _switchEpisode(EpisodeModel next) async {
    _cancelNextEpisodeFlow();
    _saveCurrentProgress();
    final old = _videoController;
    old?.removeListener(_onVideoChanged);
    if (old != null) await old.dispose();
    _videoController = null;
    if (!mounted) return;
    setState(() {
      _episode = next;
      _lastSavedProgress = 0;
      _lastIsBuffering = false;
    });
    await _initializePlayer(next);
  }

  // ——— کنترل‌ها ———

  void _scheduleControlsHide() {
    _controlsTimer?.cancel();
    final controller = _videoController;
    if (controller?.value.isPlaying != true) return;
    _controlsTimer = Timer(_controlsTimeout, () {
      if (mounted && _videoController?.value.isPlaying == true) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    if (_isLoading || _errorMessage != null) return;
    setState(() => _showControls = !_showControls);
    if (_showControls) _scheduleControlsHide();
  }

  Future<void> _togglePlay() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    HapticFeedback.mediumImpact();
    if (controller.value.isPlaying) {
      await controller.pause();
      unawaited(WakelockPlus.disable());
      _controlsTimer?.cancel();
      if (mounted) setState(() => _showControls = true);
    } else {
      await controller.play();
      unawaited(WakelockPlus.enable());
      if (mounted) setState(() => _showControls = true);
      _scheduleControlsHide();
    }
  }

  Future<void> _seekBy(int seconds, {bool fromDoubleTap = false}) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    final targetMilliseconds =
        controller.value.position.inMilliseconds + (seconds * 1000);
    final safeMilliseconds = targetMilliseconds
        .clamp(0, controller.value.duration.inMilliseconds)
        .toInt();
    await controller.seekTo(Duration(milliseconds: safeMilliseconds));
    if (fromDoubleTap && context.mounted) {
      _showSeekBurst(seconds);
    } else {
      _scheduleControlsHide();
    }
  }

  void _showSeekBurst(int seconds) {
    _seekBurstTimer?.cancel();
    _seekBurst.value = _SeekBurst(forward: seconds > 0, amount: seconds.abs());
    _seekBurstTimer = Timer(const Duration(milliseconds: 750), () {
      _seekBurst.value = null;
    });
  }

  Future<void> _seekTo(double value) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.seekTo(
      Duration(
        milliseconds:
            (controller.value.duration.inMilliseconds * value).round(),
      ),
    );
  }

  Future<void> _retry() async {
    final oldController = _videoController;
    oldController?.removeListener(_onVideoChanged);
    if (oldController != null) await oldController.dispose();
    _videoController = null;
    if (!mounted) return;
    setState(() {
      _showControls = true;
    });
    await _initializePlayer(_current);
  }

  Future<void> _toggleOrientationLock() async {
    HapticFeedback.selectionClick();
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

  // ——— UI ———

  @override
  Widget build(BuildContext context) {
    if (_episode.aparatEmbedUri != null) {
      return AparatPlayer(cartoon: widget.cartoon, initialEpisode: _episode);
    }
    final controller = _videoController;
    final ready = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        onDoubleTapDown: ready
            ? (details) {
                final width = MediaQuery.sizeOf(context).width;
                final right = details.globalPosition.dx > width / 2;
                unawaited(
                  _seekBy(right ? 10 : -10, fromDoubleTap: true),
                );
              }
            : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: Color(0xFF000910)),
            if (ready)
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio <= 0
                      ? 16 / 9
                      : controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            if (_isLoading) const _PlayerLoading(),
            if (ready && controller.value.isBuffering && !_isLoading)
              const _BufferingBadge(),
            if (_errorMessage != null)
              _PlayerError(
                message: _errorMessage!,
                onRetry: () => unawaited(_retry()),
              ),
            if (ready && _errorMessage == null) ...[
              ValueListenableBuilder<_SeekBurst?>(
                valueListenable: _seekBurst,
                builder: (context, burst, _) => _SeekBurstOverlay(burst: burst),
              ),
              _PlayerTopBar(
                title: '${widget.cartoon.title} · ${_current.title}',
                visible: _showControls,
                onBack: () => Navigator.of(context).maybePop(),
                onToggleOrientation: () => unawaited(_toggleOrientationLock()),
                orientationLocked: _landscapeLock,
              ),
              _PlayerCenterControl(
                isPlaying: controller.value.isPlaying,
                visible: _showControls || !controller.value.isPlaying,
                onPressed: () => unawaited(_togglePlay()),
              ),
              _PlayerBottomControls(
                controller: controller,
                visible: _showControls,
                episodeLabel: _current.title,
                onTogglePlay: () => unawaited(_togglePlay()),
                onSeekBack: () => unawaited(_seekBy(-10)),
                onSeekForward: () => unawaited(_seekBy(10)),
                onSeek: (value) => unawaited(_seekTo(value)),
                onStartSeek: () => _controlsTimer?.cancel(),
                onEndSeek: _scheduleControlsHide,
              ),
              if (_nextEpisodeTimer != null)
                _NextEpisodeOverlay(
                  episode: _nextEpisode!,
                  seconds: _nextCountdown,
                  onCancel: _cancelNextEpisodeFlow,
                  onPlayNow: () {
                    final next = _nextEpisode;
                    _cancelNextEpisodeFlow();
                    if (next != null) unawaited(_switchEpisode(next));
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SeekBurst {
  const _SeekBurst({required this.forward, required this.amount});

  final bool forward;
  final int amount;
}

class _PlayerLoading extends StatelessWidget {
  const _PlayerLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 14),
          Text(
            'در حال آماده‌سازی ویدئو…',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _BufferingBadge extends StatelessWidget {
  const _BufferingBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -.72),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.55),
          borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'در حال دریافت…',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeekBurstOverlay extends StatelessWidget {
  const _SeekBurstOverlay({required this.burst});

  final _SeekBurst? burst;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: burst == null
            ? const SizedBox.shrink()
            : Align(
                alignment: burst!.forward
                    ? const Alignment(.82, 0)
                    : const Alignment(-.82, 0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (burst!.forward) ...[
                        const Text(
                          '+',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Icon(
                          Icons.forward_10_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ] else ...[
                        const Icon(
                          Icons.replay_10_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        Text(
                          '-${burst!.amount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _PlayerError extends StatelessWidget {
  const _PlayerError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.68),
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PreRenderedFlak(
                  width: 92,
                  height: 106,
                  semanticLabel:
                      'فندوقی در وضعیت خطای پخش',
                ),
                const SizedBox(height: 13),
                const Text(
                  'پخش ویدئو ممکن نشد',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 18),
                GradientButton(
                  label: 'تلاش دوباره',
                  icon: Icons.refresh_rounded,
                  compact: true,
                  height: 44,
                  onPressed: onRetry,
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('بازگشت',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerTopBar extends StatelessWidget {
  const _PlayerTopBar({
    required this.title,
    required this.visible,
    required this.onBack,
    required this.onToggleOrientation,
    required this.orientationLocked,
  });

  final String title;
  final bool visible;
  final VoidCallback onBack;
  final VoidCallback onToggleOrientation;
  final bool orientationLocked;

  @override
  Widget build(BuildContext context) {
    return _ControlsLayer(
      visible: visible,
      slideOffset: const Offset(0, -.25),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Row(
            children: [
              _PlayerIconButton(
                tooltip: 'بستن پخش‌کننده',
                icon: Icons.close_rounded,
                onPressed: onBack,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _PlayerIconButton(
                tooltip:
                    orientationLocked ? 'چرخش آزاد: روشن' : 'چرخش آزاد: خاموش',
                icon: orientationLocked
                    ? Icons.screen_lock_rotation_rounded
                    : Icons.screen_rotation_rounded,
                onPressed: onToggleOrientation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerCenterControl extends StatelessWidget {
  const _PlayerCenterControl({
    required this.isPlaying,
    required this.visible,
    required this.onPressed,
  });

  final bool isPlaying;
  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedScale(
        scale: visible ? 1 : .75,
        duration: context.motion.dur(AppMotion.quick),
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: context.motion.dur(AppMotion.quick),
          child: IgnorePointer(
            ignoring: !visible,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onPressed();
              },
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.coral, AppColors.coralDeep],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: AppTheme.glow(AppColors.coral, opacity: .45),
                ),
                child: AnimatedSwitcher(
                  duration: context.motion.dur(AppMotion.micro),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    key: ValueKey(isPlaying),
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerBottomControls extends StatelessWidget {
  const _PlayerBottomControls({
    required this.controller,
    required this.visible,
    required this.episodeLabel,
    required this.onTogglePlay,
    required this.onSeekBack,
    required this.onSeekForward,
    required this.onSeek,
    required this.onStartSeek,
    required this.onEndSeek,
  });

  final VideoPlayerController controller;
  final bool visible;
  final String episodeLabel;
  final VoidCallback onTogglePlay;
  final VoidCallback onSeekBack;
  final VoidCallback onSeekForward;
  final ValueChanged<double> onSeek;
  final VoidCallback? onStartSeek;
  final VoidCallback onEndSeek;

  @override
  Widget build(BuildContext context) {
    final duration = controller.value.duration;
    final position =
        controller.value.position.inMilliseconds > duration.inMilliseconds
            ? duration
            : controller.value.position;
    final value = duration.inMilliseconds == 0
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds)
            .clamp(0.0, 1.0)
            .toDouble();

    return Align(
      alignment: Alignment.bottomCenter,
      child: _ControlsLayer(
        visible: visible,
        slideOffset: const Offset(0, .35),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black87, Colors.transparent],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    episodeLabel,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: value,
                          onChangeStart: (_) => onStartSeek?.call(),
                          onChanged: onSeek,
                          onChangeEnd: (_) => onEndSeek(),
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PlayerIconButton(
                        tooltip: '۱۰ ثانیه عقب',
                        icon: Icons.replay_10_rounded,
                        onPressed: onSeekBack,
                      ),
                      const SizedBox(width: 20),
                      _PlayerIconButton(
                        tooltip: controller.value.isPlaying ? 'توقف' : 'پخش',
                        icon: controller.value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        onPressed: onTogglePlay,
                        emphasized: true,
                      ),
                      const SizedBox(width: 20),
                      _PlayerIconButton(
                        tooltip: '۱۰ ثانیه جلو',
                        icon: Icons.forward_10_rounded,
                        onPressed: onSeekForward,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlsLayer extends StatelessWidget {
  const _ControlsLayer({
    required this.visible,
    required this.slideOffset,
    required this.child,
  });

  final bool visible;
  final Offset slideOffset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = context.motion.dur(AppMotion.quick);
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: duration,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : slideOffset,
        duration: duration,
        curve: AppMotion.curveStandard,
        child: IgnorePointer(ignoring: !visible, child: child),
      ),
    );
  }
}

class _PlayerIconButton extends StatelessWidget {
  const _PlayerIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.emphasized = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: emphasized
            ? Colors.white.withOpacity(.16)
            : Colors.white.withOpacity(.10),
        minimumSize: const Size(46, 46),
      ),
      icon: Icon(
        icon,
        color: emphasized ? AppColors.coralLight : Colors.white,
        size: emphasized ? 30 : 24,
      ),
    );
  }
}

class _NextEpisodeOverlay extends StatelessWidget {
  const _NextEpisodeOverlay({
    required this.episode,
    required this.seconds,
    required this.onCancel,
    required this.onPlayNow,
  });

  final EpisodeModel episode;
  final int seconds;
  final VoidCallback onCancel;
  final VoidCallback onPlayNow;

  @override
  Widget build(BuildContext context) {
    final skyAction = AppColors.fillAndText(AppColors.sky);
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.72),
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ProgressRing(
              value: 1 - (seconds / _nextEpisodeCountdownValue),
              color: AppColors.sky,
              size: 56,
              strokeWidth: 5,
              trackColor: Colors.white24,
              child: Text(
                toFaDigits('$seconds'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'قسمت بعدی',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  episode.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton(
                  onPressed: onPlayNow,
                  style: FilledButton.styleFrom(
                    backgroundColor: skyAction.fill,
                    foregroundColor: skyAction.foreground,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    minimumSize: const Size(0, 38),
                  ),
                  child: const Text('همین حالا'),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: onCancel,
                  child: const Text(
                    'نه، ممنون',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const double _nextEpisodeCountdownValue = 8;
}

String _formatDuration(Duration value) {
  final minutes = value.inMinutes;
  final seconds = value.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
