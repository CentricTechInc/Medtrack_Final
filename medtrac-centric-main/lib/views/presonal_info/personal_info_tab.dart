import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/personal_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_dropdown_field.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/assets.dart';

class PersonalInfoTab extends StatelessWidget {
  final bool fromRegistration;
  final PersonalInfoController controller;
  const PersonalInfoTab(
      {super.key, required this.fromRegistration, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        32.verticalSpace,
        Center(
          child: Column(
            children: [
              Obx(
                () => GestureDetector(
                  onTap: () => controller.showImageSourceSheet(),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          image: controller.selectedImage.value != null
                              ? DecorationImage(
                                  image: FileImage(
                                      controller.selectedImage.value!),
                                  fit: BoxFit.cover,
                                )
                              : controller.user.value.profilePicture.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          controller.user.value.profilePicture),
                                      fit: BoxFit.cover,
                                    )
                                  : const DecorationImage(
                                      image: AssetImage(
                                          'assets/images/wellness_image.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: -15,
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          width: 35.w,
                          height: 35.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F5663),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Image.asset(
                            Assets.cameraIcon,
                            color: Colors.white,
                            width: 18.w,
                            height: 18.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        50.verticalSpace,
        const BodyTextOne(text: 'Full Name'),
        12.verticalSpace,
        CustomTextFormField(
          hintText: 'Full Name',
          controller: controller.fullNameController,
          readOnly: true,
        ),
        24.verticalSpace,
        const BodyTextOne(text: 'Email Address'),
        12.verticalSpace,
        CustomTextFormField(
          hintText: 'Email Address',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
        ),
        24.verticalSpace,
        const BodyTextOne(text: 'Phone Number'),
        12.verticalSpace,
        CustomTextFormField(
          hintText: 'Phone Number',
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          readOnly: true,
        ),
        24.verticalSpace,
        const BodyTextOne(text: 'Gender'),
        12.verticalSpace,
        Obx(() => CustomDropdownField(
              hintText: 'Select Gender',
              items: controller.genderOptions,
              value: controller.selectedGender.value,
              onChanged: controller.setGender,
              readOnly: true,
            )),
        SizedBox(height: 50.h),
        if (fromRegistration)
          CustomElevatedButton(
            text: 'Continue',
            onPressed: () {
              controller.savePersonalInfo();
              controller.currentIndex.value = 1;
            },
          ),
        24.verticalSpace,
      ],
    );
  }
}
