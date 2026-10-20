// ignore_for_file: unused_import, unused_local_variable, unused_field, prefer_final_fields, dangling_library_doc_comments, deprecated_member_use, curly_braces_in_flow_control_structures, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations, unnecessary_null_comparison, invalid_constant, undefined_method, missing_required_argument, undefined_named_parameter
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/repositories/local_cartoon_repository.dart';

void main() {
  group('LocalCartoonRepository', () {
    test('کاتالوگ دارای شناسه‌های یکتا و قسمت قابل پخش است', () async {
      final repository = LocalCartoonRepository();
      final cartoons = await repository.fetchCartoons();

      expect(cartoons, isNotEmpty);
      expect(cartoons.map((item) => item.id).toSet().length, cartoons.length);
      expect(
        cartoons.every(
          (cartoon) =>
              cartoon.episodes.isNotEmpty &&
              cartoon.episodes
                  .every((episode) => episode.videoUrl.startsWith('https://')),
        ),
        isTrue,
      );
    });

    test('ظرفیت ۱۰۰ کارتون با تفکیک تأییدشده/در انتظار', () async {
      final cartoons = await LocalCartoonRepository().fetchCartoons();
      // ظرفیت کل ۱۰۰ (۸ تأییدشده + ۹۲ در انتظار)
      expect(cartoons.length, 100);
      final verified = cartoons.where((c) => c.verification.isPlayable).toList();
      final pending = cartoons.where((c) => !c.verification.isPlayable).toList();
      expect(verified.length, 8);
      expect(pending.length, 92);
      expect(verified.every((c) => c.episodes.length == 2), isTrue);
      final episodes = verified.expand((c) => c.episodes).toList();
      expect(episodes.length, 16);
      expect(episodes.map((e) => e.aparatVideoHash).toSet().length, 16);
      expect(episodes.every((e) => e.aparatEmbedUri != null), isTrue);
      expect(episodes.every((e) => e.durationSeconds >= 30), isTrue);
      expect(episodes.every((e) => e.description.isNotEmpty), isTrue);
      expect(episodes.any((e) => e.description.contains('منبع:')), isFalse);
      expect(episodes.any((e) => e.videoUrl.contains('bee.mp4')), isFalse);
      // pendingها قابل پخش نیستند و در گزارش تکمیل‌شده شمرده نمی‌شوند
      expect(pending.every((c) => c.episodes.length == 1), isTrue);
      expect(pending.every((c) => c.verification == c.episodes.first.verification), isTrue);
    });

    test('دستهٔ همه در ابتدای فهرست قرار دارد', () async {
      final categories = await LocalCartoonRepository().fetchCategories();
      expect(categories.first.id, 'all');
    });

    test('کارتون‌های تأییدشده تصویر پوستر محلی یکتا دارند', () async {
      final cartoons = await LocalCartoonRepository().fetchCartoons();
      final verified = cartoons.where((c) => c.verification.isPlayable).toList();
      final assets = verified.map((c) => c.artworkAsset).toList();
      expect(assets.every((a) => a != null), isTrue);
      expect(assets.toSet().length, verified.length);
      expect(
        assets.every((a) => a!.startsWith('asset/images/posters/') && a.endsWith('.webp')),
        isTrue,
      );
    });

    test('ظرفیت کامل: تعداد واقعی و وضعیت داخلی گزارش‌پذیر است', () async {
      final repo = LocalCartoonRepository();
      final all = await repo.fetchCartoons();
      final cats = await repo.fetchCategories();
      // گزارش فنی داخلی: منبع و وضعیت تأیید باید قابل دسترس باشد
      expect(all.every((c) => c.source != null), isTrue);
      expect(all.every((c) => c.verification != null), isTrue);
      expect(cats.length, greaterThanOrEqualTo(10)); // دسته‌های جدید اضافه شده
      expect(cats.first.id, 'all');
    });
  });
}
