import 'dart:convert';

import 'package:csc_4330_hobby_app/data/data.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// JSON shaped exactly like the server's responses.
Map<String, Object?> listingJson({
  required String id,
  required String ownerId,
  String hobbyId = 'painting',
  String title = 'Watercolor set',
  String status = 'available',
}) => {
  'id': id,
  'ownerId': ownerId,
  'hobbyId': hobbyId,
  'title': title,
  'description': '24 pans',
  'condition': 'Good',
  'type': 'swap',
  'wantedItem': 'Brushes',
  'status': status,
  'createdAt': '2026-10-21T15:00:00.000Z',
  'updatedAt': '2026-10-21T15:00:00.000Z',
};

Map<String, Object?> requestJson({
  required String id,
  required String listingId,
  required String requesterId,
  String message = 'Interested!',
  String status = 'pending',
}) => {
  'id': id,
  'listingId': listingId,
  'requesterId': requesterId,
  'message': message,
  'status': status,
  'createdAt': '2026-10-21T15:05:00.000Z',
  'updatedAt': '2026-10-21T15:05:00.000Z',
};

Map<String, Object?> profileJson({
  required String userId,
  required String username,
  String displayName = 'Someone',
  String bio = '',
  Map<String, String> hobbies = const {},
  List<String> wishlist = const [],
}) => {
  'userId': userId,
  'username': username,
  'displayName': displayName,
  'bio': bio,
  'hobbies': hobbies,
  'wishlist': wishlist,
  'createdAt': '2026-10-21T15:00:00.000Z',
  'updatedAt': '2026-10-21T15:00:00.000Z',
};

/// A tiny in-memory stand-in for the HobbySwap server.
class FakeServer {
  FakeServer({
    List<Map<String, Object?>>? listings,
    this.requests = const [],
    Map<String, Map<String, Object?>>? profiles,
  }) : listings = listings ?? [],
       profiles = profiles ?? {};

  final List<Map<String, Object?>> listings;
  List<Map<String, Object?>> requests;

  /// User id → profile JSON, as the server stores it.
  final Map<String, Map<String, Object?>> profiles;
  final sent = <http.Request>[];

  late final client = ApiClient(
    baseUrl: Uri.parse('http://server:8080'),
    httpClient: MockClient(_handle),
  );

  Future<http.Response> _handle(http.Request request) async {
    sent.add(request);
    final path = request.url.path;
    Object? body;
    var status = 200;
    switch ((request.method, path)) {
      case ('GET', '/listings'):
        body = listings;
      case ('GET', '/requests'):
        body = requests;
      case ('POST', '/requests'):
        final input = jsonDecode(request.body) as Map<String, Object?>;
        final created = requestJson(
          id: 'req_new',
          listingId: input['listingId'] as String,
          requesterId: input['requesterId'] as String,
          message: input['message'] as String,
        );
        requests = [created, ...requests];
        body = created;
        status = 201;
      case ('PATCH', final p) when p.startsWith('/requests/'):
        final id = p.split('/').last;
        final decision = (jsonDecode(request.body) as Map)['status'];
        requests = [
          for (final r in requests)
            r['id'] == id ? {...r, 'status': decision} : r,
        ];
        body = requests.firstWhere((r) => r['id'] == id);
      case ('GET', final p) when p.startsWith('/profiles/'):
        final profile = profiles[p.split('/').last];
        body = profile ?? {'error': 'No profile yet.'};
        status = profile == null ? 404 : 200;
      case ('PUT', final p) when p.startsWith('/profiles/'):
        final userId = p.split('/').last;
        final input = jsonDecode(request.body) as Map<String, Object?>;
        final taken = profiles.entries.any(
          (e) => e.key != userId && e.value['username'] == input['username'],
        );
        if (taken) {
          body = {
            'error': 'The username @${input['username']} is already taken.',
            'field': 'username',
          };
          status = 409;
        } else {
          status = profiles.containsKey(userId) ? 200 : 201;
          body = profiles[userId] = profileJson(
            userId: userId,
            username: input['username'] as String,
            displayName: input['displayName'] as String,
            bio: input['bio'] as String? ?? '',
            hobbies: (input['hobbies'] as Map?)?.cast<String, String>() ?? {},
            wishlist: (input['wishlist'] as List?)?.cast<String>() ?? [],
          );
        }
      default:
        body = {'error': 'No route'};
        status = 404;
    }
    return http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );
  }
}
