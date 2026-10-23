import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'errors.dart';
import 'models.dart';
import 'store.dart';

/// Routes HTTP requests to the [Store].
///
/// Endpoints (see TASKS.md):
///   GET    /health
///   GET    /listings[?hobbyId=...]
///   GET    /listings/:id
///   POST   /listings
///   GET    /requests?userId=...
///   POST   /requests
///   PATCH  /requests/:id
///   GET    /profiles/:userId
///   PUT    /profiles/:userId
class ApiHandler {
  ApiHandler(this.store, {this.log = _noLog});

  final Store store;
  final void Function(String line) log;

  /// Room for one 512 KiB photo after base64 encoding (about 683 KiB) plus
  /// the listing's text fields.
  static const maxBodyBytes = 768 * 1024;

  /// Starts listening. Use host `0.0.0.0` so phones on the same network can
  /// connect, and port 0 to pick a free port (handy in tests).
  Future<HttpServer> serve({Object host = '0.0.0.0', int port = 8080}) async {
    final server = await HttpServer.bind(host, port);
    server.listen(handle);
    return server;
  }

  Future<void> handle(HttpRequest request) async {
    final watch = Stopwatch()..start();
    final response = request.response;
    _addCors(response);
    int status;
    try {
      final (code, body) = await _route(request);
      status = code;
      await _send(response, code, body);
    } on ApiError catch (e) {
      status = e.statusCode;
      await _send(response, status, e.toJson());
    } catch (e, stack) {
      status = HttpStatus.internalServerError;
      log('Unexpected error: $e\n$stack');
      await _send(response, status, {'error': 'Internal server error.'});
    }
    log(
      '${request.method} ${request.uri} -> $status '
      '(${watch.elapsedMilliseconds} ms)',
    );
  }

  Future<(int, Object?)> _route(HttpRequest request) async {
    final method = request.method;
    final segments =
        request.uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final query = request.uri.queryParameters;

    if (method == 'OPTIONS') return (HttpStatus.noContent, null);

    switch (segments) {
      case ['health']:
        _allow(method, ['GET']);
        return (HttpStatus.ok, {'status': 'ok'});

      case ['listings']:
        _allow(method, ['GET', 'POST']);
        if (method == 'GET') {
          final hobbyId = query['hobbyId'];
          final listings = store.listListings(
            hobbyId: hobbyId == null || hobbyId.isEmpty ? null : hobbyId,
          );
          return (HttpStatus.ok, [for (final l in listings) l.toJson()]);
        }
        final input = NewListing.fromJson(await _readJson(request));
        final listing = await store.createListing(input);
        return (HttpStatus.created, listing.toJson());

      case ['listings', final id]:
        _allow(method, ['GET']);
        return (HttpStatus.ok, store.getListing(id).toJson());

      case ['requests']:
        _allow(method, ['GET', 'POST']);
        if (method == 'GET') {
          final userId = query['userId'];
          if (userId == null || userId.isEmpty) {
            throw ValidationException(
              'userId query parameter is required.',
              field: 'userId',
            );
          }
          final requests = store.requestsForUser(userId);
          return (HttpStatus.ok, [for (final r in requests) r.toJson()]);
        }
        final input = NewSwapRequest.fromJson(await _readJson(request));
        final created = await store.createRequest(input);
        return (HttpStatus.created, created.toJson());

      case ['requests', final id]:
        _allow(method, ['PATCH']);
        final status = parseRequestDecision(await _readJson(request));
        final updated = await store.decideRequest(id, status);
        return (HttpStatus.ok, updated.toJson());

      case ['profiles', final userId]:
        _allow(method, ['GET', 'PUT']);
        if (userId.length > 64) {
          throw ValidationException('userId is too long.', field: 'userId');
        }
        if (method == 'GET') {
          return (HttpStatus.ok, store.getProfile(userId).toJson());
        }
        final input = ProfileInput.fromJson(await _readJson(request));
        final (profile, created) = await store.saveProfile(userId, input);
        return (
          created ? HttpStatus.created : HttpStatus.ok,
          profile.toJson(),
        );

      default:
        throw NotFoundException('No route for ${request.uri.path}.');
    }
  }

  void _allow(String method, List<String> allowed) {
    if (!allowed.contains(method)) {
      throw MethodNotAllowedException(method, allowed);
    }
  }

  Future<Object?> _readJson(HttpRequest request) async {
    final bytes = <int>[];
    await for (final chunk in request) {
      bytes.addAll(chunk);
      if (bytes.length > maxBodyBytes) {
        throw ValidationException('Request body is too large.');
      }
    }
    if (bytes.isEmpty) {
      throw ValidationException('Request body must be a JSON object.');
    }
    try {
      return jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw ValidationException('Request body is not valid JSON.');
    }
  }

  Future<void> _send(HttpResponse response, int status, Object? body) async {
    response.statusCode = status;
    if (body != null) {
      response.headers.contentType = ContentType.json;
      response.write(jsonEncode(body));
    }
    await response.close();
  }

  /// Lets the web build (and `flutter run -d chrome`) call the server.
  void _addCors(HttpResponse response) {
    response.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, OPTIONS')
      ..set('Access-Control-Allow-Headers', 'Content-Type');
  }

  static void _noLog(String _) {}
}
