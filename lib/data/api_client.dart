import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

/// Thrown for every failed API call, so screens only need one catch.
///
/// [message] is safe to show to users. [statusCode] is null when the server
/// could not be reached at all. [field] names the invalid form field when the
/// server rejected the input.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.field});

  final String message;
  final int? statusCode;
  final String? field;

  bool get isNetworkError => statusCode == null;

  @override
  String toString() =>
      'ApiException(${statusCode ?? 'network'}${field == null ? '' : ', $field'}): $message';
}

/// The one place the app talks to the HobbySwap server.
///
/// Screens should use the shared instance from `data.dart` instead of making
/// HTTP calls themselves.
class ApiClient {
  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 10),
  }) : _http = httpClient ?? http.Client();

  final Uri baseUrl;
  final Duration timeout;
  final http.Client _http;

  /// True when the server answers `GET /health`.
  Future<bool> isHealthy() async {
    try {
      await _send('GET', '/health');
      return true;
    } on ApiException {
      return false;
    }
  }

  /// All listings, newest first. Pass [hobbyId] to show one hobby's listings.
  Future<List<Listing>> getListings({String? hobbyId}) async {
    final body = await _send('GET', '/listings', query: {'hobbyId': ?hobbyId});
    return _parse(
      () => [for (final item in body as List) Listing.fromJson(item)],
    );
  }

  Future<Listing> getListing(String id) async {
    final body = await _send('GET', '/listings/$id');
    return _parse(() => Listing.fromJson(body as Map<String, dynamic>));
  }

  /// Saves a listing owned by [ownerId] and returns it as stored.
  Future<Listing> createListing(
    NewListing listing, {
    required String ownerId,
  }) async {
    final body = await _send(
      'POST',
      '/listings',
      body: listing.toJson(ownerId: ownerId),
    );
    return _parse(() => Listing.fromJson(body as Map<String, dynamic>));
  }

  /// Requests [userId] sent plus requests for listings [userId] owns.
  Future<List<SwapRequest>> getRequests({required String userId}) async {
    final body = await _send('GET', '/requests', query: {'userId': userId});
    return _parse(
      () => [for (final item in body as List) SwapRequest.fromJson(item)],
    );
  }

  Future<SwapRequest> createRequest({
    required String listingId,
    required String requesterId,
    required String message,
  }) async {
    final body = await _send(
      'POST',
      '/requests',
      body: {
        'listingId': listingId,
        'requesterId': requesterId,
        'message': message,
      },
    );
    return _parse(() => SwapRequest.fromJson(body as Map<String, dynamic>));
  }

  /// Accepting also marks the listing completed on the server.
  Future<SwapRequest> acceptRequest(String id) =>
      _decide(id, RequestStatus.accepted);

  Future<SwapRequest> declineRequest(String id) =>
      _decide(id, RequestStatus.declined);

  Future<SwapRequest> _decide(String id, RequestStatus status) async {
    final body = await _send(
      'PATCH',
      '/requests/$id',
      body: {'status': status.name},
    );
    return _parse(() => SwapRequest.fromJson(body as Map<String, dynamic>));
  }

  /// [userId]'s profile, or null if they have not created one yet.
  Future<Profile?> getProfile(String userId) async {
    final Object? body;
    try {
      body = await _send('GET', '/profiles/$userId');
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
    return _parse(() => Profile.fromJson(body as Map<String, dynamic>));
  }

  /// Creates or replaces [profile] and returns it as stored.
  ///
  /// Throws an [ApiException] with `field == 'username'` and status 409 when
  /// another user already has that exact username.
  Future<Profile> saveProfile(Profile profile) async {
    final body = await _send(
      'PUT',
      '/profiles/${profile.userId}',
      body: profile.toJson(),
    );
    return _parse(() => Profile.fromJson(body as Map<String, dynamic>));
  }

  void close() => _http.close();

  Future<Object?> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final uri = baseUrl.replace(
      path: '${baseUrl.path.replaceAll(RegExp(r'/+$'), '')}$path',
      queryParameters: query == null || query.isEmpty ? null : query,
    );
    final request = http.Request(method, uri);
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _http.send(request).timeout(timeout),
      ).timeout(timeout);
    } on TimeoutException {
      throw ApiException(
        'The server took too long to respond. Check that it is running at $baseUrl.',
      );
    } on http.ClientException {
      throw ApiException(
        'Could not reach the server at $baseUrl. Check that it is running '
        'and that this device is on the same network.',
      );
    }

    final Object? decoded;
    try {
      decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    } on FormatException {
      throw ApiException(
        'The server sent an unexpected response.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    final error = decoded is Map ? decoded : const {};
    throw ApiException(
      error['error'] as String? ??
          'Request failed (HTTP ${response.statusCode}).',
      statusCode: response.statusCode,
      field: error['field'] as String?,
    );
  }

  /// Turns a malformed response into an [ApiException] instead of a crash.
  static T _parse<T>(T Function() parse) {
    try {
      return parse();
    } on Object catch (e) {
      if (e is! TypeError && e is! FormatException) rethrow;
      throw const ApiException('The server sent an unexpected response.');
    }
  }
}
