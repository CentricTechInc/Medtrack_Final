import 'package:medtrac/api/models/banner_response.dart';

import '../http_client.dart';
import '../constants/api_constants.dart';
import '../models/wellness_hub_response.dart';

/// Wellness Service - Singleton
/// Handles wellness hub related API calls
class WellnessService {
  static final WellnessService _instance = WellnessService._internal();
  factory WellnessService() => _instance;
  WellnessService._internal();

  final HttpClient _http = HttpClient();

  /// Get wellness hub listing with pagination
  /// Page starts from 1
  /// Type can be "Article" or "Video"
  Future<WellnessHubResponse> getWellnessHubListing({
    required int page,
    String? type,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null && type.isNotEmpty) queryParams['type'] = type;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _http.get(
        '${ApiConstants.wellnessListing}/$page',
        queryParameters: queryParams,
      );

      return WellnessHubResponse.fromJson(response.data);
    } catch (e) {
      // Return error response
      return WellnessHubResponse(
        status: false,
        errors: [e.toString()],
      );
    }
  }

  /// Get single wellness article details
  Future<Map<String, dynamic>> getWellnessDetails({
    required int id,
  }) async {
    try {
      final response = await _http.get(
        '${ApiConstants.wellnessDetails}/$id',
      );

      if (response.data is Map<String, dynamic>) {
        return response.data;
      }

      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }


}
