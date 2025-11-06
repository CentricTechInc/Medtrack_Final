import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/basic_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/views/onboarding/widgets/question_radio_container.dart';

class MindMoodCheckinScreen extends GetView<BasicInfoController> {
  const MindMoodCheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleWidget: SizedBox(
          width: 270.w,
          child: LinearProgressIndicator(
            value: 0.55,
            minHeight: 5.h,
            backgroundColor: AppColors.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                16.verticalSpace,
                HeadingTextTwo(text: "Mind & Mood Check-in"),
                16.verticalSpace,
                BodyTextOne(
                  text:
                      "Take a moment to reflect. Your answers help us support your well-being.",
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.bold,
                ),
                24.verticalSpace,

                // First Question
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Obx(() => QuestionRadioContainer(
                              question:
                                  "Have you lost interest or pleasure in activities you usually enjoy?",
                              options: controller.activityOptions,
                              selectedValue:
                                  controller.selectedActivityReason.value,
                              onOptionSelected: (value) {
                                controller.selectedActivityReason.value = value;
                              },
                            )),

                        24.verticalSpace,

                        // Second Question
                        Obx(() => QuestionRadioContainer(
                              question:
                                  "Do you feel you have someone to talk to when you're feeling down?",
                              options: controller.supportOptions,
                              selectedValue:
                                  controller.selectedSupportResponse.value,
                              onOptionSelected: (value) {
                                controller.selectedSupportResponse.value =
                                    value;
                              },
                            )),

                        24.verticalSpace,

                        // Third Question
                        Obx(() => QuestionRadioContainer(
                              question:
                                  "How often have you felt tired or had little energy?",
                              options: controller.energyOptions,
                              selectedValue:
                                  controller.selectedEnergyResponse.value,
                              onOptionSelected: (value) {
                                controller.selectedEnergyResponse.value = value;
                              },
                            )),

                        24.verticalSpace,

                        // Fourth Question
                        Obx(() => QuestionRadioContainer(
                              question:
                                  "How often have you had trouble concentrating on things, like reading or watching TV?",
                              options: controller.concentrationOptions,
                              selectedValue: controller
                                  .selectedConcentrationResponse.value,
                              onOptionSelected: (value) {
                                controller.selectedConcentrationResponse.value =
                                    value;
                              },
                            )),

                        40.verticalSpace,
                        CustomElevatedButton(
                            text: "Continue",
                            onPressed: () {
                              Get.toNamed(AppRoutes.sleepQualityScreen);
                            }),
                        10.verticalSpace,
                      ],
                    ),
                  ),
                ), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}
