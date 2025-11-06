// Simple API Exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  const ApiException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'ApiException: $message (Code: $statusCode)';
}

// Network Exception
class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}
