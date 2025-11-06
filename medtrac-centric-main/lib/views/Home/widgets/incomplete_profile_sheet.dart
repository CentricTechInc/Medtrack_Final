import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class IncompleteProfileSheet extends StatelessWidget {
  final bool isUnderReview;
  const IncompleteProfileSheet({super.key, this.isUnderReview = false} );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tick icon
          Center(
            child: isUnderReview
                ? Image.asset(
                    Assets.underReview,
                    width: 150.w,
                    height: 150.w,
                  )
                : Image.asset(
                    Assets.tickIcon,
                    width: 100.w,
                    height: 100.w,
                  ),
          ),

          24.verticalSpace,

          HeadingTextTwo(
            text: isUnderReview
                ? 'Your profile is under review'
                : 'Complete Your Profile',
            textAlign: TextAlign.center,
          ),

          12.verticalSpace,

          BodyTextOne(
            text: isUnderReview
                ? "Thanks for registering. Your profile is under review by our team. We'll notify you once it's approved."
                : "Almost there! Just a few more details and you'll start showing up in patient searches.",
            textAlign: TextAlign.center,
            color: AppColors.darkGreyText,
          ),

          32.verticalSpace,

          CustomElevatedButton(
            text: "Continue",
            onPressed: () {
                      // Close current sheet first
                      Get.back();

                      // If this was the "under review" informative sheet, immediately show
                      // the actionable incomplete-profile sheet (without under-review flag)
                      if (isUnderReview) {
                         SharedPrefsService.setFirstLogin(false);
                        // Slight delay to allow the first sheet to dismiss cleanly
                        if (!SharedPrefsService.isDoctorProfileCompelete()) {
                          Future.delayed(const Duration(milliseconds: 200), () {
                          if (Get.isBottomSheetOpen != true) {
                            Get.bottomSheet(
                              IncompleteProfileSheet(isUnderReview: false),
                              isDismissible: true,
                              enableDrag: false,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24.r),
                                  topRight: Radius.circular(24.r),
                                ),
                              ),
                            );
                          }
                        });
                        }
                        return;
                      }

                      // Normal flow: open personal info screen if user pressed Continue on the actionable sheet
                      if (!isUnderReview) {
                        Get.toNamed(AppRoutes.personalInfoScreen,
                            arguments: {"fromRegisteration": true});
                      }
            },
            isSecondary: true,
          )
        ],
      ),
    );
  }
}
