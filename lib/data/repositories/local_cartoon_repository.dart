import '../../domain/repositories/cartoon_repository.dart';
import '../models/cartoon_model.dart';
import '../models/content_source.dart';

/// کاتالوگ کارتونیا — ظرفیت ۱۰۰ عنوان با تفکیک وضعیت تأیید.
/// فقط محتوای verified به‌عنوان «تکمیل‌شده» شمرده می‌شود؛ بقیه ظرفیت توسعه
/// و برای نمایش وضعیت واقعی زیرساخت نگه‌داری می‌شوند.

class LocalCartoonRepository implements CartoonRepository {
  @override
  Future<List<CartoonModel>> fetchCartoons() async =>
      List<CartoonModel>.unmodifiable(_cartoons);

  @override
  Future<List<CategoryModel>> fetchCategories() async =>
      List<CategoryModel>.unmodifiable(_categories);

  EpisodeModel _episode(String cartoonId, int number, String hash, String title,
      int seconds, String publisher) {
    return EpisodeModel(
      id: '$cartoonId-$number',
      title: title,
      description: title,
      durationSeconds: seconds,
      videoUrl: 'https://www.aparat.com/v/$hash',
      isNew: number == 1,
      isActive: true,
      sortOrder: number,
      source: ContentSource.aparat,
      verification: VerificationStatus.verified,
    );
  }

  // ۸ عنوان تأییدشدهٔ فعلی (پخش آزمایش‌شده با hash واقعی)
  late final List<CartoonModel> _verified = [
    CartoonModel(
      id: 'felak',
      title: 'ماجراهای اسکار',
      description:
          'ماجراهای بامزهٔ اسکار مارمولک در دنیایی رنگارنگ؛ هر قسمت داستانی کوتاه و شیرین با دوستی و خنده دارد.',
      category: 'ماجراجویی',
      duration: 11,
      rating: 4.8,
      ageRange: '۳ تا ۷',
      artworkEmoji: '☁️',
      artworkColorValue: 0xFFF06A70,
      artworkAsset: 'asset/images/posters/oscar.webp',
      isNew: true,
      isFeatured: true,
      sortOrder: 1,
      source: ContentSource.aparat,
      verification: VerificationStatus.verified,
      tags: const ['دوستی', 'آسمان', 'ماجراجویی'],
      episodes: [
        _episode('felak', 1, 'vsb5i06', 'اسکار مارمولک', 677, 'آپارات نیوا'),
        _episode('felak', 2, 'z803g86', 'ماجراهای جدید اسکار', 425, 'فیلمنما'),
      ],
    ),
    CartoonModel(
      id: 'alefba',
      title: 'الفبای فارسی',
      description: 'آموزش حروف فارسی با انیمیشن و ترانه‌های شاد برای کودکان کنجکاو.',
      category: 'آموزشی',
      duration: 7,
      rating: 4.9,
      ageRange: '۴ تا ۶',
      artworkEmoji: 'آ',
      artworkColorValue: 0xFF4DB9EE,
      artworkAsset: 'asset/images/posters/alphabet.webp',
      isFeatured: true,
      sortOrder: 2,
      source: ContentSource.aparat,
      verification: VerificationStatus.verified,
      tags: const ['الفبا', 'فارسی', 'یادگیری'],
      episodes: [
        _episode('alefba', 1, 'ddy5427', 'الفبای فارسی با انیمیشن موزیکال', 420, 'کوچکستان'),
        _episode('alefba', 2, 'SfomR', 'آموزش الفبا؛ الف تا ث', 249, 'سنجاقک آبی'),
      ],
    ),
    CartoonModel(
      id: 'math',
      title: 'شمارش و اعداد',
      description: 'آموزش شمارش یک تا بیست و اعداد صفر تا سی با چوب‌خط.',
      category: 'آموزشی',
      duration: 2,
      rating: 4.7,
      ageRange: '۵ تا ۸',
      artworkEmoji: '🔢',
      artworkColorValue: 0xFF53B86A,
      artworkAsset: 'asset/images/posters/counting.webp',
      isNew: true,
      sortOrder: 3,
      source: ContentSource.aparat,
      verification: VerificationStatus.verified,
      tags: const ['اعداد', 'حل مسئله', 'ریاضی'],
      episodes: [
        _episode('math', 1, 'ymji038', 'آموزش اعداد ۱ تا ۲۰', 121, 'فیکولند'),
        _episode('math', 2, 'rfa2n7f', 'اعداد ۰ تا ۳۰ با چوب‌خط', 151, 'کوچولوها'),
      ],
    ),
    CartoonModel(
      id: 'bedtime',
      title: 'قصه‌های تصویری',
      description: 'دو داستان تصویری آرامش‌بخش دربارهٔ قوری مهربان و نور آبی جادویی؛ مناسب برای لحظه‌های آرام شب.',
      category: 'سرگرمی',
      duration: 12,
      rating: 4.9,
      ageRange: '۲ تا ۶',
      artworkEmoji: '🌙',
      artworkColorValue: 0xFF9B7CEB,
      artworkAsset: 'asset/images/posters/bedtime.webp',
      isFeatured: true,
      sortOrder: 4,
      source: ContentSource.aparat,
      verification: VerificationStatus.verified,
      tags: const ['قصه', 'خواب', 'آرامش'],
      episodes: [
        _episode('bedtime', 1, 'wyz0s88', 'قصهٔ قوری', 734, 'deliha'),
        _episode('bedtime', 2, 'g0716gm', 'قصهٔ نور آبی', 897, 'deliha'),
      ],
    ),
    CartoonModel(
      id: 'kitchen',
      title: 'آشپزی کوچولو',
      description: 'تماشای تهیه و تزئین غذای کوچک و کیک؛ انجام آشپزی فقط همراه بزرگ‌ترها.',
      category: 'هنری',
      duration: 1,
      rating: 4.6,
      ageRange: '۵ تا ۹',
      artworkEmoji: '🍓',
      artworkColorValue: 0xFFFF8A50,
      artworkAsset: 'asset/images/posters/cooking.webp',
      sortOrder: 5,
      source: ContentSource.aparat,
      verification: VerificationStatus.verified,
      tags: const ['خلاقیت', 'غذا', 'مهارت زندگی'],
      episodes: [
        _episode('kitchen', 1, 'l0498kh', 'تهیهٔ کیک باب اسفنجی', 59, 'مرد عنکبوتی'),
        _episode('kitchen', 2, 'ncky1g1', 'آشپزی کوچولو', 45, 'The land of gamers'),
      ],
    ),
    CartoonModel(
      id: 'rainbow',
      title: 'آشنایی با حیوانات',
      description: 'آشنایی با حیوانات مزرعه، باغ وحش و دنیای شگفت‌انگیز آن‌ها با تصاویری رنگارنگ.',
      category: 'سرگرمی',
      duration: 4,
      rating: 4.8,
      ageRange: '۲ تا ۶',
      artworkEmoji: '🌈',
      artworkColorValue: 0xFFFFC83D,
      artworkAsset: 'asset/images/posters/animals.webp',
      isFeatured: true,
      sortOrder: 6,
      source: ContentSource.aparat,
      verification: VerificationStatus.verified,
      tags: const ['طبیعت', 'حیوانات', 'دوستی'],
      episodes: [
        _episode('rainbow', 1, 'd1391q9', 'حیوانات مزرعه و باغ وحش', 214, 'آپارات گرام'),
        _episode('rainbow', 2, 'j93q0wf', 'آشنایی با حیوانات', 1683, 'آپارات گرام'),
      ],
    ),
    CartoonModel(
      id: 'lab',
      title: 'کشف دنیای علم',
      description: 'کشف رازهای بدن انسان و آب‌وهوا با زبانی ساده برای کودکان کنجکاو.',
      category: 'علمی',
      duration: 4,
      rating: 4.7,
      ageRange: '۶ تا ۱۰',
      artworkEmoji: '🔬',
      artworkColorValue: 0xFF53B86A,
      artworkAsset: 'asset/images/posters/science.webp',
      isNew: true,
      sortOrder: 7,
      source: ContentSource.aparat,
      verification: VerificationStatus.verified,
      tags: const ['علم', 'آزمایش', 'کنجکاوی'],
      episodes: [
        _episode('lab', 1, 'ywrbs8s', 'گوش چطور کار می‌کند؟', 229, 'فیکولند'),
        _episode('lab', 2, 'z0666k3', 'شناخت انواع آب‌و‌هوا', 238, 'فیکولند'),
      ],
    ),
    CartoonModel(
      id: 'melody',
      title: 'ترانه‌های کودکانه',
      description: 'ترانهٔ انگلیسی حیوانات جنگل و آهنگ فارسی منظومهٔ شمسی.',
      category: 'موسیقی',
      duration: 3,
      rating: 4.6,
      ageRange: '۲ تا ۵',
      artworkEmoji: '🎵',
      artworkColorValue: 0xFFFFC83D,
      artworkAsset: 'asset/images/posters/music.webp',
      sortOrder: 8,
      source: ContentSource.aparat,
      verification: VerificationStatus.verified,
      tags: const ['موسیقی', 'ریتم', 'جنگل'],
      episodes: [
        _episode('melody', 1, 'a15fnfv', 'حیوانات جنگل (انگلیسی)', 195, 'تفریح و سرگرمی'),
        _episode('melody', 2, 'a02g7w9', 'آهنگ منظومهٔ شمسی', 99, 'فیکولند'),
      ],
    ),
  ];

  // ظرفیت ۱۰۰ — ۹۲ عنوان پیش‌نویس با اطلاعات ساخت‌یافته اما بدون ادعای پخش
  // تا مجوز/منبع واقعی فراهم شود، به‌عنوان pending شمرده می‌شوند.
  List<CartoonModel> get _pending => _buildPending();

  List<CartoonModel> _buildPending() {
    const pendingTitles = [
      ('سفر به کهکشان', 'تخیلی و فانتزی', '🚀', 0xFF2E9BEB),
      ('دنیای دایناسورها', 'حیوانات و طبیعت', '🦖', 0xFF53B86A),
      ('ماجراهای جنگل', 'ماجراجویی', '🌲', 0xFF8F7AED),
      ('قصه‌های شیرین', 'داستان آموزنده', '📚', 0xFFFF8A50),
      ('دوستان صمیمی', 'دوستی و همکاری', '🤝', 0xFF17BFA8),
      ('خنده و شادی', 'کمدی و خنده‌دار', '😂', 0xFFFFC53D),
      ('کوچولوی کنجکاو', 'خردسالان', '👶', 0xFF7BC4FF),
      ('جادوی رنگ‌ها', 'هنری', '🎨', 0xFFFF6BA8),
      ('جزیره گنج', 'ماجراجویی', '🏝️', 0xFFC68A1B),
      ('ربات باهوش', 'علمی', '🤖', 0xFF557FA8),
      ('پرواز با دوستان', 'دوستی و همکاری', '🕊️', 0xFF2E9BEB),
      ('قصه شب مهتاب', 'داستان آموزنده', '🌙', 0xFF9B7CEB),
      ('مسابقه بزرگ', 'کمدی و خنده‌دار', '🏁', 0xFFFF5D6C),
      ('حیوانات بامزه', 'حیوانات و طبیعت', '🐾', 0xFFFF8A50),
      ('سفینه کوچک', 'تخیلی و فانتزی', '🛸', 0xFF8F7AED),
      ('انیمیشن کوتاه شاد', 'انیمیشن کوتاه', '🎬', 0xFF53B86A),
      ('کلاسیک دوست‌داشتنی', 'کلاسیک', '🎞️', 0xFF9B765F),
      ('موسیقی شاد', 'موسیقی', '🎵', 0xFFFFC53D),
      ('آموزش الفبا ۲', 'آموزشی', '🔤', 0xFF2E9BEB),
      ('اعداد جادویی', 'آموزشی', '🔢', 0xFF17BFA8),
      ('دکتر کوچولو', 'علمی', '🩺', 0xFFFF6BA8),
      ('باغ وحش', 'حیوانات و طبیعت', '🦁', 0xFFFF8A50),
      ('دریای آبی', 'حیوانات و طبیعت', '🐠', 0xFF7BC4FF),
      ('جنگل اسرارآمیز', 'ماجراجویی', '🌳', 0xFF53B86A),
      ('خانه عروسکی', 'خردسالان', '🏠', 0xFFF5A9C8),
      ('سیرک شاد', 'کمدی و خنده‌دار', '🎪', 0xFFFFC53D),
      ('قهرمان کوچک', 'دوستی و همکاری', '🦸', 0xFFFF5D6C),
      ('ماهی کوچولو', 'حیوانات و طبیعت', '🐟', 0xFF2E9BEB),
      ('قطار دوستی', 'دوستی و همکاری', '🚂', 0xFF8F7AED),
      ('کهکشان دور', 'تخیلی و فانتزی', '🌌', 0xFF557FA8),
    ];

    // تکثیر با تغییرات برای رسیدن به ۹۲ مورد
    final result = <CartoonModel>[];
    var counter = 0;
    for (var repeat = 0; repeat < 4; repeat++) {
      for (final entry in pendingTitles) {
        if (result.length >= 92) break;
        counter++;
        final base = entry.$1;
        final category = entry.$2;
        final emoji = entry.$3;
        final color = entry.$4;
        final title = repeat == 0 ? base : '$base ${repeat + 1}';
        result.add(
          CartoonModel(
            id: 'pending_${counter.toString().padLeft(3, '0')}',
            title: title,
            originalTitle: 'Pending Title $counter',
            description: 'این عنوان در ظرفیت ۱۰۰تایی تعریف شده اما هنوز مجوز/منبع پخش نهایی آن تأیید نشده است. پس از تأیید، ویدئوی واقعی جایگزین می‌شود.',
            category: category,
            duration: 3 + (counter % 7),
            rating: 4.0 + (counter % 5) * 0.1,
            ageRange: ['۲ تا ۴', '۳ تا ۶', '۴ تا ۷', '۵ تا ۸'][counter % 4],
            artworkEmoji: emoji,
            artworkColorValue: color,
            artworkAsset: null, // از پوستر برداری استفاده می‌کند
            isActive: true,
            isNew: counter % 7 == 0,
            isFeatured: false,
            sortOrder: 9 + counter,
            source: ContentSource.pending,
            verification: VerificationStatus.pendingReview,
            tags: const ['در انتظار تأیید'],
            episodes: [
              EpisodeModel(
                id: 'pending_${counter.toString().padLeft(3, '0')}-1',
                title: 'قسمت اول $title',
                description: 'در انتظار تأیید مجوز',
                durationSeconds: 180 + (counter * 7) % 600,
                videoUrl: 'https://example.com/pending/${counter}_1.mp4',
                isActive: false,
                verification: VerificationStatus.pendingReview,
                source: ContentSource.pending,
              ),
            ],
          ),
        );
      }
    }
    return result.take(92).toList();
  }

  late final List<CartoonModel> _cartoons = [
    ..._verified,
    ..._pending,
  ];

  static const List<CategoryModel> _categories = [
    CategoryModel(id: 'all', name: 'همه', emoji: '✨', colorValue: 0xFFFF8A50),
    CategoryModel(id: 'adventure', name: 'ماجراجویی', emoji: '🚀', colorValue: 0xFFF06A70),
    CategoryModel(id: 'comedy', name: 'کمدی و خنده‌دار', emoji: '😂', colorValue: 0xFFFFC53D),
    CategoryModel(id: 'animals', name: 'حیوانات و طبیعت', emoji: '🦁', colorValue: 0xFF53B86A),
    CategoryModel(id: 'educational', name: 'داستان آموزنده', emoji: '📚', colorValue: 0xFF4DB9EE),
    CategoryModel(id: 'friendship', name: 'دوستی و همکاری', emoji: '🤝', colorValue: 0xFF17BFA8),
    CategoryModel(id: 'fantasy', name: 'تخیلی و فانتزی', emoji: '🔮', colorValue: 0xFF8F7AED),
    CategoryModel(id: 'short', name: 'انیمیشن کوتاه', emoji: '🎬', colorValue: 0xFF9B765F),
    CategoryModel(id: 'classic', name: 'کلاسیک', emoji: '🎞️', colorValue: 0xFF9B765F),
    CategoryModel(id: 'toddler', name: 'خردسالان', emoji: '👶', colorValue: 0xFF7BC4FF),
    CategoryModel(id: 'education', name: 'آموزشی', emoji: '📚', colorValue: 0xFF4DB9EE),
    CategoryModel(id: 'fun', name: 'سرگرمی', emoji: '🎪', colorValue: 0xFFFF6B9D),
    CategoryModel(id: 'art', name: 'هنری', emoji: '🎨', colorValue: 0xFF9B7CEB),
    CategoryModel(id: 'science', name: 'علمی', emoji: '🔬', colorValue: 0xFF53B86A),
    CategoryModel(id: 'music', name: 'موسیقی', emoji: '🎵', colorValue: 0xFFFFC83D),
  ];
}
