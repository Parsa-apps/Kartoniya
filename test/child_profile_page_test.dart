import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kartoniya/data/providers/cartoons_provider.dart';
import 'package:kartoniya/presentation/pages/profile_page.dart';
import 'package:kartoniya/presentation/widgets/child_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SharedPreferences> preferences({bool withLegacyParentName = false}) async {
    SharedPreferences.setMockInitialValues({
      if (withLegacyParentName) 'parent_display_name': 'نام قدیمی والد',
    });
    return SharedPreferences.getInstance();
  }

  Future<void> openProfile(WidgetTester tester, SharedPreferences prefs) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('فضای والدین نه نام والد می‌خواهد نه آن را نمایش می‌دهد',
      (tester) async {
    final prefs = await preferences(withLegacyParentName: true);
    await openProfile(tester, prefs);

    expect(find.text('نام نمایشی والد'), findsNothing);
    expect(find.text('ویرایش نام'), findsNothing);
    expect(find.textContaining('نام قدیمی والد'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('نام کودک، سنِ سالانه و یکی از ۲۰ آواتار به‌صورت محلی ذخیره می‌شود',
      (tester) async {
    final prefs = await preferences();
    await openProfile(tester, prefs);

    await tester.tap(find.text('کودک من'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    final choices = find.byKey(const Key('child-avatar-choices'));
    expect(choices, findsOneWidget);
    expect(
      find.descendant(of: choices, matching: find.byType(ChildAvatar)),
      findsNWidgets(20),
    );

    final lastAvatar = find.byKey(const ValueKey('child-avatar-option-19'));
    await tester.ensureVisible(lastAvatar);
    await tester.tap(lastAvatar);
    await tester.pump();

    final ageField = find.byType(DropdownButtonFormField<int>);
    await tester.ensureVisible(ageField);
    await tester.tap(ageField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('۸ سال').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'آریا');
    await tester.pump();
    final saveButton = find.text('ذخیرهٔ پروفایل');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final saved = jsonDecode(prefs.getString('child_profile')!)
        as Map<String, dynamic>;
    expect(saved['name'], 'آریا');
    expect(saved['ageYears'], 8);
    expect(saved['avatar'], 19);
    expect(prefs.containsKey('parent_display_name'), isFalse);
    expect(tester.takeException(), isNull);
  });
}
