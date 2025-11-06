import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/basic_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/gender_selection_container.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/views/onboarding/widgets/age_selection_slider.dart';
import 'package:medtrac/views/onboarding/widgets/weight_selection_slider.dart';

class BasicInfoScreen extends GetView<BasicInfoController> {
  const BasicInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: SizedBox(
          width: 270.w,
          child: LinearProgressIndicator(
            value: 0.10,
            minHeight: 5.h,
            backgroundColor: AppColors.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                38.verticalSpace,
                SizedBox(
                  width: 270.w,
                  child: HeadingTextTwo(
                    text: "Give us some basic information",
                    textAlign: TextAlign.center,
                  ),
                ),
                10.verticalSpace,
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyTextOne(
                          text: "Gender",
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                        16.verticalSpace,
                        Obx(() => Row(
                              children: [
                                Expanded(
                                  child: GenderSelectionContainer(
                                    gender: "Male",
                                    icon: Assets.maleIcon,
                                    isSelected:
                                        controller.isGenderSelected("Male"),
                                    onTap: () =>
                                        controller.setSelectedGender("Male"),
                                  ),
                                ),
                                16.horizontalSpace,
                                Expanded(
                                  child: GenderSelectionContainer(
                                    gender: "Female",
                                    icon: Assets.femaleIcon,
                                    isSelected:
                                        controller.isGenderSelected("Female"),
                                    onTap: () =>
                                        controller.setSelectedGender("Female"),
                                  ),
                                ),
                              ],
                            )),
                        32.verticalSpace,
                        const WeightSelectionSlider(),
                        32.verticalSpace,
                        const AgeSelectionSlider(),
                        40.verticalSpace,
                        CustomElevatedButton(
                            text: "Continue",
                            onPressed: () {
                              Get.toNamed(AppRoutes.mentalHealthGoalSceen);
                            }),
                        20.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
