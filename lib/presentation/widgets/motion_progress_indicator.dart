import 'package:flutter/material.dart';

import '../../core/theme/app_motion.dart';

/// Static hourglass fallback for indeterminate progress when motion is reduced.
class MotionProgressIndicator extends StatelessWidget {
  const MotionProgressIndicator({
    super.key,
    this.size = 40,
    this.strokeWidth = 4,
    this.color,
  });

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (context.motion.enabled) {
      return SizedBox.square(
        dimension: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          color: color,
        ),
      );
    }

    return SizedBox.square(
      dimension: size,
      child: Icon(
        Icons.hourglass_empty_rounded,
        size: size * .68,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
