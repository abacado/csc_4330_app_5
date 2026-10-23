import 'package:csc_4330_hobby_app/features/hobbies/explore_page.dart';
import 'package:csc_4330_hobby_app/features/hobbies/hobby_catalog.dart';
import 'package:csc_4330_hobby_app/features/hobbies/hobby_detail_page.dart';
import 'package:csc_4330_hobby_app/features/hobbies/hobby_guides.dart';
import 'package:csc_4330_hobby_app/features/profile/hobby_catalog.dart'
    as shared;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Explore catalog', () {
    test('every shared hobby has a complete guide', () {
      expect(hobbyCatalog.length, shared.HobbyCatalog.all.length);
      for (final hobby in hobbyCatalog) {
        expect(hobby.description, isNotEmpty, reason: hobby.id);
        expect(hobby.firstProject, isNotEmpty, reason: hobby.id);
        expect(hobby.starterItems, isNotEmpty, reason: hobby.id);
      }
    });

    test('every guide belongs to a hobby in the shared catalog', () {
      for (final MapEntry(key: id, value: guide) in hobbyGuides.entries) {
        expect(shared.HobbyCatalog.byId(id), isNotNull, reason: id);
        expect(guide.starterItems, hasLength(5), reason: id);
      }
    });

    test('the original six keep their hand-written guides', () {
      expect(
        hobbyById('painting')!.starterItems,
        contains('Watercolor paints'),
      );
      for (final id in shared.HobbyCatalog.popularIds) {
        expect(hobbyGuides.containsKey(id), isFalse, reason: id);
      }
    });
  });

  testWidgets('Explore lists new hobbies by category and opens their guide', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ExplorePage())),
    );
    expect(find.text('Art (11)'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'yarn');
    await tester.pump();
    expect(find.text('Knitting'), findsOneWidget);
    expect(find.text('Matches "yarn" · Fiber Arts'), findsWidgets);

    await tester.tap(find.text('Knitting'));
    await tester.pumpAndSettle();
    expect(find.text('Start with knitting'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Scissors'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(HobbyDetailPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Scissors'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 5 ready'), findsOneWidget);
  });
}
