import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/basic_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/views/onboarding/widgets/stress_level_slider.dart';

class StressLevelScreen extends GetView<BasicInfoController> {
  const StressLevelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: SizedBox(
          width: 270.w,
          child: LinearProgressIndicator(
            value: 0.90,
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
                text: "How would you rate your stress level?",
                textAlign: TextAlign.center,
              ),
              134.verticalSpace,
              Obx(() => CustomText(
                    text: controller.selectedStressLevel.value.toString(),
                    fontSize: 180.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  )),

              // Add the stress level slider
              Obx(() => StressLevelSlider(
                    value: controller.selectedStressLevel.value,
                    onChanged: (v) => controller.setStressLevel(v),
                  )),

              24.verticalSpace,

              // Dynamic stress level text
              Obx(() {
                return BodyTextOne(
                  text: controller.getStressLevelText(),
                  color: AppColors.darkGreyText,
                  fontWeight: FontWeight.bold,
                );
              }),
              Spacer(),
              CustomElevatedButton(
                text: "Continue",
                onPressed: () {
                  Get.toNamed(AppRoutes.moodSelectionScreen);
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
