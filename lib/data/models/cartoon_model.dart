import 'dart:ui';

/// دادهٔ نمایشی یک قسمت. آدرس ویدئو باید فقط به محتوای دارای مجوز اشاره کند.
///
/// هر قسمت با شناسه یا هش رسمی آپارات مدیریت می‌شود؛ آدرس کامل صفحه
/// فقط قالب کانونی https://www.aparat.com/v/{hash} را می‌پذیرد و همان
/// hash به endpoint مجاز embed تبدیل می‌شود. هیچ استخراج CDN یا دور زدن
/// محدودیت انجام نمی‌شود.
class EpisodeModel {
  const EpisodeModel({
    required this.id,
    required this.title,
    required this.durationSeconds,
    required this.videoUrl,
    this.description = '',
    this.isNew = false,
    this.isActive = true,
    this.sortOrder = 0,
    this.thumbnailAsset,
  });

  final String id;
  final String title;
  final String description;
  final int durationSeconds;
  final String videoUrl;
  final bool isNew;

  /// آیا این قسمت فعال و قابل نمایش است؟
  final bool isActive;

  /// ترتیب نمایش در فهرست قسمت‌ها
  final int sortOrder;

  /// تصویر بندانگشتی اختیاری (پوستر محلی یا URL)
  final String? thumbnailAsset;

  /// هش رسمی ویدئوی آپارات (مثلاً ddy5427)، نه URL کامل.
  /// فقط قالب کانونی HTTPS بدون query/fragment/port پذیرفته می‌شود.
  String? get aparatVideoHash {
    final uri = Uri.tryParse(videoUrl.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        !const ['www.aparat.com', 'aparat.com'].contains(uri.host) ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.pathSegments.length != 2 ||
        uri.pathSegments.first != 'v') return null;
    final hash = uri.pathSegments.last;
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(hash) ? hash : null;
  }

  /// حافظهٔ کوتاه‌مدت برای منابع موقت نیست؛ اما اگر روزی لازم شد،
  /// این getter می‌تواند با AparatResolver هماهنگ شود.
  Uri? get aparatEmbedUri {
    final hash = aparatVideoHash;
    return hash == null
        ? null
        : Uri.https(
            'www.aparat.com', '/video/video/embed/videohash/$hash/vt/frame');
  }

  /// آیا این قسمت از طریق آپارات قابل پخش است؟
  bool get isAparatSource => aparatVideoHash != null;

  /// آیا hash قالبی معتبر دارد (بدون network)؟
  bool get hasValidAparatHash {
    final h = aparatVideoHash;
    return h != null && h.isNotEmpty;
  }

  String get durationLabel {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return seconds == 0
        ? '$minutes دقیقه'
        : '$minutes:${seconds.toString().padLeft(2, '0')} دقیقه';
  }
}

/// مدل محتوای کارتونیا. این مدل فقط متادیتا نگه می‌دارد؛ فایل ویدئو یا دادهٔ
/// حساس کاربر در آن ذخیره نمی‌شود.
class CartoonModel {
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

  /// Optional local illustration (for example `asset/images/posters/x.webp`).
  ///
  /// Artwork is content metadata, so it lives on the model and comes from the
  /// repository instead of being hard-coded next to catalog ids in a widget.
  /// When it is missing the UI keeps the deterministic vector poster.
  final String? artworkAsset;

  /// آیا این کارتون فعال است؟ (غیرفعال‌ها در فهرست اصلی نشان داده نمی‌شوند)
  final bool isActive;

  /// ترتیب نمایش در گرید خانه / دسته‌بندی
  final int sortOrder;

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
    this.artworkAsset,
    this.isActive = true,
    this.sortOrder = 0,
  });

  Color get artworkColor => Color(artworkColorValue);
  int get episodeCount => episodes.length;
  String get durationLabel => '$duration دقیقه';
  EpisodeModel get firstEpisode => episodes.first;

  /// فقط قسمت‌های فعال برای نمایش
  List<EpisodeModel> get activeEpisodes =>
      episodes.where((e) => e.isActive).toList(growable: false);

  /// آیا همهٔ قسمت‌ها دارای hash معتبر آپارات هستند؟
  bool get hasAllValidHashes =>
      episodes.every((e) => e.aparatVideoHash != null);

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
    String? artworkAsset,
    bool? isActive,
    int? sortOrder,
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
      artworkAsset: artworkAsset ?? this.artworkAsset,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
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
