/// App-side models for the HobbySwap API. Field names match TASKS.md and the
/// server in `server/`. The server sets `id`, `status`, and timestamps.
library;

enum ListingType { swap, giveaway }

enum ListingStatus { available, completed }

enum RequestStatus { pending, accepted, declined }

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
