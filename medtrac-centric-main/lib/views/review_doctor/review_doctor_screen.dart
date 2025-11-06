import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/review_doctor_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_checkbox.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class ReviewDoctorScreen extends GetView<ReviewDoctorController> {
  const ReviewDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Review Doctor",
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    44.verticalSpace,
                    // User Profile Image
                    Obx(() {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: controller.doctorImage.value.isNotEmpty
                            ? Image.network(
                                controller.doctorImage.value,
                                width: 120.w,
                                height: 120.h,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    Assets.vermaImage2,
                                    width: 120.w,
                                    height: 120.h,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                Assets.vermaImage2,
                                width: 120.w,
                                height: 120.h,
                                fit: BoxFit.cover,
                              ),
                      );
                    }),
                    16.verticalSpace,
                    // Patient Name Heading
                    HeadingTextTwo(
                      text: controller.doctorName.value.isNotEmpty
                          ? "How was your experience with ${controller.doctorName.value}?"
                          : "How was your experience with the doctor?",
                      textAlign: TextAlign.center,
                    ),
                    64.verticalSpace,
                    // Notes TextField
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bright,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: CustomTextFormField(
                        hintText: "Write Review...",
                        controller: controller.reviewController,
                        maxLines: 5,
                      ),
                    ),
                    16.verticalSpace,
                    Obx(() {
                      return BodyTextTwo(
                        text: controller.doctorName.value.isNotEmpty
                            ? "Would you recommend ${controller.doctorName.value} to your Friends?"
                            : "Would you recommend the doctor to your Friends?",
                      );
                    }),
                    16.verticalSpace,
                    Row(
                      children: [
                        Row(
                          children: [
                            Obx(() {
                              return CustomCheckbox(
                                value: controller.wouldRecommend.value,
                                isFilled: controller.wouldRecommend.value,
                                onChanged: (value) {
                                  controller.wouldRecommend.value = value;
                                },
                              );
                            }),
                            8.horizontalSpace,
                            BodyTextTwo(text: "Yes")
                          ],
                        ),
                        24.horizontalSpace,
                        Row(
                          children: [
                            Obx(() {
                              return CustomCheckbox(
                                value: !controller.wouldRecommend.value,
                                isFilled: !controller.wouldRecommend.value,
                                onChanged: (value) {
                                  controller.wouldRecommend.value = !value;
                                },
                              );
                            }),
                            8.horizontalSpace,
                            BodyTextTwo(text: "No")
                          ],
                        ),
                      ],
                    ),
                    64.verticalSpace,
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 200.w,
                      child: Obx(() {
                        return StarRating(
                          rating: controller.rating.value,
                          size: 35.w,
                          color: AppColors.yellow,
                          starCount: 5,
                          allowHalfRating: true,
                          borderColor: AppColors.yellow,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          onRatingChanged: (rating) {
                            controller.rating.value = rating;
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            Obx(() {
              return CustomElevatedButton(
                text: "Submit",
                isLoading: controller.isSubmitting.value,
                onPressed: () {
                  if (!controller.isSubmitting.value) {
                    controller.submitReview();
                  }
                },
              );
            }),
            32.verticalSpace,
          ],
        ),
      ),
    );
  }
}
