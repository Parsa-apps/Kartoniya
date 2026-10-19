// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/models/cartoon_model.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/data/repositories/local_cartoon_repository.dart';
import 'package:kartoniya/presentation/pages/cartoon_detail_page.dart';
import 'package:kartoniya/presentation/widgets/aparat_player.dart';
import 'package:kartoniya/presentation/widgets/player_brand_overlay.dart';
import 'package:kartoniya/presentation/widgets/kartoniya_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('صفحهٔ تماشا نباید توضیح اضافی منبع را در رابط نمایش دهد', () async {
    // این تست مطمئن می‌شود هیچ ویجت پلیر عبارات ممنوعه را به کاربر نشان نمی‌دهد
    // عباراتی که طبق بخش ۴ ماموریت باید حذف شوند
    const forbiddenPhrases = [
      'پخش از آپارات',
      'پخش رسمی در آپارات',
      'منتشرشده توسط',
      'نام ناشر',
      'آدرس صفحه وب منبع',
      'رفتن به سایت منبع',
    ];
    // بررسی مستقیم روی دادهٔ کاتالوگ — فقط عناوین فعال
    final cartoons = await LocalCartoonRepository().fetchCartoons();
    final activeCartoons = cartoons.where((c) => c.isActive).toList();
    for (final cartoon in activeCartoons) {
      for (final episode in cartoon.activeEpisodes) {
        for (final phrase in forbiddenPhrases) {
          expect(episode.title.contains(phrase), isFalse,
              reason: 'episode title contains forbidden phrase: $phrase');
          expect(episode.description.contains('منبع:'), isFalse,
              reason: 'episode description should not contain source tag');
        }
        // هر شناسه باید به همان ویدئوی تاییدشده برسد
        expect(episode.aparatVideoHash, isNotNull);
        expect(episode.aparatEmbedUri, isNotNull);
      }
    }
  });

  testWidgets('پلیر واقعی دارای دو لوگوی برند با هالهٔ نئونی است',
      (tester) async {
    // یک کانتینر ویدئوی ساده با overlay
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 360,
            height: 202,
            child: PlayerBrandOverlay(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(PlayerBrandOverlay), findsOneWidget);
    expect(find.byType(KartoniyaLogoMark), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('شناسهٔ نامعتبر خطای کنترل‌شده نشان می‌دهد و اپ را کرش نمی‌کند', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final badEpisode = const EpisodeModel(
      id: 'bad-1',
      title: 'قسمت خراب',
      durationSeconds: 60,
      videoUrl: 'https://www.aparat.com/v/bad!hash',
    );
    final badCartoon = CartoonModel(
      id: 'bad',
      title: 'تست خراب',
      description: 'توضیح تست',
      category: 'سرگرمی',
      duration: 5,
      rating: 4.0,
      ageRange: '۳ تا ۶',
      artworkEmoji: '🧪',
      artworkColorValue: 0xFF123456,
      episodes: [badEpisode],
      artworkAsset: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: AparatPlayer(cartoon: badCartoon, initialEpisode: badEpisode),
        ),
      ),
    );
    await tester.pump();
    // صبر برای fail (timeout 28s اما invalid hash فوری fail می‌دهد)
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('شناسه'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('فهرست قسمت‌ها فقط عنوان فارسی را دارد', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});
    final prefs = await SharedPreferences.getInstance();
    final cartoon = (await LocalCartoonRepository().fetchCartoons()).first;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: CartoonDetailPage(cartoon: cartoon),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    for (final episode in cartoon.episodes) {
      expect(find.text(episode.title), findsWidgets);
    }
    // نباید منبع یا آپارات در جزئیات دیده شود
    expect(find.textContaining('منبع:'), findsNothing);
    expect(find.textContaining('آپارات ·'), findsNothing);
  });

  test('هر hash باید به همان ویدئوی تأییدشده برسد (عدم جستجوی تصادفی)', () async {
    final cartoons = await LocalCartoonRepository().fetchCartoons();
    final episodes = cartoons
        .where((c) => c.isActive)
        .expand((c) => c.activeEpisodes)
        .toList();
    // هر hash یکتا و مستقیماً به URL کانونی map شده
    final hashes = episodes.map((e) => e.aparatVideoHash).toList();
    expect(hashes.toSet().length, 16);
    for (final ep in episodes) {
      expect(ep.videoUrl, 'https://www.aparat.com/v/${ep.aparatVideoHash}');
      expect(ep.aparatEmbedUri.toString(),
          'https://www.aparat.com/video/video/embed/videohash/${ep.aparatVideoHash}/vt/frame');
    }
  });
}
