import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/personal_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_tab_bar.dart';
import 'package:medtrac/custom_widgets/step_progress_indicator.dart';

class PersonalInfoScreen extends GetView<PersonalInfoController> {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Personal Info",
        leading: GestureDetector(
          onTap: () {
            if (controller.fromRegisteration) {
              controller.currentIndex.value == 0
                  ? Get.back()
                  : controller.onTabChanged(controller.currentIndex.value - 1);
            } else {
              Get.back();
            }
          },
          child: const Icon(
            Icons.arrow_back_ios_new,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      20.verticalSpace,
                      if (controller.fromRegisteration)
                        Obx(() {
                          return StepProgressIndicator(
                            currentStep: controller.currentIndex.value + 1,
                            steps: ['01', '02', '03'],
                            labels: [
                              'Personal',
                              'Professional',
                              'Set Availability'
                            ],
                          );
                        }),
                      if (!controller.fromRegisteration)
                        CustomTabBar(
                            tabs: ["Personal Info", "Professional Info"],
                            currentIndex: RxInt(0),
                            onTabChanged: (index) =>
                                controller.onTabChanged(index)),
                      Obx(() {
                        return controller.tabs[controller.currentIndex.value];
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
