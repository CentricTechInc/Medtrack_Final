import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/patient_details_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/views/onboarding/widgets/custom_labled_slider.dart';
import 'package:medtrac/custom_widgets/add_photo_widget.dart';

class PatientDetailsStepThree extends GetView<PatientDetailsController> {
  const PatientDetailsStepThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodyTextOne(
            text: 'How are you feeling?',
            fontWeight: FontWeight.bold,
          ),
          8.verticalSpace,
          Obx(() => CustomLabeledSlider(
                value: controller.selectedMood.value,
                onChanged: controller.setMood,
                thumbRadius: 14.0,
                thumbRotation: 90.0,
                trackHeight: 8.0,
                padding: EdgeInsets.zero,
                labels: controller.moodOptions,
              )),
          24.verticalSpace,
          BodyTextOne(
            text: 'How would you rate you sleep?',
            fontWeight: FontWeight.bold,
          ),
          8.verticalSpace,
          Obx(() => CustomLabeledSlider(
                value: controller.selectedSleepOption.value,
                onChanged: controller.setSleep,
                thumbRadius: 14.0,
                thumbRotation: 90.0,
                trackHeight: 8.0,
                padding: EdgeInsets.zero,
                labels: controller.sleepQualityOptions,
              )),
          24.verticalSpace,
          BodyTextOne(
            text: 'How is your stress level?',
            fontWeight: FontWeight.bold,
          ),
          8.verticalSpace,
          Obx(() => CustomLabeledSlider(
                value: controller.selectedStressLevel.value,
                onChanged: controller.setStressLevel,
                thumbRadius: 14.0,
                thumbRotation: 90.0,
                trackHeight: 8.0,
                padding: EdgeInsets.zero,
                labels: controller.stressLevelOptions,
              )),
          24.verticalSpace,
          BodyTextOne(
            text: 'How often do you excercise?',
            fontWeight: FontWeight.bold,
          ),
          8.verticalSpace,
          Obx(() => CustomLabeledSlider(
                value: controller.selectedExcerciseOption.value,
                onChanged: controller.setExcercise,
                thumbRadius: 14.0,
                thumbRotation: 90.0,
                trackHeight: 8.0,
                padding: EdgeInsets.zero,
                labels: controller.excerciseOptions,
              )),
          24.verticalSpace,
          BodyTextOne(
            text: 'Additional Information',
            fontWeight: FontWeight.bold,
          ),
          8.verticalSpace,
          CustomTextFormField(
            controller: controller.additionalInfoController,
            maxLines: 4,
            hintText: "Enter Any Additional Information",
          ),
          24.verticalSpace,
          BodyTextOne(
            text: 'Upload File',
            fontWeight: FontWeight.bold,
          ),
          8.verticalSpace,
          AddPhotoWidget(
            onImageChanged: (file) {
              if (file != null) {
                controller.addFile(file);
              } else {
                controller.removeFile();
              }
            },
          ),
        ],
      ),
    );
  }
}
