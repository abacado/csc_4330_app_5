import 'dart:io';

import 'package:hobbyswap_server/hobbyswap_server.dart';
import 'package:test/test.dart';

Map<String, Object?> listingBody({
  String ownerId = 'owner',
  String hobbyId = 'painting',
  String type = 'swap',
}) =>
    {
      'ownerId': ownerId,
      'hobbyId': hobbyId,
      'title': 'Watercolor set',
      'description': '24 pans, lightly used.',
      'condition': 'Good',
      'type': type,
      'wantedItem': 'Brushes',
    };

NewSwapRequest requestBody(String listingId, {String requesterId = 'buyer'}) =>
    NewSwapRequest.fromJson({
      'listingId': listingId,
      'requesterId': requesterId,
      'message': 'Interested!',
    });

void main() {
  late Directory dir;
  late String path;
  var tick = 0;
  DateTime clock() => DateTime.utc(2026, 10, 21).add(Duration(seconds: tick++));

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hobbyswap_store_');
    path = '${dir.path}/data.json';
  });

  tearDown(() => dir.delete(recursive: true));

  group('NewListing validation', () {
    test('accepts a valid body and trims strings', () {
      final input = NewListing.fromJson({
        ...listingBody(),
        'title': '  Watercolor set  ',
        'wantedItem': '   ',
      });
      expect(input.title, 'Watercolor set');
      expect(input.wantedItem, isNull);
    });

    test('rejects missing fields', () {
      final body = listingBody()..remove('title');
      expect(
        () => NewListing.fromJson(body),
        throwsA(
          isA<ValidationException>().having((e) => e.field, 'field', 'title'),
        ),
      );
    });

    test('rejects unknown types and non-object bodies', () {
      expect(
        () => NewListing.fromJson(listingBody(type: 'sell')),
        throwsA(isA<ValidationException>()),
      );
      expect(
        () => NewListing.fromJson(['not', 'an', 'object']),
        throwsA(isA<ValidationException>()),
      );
    });

    test('rejects overly long values', () {
      expect(
        () => NewListing.fromJson({...listingBody(), 'title': 'x' * 81}),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Store', () {
    test('creates listings with server-owned fields', () async {
      final store = await Store.open(path, clock: clock);
      final listing = await store.createListing(
        NewListing.fromJson(listingBody()),
      );
      expect(listing.id, startsWith('lst_'));
      expect(listing.status, 'available');
      expect(store.listListings(), [listing]);
    });

    test('filters listings by hobby, newest first', () async {
      final store = await Store.open(path, clock: clock);
      final a = await store.createListing(NewListing.fromJson(listingBody()));
      final b = await store.createListing(
        NewListing.fromJson(listingBody(hobbyId: 'crochet')),
      );
      final c = await store.createListing(NewListing.fromJson(listingBody()));
      expect(store.listListings(), [c, b, a]);
      expect(store.listListings(hobbyId: 'painting'), [c, a]);
      expect(store.listListings(hobbyId: 'baking'), isEmpty);
    });

    test('data survives a restart', () async {
      final first = await Store.open(path, clock: clock);
      final listing = await first.createListing(
        NewListing.fromJson(listingBody()),
      );
      final request = await first.createRequest(requestBody(listing.id));
      await first.decideRequest(request.id, 'accepted');
      await first.flush();

      final second = await Store.open(path);
      final reloaded = second.getListing(listing.id);
      expect(reloaded.toJson(), {...listing.toJson(), 'status': 'completed'});
      expect(second.requestsForUser('buyer').single.status, 'accepted');
      expect(File('$path.tmp').existsSync(), isFalse);
    });

    test('refuses to start from a corrupt data file', () async {
      await File(path).writeAsString('{not json');
      expect(Store.open(path), throwsA(isA<StateError>()));
    });

    test('starts empty when the file is missing', () async {
      final store = await Store.open('${dir.path}/nested/data.json');
      expect(store.listListings(), isEmpty);
    });
  });

  group('Swap requests', () {
    late Store store;
    late Listing listing;

    setUp(() async {
      store = await Store.open(path, clock: clock);
      listing = await store.createListing(NewListing.fromJson(listingBody()));
    });

    test('are visible to both requester and owner', () async {
      final request = await store.createRequest(requestBody(listing.id));
      expect(request.status, 'pending');
      expect(store.requestsForUser('buyer'), [request]);
      expect(store.requestsForUser('owner'), [request]);
      expect(store.requestsForUser('someone-else'), isEmpty);
    });

    test('require an existing listing', () {
      expect(
        store.createRequest(requestBody('lst_missing')),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.field,
            'field',
            'listingId',
          ),
        ),
      );
    });

    test('cannot target your own listing or duplicate a pending one', () async {
      expect(
        store.createRequest(requestBody(listing.id, requesterId: 'owner')),
        throwsA(isA<ConflictException>()),
      );
      await store.createRequest(requestBody(listing.id));
      expect(
        store.createRequest(requestBody(listing.id)),
        throwsA(isA<ConflictException>()),
      );
    });

    test('accepting completes the listing and declines the others', () async {
      final a = await store.createRequest(requestBody(listing.id));
      final b = await store.createRequest(
        requestBody(listing.id, requesterId: 'other'),
      );
      await store.decideRequest(a.id, 'accepted');
      expect(store.getListing(listing.id).status, 'completed');
      expect(b.status, 'declined');
      expect(
        store.createRequest(requestBody(listing.id, requesterId: 'third')),
        throwsA(isA<ConflictException>()),
      );
    });

    test('can only be decided once', () async {
      final request = await store.createRequest(requestBody(listing.id));
      await store.decideRequest(request.id, 'declined');
      expect(store.getListing(listing.id).status, 'available');
      expect(
        store.decideRequest(request.id, 'accepted'),
        throwsA(isA<ConflictException>()),
      );
      expect(
        store.decideRequest('req_missing', 'accepted'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
