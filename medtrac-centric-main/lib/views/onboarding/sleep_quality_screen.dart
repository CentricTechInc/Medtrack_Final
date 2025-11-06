import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/basic_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/views/onboarding/widgets/sleep_quality_slider.dart';

class SleepQualityScreen extends GetView<BasicInfoController> {
  const SleepQualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: SizedBox(
          width: 270.w,
          child: LinearProgressIndicator(
            value: 0.75,
            minHeight: 5.h,
            backgroundColor: AppColors.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              16.verticalSpace,
              HeadingTextTwo(
                text: "How would you rate your sleep quality?",
                textAlign: TextAlign.center,
              ),
              24.verticalSpace,
              Expanded(
                child: SleepQualitySlider(),
              ),
              24.verticalSpace,
              CustomElevatedButton(
                text: "Continue",
                onPressed: () {
                  Get.toNamed(AppRoutes.stressLevelScreen);
                },
              ),
              10.verticalSpace,
            ],
          ),
        ),
      )),
    );
  }
}
