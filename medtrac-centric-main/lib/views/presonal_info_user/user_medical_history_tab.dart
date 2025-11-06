import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/user/user_profile_controller.dart';
import 'package:medtrac/custom_widgets/custom_dropdown_field.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';

class UserMedicalHistoryTab extends StatelessWidget {
  final UserProfileController controller;
  const UserMedicalHistoryTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const BodyTextOne(text: 'Blood Group'),
                    12.verticalSpace,
                    Obx(
                      () => CustomDropdownField(
                        hintText: 'Select Blood Group',
                        items: controller.bloodGroupOptions,
                        value: controller.selectedBloodGroup.value,
                        onChanged: controller.setBloodGroup,
                        height: 49.h,
                      ),
                    ),
                  ],
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyTextOne(
                      text: "Weight",
                      fontWeight: FontWeight.w900,
                    ),
                    8.verticalSpace,
                    CustomTextFormField(
                      controller: controller.weightController,
                      hintText: "Weight in kg",
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final text = newValue.text;
                          if (text.isEmpty) return newValue;

                          String formatted = '$text kg';

                          return TextEditingValue(
                            text: formatted,
                            selection:
                                TextSelection.collapsed(offset: text.length),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          24.verticalSpace,
          const BodyTextOne(
            text: "Primary Concern",
            fontWeight: FontWeight.bold,
          ),
          8.verticalSpace,
          Container(
            constraints: BoxConstraints(minHeight: 60.h),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => controller.primaryConcerns.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.primaryConcerns
                                .map((tag) => Chip(
                                      label: Text(tag),
                                      backgroundColor: Colors.grey.shade200,
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                      deleteIcon:
                                          const Icon(Icons.close, size: 16),
                                      onDeleted: () =>
                                          controller.removePrimaryConcern(tag),
                                    ))
                                .toList(),
                          ),
                        )
                      : SizedBox.shrink()),
                  TextField(
                    controller: controller.primaryConcernController,
                    maxLines: null,
                    minLines: 1,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type and hit comma...',
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: controller.onPrimaryConcernChanged,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          24.verticalSpace,
          const BodyTextOne(
            text: "Medication / Treatment",
            fontWeight: FontWeight.bold,
          ),
          8.verticalSpace,
          Container(
            constraints: BoxConstraints(minHeight: 60.h),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => controller.medicationTags.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.medicationTags
                                .map((tag) => Chip(
                                      label: Text(tag),
                                      backgroundColor: Colors.grey.shade200,
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                      deleteIcon:
                                          const Icon(Icons.close, size: 16),
                                      onDeleted: () =>
                                          controller.removeMedicationTag(tag),
                                    ))
                                .toList(),
                          ),
                        )
                      : SizedBox.shrink()),
                  TextField(
                    controller: controller.medicationController,
                    maxLines: null,
                    minLines: 1,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type and hit comma...',
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: controller.onMedicationChanged,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
