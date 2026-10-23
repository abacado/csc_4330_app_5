import 'dart:convert';
import 'dart:io';

import 'package:hobbyswap_server/hobbyswap_server.dart';
import 'package:test/test.dart';

/// Talks to a real server over HTTP, the way the app does.
class TestServer {
  TestServer._(this._server, this.store);

  final HttpServer _server;
  final Store store;
  final _client = HttpClient();

  static Future<TestServer> start(String dataPath) async {
    final store = await Store.open(dataPath);
    final server = await ApiHandler(
      store,
    ).serve(host: InternetAddress.loopbackIPv4, port: 0);
    return TestServer._(server, store);
  }

  Uri uri(String path) => Uri.parse('http://127.0.0.1:${_server.port}$path');

  Future<(int, Object?)> send(String method, String path,
      {Object? body}) async {
    final request = await _client.openUrl(method, uri(path));
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(body is String ? body : jsonEncode(body));
    }
    final response = await request.close();
    final text = await utf8.decodeStream(response);
    return (response.statusCode, text.isEmpty ? null : jsonDecode(text));
  }

  Future<void> stop() async {
    _client.close(force: true);
    await _server.close(force: true);
    await store.flush();
  }
}

Future<void> expectResponse(
  Future<(int, Object?)> response,
  int status,
  Object? body,
) async {
  final (actualStatus, actualBody) = await response;
  expect(actualStatus, status);
  expect(actualBody, body);
}

const validListing = {
  'ownerId': 'demo-owner',
  'hobbyId': 'painting',
  'title': 'Watercolor set',
  'description': '24 pans, lightly used.',
  'condition': 'Good',
  'type': 'swap',
  'wantedItem': 'Brushes',
};

void main() {
  late Directory dir;
  late TestServer server;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hobbyswap_api_');
    server = await TestServer.start('${dir.path}/data.json');
  });

  tearDown(() async {
    await server.stop();
    await dir.delete(recursive: true);
  });

  test('GET /health', () async {
    await expectResponse(server.send('GET', '/health'), 200, {'status': 'ok'});
  });

  test('POST then GET /listings, with hobby filter', () async {
    final (status, created) = await server.send(
      'POST',
      '/listings',
      body: validListing,
    );
    expect(status, 201);
    created as Map;
    expect(created['id'], isA<String>());
    expect(created['status'], 'available');
    expect(created['title'], 'Watercolor set');

    final (_, all) = await server.send('GET', '/listings');
    expect(all, [created]);
    final (_, painting) =
        await server.send('GET', '/listings?hobbyId=painting');
    expect(painting, [created]);
    final (_, baking) = await server.send('GET', '/listings?hobbyId=baking');
    expect(baking, isEmpty);
    await expectResponse(
      server.send('GET', '/listings/${created['id']}'),
      200,
      created,
    );
  });

  test('POST /listings rejects bad input with a field name', () async {
    final (status, body) = await server.send(
      'POST',
      '/listings',
      body: {...validListing, 'type': 'auction'},
    );
    expect(status, 400);
    expect(body, containsPair('field', 'type'));

    expect((await server.send('POST', '/listings', body: '{oops')).$1, 400);
    expect((await server.send('POST', '/listings')).$1, 400);
  });

  test('swap request lifecycle', () async {
    final (_, listing) = await server.send(
      'POST',
      '/listings',
      body: validListing,
    );
    final listingId = (listing as Map)['id'];

    final (status, request) = await server.send(
      'POST',
      '/requests',
      body: {
        'listingId': listingId,
        'requesterId': 'demo-requester',
        'message': 'I can trade brushes.',
      },
    );
    expect(status, 201);
    request as Map;
    expect(request['status'], 'pending');

    final (_, outgoing) = await server.send(
      'GET',
      '/requests?userId=demo-requester',
    );
    final (_, incoming) =
        await server.send('GET', '/requests?userId=demo-owner');
    expect(outgoing, [request]);
    expect(incoming, [request]);

    final (patchStatus, accepted) = await server.send(
      'PATCH',
      '/requests/${request['id']}',
      body: {'status': 'accepted'},
    );
    expect(patchStatus, 200);
    expect((accepted as Map)['status'], 'accepted');

    final (_, after) = await server.send('GET', '/listings/$listingId');
    expect((after as Map)['status'], 'completed');

    final (again, _) = await server.send(
      'PATCH',
      '/requests/${request['id']}',
      body: {'status': 'declined'},
    );
    expect(again, 409);
  });

  test('request errors', () async {
    expect((await server.send('GET', '/requests')).$1, 400);
    final (status, body) = await server.send(
      'POST',
      '/requests',
      body: {
        'listingId': 'lst_missing',
        'requesterId': 'demo-requester',
        'message': 'Hi',
      },
    );
    expect(status, 400);
    expect(body, containsPair('field', 'listingId'));
    expect(
      (await server.send(
        'PATCH',
        '/requests/req_missing',
        body: {'status': 'accepted'},
      ))
          .$1,
      404,
    );
  });

  test('unknown routes, wrong methods, and CORS preflight', () async {
    expect((await server.send('GET', '/nope')).$1, 404);
    expect((await server.send('DELETE', '/listings')).$1, 405);
    expect((await server.send('GET', '/listings/lst_missing')).$1, 404);

    final client = HttpClient();
    final request = await client.openUrl('OPTIONS', server.uri('/listings'));
    final response = await request.close();
    await response.drain<void>();
    client.close();
    expect(response.statusCode, 204);
    expect(response.headers.value('access-control-allow-origin'), '*');
  });

  test('profiles: create, read, update, and unique usernames', () async {
    const body = {
      'username': 'Ada',
      'displayName': 'Ada Lovelace',
      'hobbies': {'crochet': 'learning'},
    };
    final (missingStatus, _) = await server.send('GET', '/profiles/demo-user');
    expect(missingStatus, 404);

    final (createdStatus, created) = await server.send(
      'PUT',
      '/profiles/demo-user',
      body: body,
    );
    expect(createdStatus, 201);
    expect(created, containsPair('username', 'Ada'));
    expect(created, containsPair('bio', ''));
    expect(created, containsPair('wishlist', <Object?>[]));
    await expectResponse(
      server.send('GET', '/profiles/demo-user'),
      200,
      created,
    );

    final (updatedStatus, _) = await server.send(
      'PUT',
      '/profiles/demo-user',
      body: {...body, 'bio': 'Hooks for days'},
    );
    expect(updatedStatus, 200);

    await expectResponse(
      server.send('PUT', '/profiles/demo-friend', body: body),
      409,
      {'error': 'The username @Ada is already taken.', 'field': 'username'},
    );
    final (otherCaseStatus, _) = await server.send(
      'PUT',
      '/profiles/demo-friend',
      body: {...body, 'username': 'ada'},
    );
    expect(otherCaseStatus, 201);

    await expectResponse(
      server.send(
        'PUT',
        '/profiles/demo-friend',
        body: {...body, 'username': 'a d a'},
      ),
      400,
      {'error': 'username cannot contain spaces.', 'field': 'username'},
    );
    final (methodStatus, _) = await server.send('POST', '/profiles/demo-user');
    expect(methodStatus, 405);
  });

  test('listings and requests survive a server restart', () async {
    final (_, listing) = await server.send(
      'POST',
      '/listings',
      body: validListing,
    );
    final (_, request) = await server.send(
      'POST',
      '/requests',
      body: {
        'listingId': (listing as Map)['id'],
        'requesterId': 'demo-requester',
        'message': 'Still available?',
      },
    );
    await server.stop();

    server = await TestServer.start('${dir.path}/data.json');
    await expectResponse(server.send('GET', '/listings'), 200, [listing]);
    await expectResponse(
      server.send('GET', '/requests?userId=demo-owner'),
      200,
      [request],
    );
  });
}
