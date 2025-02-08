/// Custom exception class for handling API errors
class ApiException implements Exception {
  /// User-friendly error message
  final String message;

  /// HTTP status code or custom error code
  final int statusCode;

  /// Technical details about the error (optional)
  final String? details;

  ApiException(this.message, this.statusCode, [this.details]);

  @override
  String toString() {
    if (details != null) {
      return 'ApiException: $message (Status: $statusCode, Details: $details)';
    }
    return 'ApiException: $message (Status: $statusCode)';
  }

  /// Factory constructor to create an ApiException from a response body
  factory ApiException.fromJson(Map<String, dynamic> json) {
    return ApiException(
      json['message'] as String? ?? 'Unknown error',
      json['status_code'] as int? ?? 500,
      json['details'] as String?,
    );
  }

  /// Convert the exception to a map that can be serialized to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status_code': statusCode,
      if (details != null) 'details': details,
    };
  }

  /// Common error factory methods
  static ApiException networkError([String? details]) {
    return ApiException(
      'Network connection error',
      503,
      details,
    );
  }

  static ApiException unauthorized([String? details]) {
    return ApiException(
      'Unauthorized access',
      401,
      details,
    );
  }

  static ApiException notFound([String? details]) {
    return ApiException(
      'Resource not found',
      404,
      details,
    );
  }

  static ApiException invalidRequest([String? details]) {
    return ApiException(
      'Invalid request',
      400,
      details,
    );
  }

  static ApiException serverError([String? details]) {
    return ApiException(
      'Internal server error',
      500,
      details,
    );
  }
}
