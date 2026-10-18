/// پروفایل کودک؛ فقط نام نمایشی و ایندکس آواتار روی همین دستگاه ذخیره
/// می‌شود. هیچ نام واقعی، عکس، شناسه یا داده حساسی ثبت نمی‌گردد.
class ChildProfileModel {
  const ChildProfileModel({
    required this.name,
    required this.avatarIndex,
  });

  static const empty = ChildProfileModel(name: '', avatarIndex: 0);

  final String name;
  final int avatarIndex;

  bool get hasName => name.trim().isNotEmpty;

  /// نمایشگرهای انتخاب‌شدهٔ آواتار؛ ترتیب با فهرست UI باید یکی باشد.
  static const avatars = <(String, int)>[
    ('🦊', 0xFFFF7A59),
    ('🐰', 0xFFFF6BA8),
    ('🐼', 0xFF8F7AED),
    ('🦁', 0xFFFFC53D),
    ('🐸', 0xFF17BFA8),
    ('🐨', 0xFF2E9BEB),
  ];

  (String emoji, int colorValue) get avatar =>
      avatars[avatarIndex.clamp(0, avatars.length - 1).toInt()];

  ChildProfileModel copyWith({String? name, int? avatarIndex}) {
    return ChildProfileModel(
      name: name ?? this.name,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatar': avatarIndex,
      };

  static ChildProfileModel fromJson(Map<String, dynamic> json) {
    final rawName = json['name'];
    final rawAvatar = json['avatar'];
    return ChildProfileModel(
      name: rawName is String ? rawName : '',
      avatarIndex: rawAvatar is int ? rawAvatar : 0,
    );
  }
}
