import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:csc_4330_hobby_app/data/data.dart';
import 'package:csc_4330_hobby_app/features/home/available_listings.dart';

void main() {
  testWidgets('Home reloads listings from the server when signaled', (
    tester,
  ) async {
    final titles = <String>[];
    var requests = 0;
    final client = ApiClient(
      baseUrl: Uri.parse('http://test'),
      httpClient: MockClient((_) async {
        requests++;
        return http.Response(
          jsonEncode([
            for (final title in titles)
              {
                'id': title,
                'ownerId': 'other',
                'hobbyId': 'painting',
                'title': title,
                'description': 'Shared supplies',
                'condition': 'Good',
                'type': 'giveaway',
                'status': 'available',
                'area': 'Baton Rouge',
                'createdAt': '2026-10-23T12:00:00Z',
              },
          ]),
          200,
        );
      }),
    );
    addTearDown(client.close);
    final reload = ValueNotifier<int>(0);
    addTearDown(reload.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AvailableListings(client: client, reloadSignal: reload),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(requests, 1);
    expect(find.textContaining('No supplies listed yet'), findsOneWidget);

    // Someone posts a listing; the signal fires and Home fetches it.
    titles.add('Watercolor set');
    reload.value++;
    await tester.pumpAndSettle();
    expect(requests, 2);
    expect(find.text('Watercolor set'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
