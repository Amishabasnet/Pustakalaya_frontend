/// A single field-level validation error, as returned by express-validator
/// on the backend: `{ field, message }`.
class ApiFieldError {
  final String field;
  final String message;
  const ApiFieldError({required this.field, required this.message});
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final List<ApiFieldError> fieldErrors;
  final bool isNetworkError;

  const ApiException(
    this.message, {
    this.statusCode,
    this.fieldErrors = const [],
    this.isNetworkError = false,
  });

  @override
  String toString() => message;
}
