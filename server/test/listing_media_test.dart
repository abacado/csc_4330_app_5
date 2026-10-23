import 'dart:convert';
import 'dart:io';

import 'package:hobbyswap_server/hobbyswap_server.dart';
import 'package:test/test.dart';

const pngSignature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
const jpegSignature = [0xFF, 0xD8, 0xFF, 0xE0];
// "RIFF" + 4 size bytes + "WEBP"
const webpSignature = [
  0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x45, 0x42, 0x50, //
];

/// A data URL whose bytes start with [signature], padded to [size] bytes.
String photo(String mime, List<int> signature, {int size = 64}) {
  final bytes = [...signature, ...List.filled(size - signature.length, 7)];
  return 'data:$mime;base64,${base64Encode(bytes)}';
}

Map<String, Object?> listingBody({Object? photoDataUrl, Object? area}) => {
      'ownerId': 'owner',
      'hobbyId': 'painting',
      'title': 'Easel',
      'description': 'Folding easel',
      'condition': 'Good',
      'type': 'giveaway',
      if (photoDataUrl != null) 'photoDataUrl': photoDataUrl,
      if (area != null) 'area': area,
    };

Matcher rejects(String field) => throwsA(
      isA<ValidationException>().having((e) => e.field, 'field', field),
    );

void main() {
  group('photo and area validation', () {
    test('accepts JPG, PNG, and WebP photos and trims the area', () {
      for (final (mime, sig) in [
        ('image/jpeg', jpegSignature),
        ('image/png', pngSignature),
        ('image/webp', webpSignature),
      ]) {
        final url = photo(mime, sig);
        final input = NewListing.fromJson(
          listingBody(photoDataUrl: url, area: '  Baton Rouge  '),
        );
        expect(input.photoDataUrl, url);
        expect(input.area, 'Baton Rouge');
      }
    });

    test('both fields are optional, and blank counts as absent', () {
      final input = NewListing.fromJson(
        listingBody(photoDataUrl: '', area: '   '),
      );
      expect(input.photoDataUrl, isNull);
      expect(input.area, isNull);
    });

    test('rejects other URL schemes and non-image types', () {
      for (final bad in [
        'https://example.com/cat.png',
        'javascript:alert(1)',
        'data:text/html;base64,PGgxPg==',
        'data:image/gif;base64,R0lGODlh',
        'data:image/svg+xml;base64,PHN2Zz4=',
        'data:image/png,not-base64-marked',
      ]) {
        expect(
          () => NewListing.fromJson(listingBody(photoDataUrl: bad)),
          rejects('photoDataUrl'),
          reason: bad,
        );
      }
    });

    test('rejects bytes that do not match the declared type', () {
      expect(
        () => NewListing.fromJson(
          listingBody(photoDataUrl: photo('image/png', jpegSignature)),
        ),
        rejects('photoDataUrl'),
      );
      expect(
        () => NewListing.fromJson(
          listingBody(photoDataUrl: photo('image/jpeg', [1, 2, 3, 4])),
        ),
        rejects('photoDataUrl'),
      );
    });

    test('rejects invalid base64 and non-string values', () {
      expect(
        () => NewListing.fromJson(
          listingBody(photoDataUrl: 'data:image/png;base64,abc'),
        ),
        rejects('photoDataUrl'),
      );
      expect(
        () => NewListing.fromJson(listingBody(photoDataUrl: 42)),
        rejects('photoDataUrl'),
      );
    });

    test('enforces the 512 KB photo and 80 character area limits', () {
      final atLimit = photo('image/png', pngSignature, size: maxPhotoBytes);
      expect(
        NewListing.fromJson(listingBody(photoDataUrl: atLimit)).photoDataUrl,
        atLimit,
      );
      expect(
        () => NewListing.fromJson(
          listingBody(
            photoDataUrl: photo(
              'image/png',
              pngSignature,
              size: maxPhotoBytes + 1,
            ),
          ),
        ),
        rejects('photoDataUrl'),
      );
      expect(
        () => NewListing.fromJson(listingBody(area: 'x' * 81)),
        rejects('area'),
      );
    });
  });

  group('storage and HTTP', () {
    late Directory dir;
    late String path;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('hobbyswap_media_');
      path = '${dir.path}/data.json';
    });

    tearDown(() => dir.delete(recursive: true));

    test('photo and area survive a restart', () async {
      final url = photo('image/jpeg', jpegSignature, size: 2048);
      final first = await Store.open(path);
      final saved = await first.createListing(
        NewListing.fromJson(listingBody(photoDataUrl: url, area: 'Metairie')),
      );
      await first.flush();

      final reloaded = (await Store.open(path)).getListing(saved.id);
      expect(reloaded.photoDataUrl, url);
      expect(reloaded.area, 'Metairie');
    });

    test('listings saved before this change load with null fields', () async {
      await File(path).writeAsString(
        jsonEncode({
          'version': 1,
          'listings': [
            {
              'id': 'lst_old',
              'ownerId': 'owner',
              'hobbyId': 'painting',
              'title': 'Old easel',
              'description': 'From before photos',
              'condition': 'Good',
              'type': 'giveaway',
              'wantedItem': null,
              'status': 'available',
              'createdAt': '2026-10-21T00:00:00.000Z',
              'updatedAt': '2026-10-21T00:00:00.000Z',
            },
          ],
          'requests': [],
        }),
      );
      final listing = (await Store.open(path)).getListing('lst_old');
      expect(listing.photoDataUrl, isNull);
      expect(listing.area, isNull);
      expect(listing.toJson(), containsPair('photoDataUrl', null));
      expect(listing.toJson(), containsPair('area', null));
    });

    test('a full-size photo posts over HTTP and comes back in GET', () async {
      final store = await Store.open(path);
      final server = await ApiHandler(store)
          .serve(host: InternetAddress.loopbackIPv4, port: 0);
      final client = HttpClient();
      addTearDown(() async {
        client.close(force: true);
        await server.close(force: true);
      });

      Future<(int, Object?)> send(String method, String route,
          [Object? body]) async {
        final request = await client.openUrl(
          method,
          Uri.parse('http://127.0.0.1:${server.port}$route'),
        );
        if (body != null) {
          request.headers.contentType = ContentType.json;
          request.write(jsonEncode(body));
        }
        final response = await request.close();
        final text = await utf8.decodeStream(response);
        return (response.statusCode, text.isEmpty ? null : jsonDecode(text));
      }

      // 512 KiB of image is ~683 KiB of base64: over the old 64 KiB limit.
      final url = photo('image/png', pngSignature, size: maxPhotoBytes);
      final (status, created) = await send(
        'POST',
        '/listings',
        listingBody(photoDataUrl: url, area: 'Baton Rouge'),
      );
      expect(status, 201);
      expect(created, containsPair('photoDataUrl', url));
      expect(created, containsPair('area', 'Baton Rouge'));

      final (_, all) = await send('GET', '/listings');
      expect((all as List).single, containsPair('photoDataUrl', url));

      final (badStatus, badBody) = await send(
        'POST',
        '/listings',
        listingBody(photoDataUrl: 'https://example.com/a.png'),
      );
      expect(badStatus, 400);
      expect(badBody, containsPair('field', 'photoDataUrl'));

      final (tooBig, _) = await send(
        'POST',
        '/listings',
        listingBody(area: 'x' * (ApiHandler.maxBodyBytes + 1)),
      );
      expect(tooBig, 400);
    });
  });
}
