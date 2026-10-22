import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'errors.dart';
import 'models.dart';

/// Keeps listings, swap requests, and profiles in memory and saves every
/// change to a JSON file, so data survives a server restart.
///
/// Writes go to a temporary file that is then renamed over the real one, so a
/// crash mid-write never leaves a half-written data file behind.
class Store {
  Store._(
    this.file,
    this._listings,
    this._requests,
    this._profiles,
    this._clock,
  );

  /// The JSON file backing this store.
  final File file;
  final Map<String, Listing> _listings;
  final Map<String, SwapRequest> _requests;

  /// Keyed by user id.
  final Map<String, Profile> _profiles;
  final DateTime Function() _clock;
  Future<void> _pendingSave = Future.value();

  static const _formatVersion = 1;

  /// Loads the store from [path], creating an empty one if the file is absent.
  ///
  /// [clock] lets tests control timestamps.
  static Future<Store> open(String path, {DateTime Function()? clock}) async {
    final file = File(path);
    final listings = <String, Listing>{};
    final requests = <String, SwapRequest>{};
    final profiles = <String, Profile>{};
    if (await file.exists()) {
      final text = await file.readAsString();
      if (text.trim().isNotEmpty) {
        final Map<String, Object?> data;
        try {
          data = jsonDecode(text) as Map<String, Object?>;
        } on FormatException catch (e) {
          throw StateError(
            'Data file ${file.path} is not valid JSON ($e). '
            'Fix or move it before starting the server.',
          );
        }
        for (final item in data['listings'] as List? ?? const []) {
          final listing = Listing.fromJson(item as Map<String, Object?>);
          listings[listing.id] = listing;
        }
        for (final item in data['requests'] as List? ?? const []) {
          final request = SwapRequest.fromJson(item as Map<String, Object?>);
          requests[request.id] = request;
        }
        // Data files written before profiles existed have no 'profiles' key.
        for (final item in data['profiles'] as List? ?? const []) {
          final profile = Profile.fromJson(item as Map<String, Object?>);
          profiles[profile.userId] = profile;
        }
      }
    }
    return Store._(file, listings, requests, profiles, clock ?? DateTime.now);
  }

  /// Listings, newest first, optionally filtered by [hobbyId].
  List<Listing> listListings({String? hobbyId}) {
    final result = _listings.values
        .where((l) => hobbyId == null || l.hobbyId == hobbyId)
        .toList();
    result.sort(_newestFirst);
    return result;
  }

  Listing getListing(String id) =>
      _listings[id] ?? (throw NotFoundException('Listing $id not found.'));

  Future<Listing> createListing(NewListing input) async {
    final now = _clock().toUtc();
    final listing = Listing(
      id: _newId('lst'),
      ownerId: input.ownerId,
      hobbyId: input.hobbyId,
      title: input.title,
      description: input.description,
      condition: input.condition,
      type: input.type,
      wantedItem: input.wantedItem,
      status: 'available',
      createdAt: now,
      updatedAt: now,
    );
    _listings[listing.id] = listing;
    await _save();
    return listing;
  }

  /// Requests where [userId] is the requester (outgoing) or owns the listing
  /// (incoming), newest first.
  List<SwapRequest> requestsForUser(String userId) {
    final result = _requests.values
        .where(
          (r) =>
              r.requesterId == userId ||
              _listings[r.listingId]?.ownerId == userId,
        )
        .toList();
    result.sort(_newestFirst);
    return result;
  }

  Future<SwapRequest> createRequest(NewSwapRequest input) async {
    final listing = _listings[input.listingId];
    if (listing == null) {
      throw ValidationException(
        'Listing ${input.listingId} does not exist.',
        field: 'listingId',
      );
    }
    if (listing.status != 'available') {
      throw ConflictException('This listing is no longer available.');
    }
    if (listing.ownerId == input.requesterId) {
      throw ConflictException('You cannot request your own listing.');
    }
    final duplicate = _requests.values.any(
      (r) =>
          r.listingId == listing.id &&
          r.requesterId == input.requesterId &&
          r.status == 'pending',
    );
    if (duplicate) {
      throw ConflictException(
        'You already have a pending request for this listing.',
      );
    }
    final now = _clock().toUtc();
    final request = SwapRequest(
      id: _newId('req'),
      listingId: listing.id,
      requesterId: input.requesterId,
      message: input.message,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    );
    _requests[request.id] = request;
    await _save();
    return request;
  }

  /// Accepts or declines a pending request.
  ///
  /// Accepting marks the listing `completed` and declines any other pending
  /// requests for the same listing.
  Future<SwapRequest> decideRequest(String id, String status) async {
    final request =
        _requests[id] ?? (throw NotFoundException('Request $id not found.'));
    if (request.status != 'pending') {
      throw ConflictException('This request was already ${request.status}.');
    }
    final now = _clock().toUtc();
    request
      ..status = status
      ..updatedAt = now;
    if (status == 'accepted') {
      final listing = _listings[request.listingId];
      if (listing != null) {
        listing
          ..status = 'completed'
          ..updatedAt = now;
      }
      for (final other in _requests.values) {
        if (other.listingId == request.listingId && other.status == 'pending') {
          other
            ..status = 'declined'
            ..updatedAt = now;
        }
      }
    }
    await _save();
    return request;
  }

  Profile getProfile(String userId) =>
      _profiles[userId] ??
      (throw NotFoundException('No profile for $userId yet.'));

  /// Creates or replaces [userId]'s profile. Returns the saved profile and
  /// whether it was newly created.
  ///
  /// Usernames must be unique across users, compared exactly: `Ada` and `ada`
  /// can belong to different people, but two people cannot both be `Ada`.
  Future<(Profile, bool)> saveProfile(String userId, ProfileInput input) async {
    final taken = _profiles.values.any(
      (p) => p.username == input.username && p.userId != userId,
    );
    if (taken) {
      throw ConflictException(
        'The username @${input.username} is already taken.',
        field: 'username',
      );
    }
    final now = _clock().toUtc();
    final existing = _profiles[userId];
    final profile = existing ??
        Profile(
          userId: userId,
          username: input.username,
          displayName: input.displayName,
          bio: input.bio,
          hobbies: input.hobbies,
          wishlist: input.wishlist,
          createdAt: now,
          updatedAt: now,
        );
    profile
      ..username = input.username
      ..displayName = input.displayName
      ..bio = input.bio
      ..hobbies = input.hobbies
      ..wishlist = input.wishlist
      ..updatedAt = now;
    _profiles[userId] = profile;
    await _save();
    return (profile, existing == null);
  }

  /// Waits for any in-flight write to finish.
  Future<void> flush() => _pendingSave;

  Future<void> _save() {
    // Snapshot now so the file reflects the state at the time of the change,
    // and chain writes so they land in order.
    final snapshot = const JsonEncoder.withIndent('  ').convert({
      'version': _formatVersion,
      'listings': [for (final l in _listings.values) l.toJson()],
      'requests': [for (final r in _requests.values) r.toJson()],
      'profiles': [for (final p in _profiles.values) p.toJson()],
    });
    return _pendingSave = _pendingSave.then((_) => _write(snapshot));
  }

  Future<void> _write(String contents) async {
    await file.parent.create(recursive: true);
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(contents, flush: true);
    await temp.rename(file.path);
  }

  static final _random = Random.secure();

  static String _newId(String prefix) {
    final bytes = List.generate(8, (_) => _random.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${prefix}_$hex';
  }

  static int _newestFirst(StoredRecord a, StoredRecord b) {
    final byTime = b.createdAt.compareTo(a.createdAt);
    return byTime != 0 ? byTime : a.id.compareTo(b.id);
  }
}
