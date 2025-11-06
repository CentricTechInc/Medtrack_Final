import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/models/doctor_response.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:medtrac/views/doctor_details/widgets/custom_review_tile.dart';

class ReviewsWidget extends StatelessWidget {
  final Doctor doctor;
  final BottomNavigationController _controller =
      Get.find<BottomNavigationController>();
      
  ReviewsWidget({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BodyTextOne(
              text: 'Reviews',
              fontWeight: FontWeight.bold,
            ),
            GestureDetector(
              onTap: () {
                if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                  HelperFunctions.showIncompleteProfileBottomSheet();
                  return;
                }
                _controller.selectedNavIndex.value = 1;
              },
              child: const BodyTextOne(
                text: 'see all',
                fontWeight: FontWeight.bold,
                color: AppColors.lightGreyText,
              ),
            ),
          ],
        ),
        16.verticalSpace,
        // Show real reviews or empty state
        doctor.displayReviews.isNotEmpty
            ? SizedBox(
                height: 140.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final review = doctor.displayReviews[index];
                    return CustomReviewTile(
                      onTap: () {
                        if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                          HelperFunctions.showIncompleteProfileBottomSheet();
                          return;
                        }
                        // Navigation to detailed review if needed
                      },
                      name: review.patient.name,
                      time: review.date,
                      imagePath: review.patient.picture.isNotEmpty 
                          ? review.patient.picture 
                          : Assets.doctorImageLarge,
                      rating: review.rating,
                    );
                  },
                  separatorBuilder: (context, index) => 4.horizontalSpace,
                  itemCount: doctor.displayReviews.length,
                ),
              )
            : Container(
                height: 80.h,
                alignment: Alignment.center,
                child: const BodyTextOne(
                  text: 'No reviews yet',
                  color: AppColors.lightGreyText,
                ),
              ),
      ],
    );
  }
}
