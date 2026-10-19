/// نوع تصویر برداری آواتار کودک.
enum ChildAvatarStyle {
  fox,
  rabbit,
  bear,
  lion,
  frog,
  koala,
  panda,
  cat,
  tiger,
  owl,
  penguin,
  elephant,
  duck,
  deer,
  dinosaur,
  unicorn,
  puppy,
  monkey,
  bee,
  butterfly,
  dragon,
}

/// مشخصات سبک و رنگ یک آواتار برداریِ کم‌حجم.
class ChildAvatarSpec {
  const ChildAvatarSpec({
    required this.label,
    required this.style,
    required this.colorValue,
    required this.accentValue,
    required this.backgroundValue,
  });

  final String label;
  final ChildAvatarStyle style;
  final int colorValue;
  final int accentValue;
  final int backgroundValue;
}

/// پروفایل کودک فقط نام نمایشی، سن به سال و شمارهٔ تصویر برداری را روی
/// دستگاه نگه می‌دارد؛ تاریخ تولد، عکس، نام والد یا شناسه‌ای ذخیره نمی‌شود.
class ChildProfileModel {
  const ChildProfileModel({
    required this.name,
    required this.avatarIndex,
    this.ageYears,
  });

  static const empty = ChildProfileModel(name: '', avatarIndex: 0);

  final String name;
  final int avatarIndex;
  final int? ageYears;

  bool get hasName => name.trim().isNotEmpty;

  /// بیست تصویر مستقل و برداری؛ بدون emoji، دانلود یا فایل تصویری سنگین.
  static const avatars = <ChildAvatarSpec>[
    ChildAvatarSpec(
      label: 'روباه نارنجی', style: ChildAvatarStyle.fox,
      colorValue: 0xFFFF8A50, accentValue: 0xFFFFD0A8,
      backgroundValue: 0xFFFFE8D8,
    ),
    ChildAvatarSpec(
      label: 'خرگوش صورتی', style: ChildAvatarStyle.rabbit,
      colorValue: 0xFFF5A9C8, accentValue: 0xFFFFE4EF,
      backgroundValue: 0xFFFFEAF2,
    ),
    ChildAvatarSpec(
      label: 'شیر طلایی', style: ChildAvatarStyle.lion,
      colorValue: 0xFFFFB938, accentValue: 0xFFFFE19A,
      backgroundValue: 0xFFFFF2D1,
    ),
    ChildAvatarSpec(
      label: 'قورباغه سبز', style: ChildAvatarStyle.frog,
      colorValue: 0xFF58C68A, accentValue: 0xFFA7E9B6,
      backgroundValue: 0xFFE2F8E9,
    ),
    ChildAvatarSpec(
      label: 'کوالا آبی', style: ChildAvatarStyle.koala,
      colorValue: 0xFF84B9D8, accentValue: 0xFFD4EAF4,
      backgroundValue: 0xFFE7F5FC,
    ),
    ChildAvatarSpec(
      label: 'پاندای بنفش', style: ChildAvatarStyle.panda,
      colorValue: 0xFFB79BE8, accentValue: 0xFFE8DDF9,
      backgroundValue: 0xFFF0EAFE,
    ),
    ChildAvatarSpec(
      label: 'گربهٔ یاسی', style: ChildAvatarStyle.cat,
      colorValue: 0xFF9B91DB, accentValue: 0xFFE1DDF8,
      backgroundValue: 0xFFEFECFF,
    ),
    ChildAvatarSpec(
      label: 'ببر راه‌راه', style: ChildAvatarStyle.tiger,
      colorValue: 0xFFFF9650, accentValue: 0xFFFFD394,
      backgroundValue: 0xFFFFEBD7,
    ),
    ChildAvatarSpec(
      label: 'جغد دانا', style: ChildAvatarStyle.owl,
      colorValue: 0xFF9B765F, accentValue: 0xFFE9C987,
      backgroundValue: 0xFFF5EBD7,
    ),
    ChildAvatarSpec(
      label: 'پنگوئن دوست‌داشتنی', style: ChildAvatarStyle.penguin,
      colorValue: 0xFF557FA8, accentValue: 0xFFD6F0F5,
      backgroundValue: 0xFFE4F5FA,
    ),
    ChildAvatarSpec(
      label: 'فیل کوچولو', style: ChildAvatarStyle.elephant,
      colorValue: 0xFF8A9CDC, accentValue: 0xFFDDE3FF,
      backgroundValue: 0xFFEAEFFF,
    ),
    ChildAvatarSpec(
      label: 'اردک زرد', style: ChildAvatarStyle.duck,
      colorValue: 0xFFFFD34E, accentValue: 0xFFFFF0A6,
      backgroundValue: 0xFFFFF5D5,
    ),
    ChildAvatarSpec(
      label: 'گوزن مهربان', style: ChildAvatarStyle.deer,
      colorValue: 0xFFD58A62, accentValue: 0xFFF2D0A7,
      backgroundValue: 0xFFFFECDD,
    ),
    ChildAvatarSpec(
      label: 'دایناسور فیروزه‌ای', style: ChildAvatarStyle.dinosaur,
      colorValue: 0xFF43B9B1, accentValue: 0xFF9BE2D2,
      backgroundValue: 0xFFDCF7F0,
    ),
    ChildAvatarSpec(
      label: 'تک‌شاخ یخی', style: ChildAvatarStyle.unicorn,
      colorValue: 0xFFC58DE6, accentValue: 0xFFFFD6E8,
      backgroundValue: 0xFFF8E6FF,
    ),
    ChildAvatarSpec(
      label: 'توله‌سگ عسلی', style: ChildAvatarStyle.puppy,
      colorValue: 0xFFD99B58, accentValue: 0xFFFFDDA5,
      backgroundValue: 0xFFFFEFD9,
    ),
    ChildAvatarSpec(
      label: 'میمون بازیگوش', style: ChildAvatarStyle.monkey,
      colorValue: 0xFFA97956, accentValue: 0xFFEBC59B,
      backgroundValue: 0xFFF5E8D6,
    ),
    ChildAvatarSpec(
      label: 'زنبور عسل', style: ChildAvatarStyle.bee,
      colorValue: 0xFFFFC83D, accentValue: 0xFFFFE58A,
      backgroundValue: 0xFFFFF3CD,
    ),
    ChildAvatarSpec(
      label: 'پروانهٔ رنگین', style: ChildAvatarStyle.butterfly,
      colorValue: 0xFF8D9FEB, accentValue: 0xFFFFB4CF,
      backgroundValue: 0xFFEDEEFF,
    ),
    ChildAvatarSpec(
      label: 'اژدهای کوچولو', style: ChildAvatarStyle.dragon,
      colorValue: 0xFF68B9D2, accentValue: 0xFFB8E8E5,
      backgroundValue: 0xFFDFF6FA,
    ),
  ];

  ChildAvatarSpec get avatar =>
      avatars[avatarIndex.clamp(0, avatars.length - 1).toInt()];

  ChildProfileModel copyWith({
    String? name,
    int? ageYears,
    int? avatarIndex,
  }) {
    return ChildProfileModel(
      name: name ?? this.name,
      ageYears: ageYears ?? this.ageYears,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (ageYears != null) 'ageYears': ageYears,
        'avatar': avatarIndex,
      };

  static ChildProfileModel fromJson(Map<String, dynamic> json) {
    final rawName = json['name'];
    final rawAvatar = json['avatar'];
    final rawAge = json['ageYears'];
    return ChildProfileModel(
      name: rawName is String ? rawName : '',
      ageYears: rawAge is int && rawAge >= 1 && rawAge <= 18 ? rawAge : null,
      avatarIndex: rawAvatar is int ? rawAvatar : 0,
    );
  }
}
