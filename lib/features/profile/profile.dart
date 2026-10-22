/// The demo user's profile, hobby selections, and wishlist.
///
/// There are no accounts on the server yet (see TASKS.md), so the profile is
/// kept on the device for this session and tied to [ApiConfig.demoUserId].
/// Screens share the one [profileStore] and rebuild when it changes.
library;

import 'package:flutter/material.dart';

import '../hobbies/explore_page.dart';

enum HobbyLevel {
  wantToTry('Want to try'),
  learning('Learning'),
  experienced('Experienced');

  const HobbyLevel(this.label);
  final String label;
}

/// The hobbies a user can pick, taken from the Explore tab so the two stay in
/// sync. Listing `hobbyId`s are the lowercase hobby names (`painting`).
abstract final class HobbyCatalog {
  static Iterable<String> get ids => ExplorePage.hobbies.keys.map(idFor);

  static String idFor(String name) => name.toLowerCase();

  static String nameFor(String id) => ExplorePage.hobbies.keys.firstWhere(
    (name) => idFor(name) == id,
    orElse: () => id,
  );

  static IconData iconFor(String id) =>
      ExplorePage.hobbies[nameFor(id)] ?? Icons.interests_outlined;
}

class UserProfile {
  const UserProfile({
    required this.displayName,
    this.bio = '',
    this.hobbies = const {},
    this.wishlist = const [],
  });

  static const maxNameLength = 40;
  static const maxBioLength = 160;
  static const maxWishLength = 60;

  final String displayName;
  final String bio;

  /// Hobby id → how experienced the user is with it.
  final Map<String, HobbyLevel> hobbies;
  final List<String> wishlist;

  String get initials {
    final words = displayName.trim().split(RegExp(r'\s+'));
    return words.take(2).map((w) => w.isEmpty ? '' : w[0]).join().toUpperCase();
  }

  UserProfile copyWith({
    String? displayName,
    String? bio,
    Map<String, HobbyLevel>? hobbies,
    List<String>? wishlist,
  }) => UserProfile(
    displayName: displayName ?? this.displayName,
    bio: bio ?? this.bio,
    hobbies: hobbies ?? this.hobbies,
    wishlist: wishlist ?? this.wishlist,
  );
}

class ProfileStore extends ChangeNotifier {
  UserProfile? _profile;

  /// Null until the user creates a profile.
  UserProfile? get profile => _profile;

  /// Creates the profile, or updates its name and bio if it exists.
  void saveDetails({required String displayName, required String bio}) {
    _profile =
        _profile?.copyWith(displayName: displayName, bio: bio) ??
        UserProfile(displayName: displayName, bio: bio);
    notifyListeners();
  }

  void setHobbies(Map<String, HobbyLevel> hobbies) =>
      _update((p) => p.copyWith(hobbies: Map.unmodifiable(hobbies)));

  /// Returns false when [item] is blank or already on the list.
  bool addWish(String item) {
    final trimmed = item.trim();
    final current = _profile?.wishlist ?? const [];
    final duplicate = current.any(
      (w) => w.toLowerCase() == trimmed.toLowerCase(),
    );
    if (_profile == null || trimmed.isEmpty || duplicate) return false;
    _update(
      (p) => p.copyWith(wishlist: List.unmodifiable([...current, trimmed])),
    );
    return true;
  }

  void removeWish(String item) => _update(
    (p) => p.copyWith(
      wishlist: List.unmodifiable(p.wishlist.where((w) => w != item)),
    ),
  );

  void _update(UserProfile Function(UserProfile) change) {
    final current = _profile;
    if (current == null) return;
    _profile = change(current);
    notifyListeners();
  }
}

/// The shared profile the whole app uses.
final ProfileStore profileStore = ProfileStore();
