import 'dart:convert';

import 'package:csc_4330_hobby_app/data/data.dart';
import 'package:csc_4330_hobby_app/features/messages/messages_page.dart';
import 'package:csc_4330_hobby_app/features/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fake_server.dart';

void main() {
  final me = ApiConfig.demoUserId;
  late FakeServer server;
  late ProfileStore store;

  Future<void> pumpMessages(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessagesPage(client: server.client, store: store),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    server = FakeServer(
      profiles: {
        'demo-friend': profileJson(
          userId: 'demo-friend',
          username: 'Yarn.Queen',
        ),
      },
      listings: [
        listingJson(id: 'my_paint', ownerId: me, title: 'My paints'),
        listingJson(
          id: 'their_yarn',
          ownerId: 'demo-friend',
          hobbyId: 'crochet',
          title: 'Wool yarn bundle',
        ),
        listingJson(
          id: 'their_seeds',
          ownerId: 'demo-friend',
          hobbyId: 'gardening',
          title: 'Tomato seeds',
        ),
      ],
      requests: [
        requestJson(
          id: 'req_in',
          listingId: 'my_paint',
          requesterId: 'demo-friend',
          message: 'Can I have your paints?',
        ),
        requestJson(
          id: 'req_out',
          listingId: 'their_seeds',
          requesterId: me,
          message: 'Seeds please',
          status: 'declined',
        ),
      ],
    );
    store = ProfileStore(client: server.client, userId: me);
  });

  testWidgets('shows received and sent requests', (tester) async {
    await pumpMessages(tester);

    expect(find.text('Received (1 new)'), findsOneWidget);
    expect(find.text('My paints'), findsOneWidget);
    expect(find.text('Can I have your paints?'), findsOneWidget);
    expect(find.textContaining('From @Yarn.Queen'), findsOneWidget);
    expect(find.text('Seeds please'), findsNothing);

    await tester.tap(find.text('Sent (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Seeds please'), findsOneWidget);
    expect(find.text('Declined'), findsOneWidget);
    expect(find.textContaining('To @Yarn.Queen'), findsOneWidget);
  });

  testWidgets('accepts an incoming request', (tester) async {
    await pumpMessages(tester);
    await tester.scrollUntilVisible(find.text('Accept'), 200);
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();

    final patch = server.sent.singleWhere((r) => r.method == 'PATCH');
    expect(patch.url.path, '/requests/req_in');
    expect(jsonDecode(patch.body), {'status': 'accepted'});
    expect(find.text('Accepted'), findsOneWidget);
    expect(find.text('Accept'), findsNothing);
  });

  testWidgets('sends a request for a listing in my hobbies', (tester) async {
    server.profiles[me] = profileJson(
      userId: me,
      username: 'ada',
      hobbies: {'crochet': 'learning'},
    );
    await pumpMessages(tester);

    await tester.tap(find.text('New swap request'));
    await tester.pumpAndSettle();
    expect(find.text('Wool yarn bundle'), findsOneWidget);
    expect(find.textContaining('@Yarn.Queen'), findsOneWidget);
    expect(find.text('Tomato seeds'), findsNothing, reason: 'not my hobby');
    expect(find.text('My paints'), findsNothing, reason: 'my own listing');

    await tester.tap(find.text('Only my hobbies'));
    await tester.pumpAndSettle();
    expect(find.text('Tomato seeds'), findsOneWidget);

    await tester.tap(find.text('Wool yarn bundle'));
    await tester.pumpAndSettle();
    expect(find.text('Message to @Yarn.Queen'), findsOneWidget);
    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();
    expect(find.text('Write a short message.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'I can trade hooks');
    await tester.tap(find.text('Send request'));
    await tester.pumpAndSettle();

    final post = server.sent.singleWhere((r) => r.method == 'POST');
    expect(jsonDecode(post.body), {
      'listingId': 'their_yarn',
      'requesterId': me,
      'message': 'I can trade hooks',
    });
    expect(find.text('Sent (2)'), findsOneWidget);
    expect(find.text('I can trade hooks'), findsOneWidget);
  });

  testWidgets('shows a retry card when the server is unreachable', (
    tester,
  ) async {
    final offline = ApiClient(
      baseUrl: Uri.parse('http://server:8080'),
      httpClient: MockClient(
        (request) async => throw http.ClientException('offline'),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MessagesPage(client: offline, store: store),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load your requests'), findsOneWidget);
    expect(find.textContaining('Could not reach the server'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
