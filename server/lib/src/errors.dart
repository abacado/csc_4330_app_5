/// Errors the store raises. The HTTP layer maps each one to a status code.
sealed class ApiError implements Exception {
  ApiError(this.message);
  final String message;
  int get statusCode;

  Map<String, Object?> toJson() => {'error': message};

  @override
  String toString() => '$runtimeType: $message';
}

/// 400: the request body is missing a field or has a bad value.
class ValidationException extends ApiError {
  ValidationException(super.message, {this.field});
  final String? field;

  @override
  int get statusCode => 400;

  @override
  Map<String, Object?> toJson() => {
        'error': message,
        if (field != null) 'field': field,
      };
}

/// 404: the listing or request does not exist.
class NotFoundException extends ApiError {
  NotFoundException(super.message);

  @override
  int get statusCode => 404;
}

/// 409: the request is valid but conflicts with the current state.
class ConflictException extends ApiError {
  ConflictException(super.message);

  @override
  int get statusCode => 409;
}

/// 405: the path exists but does not support this HTTP method.
class MethodNotAllowedException extends ApiError {
  MethodNotAllowedException(String method, this.allowed)
      : super('$method is not allowed here. Use ${allowed.join(' or ')}.');
  final List<String> allowed;

  @override
  int get statusCode => 405;
}
