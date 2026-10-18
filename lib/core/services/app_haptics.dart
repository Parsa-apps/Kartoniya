import 'dart:async';

import 'package:flutter/services.dart';

/// Optional, centralized tactile feedback for user-initiated UI actions.
///
/// Android and iOS remain responsible for honoring their system-level haptic
/// settings. The parent can also turn all Kartoniya feedback off in Settings.
/// Platform failures are intentionally swallowed: haptics are decorative and
/// must never block navigation, playback, or another primary action.
abstract final class AppHaptics {
  static bool _enabled = true;

  static bool get enabled => _enabled;

  /// Configure from the persisted parent preference during app startup and
  /// whenever that preference changes.
  static void setEnabled(bool value) => _enabled = value;

  static void selection() => _dispatch(HapticFeedback.selectionClick);

  static void light() => _dispatch(HapticFeedback.lightImpact);

  static void medium() => _dispatch(HapticFeedback.mediumImpact);

  static void heavy() => _dispatch(HapticFeedback.heavyImpact);

  static void _dispatch(Future<void> Function() feedback) {
    if (!_enabled) return;
    unawaited(_ignorePlatformFailure(feedback));
  }

  static Future<void> _ignorePlatformFailure(
    Future<void> Function() feedback,
  ) async {
    try {
      await feedback();
    } on PlatformException {
      // The system service may be unavailable on a device/test environment.
      return;
    } on MissingPluginException {
      // A missing optional platform channel must not affect the action.
      return;
    }
  }
}
