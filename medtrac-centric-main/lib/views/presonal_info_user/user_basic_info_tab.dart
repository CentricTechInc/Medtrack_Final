import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/user/user_profile_controller.dart';
import 'package:medtrac/custom_widgets/custom_dropdown_field.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/assets.dart';

class UserBasicInfoTab extends StatelessWidget {
  final UserProfileController controller;
  const UserBasicInfoTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Obx(
                () => GestureDetector(
                  onTap: controller.showImageSourceSheet,
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
                              : controller.currentUser.value.profilePicture.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(controller
                                          .currentUser.value.profilePicture),
                                      fit: BoxFit.cover,
                                      onError: (exception, stackTrace) =>
                                          const AssetImage(Assets.avatar),
                                    )
                                  : const DecorationImage(
                                      image: AssetImage(Assets.avatar),
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
              // ),
            ],
          ),
        ),
        50.verticalSpace,
        const BodyTextOne(text: 'Full Name'),
        12.verticalSpace,
        CustomTextFormField(
          hintText: 'Full Name',
          controller: controller.fullNameController,
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
        ),
        24.verticalSpace,
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BodyTextOne(text: 'Age'),
                  12.verticalSpace,
                  CustomTextFormField(
                    hintText: 'Age',
                    controller: controller.ageController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BodyTextOne(text: 'Gender'),
                  12.verticalSpace,
                  Obx(
                    () => CustomDropdownField(
                      hintText: 'Select Gender',
                      items: controller.genderOptions,
                      value: controller.selectedGender.value,
                      onChanged: controller.setGender,
                      height: 49.h,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
