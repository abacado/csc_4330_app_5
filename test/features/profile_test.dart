import 'dart:convert';

import 'package:csc_4330_hobby_app/data/data.dart';
import 'package:csc_4330_hobby_app/features/hobbies/hobby_catalog.dart'
    as explore;
import 'package:csc_4330_hobby_app/features/profile/profile.dart';
import 'package:csc_4330_hobby_app/features/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fake_server.dart';

void main() {
  final me = ApiConfig.demoUserId;
  late FakeServer server;
  late ProfileStore store;

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

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  setUp(() {
    server = FakeServer(
      listings: [
        listingJson(id: 'mine', ownerId: me, title: 'My spare yarn'),
        listingJson(id: 'theirs', ownerId: 'demo-friend', title: 'Not mine'),
      ],
      profiles: {
        'demo-friend': profileJson(userId: 'demo-friend', username: 'ada'),
      },
    );
    store = ProfileStore(client: server.client, userId: me);
  });

  testWidgets('creates a profile, then finds hobbies by searching', (
    tester,
  ) async {
    await pumpProfile(tester);
    await tester.tap(find.text('Create profile'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next: choose hobbies'));
    await tester.pumpAndSettle();
    expect(find.text('Use at least 3 characters.'), findsOneWidget);
    expect(find.text('Enter a display name.'), findsOneWidget);

    await tester.enterText(field('Username'), 'Ada Lovelace');
    await tester.enterText(field('Display name'), 'Ada Lovelace');
    await tester.tap(find.text('Next: choose hobbies'));
    await tester.pumpAndSettle();
    expect(find.text('Usernames cannot have spaces.'), findsOneWidget);

    await tester.enterText(field('Username'), 'Ada.Knits!');
    await tester.enterText(field('About you (optional)'), 'I crochet.');
    await tester.tap(find.text('Next: choose hobbies'));
    await tester.pumpAndSettle();
    expect(server.profiles[me]!['username'], 'Ada.Knits!');

    // Typing a supply suggests the hobbies that use it.
    await tester.enterText(find.byType(TextField).first, 'yarn');
    await tester.pumpAndSettle();
    expect(find.text('Matches "yarn" · Fiber Arts'), findsWidgets);
    await tester.tap(find.text('Crochet'));
    await tester.pumpAndSettle();
    expect(find.text('Your hobbies (1)'), findsOneWidget);

    await tester.ensureVisible(find.text('Experienced'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Experienced'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save 1 hobby'));
    await tester.pumpAndSettle();

    expect(server.profiles[me]!['hobbies'], {'crochet': 'experienced'});
    expect(find.text('@Ada.Knits!'), findsOneWidget);
    expect(find.text('Crochet · Experienced'), findsOneWidget);
  });

  testWidgets('a taken username is refused, but other capitals are fine', (
    tester,
  ) async {
    await pumpProfile(tester);
    await tester.tap(find.text('Create profile'));
    await tester.pumpAndSettle();

    await tester.enterText(field('Username'), 'ada');
    await tester.enterText(field('Display name'), 'Ada');
    await tester.tap(find.text('Next: choose hobbies'));
    await tester.pumpAndSettle();
    expect(find.text('The username @ada is already taken.'), findsOneWidget);
    expect(server.profiles.containsKey(me), isFalse);

    await tester.enterText(field('Username'), 'Ada');
    await tester.pumpAndSettle();
    expect(find.text('The username @ada is already taken.'), findsNothing);
    await tester.tap(find.text('Next: choose hobbies'));
    await tester.pumpAndSettle();
    expect(server.profiles[me]!['username'], 'Ada');
    expect(find.text('Choose your hobbies'), findsOneWidget);
  });

  testWidgets('loads the saved profile, edits it, and shows my listings', (
    tester,
  ) async {
    server.profiles[me] = profileJson(
      userId: me,
      username: 'ada_l',
      displayName: 'Ada',
      hobbies: {'board-games': 'learning'},
    );
    await pumpProfile(tester);

    expect(find.text('@ada_l'), findsOneWidget);
    expect(find.text('Board Games · Learning'), findsOneWidget);
    expect(find.text('My spare yarn'), findsOneWidget);
    expect(find.text('Not mine'), findsNothing);

    await tester.tap(find.byTooltip('Edit profile'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Display name'), 'Ada L.');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(server.profiles[me]!['displayName'], 'Ada L.');
    expect(server.profiles[me]!['username'], 'ada_l');
    expect(find.text('Ada L.'), findsOneWidget);
  });

  testWidgets('wishlist changes are saved to the server', (tester) async {
    server.profiles[me] = profileJson(userId: me, username: 'ada_l');
    await pumpProfile(tester);

    await tester.scrollUntilVisible(find.text('Wishlist'), 200);
    await tester.tap(find.widgetWithText(TextButton, 'Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Knitting needles');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    expect(server.profiles[me]!['wishlist'], ['Knitting needles']);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(server.profiles[me]!['wishlist'], isEmpty);
  });

  testWidgets('shows a retry when the server is unreachable', (tester) async {
    final offline = ApiClient(
      baseUrl: Uri.parse('http://server:8080'),
      httpClient: MockClient((_) async => throw http.ClientException('down')),
    );
    store = ProfileStore(client: offline, userId: me);
    await pumpProfile(tester);
    expect(find.text('Could not load your profile'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  test('profile JSON round-trips hobby levels', () {
    final profile = Profile.fromJson(
      profileJson(userId: me, username: 'x_y', hobbies: {'chess': 'learning'}),
    );
    expect(profile.hobbies, {'chess': HobbyLevel.learning});
    expect(jsonDecode(jsonEncode(profile.toJson()))['hobbies'], {
      'chess': 'learning',
    });
  });

  group('HobbyCatalog', () {
    List<String> names(String query) => [
      for (final m in HobbyCatalog.search(query)) m.hobby.name,
    ];

    test('ids are unique and include every Explore hobby', () {
      final ids = HobbyCatalog.all.map((h) => h.id).toList();
      expect(ids.toSet().length, ids.length);
      // Explore's hobby guides and listings use these ids, so profiles must too.
      for (final hobby in explore.hobbyCatalog) {
        expect(HobbyCatalog.byId(hobby.id)?.name, hobby.name);
      }
      expect(HobbyCatalog.all.length, greaterThan(100));
    });

    test('name prefixes rank before keyword and mid-word matches', () {
      expect(names('paint').first, 'Painting');
      expect(names('Paint').first, 'Painting', reason: 'ignores case');
      expect(names('climb'), contains('Rock Climbing'));
      expect(names('yarn'), containsAll(['Crochet', 'Knitting']));
      expect(names('d&d'), ['Tabletop RPGs']);
      expect(HobbyCatalog.search('zzzz'), isEmpty);
      expect(HobbyCatalog.search('   '), isEmpty);
    });

    test('keyword matches say which keyword matched', () {
      final crochet = HobbyCatalog.search('yarn')
          .firstWhere((m) => m.hobby.name == 'Crochet');
      expect(crochet.keyword, 'yarn');
      expect(HobbyCatalog.search('crochet').first.keyword, isNull);
    });
  });
}
