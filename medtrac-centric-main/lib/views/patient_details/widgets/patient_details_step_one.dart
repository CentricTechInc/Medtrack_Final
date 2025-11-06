import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:medtrac/controllers/patient_details_controller.dart';
import 'package:medtrac/custom_widgets/custom_dropdown_field.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';

class PatientDetailsStepOne extends GetView<PatientDetailsController> {
  const PatientDetailsStepOne({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.translucent,
      child: Form(
        key: controller.formKeyStepOne,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyTextOne(
                text: "Name",
                fontWeight: FontWeight.w900,
              ),
              8.verticalSpace,
              CustomTextFormField(
                controller: controller.nameController,
                hintText: "Full Name",
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
            24.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyTextOne(
                        text: "Age",
                      ),
                      8.verticalSpace,
                      CustomTextFormField(
                        controller: controller.ageController,
                        hintText: "Enter Age",
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your age';
                          }
                          // Remove any non-digit characters (in case formatting added kg etc.)
                          final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (digits.isEmpty) return 'Please enter a valid age';
                          final age = int.tryParse(digits);
                          if (age == null || age <= 0 || age > 120) {
                            return 'Please enter a valid age between 1 and 120';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                16.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyTextOne(
                        text: "Gender",
                      ),
                      8.verticalSpace,
                      Obx(() {
                        return CustomDropdownField(
                          hintText: "Gender",
                          value: controller.selectedGender.value.isEmpty
                              ? null
                              : controller.selectedGender.value,
                          items: controller.genderOptions,
                          onChanged: controller.setGender,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
            24.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyTextOne(
                        text: "Blood Group",
                      ),
                      8.verticalSpace,
                      Obx(() {
                        return CustomDropdownField(
                          hintText: "Blood Group",
                          value: controller.selectedBloodGroup.value.isEmpty
                              ? null
                              : controller.selectedBloodGroup.value,
                          items: controller.bloodGroupOptions,
                          onChanged: controller.setBloodGroup,
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
                        text: "Height",
                      ),
                      8.verticalSpace,
                      CustomTextFormField(
                        controller: controller.heightController,
                        hintText: "e.g., 5'11\"",
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your height';
                          }

                          // Accept formats like 5'11 or 511 (from formatter). Extract digits
                          final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                          if (digits.isEmpty) return 'Please enter a valid height';

                          // Interpret last two digits as inches if length >=2, first as feet
                          int feet = 0;
                          int inches = 0;
                          if (digits.length == 1) {
                            feet = int.parse(digits);
                            inches = 0;
                          } else if (digits.length == 2) {
                            // e.g., '51' -> 5'1
                            feet = int.parse(digits[0]);
                            inches = int.parse(digits[1]);
                          } else {
                            // take first digit as feet, next two as inches (e.g., 511 -> 5'11)
                            feet = int.parse(digits[0]);
                            inches = int.parse(digits.substring(1, min(3, digits.length)));
                          }

                          if (feet < 1 || feet > 8) return 'Please enter feet between 1 and 8';
                          if (inches < 0 || inches > 11) return 'Please enter inches between 0 and 11';

                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            final text = newValue.text;
                            if (text.isEmpty) return newValue;

                            String formatted = '';
                            if (text.length == 1) {
                              formatted = text;
                            } else if (text.length == 2) {
                              formatted = "${text[0]}'${text[1]}";
                            } else if (text.length >= 3) {
                              formatted = "${text[0]}'${text.substring(1, 3)}";
                            }

                            return TextEditingValue(
                              text: formatted,
                              selection: TextSelection.collapsed(
                                  offset: formatted.length),
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
            BodyTextOne(
              text: "Weight",
              fontWeight: FontWeight.w900,
            ),
            8.verticalSpace,
            CustomTextFormField(
              controller: controller.weightController,
              hintText: "Weight in kg",
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your weight';
                }
                final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (digits.isEmpty) return 'Please enter a valid weight';
                final weight = int.tryParse(digits);
                if (weight == null || weight <= 0 || weight > 300) {
                  return 'Please enter a valid weight between 1 and 300 kg';
                }
                return null;
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  final text = newValue.text;
                  if (text.isEmpty) return newValue;

                  String formatted = '$text kg';

                  return TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: text.length),
                  );
                }),
              ],
            ),
          ],
          )
        ),
      ),
    );
  }
}
