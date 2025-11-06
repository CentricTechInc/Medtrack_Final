import '../http_client.dart';
import '../constants/api_constants.dart';
import '../models/review.dart';

/// Review Service - Singleton
/// Handles review-related API calls
class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final HttpClient _http = HttpClient();

  /// Get review listing
  Future<ReviewsResponse> getReviewListing({
    required int page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;

      final response = await _http.get(
        '${ApiConstants.reviewListing}/$page',
        queryParameters: queryParams,
      );

      return ReviewsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
