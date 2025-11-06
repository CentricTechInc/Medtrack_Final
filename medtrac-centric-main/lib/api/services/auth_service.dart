/// Helper to parse API response for AuthResponse
library;

import 'dart:convert';

import 'package:medtrac/utils/helper_functions.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import '../http_client.dart';
import '../constants/api_constants.dart';
import '../models/auth_response.dart';

/// Authentication Service - Singleton
/// Handles all auth-related API calls
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final HttpClient _http = HttpClient();

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
    required String fcmToken,
  }) async {
    try {
      final response = await _http.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
          'fcm_token': fcmToken,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Register new user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String gender,
  }) async {
    try {
      final response = await _http.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone_number': phone,
          'gender': gender,
          'role': HelperFunctions.isUser() ? 'User' : 'Practitioner',
        },
      );
      return _parseAuthResponse(response.data,
          defaultError: 'Registration failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> verifyOtp({
    required String otp,
    required String email,
  }) async {
    try {
      final response = await _http.post(
        ApiConstants.verifyOtp + email,
        data: {
          'otp': otp,
        },
      );

      // The verify-OTP endpoint returns a slightly different shape (nested under "data").
      // Use AuthResponse.fromJson to normalize the response and then persist tokens/user info
      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.status == true) {
        // Save tokens and user info (if present) so callers can rely on persisted state
        if (authResponse.token != null && authResponse.token!.isNotEmpty) {
          await SharedPrefsService.setAccessToken(authResponse.token!);
        }
        if (authResponse.refreshToken != null && authResponse.refreshToken!.isNotEmpty) {
          await SharedPrefsService.setRefreshToken(authResponse.refreshToken!);
        }
        if (authResponse.user != null) {
          // Persist user JSON and role
          await SharedPrefsService.setUserInfo(jsonEncode(authResponse.user!.toJson()));
          await SharedPrefsService.setRole(authResponse.user!.role.name.toLowerCase());

          // If the response provides any doctor-specific approval/pending flags, save them
          if (authResponse.user!.isPending != null) {
            await SharedPrefsService.setProfileApprovalStatus(authResponse.user!.isPending!.name);
          }
        }
      }

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Forgot password
  Future<AuthResponse> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await _http.get(
        '${ApiConstants.forgotPassword}/$email',
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> createNewPassword({
    required String email,
    required String newPassword,
    required String otp,
  }) async {
    try {
      final response =
          await _http.post('${ApiConstants.updatePassword}/$email', data: {
        'password': newPassword,
        'confirm_password': newPassword,
        'otp': otp,
          });

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update FCM token for push notifications
  Future<AuthResponse> updateFcmToken({
    required int userId,
    required String fcmToken,
  }) async {
    try {
      print('📡 Updating FCM token for user $userId...');
      print('🔑 FCM Token: $fcmToken');
      
      final response = await _http.put(
        '/auth/update-fcm/$userId',
        data: {
          'fcm_token': fcmToken,
        },
      );

      print('✅ FCM token update API response: ${response.data}');
      
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      print('❌ Failed to update FCM token: $e');
      rethrow;
    }
  }

  /// Logout (if your API has logout endpoint)
  Future<void> logout() async {
    try {
      // Clear local tokens and user info
      await SharedPrefsService.clearAuthData();

      // Call logout endpoint if exists
      // await _http.post('/auth/logout');
    } catch (e) {
      // Even if API call fails, clear local tokens
      rethrow;
    }
  }
}

AuthResponse _parseAuthResponse(dynamic data,
    {String defaultError = 'Request failed'}) {
  bool status = false;
  String? message;
  String? token;
  String? refreshToken;

  if (data != null) {
    status = data['status'] ?? false;
    token = data['token'] ?? data['access_token'] ?? data['accessToken'];
    refreshToken = data['refresh_token'] ?? data['refreshToken'];

    if (data['message'] != null) {
      message = data['message'];
    } else if (data['errors'] != null) {
      if (data['errors'] is String) {
        message = data['errors'];
      } else if (data['errors'] is List) {
        message = (data['errors'] as List).join("\n");
      } else {
        message = data['errors'].toString();
      }
    } else {
      message = defaultError;
    }
  } else {
    message = defaultError;
  }
  return AuthResponse(
    status: status,
    message: message,
    token: token,
    refreshToken: refreshToken,
  );
}
