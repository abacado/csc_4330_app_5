/// The demo user's profile, kept on the server so it survives restarts and
/// other users can see the unique @username.
///
/// Screens share the one [profileStore] and rebuild when it changes.
library;

import 'package:flutter/foundation.dart';

import '../../data/data.dart';

export 'hobby_catalog.dart';

extension HobbyLevelLabel on HobbyLevel {
  String get label => switch (this) {
    HobbyLevel.wantToTry => 'Want to try',
    HobbyLevel.learning => 'Learning',
    HobbyLevel.experienced => 'Experienced',
  };
}

/// Limits shared with the server (`server/lib/src/models.dart`).
abstract final class ProfileRules {
  static const minUsernameLength = 3;
  static const maxUsernameLength = 30;
  static const maxNameLength = 40;
  static const maxBioLength = 160;
  static const maxWishLength = 60;
  static const maxWishlistItems = 50;

  /// Usernames are case and symbol sensitive; only whitespace is refused.
  /// Returns an error message, or null when [value] is acceptable.
  static String? checkUsername(String value) {
    final username = value.trim();
    if (username.length < minUsernameLength) {
      return 'Use at least $minUsernameLength characters.';
    }
    if (username.contains(RegExp(r'\s'))) {
      return 'Usernames cannot have spaces.';
    }
    return null;
  }
}

extension ProfileDisplay on Profile {
  String get handle => '@$username';

  String get initials {
    final words = displayName.trim().split(RegExp(r'\s+'));
    return words.take(2).map((w) => w.isEmpty ? '' : w[0]).join().toUpperCase();
  }
}

class ProfileStore extends ChangeNotifier {
  /// Defaults to the shared [apiClient] and the demo user; tests pass fakes.
  ProfileStore({ApiClient? client, String? userId})
    : _client = client ?? apiClient,
      userId = userId ?? ApiConfig.demoUserId;

  final ApiClient _client;
  final String userId;

  Profile? _profile;
  bool _loading = false;
  ApiException? _loadError;
  Future<void>? _firstLoad;

  /// Usernames of other users, by user id. Null means they have no profile.
  final _usernames = <String, String?>{};

  /// Null until loaded, or when the user has not created a profile yet.
  Profile? get profile => _profile;
  bool get isLoading => _loading;

  /// Set when the last load failed, for example because the server is down.
  ApiException? get loadError => _loadError;

  /// Loads the profile from the server the first time it is called.
  Future<void> ensureLoaded() => _firstLoad ??= reload();

  Future<void> reload() async {
    _loading = true;
    _loadError = null;
    notifyListeners();
    try {
      _profile = await _client.getProfile(userId);
    } on ApiException catch (e) {
      _loadError = e;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Creates or updates the profile on the server.
  ///
  /// Throws [ApiException]; a taken username has `field == 'username'`.
  Future<void> save({
    required String username,
    required String displayName,
    required String bio,
  }) => _put(
    _profile?.copyWith(
          username: username,
          displayName: displayName,
          bio: bio,
        ) ??
        Profile(
          userId: userId,
          username: username,
          displayName: displayName,
          bio: bio,
        ),
  );

  Future<void> setHobbies(Map<String, HobbyLevel> hobbies) =>
      _put(_profile!.copyWith(hobbies: Map.unmodifiable(hobbies)));

  /// Returns false, without saving, when [item] is blank or already listed.
  Future<bool> addWish(String item) async {
    final trimmed = item.trim();
    final current = _profile?.wishlist ?? const [];
    final duplicate = current.any(
      (w) => w.toLowerCase() == trimmed.toLowerCase(),
    );
    if (_profile == null || trimmed.isEmpty || duplicate) return false;
    await _put(
      _profile!.copyWith(wishlist: List.unmodifiable([...current, trimmed])),
    );
    return true;
  }

  Future<void> removeWish(String item) => _put(
    _profile!.copyWith(
      wishlist: List.unmodifiable(_profile!.wishlist.where((w) => w != item)),
    ),
  );

  Future<void> _put(Profile profile) async {
    _profile = await _client.saveProfile(profile);
    _usernames[userId] = _profile!.username;
    notifyListeners();
  }

  /// `@username` for each of [userIds], falling back to the user id for
  /// people without a profile or when the server cannot be reached.
  Future<Map<String, String>> handlesFor(Iterable<String> userIds) async {
    final missing = {
      for (final id in userIds)
        if (!_usernames.containsKey(id) && id != userId) id,
    };
    await Future.wait([
      for (final id in missing)
        _client
            .getProfile(id)
            .then((p) => _usernames[id] = p?.username)
            .catchError((Object _) => null, test: (e) => e is ApiException),
    ]);
    return {
      for (final id in userIds)
        id: switch (id == userId ? _profile?.username : _usernames[id]) {
          final username? => '@$username',
          null => id,
        },
    };
  }
}

/// The shared profile the whole app uses.
final ProfileStore profileStore = ProfileStore();
