// lib/services/api_exception.dart

/// Base type for all errors raised by the service layer.
///
/// Having typed exceptions lets the [CourseRepository] make a smart decision:
///   - a [NetworkException] means "we're probably offline" → fall back to cache
///   - an [ApiException] means "the server answered, but with an error"
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when the device cannot reach the server at all
/// (no internet, DNS failure, connection refused, timeout, …).
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

/// Thrown when the server responded but with a non-success status code,
/// or the response could not be parsed.
class ApiException extends AppException {
  final int? statusCode;
  const ApiException(super.message, {this.statusCode});
}
