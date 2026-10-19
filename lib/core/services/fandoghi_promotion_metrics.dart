import 'package:shared_preferences/shared_preferences.dart';

/// شمارنده‌های محلی و ناشناسِ معرفی جزیره فندقی؛ هیچ شناسه یا دادهٔ شخصی ندارد.
enum FandoghiPromotionEvent {
  impression('fandoghi_promo_impressions'),
  click('fandoghi_promo_clicks'),
  opened('fandoghi_promo_opened'),
  failed('fandoghi_promo_failed');

  const FandoghiPromotionEvent(this.storageKey);

  final String storageKey;
}

class FandoghiPromotionMetrics {
  const FandoghiPromotionMetrics();

  /// رخدادها فقط در SharedPreferences همین دستگاه ثبت می‌شوند.
  /// خرابی ذخیره‌سازی نباید روی تجربهٔ اصلی اپ اثر بگذارد.
  Future<void> record(FandoghiPromotionEvent event) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final next = (preferences.getInt(event.storageKey) ?? 0) + 1;
      await preferences.setInt(event.storageKey, next);
    } catch (_) {
      // آمار محلی اختیاری است؛ هیچ خطایی به کاربر منتقل نمی‌شود.
    }
  }
}
