/// Data models shared by the store and the HTTP layer.
///
/// Field names follow the contract in TASKS.md. The server owns `id`,
/// `status`, `createdAt`, and `updatedAt`; clients never set them.
library;

import 'errors.dart';

const listingTypes = {'swap', 'giveaway'};
const listingStatuses = {'available', 'completed'};
const requestStatuses = {'pending', 'accepted', 'declined'};

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
        'status': status,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
      };

  factory Listing.fromJson(Map<String, Object?> json) => Listing(
        id: json['id'] as String,
        ownerId: json['ownerId'] as String,
        hobbyId: json['hobbyId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        condition: json['condition'] as String,
        type: json['type'] as String,
        wantedItem: json['wantedItem'] as String?,
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
  });

  final String ownerId;
  final String hobbyId;
  final String title;
  final String description;
  final String condition;
  final String type;
  final String? wantedItem;

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
