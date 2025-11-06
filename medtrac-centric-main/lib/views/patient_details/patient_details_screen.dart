import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/patient_details_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/step_progress_indicator.dart';

class PatientDetailsScreen extends GetView<PatientDetailsController> {
  const PatientDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Patient Details",
        showBackArrow: false,
        leading: GestureDetector(
          onTap: controller.onBackPressed,
          child: Icon(Icons.arrow_back, size: 24.w),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Obx(() {
                      return StepProgressIndicator(
                        currentStep: controller.currentStep.value,
                        steps: ['01', '02', '03'],
                        labels: ['Basic Info', 'History', 'Health'],
                        spacing: 16.w,
                      );
                    }),
                    32.verticalSpace,
                    Obx(() {
                      return controller.steps[controller.currentStep.value - 1];
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 24, left: 24.w, right: 24.w),
              child: Obx(() => CustomElevatedButton(
                text: controller.currentStep.value == 3 ? "Submit" : "Continue",
                onPressed: controller.isSubmitting.value ? () {} : controller.onContinuePressed,
                isLoading: controller.isSubmitting.value,
              )),
            ),
          ],
        ),
      ),
    );
  }
}
