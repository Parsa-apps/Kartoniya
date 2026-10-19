/// سرویس رسمی حل شناسهٔ آپارات به منبع پخش مجاز.
///
/// فقط از endpoint رسمی embed استفاده می‌کند؛ هیچ استخراج غیرمجاز CDN،
/// جعل User-Agent یا دور زدن محدودیت انجام نمی‌شود.
/// هر hash باید دقیقاً به همان ویدئوی تأیید‌شده برسد.
library;

import '../../data/models/cartoon_model.dart';

abstract final class AparatResolver {
  static final _hashPattern = RegExp(r'^[A-Za-z0-9]+$');

  /// آیا hash قالبی معتبر دارد؟ (فقط حروف و اعداد)
  static bool isValidHash(String hash) =>
      hash.isNotEmpty && _hashPattern.hasMatch(hash);

  /// URL کانونی تماشای آپارات از روی hash
  static String watchUrl(String hash) => 'https://www.aparat.com/v/$hash';

  /// URI رسمی embed از روی hash
  static Uri embedUri(String hash) => Uri.https(
        'www.aparat.com',
        '/video/video/embed/videohash/$hash/vt/frame',
      );

  /// تلاش برای استخراج hash از یک videoUrl کانونی.
  /// فقط https، بدون query/fragment/port/userInfo.
  static String? hashFromUrl(String videoUrl) {
    final uri = Uri.tryParse(videoUrl.trim());
    if (uri == null) return null;
    if (uri.scheme != 'https') return null;
    if (!const ['www.aparat.com', 'aparat.com'].contains(uri.host)) {
      return null;
    }
    if (uri.userInfo.isNotEmpty || uri.hasPort || uri.hasQuery || uri.hasFragment) {
      return null;
    }
    if (uri.pathSegments.length != 2) return null;
    if (uri.pathSegments.first != 'v') return null;
    final hash = uri.pathSegments.last;
    return isValidHash(hash) ? hash : null;
  }

  /// آیا videoUrl یک منبع آپارات مجاز و قابل embed است؟
  static bool isAparatSource(String videoUrl) => hashFromUrl(videoUrl) != null;

  /// URI embed از روی videoUrl، یا null اگر نامعتبر باشد.
  static Uri? embedUriFromUrl(String videoUrl) {
    final hash = hashFromUrl(videoUrl);
    if (hash == null) return null;
    return embedUri(hash);
  }

  /// اعتبارسنجی یک EpisodeModel برای پخش
  static AparatResolution resolveEpisode(EpisodeModel episode) {
    final url = episode.videoUrl.trim();
    if (url.isEmpty) {
      return const AparatResolution.invalid('آدرس ویدئو خالی است.');
    }
    final hash = hashFromUrl(url);
    if (hash == null) {
      // اگر URL خالی نیست ولی آپارات نیست، ممکن است direct URL باشد
      final uri = Uri.tryParse(url);
      if (uri != null && uri.scheme == 'https' && uri.host.isNotEmpty) {
        return AparatResolution.direct(uri);
      }
      return const AparatResolution.invalid('شناسهٔ ویدئو نامعتبر است.');
    }
    return AparatResolution.embedded(embedUri(hash), hash);
  }
}

/// نتیجهٔ حل شناسه
class AparatResolution {
  const AparatResolution._(this.type, this.embedUri, this.hash, this.directUri, this.error);

  const AparatResolution.embedded(Uri uri, String hash)
      : this._(AparatResolutionType.embedded, uri, hash, null, null);

  const AparatResolution.direct(Uri uri)
      : this._(AparatResolutionType.direct, null, null, uri, null);

  const AparatResolution.invalid(String message)
      : this._(AparatResolutionType.invalid, null, null, null, message);

  final AparatResolutionType type;
  final Uri? embedUri;
  final String? hash;
  final Uri? directUri;
  final String? error;

  bool get isEmbedded => type == AparatResolutionType.embedded;
  bool get isDirect => type == AparatResolutionType.direct;
  bool get isInvalid => type == AparatResolutionType.invalid;
  bool get isPlayable => isEmbedded || isDirect;
}

enum AparatResolutionType { embedded, direct, invalid }
