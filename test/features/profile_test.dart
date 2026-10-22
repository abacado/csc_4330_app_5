import 'package:csc_4330_hobby_app/data/data.dart';
import 'package:csc_4330_hobby_app/features/profile/profile.dart';
import 'package:csc_4330_hobby_app/features/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_server.dart';

void main() {
  late ProfileStore store;
  late FakeServer server;

  Future<void> pumpProfile(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfilePage(store: store, client: server.client),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    store = ProfileStore();
    server = FakeServer(
      listings: [
        listingJson(
          id: 'mine',
          ownerId: ApiConfig.demoUserId,
          title: 'My spare yarn',
        ),
        listingJson(id: 'theirs', ownerId: 'demo-friend', title: 'Not mine'),
      ],
    );
  });

  testWidgets('creates a profile, then picks hobbies and levels', (
    tester,
  ) async {
    await pumpProfile(tester);
    await tester.tap(find.text('Create profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next: choose hobbies'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a display name.'), findsOneWidget);
    expect(store.profile, isNull);

    await tester.enterText(find.byType(TextFormField).first, 'Ada Lovelace');
    await tester.enterText(find.byType(TextFormField).last, 'I knit.');
    await tester.tap(find.text('Next: choose hobbies'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crochet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Experienced'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Save 1 hobby'), 200);
    await tester.tap(find.text('Save 1 hobby'));
    await tester.pumpAndSettle();

    expect(store.profile!.hobbies, {'crochet': HobbyLevel.experienced});
    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('I knit.'), findsOneWidget);
    expect(find.text('Crochet · Experienced'), findsOneWidget);
    expect(find.text('AL'), findsOneWidget);
  });

  testWidgets('edits details and shows only my listings', (tester) async {
    store.saveDetails(displayName: 'Ada', bio: '');
    await pumpProfile(tester);

    expect(find.text('My spare yarn'), findsOneWidget);
    expect(find.text('Not mine'), findsNothing);

    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Ada L.');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(store.profile!.displayName, 'Ada L.');
    expect(find.text('Ada L.'), findsOneWidget);
  });

  testWidgets('adds and removes wishlist items', (tester) async {
    store.saveDetails(displayName: 'Ada', bio: '');
    await pumpProfile(tester);

    await tester.scrollUntilVisible(find.text('Wishlist'), 200);
    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Knitting needles');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    expect(store.profile!.wishlist, ['Knitting needles']);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(store.profile!.wishlist, isEmpty);
  });

  test('wishlist ignores blanks and duplicates', () {
    store.saveDetails(displayName: 'Ada', bio: '');
    expect(store.addWish('Brushes'), isTrue);
    expect(store.addWish(' brushes '), isFalse);
    expect(store.addWish('   '), isFalse);
    expect(store.profile!.wishlist, ['Brushes']);
  });
}
