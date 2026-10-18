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
    final uri = Uri.tryParse(videoUrl);
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
    return hash == null ? null : Uri.https('www.aparat.com',
        '/video/video/embed/videohash/$hash/vt/frame');
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
    required this.duration,
    required this.rating,
    required this.ageRange,
    required this.artworkEmoji,
    required this.artworkColorValue,
    required this.episodes,
    this.isNew = false,
    this.isFeatured = false,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final int duration;
  final double rating;
  final String ageRange;
  final String artworkEmoji;
  final int artworkColorValue;
  final List<EpisodeModel> episodes;
  final bool isNew;
  final bool isFeatured;
  final List<String> tags;

  Color get artworkColor => Color(artworkColorValue);
  int get episodeCount => episodes.length;
  String get durationLabel => '$duration دقیقه';
  EpisodeModel get firstEpisode => episodes.first;

  CartoonModel copyWith({
    String? title,
    String? description,
    String? category,
    int? duration,
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
      duration: duration ?? this.duration,
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
