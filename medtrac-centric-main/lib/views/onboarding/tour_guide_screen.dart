import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/snackbar.dart';

class TourGuideScreen extends StatelessWidget {
  const TourGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CustomSkipButton(
              text: 'Skip',
              onPressed: () {
                Get.offAllNamed(AppRoutes.basicInfoScreen);
                SharedPrefsService.setFirstLogin(false);
              },
              color: AppColors.primary,
              height: 48.h,
              width: 96.w,
              fontSize: 14.sp,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main heading
              HeadingTextTwo(
                text: 'How to use the app for\nmaximum benefit',
                textAlign: TextAlign.center,
                color: AppColors.secondary,
              ),

              16.verticalSpace,

              // Subtitle
              BodyTextOne(
                text:
                    'Follow these tips to make the most of Medtrac\nand improve your health journey.',
                textAlign: TextAlign.center,
                color: AppColors.darkGreyText,
              ),

              60.verticalSpace,

              // Phone mockup image
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () {
                         SnackbarUtils.showInfo('Playing: Tour Guide', title: 'Video');

                    },
                    child: Image.asset(
                      Assets.ssImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              60.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }

}
