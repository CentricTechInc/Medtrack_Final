import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/personal_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_dropdown_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/snackbar.dart';

class ProfessionalInfoTab extends StatelessWidget {
  final PersonalInfoController controller;
  final bool fromRegistration;
  const ProfessionalInfoTab(
      {super.key, required this.controller, required this.fromRegistration});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          32.verticalSpace,
          const BodyTextOne(text: 'Specialty'),
          12.verticalSpace,
          Obx(() => CustomDropdownField(
                hintText: 'Select Specialty',
                items: controller.specialtyOptions,
                value: controller.specialtySelectedValue.value.isNotEmpty
                    ? controller.specialtySelectedValue.value
                    : null,
                onChanged: (value) {
                  if (value != null) {
                    controller.specialtySelectedValue.value = value;
                  }
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Specialty is required' : null,
              )),
          24.verticalSpace,
          const BodyTextOne(text: 'License/Certification Number'),
          12.verticalSpace,
          CustomTextFormField(
            hintText: 'License/Certification Number',
            controller: controller.licenseNumberController,
            validator: (p0) =>
                p0!.isEmpty ? 'License/Certification Number is required' : null,
          ),
          24.verticalSpace,
          const BodyTextOne(text: 'Years of Experience'),
          12.verticalSpace,
          CustomTextFormField(
            hintText: 'Enter Years of Experience',
            controller: controller.experienceController,
            keyboardType: TextInputType.number,
            validator: (p0) =>
                p0!.isEmpty ? 'Years of Experience is required' : null,
          ),
          24.verticalSpace,
          const BodyTextOne(text: 'About Me'),
          12.verticalSpace,
          CustomTextFormField(
            hintText: 'Enter something about yourself',
            controller: controller.aboutMeController,
            maxLines: 3,
            validator: (p0) => p0!.isEmpty ? 'About Me is required' : null,
          ),
          24.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const BodyTextOne(text: 'Upload Certification Documents'),
              GestureDetector(
                onTap: () => controller.pickDocuments(),
                child: const BodyTextOne(
                  text: '+ Add',
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Obx(
            () => Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.pickDocuments();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 192.h,
                    decoration: BoxDecoration(
                      color: AppColors.bright,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                          color: AppColors.greyBackgroundColor, width: 1),
                    ),
                    child: controller.hasCertificateFromAPI && controller.certificationDocument.isEmpty
                        ? _buildCertificateFromAPI(controller.certificateURL)
                        : controller.certificationDocument.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.upload_file_rounded,
                                  size: 40.sp,
                                  color: AppColors.darkGreyText,
                                ),
                                8.verticalSpace,
                                const BodyTextOne(
                                  text: 'Upload Document',
                                  color: AppColors.darkGreyText,
                                ),
                              ],
                            ),
                          )
                        : _buildDocumentPreview(
                            controller.certificationDocument[0]!),
                  ),
                ),
                if (controller.certificationDocument.isNotEmpty)
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: GestureDetector(
                      onTap: () => controller.removeDocument(),
                      child: Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: AppColors.bright,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.dark.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                if (controller.hasCertificateFromAPI && controller.certificationDocument.isEmpty)
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: GestureDetector(
                      onTap: () => controller.pickDocuments(),
                      child: Container(
                        width: 30.w,
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.dark.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 18.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          24.verticalSpace,
          Obx(() => CustomElevatedButton(
            text: fromRegistration ? 'Continue' : 'Update',
            isLoading: controller.isLoading.value,
            onPressed: () async {
              if ((controller.formKey.currentState?.validate() ?? false) &&
                  (controller.certificationDocument.isNotEmpty || controller.hasCertificateFromAPI)) {
                await controller.saveProfessionalInfo();

                if (fromRegistration) {
                  Get.toNamed(
                    AppRoutes.availabilityInfoScreen,
                    arguments: {"fromRegisteration": fromRegistration},
                  );
                } else {
                  // Call the new API for updating profile info
                      await controller.updateProfessionalProfileInfo();
                      Future.delayed(const Duration(seconds: 3), () {
                        if (Get.isSnackbarOpen) {
                          Get.closeAllSnackbars();
                        }
                        Get.back();
                      });
                    }
              } else if (controller.certificationDocument.isEmpty && !controller.hasCertificateFromAPI) {
                SnackbarUtils.showError('Please upload at least one document');
              }
            },
          )),
          24.verticalSpace,
        ],
      ),
    );
  }
}

Widget _buildDocumentPreview(PlatformFile document) {
  final isImage =
      ['jpg', 'jpeg', 'png'].contains(document.extension?.toLowerCase());

  if (isImage) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.file(
        File(document.path!),
        fit: BoxFit.contain,
        height: 150.h,
        errorBuilder: (context, error, stackTrace) {
          return _buildFileIcon(document);
        },
      ),
    );
  } else {
    return _buildFileIcon(document);
  }
}

Widget _buildFileIcon(PlatformFile document) {
  return SizedBox(
    height: 192.h,
    child: Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 50.sp,
              color: AppColors.primary,
            ),
            16.verticalSpace,
            SizedBox(
              width: 200.w,
              child: Text(
                document.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary,
                ),
              ),
            ),
            8.verticalSpace,
            Text(
              document.extension?.toUpperCase() ?? '',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.lightGreyText,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildCertificateFromAPI(String certificateURL) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12.r),
    child: Stack(
      children: [
        Container(
          width: double.infinity,
          height: 192.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Image.network(
            certificateURL,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 192.h,
                decoration: BoxDecoration(
                  color: AppColors.bright,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.greyBackgroundColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 40.sp,
                      color: AppColors.darkGreyText,
                    ),
                    8.verticalSpace,
                    const BodyTextOne(
                      text: 'Certificate Available',
                      color: AppColors.darkGreyText,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 8.h,
          left: 8.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              'Current Certificate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
