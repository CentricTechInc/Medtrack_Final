import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/auth_controllers/change_password_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/validation_extension.dart';

class ChangePasswordScreen extends StatelessWidget {
  final ChangePasswordController controller =
      Get.put(ChangePasswordController());

  ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Change Password',
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: SingleChildScrollView(
                child: AbsorbPointer(
                  absorbing: controller.isLoading.value,
                  child: Form(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    key: controller.changePasswordFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyTextOne(
                          text: "Current Password",
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                        8.verticalSpace,
                        Obx(() => CustomTextFormField(
                              hintText: 'Current Password',
                              controller: controller.currentPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText:
                                  !controller.isCurrentPasswordVisible.value,
                              isPasswordVisible:
                                  controller.isCurrentPasswordVisible.value,
                              isPassword: true,
                              maxLines: 1,
                              onToggleVisibility:
                                  controller.toggleCurrentPasswordVisibility,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return value?.validateNotEmpty();
                                }
                                return null;
                              },
                            )),
                        16.verticalSpace,
                        BodyTextOne(
                          text: "New Password",
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                        8.verticalSpace,
                        Obx(() => CustomTextFormField(
                              hintText: 'New Password',
                              controller: controller.newPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText:
                                  !controller.isNewPasswordVisible.value,
                              isPasswordVisible:
                                  controller.isNewPasswordVisible.value,
                              isPassword: true,
                              maxLines: 1,
                              onToggleVisibility:
                                  controller.toggleNewPasswordVisibility,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return value?.validateNotEmpty();
                                }
                                return value?.validateStrongPassword();
                              },
                            )),
                        16.verticalSpace,
                        BodyTextOne(
                          text: "Confirm Password",
                          fontWeight: FontWeight.w700,
                        ),
                        8.verticalSpace,
                        Obx(() => CustomTextFormField(
                              hintText: 'Confirm Password',
                              controller: controller.confirmPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText:
                                  !controller.isConfirmPasswordVisible.value,
                              isPasswordVisible:
                                  controller.isConfirmPasswordVisible.value,
                              isPassword: true,
                              maxLines: 1,
                              onToggleVisibility:
                                  controller.toggleConfirmPasswordVisibility,
                              validator: (value) {
                                final error = value?.validateMatch(
                                    controller.newPasswordController.text);
                                return error?.isEmpty ?? true ? null : error;
                              },
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.h),
            child: Obx(() {
              return CustomElevatedButton(
                isLoading: controller.isLoading.value,
                text: 'Change Password',
                onPressed: () => controller.changePassword(),
              );
            }),
          ),
          16.verticalSpace,
        ],
      ),
    );
  }
}
