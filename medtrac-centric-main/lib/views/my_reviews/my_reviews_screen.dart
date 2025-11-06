import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:medtrac/controllers/reviews_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/utils/app_colors.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  Widget buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: AppColors.yellow, size: 16);
        } else {
          return const Icon(Icons.star_border,
              color: AppColors.greyBackgroundColor, size: 16);
        }
      }),
    );
  }

    @override
  Widget build(BuildContext context) {
    final ReviewsController controller = Get.find<ReviewsController>();
    
    return Scaffold(
      appBar: CustomAppBar(title: "My Reviews"),
      body: Obx(() {
        if (controller.isLoading.value && controller.reviews.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SmartRefresher(
          controller: controller.refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: controller.onRefresh,
          onLoading: controller.onLoading,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Overall Rating Section
              Center(
                child: Column(
                  children: [
                    Text(
                      controller.averageRating.value,
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < controller.averageRatingDouble.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: AppColors.yellow,
                          size: 30,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on ${controller.totalReviews.value} reviews',
                      style: const TextStyle(color: AppColors.dark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Rating Distribution
              Card(
                color: AppColors.bright,
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      buildRatingBar('Excellent', controller.getRatingPercentage(5)),
                      buildRatingBar('Good', controller.getRatingPercentage(4)),
                      buildRatingBar('Average', controller.getRatingPercentage(3)),
                      buildRatingBar('Below Average', controller.getRatingPercentage(2)),
                      buildRatingBar('Poor', controller.getRatingPercentage(1)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Reviews List
              if (controller.reviews.isEmpty && !controller.isLoading.value)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 64,
                          color: AppColors.darkGreyText,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No reviews yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Your patient reviews will appear here',
                          style: TextStyle(
                            color: AppColors.darkGreyText,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...controller.reviews.map((review) => buildReviewTile(
                      name: review.patient.name,
                      rating: review.ratingDouble,
                      daysAgo: review.date,
                      review: review.description,
                      avatarUrl: review.patient.picture,
                    )).toList(),
              
              // Loading indicator for pagination
              if (controller.isLoadingMore.value)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildRatingBar(String label, double fraction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(
              child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: fraction,
              color: AppColors.primary,
              backgroundColor: AppColors.greyBackgroundColor,
              minHeight: 10,
            ),
          )),
        ],
      ),
    );
  }

  Widget buildReviewTile({
    required String name,
    required double rating,
    required String daysAgo,
    required String review,
    required String avatarUrl,
  }) {
    return Container(
      color: AppColors.bright,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: avatarUrl.startsWith('http')
                      ? NetworkImage(avatarUrl)
                      : AssetImage(avatarUrl) as ImageProvider,
                  onBackgroundImageError: avatarUrl.startsWith('http')
                      ? (exception, stackTrace) {}
                      : null,
                  child: avatarUrl.startsWith('http')
                      ? null
                      : avatarUrl.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          buildStars(rating),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(color: AppColors.dark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  daysAgo,
                  style: const TextStyle(color: AppColors.dark, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review),
          ],
        ),
      ),
    );
  }
}
