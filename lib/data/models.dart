/// App-side models for the HobbySwap API. Field names match TASKS.md and the
/// server in `server/`. The server sets `id`, `status`, and timestamps.
library;

enum ListingType { swap, giveaway }

enum ListingStatus { available, completed }

enum RequestStatus { pending, accepted, declined }

enum HobbyLevel { wantToTry, learning, experienced }

T _enumByName<T extends Enum>(List<T> values, Object? name, String field) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException('Unexpected $field: $name');
}

class Listing {
  const Listing({
    required this.id,
    required this.ownerId,
    required this.hobbyId,
    required this.title,
    required this.description,
    required this.condition,
    required this.type,
    required this.status,
    required this.createdAt,
    this.wantedItem,
  });

  final String id;
  final String ownerId;
  final String hobbyId;
  final String title;
  final String description;
  final String condition;
  final ListingType type;
  final String? wantedItem;
  final ListingStatus status;
  final DateTime createdAt;

  bool get isAvailable => status == ListingStatus.available;

  factory Listing.fromJson(Map<String, dynamic> json) => Listing(
    id: json['id'] as String,
    ownerId: json['ownerId'] as String,
    hobbyId: json['hobbyId'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    condition: json['condition'] as String,
    type: _enumByName(ListingType.values, json['type'], 'listing type'),
    wantedItem: json['wantedItem'] as String?,
    status: _enumByName(ListingStatus.values, json['status'], 'listing status'),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

/// What a user fills in to post a listing. The owner is passed separately.
class NewListing {
  const NewListing({
    required this.hobbyId,
    required this.title,
    required this.description,
    required this.condition,
    required this.type,
    this.wantedItem,
  });

  final String hobbyId;
  final String title;
  final String description;
  final String condition;
  final ListingType type;
  final String? wantedItem;

  Map<String, Object?> toJson({required String ownerId}) => {
    'ownerId': ownerId,
    'hobbyId': hobbyId,
    'title': title,
    'description': description,
    'condition': condition,
    'type': type.name,
    if (wantedItem != null) 'wantedItem': wantedItem,
  };
}

class SwapRequest {
  const SwapRequest({
    required this.id,
    required this.listingId,
    required this.requesterId,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String listingId;
  final String requesterId;
  final String message;
  final RequestStatus status;
  final DateTime createdAt;

  /// True when [userId] sent this request (as opposed to receiving it).
  bool isOutgoingFor(String userId) => requesterId == userId;

  factory SwapRequest.fromJson(Map<String, dynamic> json) => SwapRequest(
    id: json['id'] as String,
    listingId: json['listingId'] as String,
    requesterId: json['requesterId'] as String,
    message: json['message'] as String,
    status: _enumByName(RequestStatus.values, json['status'], 'request status'),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

/// A user's public profile. [userId] is the identity sent with listings and
/// requests; [username] is the unique handle shown to other people. Usernames
/// are compared exactly, so `Ada` and `ada` are different handles.
class Profile {
  const Profile({
    required this.userId,
    required this.username,
    required this.displayName,
    this.bio = '',
    this.hobbies = const {},
    this.wishlist = const [],
  });

  final String userId;
  final String username;
  final String displayName;
  final String bio;

  /// Hobby id → how experienced the user is with it.
  final Map<String, HobbyLevel> hobbies;
  final List<String> wishlist;

  Profile copyWith({
    String? username,
    String? displayName,
    String? bio,
    Map<String, HobbyLevel>? hobbies,
    List<String>? wishlist,
  }) => Profile(
    userId: userId,
    username: username ?? this.username,
    displayName: displayName ?? this.displayName,
    bio: bio ?? this.bio,
    hobbies: hobbies ?? this.hobbies,
    wishlist: wishlist ?? this.wishlist,
  );

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    userId: json['userId'] as String,
    username: json['username'] as String,
    displayName: json['displayName'] as String,
    bio: json['bio'] as String,
    hobbies: {
      for (final MapEntry(:key, :value)
          in (json['hobbies'] as Map<String, dynamic>).entries)
        key: _enumByName(HobbyLevel.values, value, 'hobby level'),
    },
    wishlist: [for (final item in json['wishlist'] as List) item as String],
  );

  /// The body for `PUT /profiles/:userId`; the server keeps [userId] from
  /// the path and owns the timestamps.
  Map<String, Object?> toJson() => {
    'username': username,
    'displayName': displayName,
    'bio': bio,
    'hobbies': {
      for (final MapEntry(:key, :value) in hobbies.entries) key: value.name,
    },
    'wishlist': wishlist,
  };
}
