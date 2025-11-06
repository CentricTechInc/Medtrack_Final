import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/basic_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/views/onboarding/widgets/mental_health_goal_container.dart';

class MentalHealthGoalScreen extends GetView<BasicInfoController> {
  const MentalHealthGoalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: SizedBox(
          width: 270.w,
          child: LinearProgressIndicator(
            value: 0.35,
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
              HeadingTextTwo(text: "Whats your mental health goal?"),
              84.verticalSpace,

              // Manage Anxiety
              Obx(() => MentalHealthGoalContainer(
                    iconPath: Assets.anxeityIcon,
                    goalText: "Manage Anxiety",
                    isSelected: controller.isManageAnxietySelected.value,
                    onSelectionChanged: (isSelected) {
                      controller.setManageAnxietySelection(isSelected);
                    },
                  )),
              24.verticalSpace,

              // Reduce Stress
              Obx(() => MentalHealthGoalContainer(
                    iconPath: Assets.activityIcon,
                    goalText: "Reduce Stress",
                    isSelected: controller.isReduceStressSelected.value,
                    onSelectionChanged: (isSelected) {
                      controller.setReduceStressSelection(isSelected);
                    },
                  )),
              24.verticalSpace,

              // Improve Mood
              Obx(() => MentalHealthGoalContainer(
                    iconPath: Assets.moodIcon,
                    goalText: "Improve Mood",
                    isSelected: controller.isImproveMoodSelected.value,
                    onSelectionChanged: (isSelected) {
                      controller.setImproveMoodSelection(isSelected);
                    },
                  )),
              24.verticalSpace,

              // Boost Confidence
              Obx(() => MentalHealthGoalContainer(
                    iconPath: Assets.thumbsUpIcon,
                    goalText: "Boost Confidence",
                    isSelected: controller.isBoostConfidenceSelected.value,
                    onSelectionChanged: (isSelected) {
                      controller.setBoostConfidenceSelection(isSelected);
                    },
                  )),
              24.verticalSpace,

              // Improve Sleep
              Obx(() => MentalHealthGoalContainer(
                    iconPath: Assets.sleepIcon,
                    goalText: "Improve Sleep",
                    isSelected: controller.isImproveSleepSelected.value,
                    onSelectionChanged: (isSelected) {
                      controller.setImproveSleepSelection(isSelected);
                    },
                  )),

              Spacer(),
              CustomElevatedButton(
                  text: "Continue",
                  onPressed: () {
                    Get.toNamed(AppRoutes.mindMoodCheckinScreen);
                  }),
              10.verticalSpace,
            ],
          ),
        ),
      )),
    );
  }
}
