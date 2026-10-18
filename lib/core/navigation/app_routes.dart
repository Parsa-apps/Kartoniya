import 'package:flutter/material.dart';

import '../theme/app_motion.dart';

/// ترنزیشن یکنواخت صفحات کارتونیا: محو + مقیاس و لغزش بسیار ظریف.
///
/// تمام `Navigator.push`های برنامه باید از `pushAppPage` یا
/// `kartoniyaPageRoute` استفاده کنند تا حرکت بین صفحات یکدست بماند.
Route<T> kartoniyaPageRoute<T>({
  required Widget page,
  bool fadeOnly = false,
}) {
  return PageRouteBuilder<T>(
    transitionDuration: AppMotion.soft,
    reverseTransitionDuration: const Duration(milliseconds: 240),
    opaque: true,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.curveEntrance,
        reverseCurve: AppMotion.curveExit,
      );
      if (!context.motion.enabled) return child;
      if (fadeOnly) return FadeTransition(opacity: curved, child: child);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, .025),
            end: Offset.zero,
          ).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: .985, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

Future<T?> pushAppPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(kartoniyaPageRoute<T>(page: page));

Future<T?> pushAppPageFade<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(
      kartoniyaPageRoute<T>(page: page, fadeOnly: true),
    );

Future<void> replaceAppPage(BuildContext context, Widget page) =>
    Navigator.of(context).pushReplacement(
      kartoniyaPageRoute<void>(page: page, fadeOnly: true),
    );
