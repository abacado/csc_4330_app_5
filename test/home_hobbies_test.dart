import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:csc_4330_hobby_app/data/api_client.dart';
import 'package:csc_4330_hobby_app/features/home/available_listings.dart';
import 'package:csc_4330_hobby_app/features/hobbies/explore_page.dart';

void main() {
  testWidgets('Checklist survives closing and reopening a hobby', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ExplorePage())),
    );
    await tester.tap(find.text('Painting'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Watercolor paints'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Watercolor paints'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 5 ready'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Painting'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 5 ready'), findsOneWidget);
  });

  testWidgets('Search narrows the hobby catalog', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ExplorePage())),
    );
    await tester.enterText(find.byType(TextField), 'photo');
    await tester.pump();
    expect(find.text('Photography'), findsOneWidget);
    expect(find.text('Painting'), findsNothing);
    await tester.enterText(find.byType(TextField), 'unknown');
    await tester.pump();
    expect(find.text('No hobbies match your search.'), findsOneWidget);
  });

  testWidgets(
    'Server errors can be retried and completed listings are hidden',
    (tester) async {
      var calls = 0;
      final client = ApiClient(
        baseUrl: Uri.parse('http://test'),
        httpClient: MockClient((request) async {
          expect(request.url.path, '/listings');
          calls++;
          if (calls == 1) {
            return http.Response('{"error":"Offline for test"}', 503);
          }
          return http.Response(
            jsonEncode([
              for (final status in ['available', 'completed'])
                {
                  'id': status,
                  'ownerId': 'other',
                  'hobbyId': 'painting',
                  'title': '$status paints',
                  'description': 'A small paint set',
                  'condition': 'Good',
                  'type': 'swap',
                  'status': status,
                  'wantedItem': 'Yarn',
                  'createdAt': '2026-10-22T12:00:00Z',
                },
            ]),
            200,
          );
        }),
      );
      addTearDown(client.close);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AvailableListings(client: client),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Offline for test'), findsOneWidget);
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('available paints'), findsOneWidget);
      expect(find.text('completed paints'), findsNothing);
      await tester.ensureVisible(find.text('available paints'));
      await tester.tap(find.text('available paints'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Looking for: Yarn'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Looking for: Yarn'), findsOneWidget);
    },
  );
}
