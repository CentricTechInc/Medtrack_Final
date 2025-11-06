import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/auth_controllers/reset_password_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/validation_extension.dart';

class ResetPasswordScreen extends StatelessWidget {
  final ResetPasswordController controller = Get.put(ResetPasswordController());
  // final LoginController controller = Get.find<LoginController>();

  ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: AbsorbPointer(
            absorbing: controller.isLoading.value,
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: controller.resetPasswordFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: HeadingTextTwo(
                      text: "Create Password",
                      textAlign: TextAlign.center,
                      color: AppColors.secondary,
                    ),
                  ),
                  8.verticalSpace,
                  Center(
                    child: BodyTextOne(
                      text: "Enter new password and confirm password",
                      textAlign: TextAlign.center,
                      color: AppColors.darkGreyText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  60.verticalSpace,
                  BodyTextOne(
                    text: "New Password",
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                  8.verticalSpace,
                  Obx(() => CustomTextFormField(
                      hintText: 'New Password',
                      controller: controller.newPasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      isPasswordVisible: controller.isNewPasswordVisible.value,
                      isPassword: true,
                      maxLines: 1,
                      onToggleVisibility:
                          controller.toggleNewPasswordVisibility,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return value?.validateNotEmpty();
                        }
                        return value?.validateStrongPassword();
                      })),
                  16.verticalSpace,
                  BodyTextOne(
                    text: "Confirm Password",
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                  8.verticalSpace,
                  Obx(() => CustomTextFormField(
                      hintText: 'Confirm Password',
                      controller: controller.confirmPasswordController,
                      keyboardType: TextInputType.visiblePassword,
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
                      })),
                  const Spacer(),
                  Obx(() {
                    return CustomElevatedButton(
                      text: 'Confirm',
                      onPressed: controller.resetPassword,
                      isLoading: controller.isLoading.value,
                    );
                  }),
                  24.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
