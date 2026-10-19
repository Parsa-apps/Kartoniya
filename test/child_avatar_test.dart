import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/models/child_profile_model.dart';
import 'package:kartoniya/presentation/widgets/child_avatar.dart';

void main() {
  test('پروفایل دقیقاً ۲۰ آواتار برداری با نام‌های یکتا دارد', () {
    final labels = ChildProfileModel.avatars.map((avatar) => avatar.label);
    expect(ChildProfileModel.avatars, hasLength(20));
    expect(labels.toSet(), hasLength(20));
  });

  test('مدل پروفایل سن کامل را می‌خواند و رکورد قدیمی را سازگار نگه می‌دارد',
      () {
    final current = ChildProfileModel.fromJson({
      'name': 'آریا',
      'ageYears': 8,
      'avatar': 19,
    });
    final old = ChildProfileModel.fromJson({'name': 'نیکا', 'avatar': 2});

    expect(current.name, 'آریا');
    expect(current.ageYears, 8);
    expect(current.avatarIndex, 19);
    expect(old.name, 'نیکا');
    expect(old.ageYears, isNull);
  });

  testWidgets('هر ۲۰ آواتار در اندازهٔ کوچک بدون emoji یا خطای رندر ساخته می‌شود',
      (tester) async {
    tester.view.physicalSize = const Size(960, 1600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (var index = 0;
                    index < ChildProfileModel.avatars.length;
                    index++)
                  ChildAvatar(index: index, size: 48),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(ChildAvatar), findsNWidgets(20));
    expect(tester.takeException(), isNull);
  });
}
