import 'dart:convert';

import 'package:csc_4330_hobby_app/data/api_client.dart';
import 'package:csc_4330_hobby_app/data/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// JSON shaped exactly like the server's responses.
Map<String, Object?> listingJson({
  String id = 'lst_1',
  String status = 'available',
}) => {
  'id': id,
  'ownerId': 'demo-user',
  'hobbyId': 'painting',
  'title': 'Watercolor set',
  'description': '24 pans',
  'condition': 'Good',
  'type': 'swap',
  'wantedItem': 'Brushes',
  'status': status,
  'createdAt': '2026-10-21T15:00:00.000Z',
  'updatedAt': '2026-10-21T15:00:00.000Z',
};

Map<String, Object?> requestJson({String status = 'pending'}) => {
  'id': 'req_1',
  'listingId': 'lst_1',
  'requesterId': 'demo-friend',
  'message': 'Interested!',
  'status': status,
  'createdAt': '2026-10-21T15:05:00.000Z',
  'updatedAt': '2026-10-21T15:05:00.000Z',
};

void main() {
  late List<http.Request> sent;

  ApiClient clientReturning(
    int status,
    Object? body, {
    String base = 'http://server:8080',
  }) {
    sent = [];
    return ApiClient(
      baseUrl: Uri.parse(base),
      httpClient: MockClient((request) async {
        sent.add(request);
        return http.Response(
          body == null ? '' : jsonEncode(body),
          status,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
  }

  test('getListings parses listings and sends the hobby filter', () async {
    final client = clientReturning(200, [listingJson()]);
    final listings = await client.getListings(hobbyId: 'painting');

    expect(sent.single.method, 'GET');
    expect(
      sent.single.url.toString(),
      'http://server:8080/listings?hobbyId=painting',
    );
    final listing = listings.single;
    expect(listing.id, 'lst_1');
    expect(listing.type, ListingType.swap);
    expect(listing.status, ListingStatus.available);
    expect(listing.isAvailable, isTrue);
    expect(listing.wantedItem, 'Brushes');
    expect(listing.createdAt, DateTime.utc(2026, 10, 21, 15));
  });

  test('getListings without a filter has no query string', () async {
    final client = clientReturning(200, <Object>[]);
    expect(await client.getListings(), isEmpty);
    expect(sent.single.url.toString(), 'http://server:8080/listings');
  });

  test('a base URL with a path prefix is kept', () async {
    final client = clientReturning(200, {
      'status': 'ok',
    }, base: 'http://host/api/');
    expect(await client.isHealthy(), isTrue);
    expect(sent.single.url.toString(), 'http://host/api/health');
  });

  test('createListing posts the contract fields', () async {
    final client = clientReturning(201, listingJson());
    await client.createListing(
      const NewListing(
        hobbyId: 'painting',
        title: 'Watercolor set',
        description: '24 pans',
        condition: 'Good',
        type: ListingType.giveaway,
      ),
      ownerId: 'demo-user',
    );

    expect(sent.single.method, 'POST');
    expect(sent.single.headers['Content-Type'], startsWith('application/json'));
    expect(jsonDecode(sent.single.body), {
      'ownerId': 'demo-user',
      'hobbyId': 'painting',
      'title': 'Watercolor set',
      'description': '24 pans',
      'condition': 'Good',
      'type': 'giveaway',
    });
  });

  test('requests: list, create, accept, decline', () async {
    var client = clientReturning(200, [requestJson()]);
    final requests = await client.getRequests(userId: 'demo-user');
    expect(sent.single.url.query, 'userId=demo-user');
    expect(requests.single.status, RequestStatus.pending);
    expect(requests.single.isOutgoingFor('demo-user'), isFalse);

    client = clientReturning(201, requestJson());
    await client.createRequest(
      listingId: 'lst_1',
      requesterId: 'demo-friend',
      message: 'Interested!',
    );
    expect(jsonDecode(sent.single.body), {
      'listingId': 'lst_1',
      'requesterId': 'demo-friend',
      'message': 'Interested!',
    });

    client = clientReturning(200, requestJson(status: 'accepted'));
    final accepted = await client.acceptRequest('req_1');
    expect(sent.single.method, 'PATCH');
    expect(sent.single.url.path, '/requests/req_1');
    expect(jsonDecode(sent.single.body), {'status': 'accepted'});
    expect(accepted.status, RequestStatus.accepted);

    client = clientReturning(200, requestJson(status: 'declined'));
    await client.declineRequest('req_1');
    expect(jsonDecode(sent.single.body), {'status': 'declined'});
  });

  test('server validation errors keep the message and field', () async {
    final client = clientReturning(400, {
      'error': 'title is required.',
      'field': 'title',
    });
    await expectLater(
      client.createListing(
        const NewListing(
          hobbyId: 'painting',
          title: '',
          description: 'x',
          condition: 'Good',
          type: ListingType.swap,
        ),
        ownerId: 'demo-user',
      ),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having((e) => e.field, 'field', 'title')
            .having((e) => e.message, 'message', 'title is required.'),
      ),
    );
  });

  test('errors without a JSON body still produce a readable message', () async {
    final client = clientReturning(502, null);
    await expectLater(
      client.getListings(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('502'),
        ),
      ),
    );
  });

  test('unreachable server becomes a network ApiException', () async {
    final client = ApiClient(
      baseUrl: Uri.parse('http://offline:8080'),
      httpClient: MockClient(
        (_) async => throw http.ClientException('refused'),
      ),
    );
    await expectLater(
      client.getListings(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.isNetworkError,
          'isNetworkError',
          isTrue,
        ),
      ),
    );
    expect(await client.isHealthy(), isFalse);
  });

  test('slow server times out', () async {
    final client = ApiClient(
      baseUrl: Uri.parse('http://slow:8080'),
      timeout: const Duration(milliseconds: 50),
      httpClient: MockClient(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => http.Response('[]', 200),
        ),
      ),
    );
    await expectLater(
      client.getListings(),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          contains('too long'),
        ),
      ),
    );
  });

  test('malformed responses become ApiException, not crashes', () async {
    final client = clientReturning(200, [
      {...listingJson(), 'type': 'auction'},
    ]);
    await expectLater(client.getListings(), throwsA(isA<ApiException>()));

    final notJson = ApiClient(
      baseUrl: Uri.parse('http://server'),
      httpClient: MockClient((_) async => http.Response('<html>', 200)),
    );
    await expectLater(notJson.getListings(), throwsA(isA<ApiException>()));
  });
}
