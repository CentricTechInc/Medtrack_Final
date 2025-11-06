import 'package:medtrac/api/models/banner_response.dart';

import '../http_client.dart';
import '../constants/api_constants.dart';
import '../models/api_response.dart';

/// General Service - Singleton
/// Handles general API calls like customer support, tickets, etc.
class GeneralService {
  static final GeneralService _instance = GeneralService._internal();
  factory GeneralService() => _instance;
  GeneralService._internal();

  final HttpClient _http = HttpClient();

  /// Create customer support ticket
  Future<ApiResponse<String>> createSupportTicket({
    required String subject,
    required String message,
    String status = 'Open',
  }) async {
    try {
      final response = await _http.post(
        ApiConstants.createTicket,
        data: {
          'subject': subject,
          'message': message,
          'status': status,
        },
      );

      return ApiResponse<String>.fromJson(response.data, null);
    } catch (e) {
      rethrow;
    }
  }

    /// Get banners for wellness home screen
  Future<BannerResponse> getBanners() async {
    try {
      final response = await _http.get(ApiConstants.banners);
      return BannerResponse.fromJson(response.data);
    } catch (e) {
      return BannerResponse(
        status: false,
        message: e.toString(),
      );
    }
  }

}
