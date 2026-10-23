import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:csc_4330_hobby_app/data/data.dart';
import 'package:csc_4330_hobby_app/features/listings/post_page.dart';
import 'package:csc_4330_hobby_app/features/listings/listing_detail_page.dart';

void main() {
  Future<void> tapText(WidgetTester tester, String label) async {
    final finder = find.text(label).last;
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> fill(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Item name'),
      'Paint set',
    );
    await tapText(tester, 'Hobby');
    await tapText(tester, 'Painting');
    await tapText(tester, 'Condition');
    await tapText(tester, 'Good');
    final description = find.widgetWithText(TextFormField, 'Description');
    await tester.ensureVisible(description);
    await tester.enterText(description, 'A small paint set with brushes.');
  }

  testWidgets(
    'Phone form validates, posts a giveaway once, and clears the draft',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var posts = 0;
      final client = ApiClient(
        baseUrl: Uri.parse('http://test'),
        httpClient: MockClient((request) async {
          posts++;
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['type'], 'giveaway');
          expect(body.containsKey('wantedItem'), false);
          return http.Response(
            jsonEncode({
              ...body,
              'id': 'new',
              'status': 'available',
              'createdAt': '2026-10-23T12:00:00Z',
            }),
            201,
          );
        }),
      );
      addTearDown(client.close);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PostPage(client: client)),
        ),
      );
      await tapText(tester, 'Post listing');
      expect(posts, 0);
      await fill(tester);
      await tapText(tester, 'Giveaway');
      await tapText(tester, 'Post listing');
      expect(posts, 1);
      expect(
        find.text('Listing posted! Find it on Home using Refresh.'),
        findsOneWidget,
      );
      expect(find.text('Paint set'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Preview preserves the draft and unsupported area does not create a listing',
    (tester) async {
      var posts = 0;
      final client = ApiClient(
        baseUrl: Uri.parse('http://test'),
        httpClient: MockClient((_) async {
          posts++;
          return http.Response('{}', 500);
        }),
      );
      addTearDown(client.close);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PostPage(client: client)),
        ),
      );
      await fill(tester);
      await tapText(tester, 'Giveaway');
      final area = find.widgetWithText(TextFormField, 'City / area (optional)');
      await tester.ensureVisible(area);
      await tester.enterText(area, 'Baton Rouge');
      await tapText(tester, 'Preview listing');
      expect(find.byType(ListingDetailPage), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('City / area: Baton Rouge'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('City / area: Baton Rouge'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tapText(tester, 'Post listing');
      expect(posts, 0);
      expect(
        find.textContaining(
          'Photo and city/area publishing is not available yet.',
        ),
        findsOneWidget,
      );
      expect(find.text('Paint set'), findsOneWidget);
    },
  );

  testWidgets(
    'Canceled picker keeps fallback and API failure preserves fields',
    (tester) async {
      final client = ApiClient(
        baseUrl: Uri.parse('http://test'),
        httpClient: MockClient(
          (_) async => http.Response('{"error":"Server unavailable"}', 503),
        ),
      );
      addTearDown(client.close);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostPage(client: client, pickPhoto: () async => null),
          ),
        ),
      );
      await tapText(tester, 'Add photo (optional)');
      expect(find.text('Remove photo'), findsNothing);
      await fill(tester);
      final wanted = find.widgetWithText(
        TextFormField,
        'What would you like in exchange?',
      );
      await tester.ensureVisible(wanted);
      await tester.enterText(wanted, 'Yarn');
      await tapText(tester, 'Post listing');
      expect(find.text('Server unavailable'), findsOneWidget);
      expect(find.text('Paint set'), findsOneWidget);
      expect(find.text('Yarn'), findsOneWidget);
    },
  );

  testWidgets('Oversized photo is rejected before rendering', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PostPage(pickPhoto: () async => Uint8List(512 * 1024 + 1)),
        ),
      ),
    );
    await tapText(tester, 'Add photo (optional)');
    expect(find.text('Choose a smaller image (up to 512 KB).'), findsOneWidget);
  });

  test('Media fields serialize and old server records remain compatible', () {
    const draft = NewListing(
      hobbyId: 'painting',
      title: 'Paint',
      description: 'Paint set',
      condition: 'Good',
      type: ListingType.swap,
      photoDataUrl: 'data:image/png;base64,AA==',
      area: 'Baton Rouge',
    );
    final json = draft.toJson(ownerId: 'owner');
    final item = Listing.fromJson({
      ...json,
      'id': 'item',
      'status': 'available',
      'createdAt': '2026-10-23T12:00:00Z',
    });
    expect(item.photoDataUrl, draft.photoDataUrl);
    expect(item.area, draft.area);
    json.remove('photoDataUrl');
    json.remove('area');
    final old = Listing.fromJson({
      ...json,
      'id': 'item',
      'status': 'available',
      'createdAt': '2026-10-23T12:00:00Z',
    });
    expect(old.photoDataUrl, isNull);
    expect(old.area, isNull);
  });
}
