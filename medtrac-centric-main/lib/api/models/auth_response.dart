import 'user.dart';

/// Auth Response model
class AuthResponse {
  final String? token;
  final String? refreshToken;
  final User? user;
  final String? message;
  final bool status;

  AuthResponse({
    this.token,
    this.refreshToken,
    this.user,
    this.message,
    this.status = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['data'] != null && json['data'] is Map<String, dynamic>
          ? json['data']['token'] ?? json['access_token'] ?? ""
          : json['access_token'] ?? "",
      refreshToken: json['data'] != null && json['data'] is Map<String, dynamic>
          ? json['data']['refresh_token'] ?? ""
          : "",
      user: json['data'] != null ? User.fromJson(json['data']) : null,
      message: json['message'] ??
          (json['errors'] != null
              ? (json['errors'] is List
                  ? (json['errors'].isNotEmpty
                      ? json['errors'][0].toString()
                      : "Error")
                  : (json['errors'] is String
                      ? json['errors']
                      : json['errors'].toString()))
              : null),
      status: json['status'] ?? false,
    );
  }
}
