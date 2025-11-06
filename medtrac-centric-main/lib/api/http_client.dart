import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:medtrac/api/constants/api_constants.dart';
import 'package:medtrac/api/errors/api_exceptions.dart';
import 'package:medtrac/services/shared_preference_service.dart';

/// Simple HTTP Client using Dio
/// Singleton pattern - easy to use everywhere
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  late Dio _dio;

  /// Initialize the HTTP client
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${SharedPrefsService.getAccessToken()}',
      },
      // Allow all status codes, so we can handle error responses in try block
      validateStatus: (_) => true,
    ));

    // Add interceptors
    _addInterceptors();
  }

  void _addInterceptors() {
    // Logging in debug mode
    if (kDebugMode) {
      LogInterceptor(
      requestBody: false,
      responseBody: false,
      requestHeader: false,
      responseHeader: false,
      error: true,
      logPrint: (obj) => log("API Error: $obj"),
    );
    }

    // Auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle 401 errors globally
        if (error.response?.statusCode == 401) {
          _handleUnauthorized();
        }
        handler.next(error);
      },
    ));
  }

  /// GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final response =
          await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request
  Future<Response> put(String path, {dynamic data, Options? options}) async {
    try {
      return await _dio.put(path, data: data, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PATCH request
  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to custom exceptions
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timeout. Please try again.');
      
      case DioExceptionType.connectionError:
        return const NetworkException('No internet connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response?.data) ?? 
                       'Server error occurred';
        return ApiException(message, statusCode);
      
      default:
        return const ApiException('Something went wrong. Please try again.');
    }
  }

  /// Extract error message from response
  String? _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? data['msg'];
    }
    return null;
  }

  /// Get auth token (implement based on your storage method)
  Future<String?> _getAuthToken() async {
    // TODO: Implement token retrieval from secure storage
    // Example: return await SecureStorage.getToken();
    return null;
  }

  /// Handle unauthorized access
  void _handleUnauthorized() {
    // TODO: Implement logout logic, clear tokens, navigate to login
    if (kDebugMode) {
      print('Unauthorized access - redirecting to login');
    }
  }
}
