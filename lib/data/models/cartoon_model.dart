import 'dart:ui';

/// دادهٔ نمایشی یک قسمت. آدرس ویدئو باید فقط به محتوای دارای مجوز اشاره کند.
class EpisodeModel {
  const EpisodeModel({
    required this.id,
    required this.title,
    required this.durationSeconds,
    required this.videoUrl,
    this.description = '',
    this.isNew = false,
  });

  final String id;
  final String title;
  final String description;
  final int durationSeconds;
  final String videoUrl;
  final bool isNew;

  /// Only canonical HTTPS Aparat watch pages can enter the embedded player.
  String? get aparatVideoHash {
    final uri = Uri.tryParse(videoUrl.trim());
    if (uri == null || uri.scheme != 'https' ||
        !const ['www.aparat.com', 'aparat.com'].contains(uri.host) ||
        uri.userInfo.isNotEmpty || uri.hasPort || uri.hasQuery ||
        uri.hasFragment || uri.pathSegments.length != 2 ||
        uri.pathSegments.first != 'v') return null;
    final hash = uri.pathSegments.last;
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(hash) ? hash : null;
  }

  Uri? get aparatEmbedUri {
    final hash = aparatVideoHash;
    return hash == null
        ? null
        : Uri.https('www.aparat.com', '/video/video/embed/videohash/$hash/vt/frame');
  }

  /// Only secure, non-Aparat HTTPS URLs may enter the native-player path.
  Uri? get secureDirectVideoUri {
    final uri = Uri.tryParse(videoUrl.trim());
    if (uri == null) return null;
    final isAparatHost =
        uri.host == 'aparat.com' || uri.host.endsWith('.aparat.com');
    if (uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        isAparatHost) {
      return null;
    }
    return uri;
  }

  String get durationLabel {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return seconds == 0 ? '$minutes دقیقه' : '$minutes:${seconds.toString().padLeft(2, '0')} دقیقه';
  }
}

/// مدل محتوای کارتونیا. این مدل فقط متادیتا نگه می‌دارد؛ فایل ویدئو یا دادهٔ
/// حساس کاربر در آن ذخیره نمی‌شود.
class CartoonModel {
  const CartoonModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.artworkEmoji,
    required this.artworkColorValue,
    required this.episodes,
    this.rating,
    this.ageRange,
    this.isNew = false,
    this.isFeatured = false,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String description;
  final String category;

  /// Null unless the rating has a verified source; never inferred locally.
  final double? rating;

  /// Null until an age suitability review is confirmed.
  final String? ageRange;
  final String artworkEmoji;
  final int artworkColorValue;
  final List<EpisodeModel> episodes;
  final bool isNew;

  /// An editorial homepage pick, not a popularity or watch-count claim.
  final bool isFeatured;
  final List<String> tags;

  Color get artworkColor => Color(artworkColorValue);
  int get episodeCount => episodes.length;
  int get totalDurationSeconds =>
      episodes.fold(0, (total, episode) => total + episode.durationSeconds);

  /// بیشترین پیشرفت فقط از قسمت‌هایی می‌آید که واقعاً با پلیر بومی پشتیبانی
  /// می‌شوند؛ وضعیت embed آپارات از این خلاصهٔ «ادامهٔ تماشا» کنار گذاشته می‌شود.
  double maxDirectPlaybackProgress(Map<String, double> progressByEpisode) {
    var maximum = 0.0;
    for (final episode in episodes) {
      if (episode.secureDirectVideoUri == null) continue;
      final progress = progressByEpisode[episode.id] ?? 0.0;
      if (progress > maximum) maximum = progress;
    }
    return maximum;
  }

  /// مجموع زمان واقعی قسمت‌های فهرست‌شده؛ هر قسمت مستقل از بقیه محاسبه می‌شود.
  String get durationLabel {
    final minutes = totalDurationSeconds ~/ 60;
    final seconds = totalDurationSeconds % 60;
    return seconds == 0
        ? '$minutes دقیقه'
        : '$minutes:${seconds.toString().padLeft(2, '0')} دقیقه';
  }

  EpisodeModel get firstEpisode => episodes.first;

  CartoonModel copyWith({
    String? title,
    String? description,
    String? category,
    double? rating,
    String? ageRange,
    String? artworkEmoji,
    int? artworkColorValue,
    List<EpisodeModel>? episodes,
    bool? isNew,
    bool? isFeatured,
    List<String>? tags,
  }) {
    return CartoonModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      ageRange: ageRange ?? this.ageRange,
      artworkEmoji: artworkEmoji ?? this.artworkEmoji,
      artworkColorValue: artworkColorValue ?? this.artworkColorValue,
      episodes: episodes ?? this.episodes,
      isNew: isNew ?? this.isNew,
      isFeatured: isFeatured ?? this.isFeatured,
      tags: tags ?? this.tags,
    );
  }
}

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.colorValue,
  });

  final String id;
  final String name;
  final String emoji;
  final int colorValue;

  Color get color => Color(colorValue);
}
