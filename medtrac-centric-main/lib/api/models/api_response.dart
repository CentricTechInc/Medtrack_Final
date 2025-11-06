/// Generic API Response wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    // Handle both boolean status and string success fields
    bool success = false;
    if (json['success'] != null) {
      success = json['success'] is bool ? json['success'] : json['success'] == 'true';
    } else if (json['status'] != null) {
      success = json['status'] is bool ? json['status'] : json['status'] == 'success';
    }

    // Handle error messages from errors array
    String? message = json['message'] ?? json['msg'];
    if (message == null && json['errors'] != null) {
      if (json['errors'] is List && (json['errors'] as List).isNotEmpty) {
        message = (json['errors'] as List).first.toString();
      } else if (json['errors'] is String) {
        message = json['errors'];
      }
    }

    return ApiResponse<T>(
      success: success,
      message: message,
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      statusCode: json['status_code'] ?? json['statusCode'],
    );
  }
}
