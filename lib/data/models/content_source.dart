// ignore_for_file: dangling_library_doc_comments
/// منبع تأمین محتوا و وضعیت تأیید — اطلاعات داخلی، جدا از رابط نمایشی.
///
/// مطابق بخش ۴ ماموریت: شناسهٔ منبع، وضعیت مجوز و عیب‌یابی در مدل داخلی
/// نگه‌داری می‌شود اما خودکار در صفحهٔ تماشا نمایش داده نمی‌شود.

enum ContentSource {
  aparat('aparat', 'آپارات'),
  localAsset('local', 'دارایی محلی'),
  creativeCommons('cc', 'CC/آرشیو آزاد'),
  officialPublisher('official', 'ناشر رسمی'),
  pending('pending', 'در انتظار بررسی');

  const ContentSource(this.id, this.labelFa);
  final String id;
  final String labelFa;

  static ContentSource fromId(String? id) =>
      ContentSource.values.firstWhere((s) => s.id == id,
          orElse: () => ContentSource.pending);
}

enum VerificationStatus {
  verified('verified', 'تأییدشده'),
  pendingReview('pending', 'در انتظار تأیید'),
  draft('draft', 'پیش‌نویس'),
  disabled('disabled', 'غیرفعال');

  const VerificationStatus(this.id, this.labelFa);
  final String id;
  final String labelFa;

  static VerificationStatus fromId(String? id) =>
      VerificationStatus.values.firstWhere((v) => v.id == id,
          orElse: () => VerificationStatus.pendingReview);

  bool get isPlayable => this == VerificationStatus.verified;
}

enum ContentLicense {
  licensed('licensed', 'دارای مجوز'),
  ccBy('cc-by', 'CC BY'),
  ccBySa('cc-by-sa', 'CC BY-SA'),
  publicDomain('pd', 'مالکیت عمومی'),
  unknown('unknown', 'نامشخص'),
  notApplicable('na', '—');

  const ContentLicense(this.id, this.labelFa);
  final String id;
  final String labelFa;
}
