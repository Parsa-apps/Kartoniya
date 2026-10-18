import '../../domain/repositories/cartoon_repository.dart';
import '../models/cartoon_model.dart';

/// کاتالوگ منتخب آپارات؛ شناسهٔ پایدار صفحه، نه URL موقت CDN.
/// منابع و محدودیت‌های بازبینی در docs/aparat-content.md ثبت شده‌اند.
class LocalCartoonRepository implements CartoonRepository {
  @override
  Future<List<CartoonModel>> fetchCartoons() async =>
      List<CartoonModel>.unmodifiable(_cartoons);

  @override
  Future<List<CategoryModel>> fetchCategories() async =>
      List<CategoryModel>.unmodifiable(_categories);

  EpisodeModel _episode(String cartoonId, int number, String hash,
      String title, int seconds, String publisher) {
    return EpisodeModel(
      id: '$cartoonId-$number',
      title: title,
      description: 'منبع: آپارات · منتشرکننده: $publisher',
      durationSeconds: seconds,
      videoUrl: 'https://www.aparat.com/v/$hash',
    );
  }

  late final List<CartoonModel> _cartoons = [
    CartoonModel(
      id: 'felak',
      title: 'ماجراهای اسکار',
      description:
          'دو قسمت فهرست‌شده با عنوان‌های «اسکار مارمولک» و «ماجراهای جدید اسکار».',
      category: 'ماجراجویی',
      artworkEmoji: '☁️',
      artworkColorValue: 0xFFF06A70,
      isFeatured: true,
      tags: const ['دوستی', 'آسمان', 'ماجراجویی'],
      episodes: [
        _episode('felak', 1, 'vsb5i06', 'اسکار مارمولک', 677, 'آپارات نیوا'),
        _episode('felak', 2, 'z803g86', 'ماجراهای جدید اسکار', 425, 'فیلمنما'),
      ],
    ),
    CartoonModel(
      id: 'alefba',
      title: 'الفبای فارسی',
      description:
          'دو عنوان فهرست‌شده دربارهٔ آموزش حروف و الفبای فارسی با انیمیشن.',
      category: 'آموزشی',
      artworkEmoji: 'آ',
      artworkColorValue: 0xFF4DB9EE,
      isFeatured: true,
      tags: const ['الفبا', 'فارسی', 'یادگیری'],
      episodes: [
        _episode('alefba', 1, 'ddy5427', 'الفبای فارسی با انیمیشن موزیکال', 420, 'کوچکستان'),
        _episode('alefba', 2, 'SfomR', 'آموزش الفبا؛ الف تا ث', 249, 'سنجاقک آبی'),
      ],
    ),
    CartoonModel(
      id: 'math',
      title: 'شمارش و اعداد',
      description:
          'دو عنوان فهرست‌شده دربارهٔ شمارش، اعداد و چوب‌خط.',
      category: 'آموزشی',
      artworkEmoji: '🔢',
      artworkColorValue: 0xFF53B86A,
      tags: const ['اعداد', 'حل مسئله', 'ریاضی'],
      episodes: [
        _episode('math', 1, 'ymji038', 'آموزش اعداد ۱ تا ۲۰', 121, 'فیکولند'),
        _episode('math', 2, 'rfa2n7f', 'اعداد ۰ تا ۳۰ با چوب‌خط', 151, 'کوچولوها'),
      ],
    ),
    CartoonModel(
      id: 'bedtime',
      title: 'قصه‌های تصویری',
      description: 'دو عنوان فهرست‌شده: «قصهٔ قوری» و «قصهٔ نور آبی».',
      category: 'سرگرمی',
      artworkEmoji: '🌙',
      artworkColorValue: 0xFF9B7CEB,
      isFeatured: true,
      tags: const ['قصه', 'خواب', 'آرامش'],
      episodes: [
        _episode('bedtime', 1, 'wyz0s88', 'قصهٔ قوری', 734, 'deliha'),
        _episode('bedtime', 2, 'g0716gm', 'قصهٔ نور آبی', 897, 'deliha'),
      ],
    ),
    CartoonModel(
      id: 'kitchen',
      title: 'آشپزی کوچولو',
      description:
          'دو عنوان دربارهٔ تهیهٔ کیک و آشپزی کوچولو؛ کار با خوراکی یا وسایل آشپزی فقط همراه بزرگ‌ترها.',
      category: 'هنری',
      artworkEmoji: '🍓',
      artworkColorValue: 0xFFFF8A50,
      tags: const ['خلاقیت', 'غذا', 'مهارت زندگی'],
      episodes: [
        _episode('kitchen', 1, 'l0498kh', 'تهیهٔ کیک باب اسفنجی', 59, 'مرد عنکبوتی'),
        _episode('kitchen', 2, 'ncky1g1', 'آشپزی کوچولو', 45, 'The land of gamers'),
      ],
    ),
    CartoonModel(
      id: 'rainbow',
      title: 'آشنایی با حیوانات',
      description:
          'دو عنوان فهرست‌شده دربارهٔ حیوانات مزرعه، باغ‌وحش و آشنایی با حیوانات.',
      category: 'سرگرمی',
      artworkEmoji: '🌈',
      artworkColorValue: 0xFFFFC83D,
      isFeatured: true,
      tags: const ['طبیعت', 'حیوانات', 'دوستی'],
      episodes: [
        _episode('rainbow', 1, 'd1391q9', 'حیوانات مزرعه و باغ وحش', 214, 'آپارات گرام'),
        _episode('rainbow', 2, 'j93q0wf', 'آشنایی با حیوانات', 1683, 'آپارات گرام'),
      ],
    ),
    CartoonModel(
      id: 'lab',
      title: 'کشف دنیای علم',
      description:
          'دو عنوان فهرست‌شده دربارهٔ کارکرد گوش و شناخت گونه‌های آب‌وهوا.',
      category: 'علمی',
      artworkEmoji: '🔬',
      artworkColorValue: 0xFF53B86A,
      tags: const ['علم', 'آزمایش', 'کنجکاوی'],
      episodes: [
        _episode('lab', 1, 'ywrbs8s', 'گوش چطور کار می‌کند؟', 229, 'فیکولند'),
        _episode('lab', 2, 'z0666k3', 'شناخت انواع آب‌و‌هوا', 238, 'فیکولند'),
      ],
    ),
    CartoonModel(
      id: 'melody',
      title: 'ترانه‌های کودکانه',
      description:
          'دو عنوان ترانه: «حیوانات جنگل» به انگلیسی و آهنگ منظومهٔ شمسی.',
      category: 'موسیقی',
      artworkEmoji: '🎵',
      artworkColorValue: 0xFFFFC83D,
      tags: const ['موسیقی', 'ریتم', 'جنگل'],
      episodes: [
        _episode('melody', 1, 'a15fnfv', 'حیوانات جنگل (انگلیسی)', 195, 'تفریح و سرگرمی'),
        _episode('melody', 2, 'a02g7w9', 'آهنگ منظومهٔ شمسی', 99, 'فیکولند'),
      ],
    ),
  ];

  static const List<CategoryModel> _categories = [
    CategoryModel(id: 'all', name: 'همه', emoji: '✨', colorValue: 0xFFFF8A50),
    CategoryModel(
      id: 'adventure',
      name: 'ماجراجویی',
      emoji: '🚀',
      colorValue: 0xFFF06A70,
    ),
    CategoryModel(
      id: 'education',
      name: 'آموزشی',
      emoji: '📚',
      colorValue: 0xFF4DB9EE,
    ),
    CategoryModel(
      id: 'fun',
      name: 'سرگرمی',
      emoji: '🎪',
      colorValue: 0xFFFF6B9D,
    ),
    CategoryModel(id: 'art', name: 'هنری', emoji: '🎨', colorValue: 0xFF9B7CEB),
    CategoryModel(id: 'science', name: 'علمی', emoji: '🔬', colorValue: 0xFF53B86A),
    CategoryModel(id: 'music', name: 'موسیقی', emoji: '🎵', colorValue: 0xFFFFC83D),
  ];
}
