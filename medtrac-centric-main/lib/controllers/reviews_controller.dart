import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:medtrac/api/models/review.dart';
import 'package:medtrac/api/services/review_service.dart';
import 'package:medtrac/utils/snackbar.dart';

class ReviewsController extends GetxController {
  final ReviewService _reviewService = ReviewService();
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  final RxList<Review> reviews = <Review>[].obs;
  final RxList<RatingCount> ratingCounts = <RatingCount>[].obs;
  final RxString averageRating = '0'.obs;
  final RxInt totalReviews = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadReviews();
  }

  Future<void> loadReviews({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      reviews.clear();
    }

    if (!hasMoreData.value) return;

    try {
      if (currentPage.value == 1) {
        isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }

      final response = await _reviewService.getReviewListing(page: currentPage.value);

      if (response.status) {
        if (response.data.rows.isEmpty) {
          hasMoreData.value = false;
        } else {
          if (isRefresh) {
            reviews.assignAll(response.data.rows);
          } else {
            reviews.addAll(response.data.rows);
          }
          currentPage.value++;
        }

        // Update summary data only on first load
        if (currentPage.value == 2) {
          averageRating.value = response.data.averageRating;
          totalReviews.value = response.data.count;
          ratingCounts.assignAll(response.data.ratingCount);
        }
      }
    } catch (e) {
      SnackbarUtils.showError('Failed to load reviews: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      if (isRefresh) {
        refreshController.refreshCompleted();
      } else {
        refreshController.loadComplete();
      }
    }
  }

  Future<void> onRefresh() async {
    await loadReviews(isRefresh: true);
  }

  Future<void> onLoading() async {
    if (!hasMoreData.value) {
      refreshController.loadNoData();
      return;
    }
    await loadReviews();
  }

  // Method to manually refresh reviews (can be called from anywhere)
  Future<void> refreshReviews() async {
    await loadReviews(isRefresh: true);
  }

  double get averageRatingDouble => double.tryParse(averageRating.value) ?? 0.0;

  // Get rating count for a specific rating
  int getRatingCount(int rating) {
    final ratingCount = ratingCounts.firstWhere(
      (rc) => rc.ratingDouble.round() == rating,
      orElse: () => RatingCount(rating: rating.toString(), count: '0'),
    );
    return ratingCount.countInt;
  }

  // Get rating percentage for progress bar
  double getRatingPercentage(int rating) {
    if (totalReviews.value == 0) return 0.0;
    final count = getRatingCount(rating);
    return count / totalReviews.value;
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
