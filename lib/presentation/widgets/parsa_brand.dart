import 'package:flutter/material.dart';

/// نشان رسمی استودیوی Parsa Apps (برند سازندهٔ کارتونیَا).
///
/// فایل منبع یک PNG شفاف است که بدون هیچ بازسازی شکلی، فقط برش حاشیهٔ خالی
/// و resize بدون‌اتلاف به WebP lossless تبدیل شده تا نسبت تصویر و لبه‌ها
/// دقیقاً همان اثر اصلی بماند. هیچ نوشته یا نمادی به خود لوگو اضافه نمی‌شود؛
/// نور و هاله فقط در لایهٔ نمایش (اسپلش) روی آن قرار می‌گیرند.
class ParsaBrandMark extends StatelessWidget {
  const ParsaBrandMark({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.semanticLabel = 'لوگوی استودیوی Parsa Apps',
  });

  /// مسیر ثابت دارایی در بستهٔ اپ؛ همهٔ مصرف‌کننده‌ها از همین ثابت استفاده
  /// می‌کنند تا مسیر در build نهایی همیشه حاضر باشد.
  static const String assetPath = 'asset/images/branding/parsa_apps_logo.webp';

  /// نسبت تصویر فایل (width / height)؛ برای نگهداشتن تناسپ بدون کشیدگی.
  static const double aspectRatio = 810 / 1024;

  final double? height;
  final double? width;
  final BoxFit fit;
  final String semanticLabel;

  double get _resolvedHeight =>
      height ?? (width != null ? width! / aspectRatio : 120);
  double get _resolvedWidth => width ?? _resolvedHeight * aspectRatio;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: Image.asset(
        assetPath,
        width: _resolvedWidth,
        height: _resolvedHeight,
        fit: fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        excludeFromSemantics: true,
      ),
    );
  }
}
