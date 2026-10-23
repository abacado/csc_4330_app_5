/// Data models shared by the store and the HTTP layer.
///
/// Field names follow the contract in TASKS.md. The server owns `id`,
/// `status`, `createdAt`, and `updatedAt`; clients never set them.
library;

import 'dart:convert';

import 'errors.dart';

const listingTypes = {'swap', 'giveaway'};
const listingStatuses = {'available', 'completed'};
const requestStatuses = {'pending', 'accepted', 'declined'};
const hobbyLevels = {'wantToTry', 'learning', 'experienced'};

/// Fields every stored record has.
abstract interface class StoredRecord {
  String get id;
  DateTime get createdAt;
}

class Listing implements StoredRecord {
  Listing({
    required this.id,
    required this.ownerId,
    required this.hobbyId,
    required this.title,
    required this.description,
    required this.condition,
    required this.type,
    required this.wantedItem,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.area,
    this.photoDataUrl,
  });

  @override
  final String id;
  final String ownerId;
  final String hobbyId;
  final String title;
  final String description;
  final String condition;
  final String type;
  final String? wantedItem;

  /// City or area the owner typed, or null.
  final String? area;

  /// One validated `data:image/...;base64,...` photo, or null.
  final String? photoDataUrl;
  String status;
  @override
  final DateTime createdAt;
  DateTime updatedAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'hobbyId': hobbyId,
        'title': title,
        'description': description,
        'condition': condition,
        'type': type,
        'wantedItem': wantedItem,
        'area': area,
        'photoDataUrl': photoDataUrl,
        'status': status,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  /// Records saved before photos and areas existed load with both as null.
  factory Listing.fromJson(Map<String, Object?> json) => Listing(
        id: json['id'] as String,
        ownerId: json['ownerId'] as String,
        hobbyId: json['hobbyId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        condition: json['condition'] as String,
        type: json['type'] as String,
        wantedItem: json['wantedItem'] as String?,
        area: json['area'] as String?,
        photoDataUrl: json['photoDataUrl'] as String?,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

class SwapRequest implements StoredRecord {
  SwapRequest({
    required this.id,
    required this.listingId,
    required this.requesterId,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  final String id;
  final String listingId;
  final String requesterId;
  final String message;
  String status;
  @override
  final DateTime createdAt;
  DateTime updatedAt;

  Map<String, Object?> toJson() => {
        'id': id,
        'listingId': listingId,
        'requesterId': requesterId,
        'message': message,
        'status': status,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory SwapRequest.fromJson(Map<String, Object?> json) => SwapRequest(
        id: json['id'] as String,
        listingId: json['listingId'] as String,
        requesterId: json['requesterId'] as String,
        message: json['message'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

/// A user's public profile. [userId] is the identity the app sends with
/// listings and requests; [username] is the unique handle people see.
class Profile implements StoredRecord {
  Profile({
    required this.userId,
    required this.username,
    required this.displayName,
    required this.bio,
    required this.hobbies,
    required this.wishlist,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  String username;
  String displayName;
  String bio;

  /// Hobby id → one of [hobbyLevels].
  Map<String, String> hobbies;
  List<String> wishlist;
  @override
  final DateTime createdAt;
  DateTime updatedAt;

  @override
  String get id => userId;

  Map<String, Object?> toJson() => {
        'userId': userId,
        'username': username,
        'displayName': displayName,
        'bio': bio,
        'hobbies': hobbies,
        'wishlist': wishlist,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory Profile.fromJson(Map<String, Object?> json) => Profile(
        userId: json['userId'] as String,
        username: json['username'] as String,
        displayName: json['displayName'] as String,
        bio: json['bio'] as String,
        hobbies: (json['hobbies'] as Map).cast<String, String>(),
        wishlist: (json['wishlist'] as List).cast<String>(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

/// Validated body for PUT /profiles/:userId. The whole profile is sent each
/// time, so a missing optional field is cleared.
class ProfileInput {
  ProfileInput._({
    required this.username,
    required this.displayName,
    required this.bio,
    required this.hobbies,
    required this.wishlist,
  });

  static const minUsernameLength = 3;
  static const maxUsernameLength = 30;
  static const maxWishlistItems = 50;

  /// Usernames keep their exact case and symbols, so `Ada` and `ada` are
  /// different handles. Only whitespace and control characters are refused.
  final String username;
  final String displayName;
  final String bio;
  final Map<String, String> hobbies;
  final List<String> wishlist;

  factory ProfileInput.fromJson(Object? body) {
    final json = _requireObject(body);
    final username = _requireString(
      json,
      'username',
      maxLength: maxUsernameLength,
    );
    if (username.length < minUsernameLength) {
      throw ValidationException(
        'username must be at least $minUsernameLength characters.',
        field: 'username',
      );
    }
    if (RegExp(r'[\s\x00-\x1F\x7F]').hasMatch(username)) {
      throw ValidationException(
        'username cannot contain spaces.',
        field: 'username',
      );
    }

    final rawHobbies = json['hobbies'] ?? const <String, Object?>{};
    if (rawHobbies is! Map<String, Object?>) {
      throw ValidationException(
        'hobbies must be an object of hobby id to level.',
        field: 'hobbies',
      );
    }
    final hobbies = <String, String>{};
    for (final MapEntry(key: hobbyId, value: level) in rawHobbies.entries) {
      if (hobbyId.trim().isEmpty || hobbyId.length > 64) {
        throw ValidationException(
          'Each hobby id must be 1 to 64 characters.',
          field: 'hobbies',
        );
      }
      if (level is! String || !hobbyLevels.contains(level)) {
        throw ValidationException(
          'Hobby levels must be one of: ${hobbyLevels.join(', ')}',
          field: 'hobbies',
        );
      }
      hobbies[hobbyId] = level;
    }

    final rawWishlist = json['wishlist'] ?? const <Object?>[];
    if (rawWishlist is! List ||
        rawWishlist.length > maxWishlistItems ||
        rawWishlist.any((item) => item is! String)) {
      throw ValidationException(
        'wishlist must be a list of at most $maxWishlistItems strings.',
        field: 'wishlist',
      );
    }
    final wishlist = [
      for (final item in rawWishlist.cast<String>())
        if (item.trim().isNotEmpty) _checkLength(item.trim(), 'wishlist', 60),
    ];

    return ProfileInput._(
      username: username,
      displayName: _requireString(json, 'displayName', maxLength: 40),
      bio: _optionalString(json, 'bio', maxLength: 160) ?? '',
      hobbies: hobbies,
      wishlist: wishlist,
    );
  }
}

/// Validated input for creating a listing.
class NewListing {
  NewListing._({
    required this.ownerId,
    required this.hobbyId,
    required this.title,
    required this.description,
    required this.condition,
    required this.type,
    required this.wantedItem,
    required this.area,
    required this.photoDataUrl,
  });

  final String ownerId;
  final String hobbyId;
  final String title;
  final String description;
  final String condition;
  final String type;
  final String? wantedItem;
  final String? area;
  final String? photoDataUrl;

  /// Parses and validates a request body. Throws [ValidationException].
  factory NewListing.fromJson(Object? body) {
    final json = _requireObject(body);
    final type = _requireString(json, 'type', maxLength: 20);
    if (!listingTypes.contains(type)) {
      throw ValidationException(
        'type must be one of: ${listingTypes.join(', ')}',
        field: 'type',
      );
    }
    return NewListing._(
      ownerId: _requireString(json, 'ownerId', maxLength: 64),
      hobbyId: _requireString(json, 'hobbyId', maxLength: 64),
      title: _requireString(json, 'title', maxLength: 80),
      description: _requireString(json, 'description', maxLength: 1000),
      condition: _requireString(json, 'condition', maxLength: 40),
      type: type,
      wantedItem: _optionalString(json, 'wantedItem', maxLength: 120),
      area: _optionalString(json, 'area', maxLength: 80),
      photoDataUrl: _optionalPhoto(json, 'photoDataUrl'),
    );
  }
}

/// Validated input for creating a swap request.
class NewSwapRequest {
  NewSwapRequest._({
    required this.listingId,
    required this.requesterId,
    required this.message,
  });

  final String listingId;
  final String requesterId;
  final String message;

  factory NewSwapRequest.fromJson(Object? body) {
    final json = _requireObject(body);
    return NewSwapRequest._(
      listingId: _requireString(json, 'listingId', maxLength: 64),
      requesterId: _requireString(json, 'requesterId', maxLength: 64),
      message: _requireString(json, 'message', maxLength: 500),
    );
  }
}

/// Parses `{"status": "accepted" | "declined"}` for PATCH /requests/:id.
String parseRequestDecision(Object? body) {
  final json = _requireObject(body);
  final status = _requireString(json, 'status', maxLength: 20);
  if (status != 'accepted' && status != 'declined') {
    throw ValidationException(
      'status must be "accepted" or "declined"',
      field: 'status',
    );
  }
  return status;
}

Map<String, Object?> _requireObject(Object? body) {
  if (body is Map<String, Object?>) return body;
  throw ValidationException('Request body must be a JSON object.');
}

String _requireString(
  Map<String, Object?> json,
  String field, {
  required int maxLength,
}) {
  final value = json[field];
  if (value is! String || value.trim().isEmpty) {
    throw ValidationException('$field is required.', field: field);
  }
  return _checkLength(value.trim(), field, maxLength);
}

String? _optionalString(
  Map<String, Object?> json,
  String field, {
  required int maxLength,
}) {
  final value = json[field];
  if (value == null) return null;
  if (value is! String) {
    throw ValidationException('$field must be a string.', field: field);
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : _checkLength(trimmed, field, maxLength);
}

String _checkLength(String value, String field, int maxLength) {
  if (value.length > maxLength) {
    throw ValidationException(
      '$field must be at most $maxLength characters.',
      field: field,
    );
  }
  return value;
}

/// Largest photo the server stores, measured after base64 decoding.
const maxPhotoBytes = 512 * 1024;

final _photoDataUrl = RegExp(
  r'^data:(image/(?:jpeg|png|webp));base64,([A-Za-z0-9+/]+={0,2})$',
);

/// Accepts only a base64 `data:` URL holding a JPEG, PNG, or WebP image whose
/// bytes really are that format. Other URL schemes are rejected.
String? _optionalPhoto(Map<String, Object?> json, String field) {
  final value = json[field];
  if (value == null) return null;
  if (value is! String) {
    throw ValidationException('$field must be a string.', field: field);
  }
  if (value.isEmpty) return null;
  final match = _photoDataUrl.firstMatch(value);
  if (match == null) {
    throw ValidationException(
      'The photo must be a JPG, PNG, or WebP image.',
      field: field,
    );
  }
  final List<int> bytes;
  try {
    bytes = base64.decode(match.group(2)!);
  } on FormatException {
    throw ValidationException('The photo could not be read.', field: field);
  }
  if (bytes.length > maxPhotoBytes) {
    throw ValidationException(
      'The photo must be at most 512 KB.',
      field: field,
    );
  }
  if (_imageType(bytes) != match.group(1)) {
    throw ValidationException(
      'The photo does not match its file type.',
      field: field,
    );
  }
  return value;
}

/// Identifies an image by its first bytes rather than trusting its label.
String? _imageType(List<int> b) {
  bool startsWith(List<int> sig, [int offset = 0]) {
    if (b.length < offset + sig.length) return false;
    for (var i = 0; i < sig.length; i++) {
      if (b[offset + i] != sig[i]) return false;
    }
    return true;
  }

  if (startsWith(const [0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (startsWith(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
    return 'image/png';
  }
  if (startsWith(const [0x52, 0x49, 0x46, 0x46]) && // RIFF
      startsWith(const [0x57, 0x45, 0x42, 0x50], 8)) {
    // WEBP
    return 'image/webp';
  }
  return null;
}
