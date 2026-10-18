import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_motion.dart';
import 'core/theme/app_theme.dart';
import 'data/models/cartoon_model.dart';
import 'data/providers/cartoons_provider.dart';
import 'presentation/pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();

  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
      child: const KartoniyaApp(),
    ),
  );
}

/// نقطهٔ ورود اپ؛ تم، RTL، MotionScope و providerهای سراسری تنها در این
/// لایه تنظیم می‌شوند.
class KartoniyaApp extends ConsumerStatefulWidget {
  const KartoniyaApp({super.key});

  @override
  ConsumerState<KartoniyaApp> createState() => _KartoniyaAppState();
}

class _KartoniyaAppState extends ConsumerState<KartoniyaApp> {
  void _syncLocalData(List<CartoonModel>? cartoons) {
    if (cartoons == null) return;
    final cartoonIds = cartoons.map((cartoon) => cartoon.id).toSet();
    final episodeIds = {
      for (final cartoon in cartoons)
        for (final episode in cartoon.episodes) episode.id,
    };
    ref.read(favoritesProvider.notifier).pruneTo(cartoonIds);
    ref.read(watchHistoryProvider.notifier).pruneTo(episodeIds);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);
    // هم‌سازی داده‌های محلی با کاتالوگ: شناسه‌های نامعتبر (محتوای حذف‌شده)
    // نباید در شمارنده‌ها یا فهرست‌ها باقی بمانند.
    ref.listen(cartoonsProvider, (_, next) {
      _syncLocalData(next.value);
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'کارتونیا',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const SplashPage(),
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        // نسخهٔ ایستای «کاهش حرکت» تا ویجت‌ها در initState هم بتوانند
        // بدون وابستگی به درخت، تصمیم درست بگیرند.
        MotionScope.applyGlobal(
          parentReduced: reduceMotion,
          systemReduce: MediaQuery.maybeOf(context)?.disableAnimations ?? false,
        );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: AppLifecycleTickerMode(
              child: MotionScope(
                info: MotionInfo(reduced: reduceMotion),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
