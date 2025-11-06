import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/patient_details_controller.dart';
import 'package:medtrac/custom_widgets/custom_dropdown_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';

class PatientDetailsStepTwo extends GetView<PatientDetailsController> {
  const PatientDetailsStepTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Form(
        key: controller.formKeyStepTwo,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const BodyTextOne(
              text: "Primary Concern",
              fontWeight: FontWeight.bold,
            ),
            8.verticalSpace,
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.primaryConcerns
                            .map((tag) => Chip(
                                  label: Text(tag),
                                  backgroundColor: Colors.grey.shade200,
                                  labelStyle: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () =>
                                      controller.removePrimaryConcern(tag),
                                ))
                            .toList(),
                      )),
                  TextField(
                    controller: controller.primaryConcernController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type and hit comma...',
                    ),
                    onChanged: controller.onPrimaryConcernChanged,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            24.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyTextOne(
                        text: "Duration",
                      ),
                      8.verticalSpace,
                      Obx(() {
                        return CustomDropdownField(
                          hintText: "Duration",
                          value: controller.selectedDuration.value.isEmpty
                              ? null
                              : controller.selectedDuration.value,
                          items: controller.durationOptions,
                          onChanged: controller.setDuration,
                        );
                      }),
                    ],
                  ),
                ),
                16.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyTextOne(
                        text: "Diagnosis",
                      ),
                      8.verticalSpace,
                      Obx(() {
                        return CustomDropdownField(
                          hintText: "Diagnosis",
                          value: controller.selectedDiagnosis.value.isEmpty
                              ? null
                              : controller.selectedDiagnosis.value,
                          items: controller.diagnosisOptions,
                          onChanged: controller.setDiagnosis,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            24.verticalSpace,
            const BodyTextOne(
              text: "Medication / Treatment",
              fontWeight: FontWeight.bold,
            ),
            8.verticalSpace,
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.medicationTags
                            .map((tag) => Chip(
                                  label: Text(tag),
                                  backgroundColor: Colors.grey.shade200,
                                  labelStyle: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () =>
                                      controller.removeMedicationTag(tag),
                                ))
                            .toList(),
                      )),
                  TextField(
                    controller: controller.medicationController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type and hit comma...',
                    ),
                    onChanged: controller.onMedicationChanged,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      )
    );
  }
}
