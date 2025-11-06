import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/professional_details_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/validation_extension.dart';

class SignupProfessionalDetailsScreen extends StatelessWidget {
  final ProfessionalDetailsController controller =
      Get.put(ProfessionalDetailsController());

  SignupProfessionalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left:  24.w , right: 24.w , top: 24.h , bottom: 24.h),
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeadingTextTwo(
                    text: 'Professional Details',
                    color: AppColors.secondary,
                  ),
                  40.verticalSpace,
                  _buildSpecializationDropdown(),
                  16.verticalSpace,
                  _buildLicenseNumberField(),
                  16.verticalSpace,
                  _buildFileUploadSection(),
                  8.verticalSpace,
                  BodyTextOne(
                    text: 'Please attach Medical Degree',
                    color: AppColors.darkGreyText,
                    fontWeight: FontWeight.w400,
                  ),
                  24.verticalSpace,
                  _buildConsentCheckbox(),
                  40.verticalSpace,
                  Obx(() => CustomElevatedButton(
                        text: controller.isLoading.value
                            ? 'Submitting...'
                            : 'Continue',
                        onPressed: controller.isLoading.value
                            ? () {} // Provide empty callback when loading
                            : () => controller.submitForm(),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecializationDropdown() {
    return Container(
      color: AppColors.bright,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.primary),
            borderRadius: BorderRadius.circular(12),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          fillColor: Colors.white,
          // filled: true,
        ),
        hint: Text(
          'Specialization',
          style: TextStyle(fontSize: 16.sp, color: AppColors.dark),
        ),
        dropdownColor: Colors.white,
        icon:
            const Icon(Icons.keyboard_arrow_down, color: AppColors.darkGreyText),
        value: controller.specializationController.text.isNotEmpty
            ? controller.specializationController.text
            : null,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a specialization';
          }
          return null;
        },
        isExpanded: true,
        items: controller.specializations.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value,
                style: TextStyle(fontSize: 16.sp, color: AppColors.darkGreyText)),
          );
        }).toList(),
        onChanged: (newValue) {
          controller.specializationController.text = newValue ?? '';
          (controller.formKey.currentState as FormState).validate();
        },
      ),
    );
  }

  Widget _buildLicenseNumberField() {
    return CustomTextFormField(
      hintText: 'License Number',
      controller: controller.licenseNumberController,
      keyboardType: TextInputType.number,
      validator: (value) => value == null ? '' : value.validateNotEmpty(),
    );
  }

  Widget _buildFileUploadSection() {
    return Obx(() {
      final bool hasError = controller.showFileValidationError.value &&
          controller.selectedFile.value == null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => controller.pickFile(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError ? AppColors.error : AppColors.borderGrey,
                ),
              ),
              child: Row(
                children: [
                  BodyTextOne(
                    text: 'Choose File',
                    color: AppColors.darkGreyText,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '|',
                    style: TextStyle(
                      color: AppColors.lightGreyText,
                      fontSize: 16.sp,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BodyTextOne(
                      text: controller.selectedFileName.value,
                      color: AppColors.lightGreyText,
                      fontWeight: FontWeight.w400,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: EdgeInsets.only(top: 6.h, left: 12.w),
              child: Text(
                'Please upload your medical degree',
                style: TextStyle(
                  color: AppColors.error.withAlpha(75),
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildConsentCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Obx(() => SizedBox(
              width: 24.w,
              height: 24.w,
              child: Checkbox(
                value: controller.consentToBackgroundCheck.value,
                onChanged: controller.toggleConsent,
                checkColor: AppColors.bright,
                activeColor: AppColors.dark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )),
        SizedBox(width: 8.w),
        Expanded(
          child: BodyTextOne(
            text: 'I consent to a background check.',
            color: AppColors.secondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Removed unused method
}
