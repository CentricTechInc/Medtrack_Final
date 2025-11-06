import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/auth_controllers/login_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/validation_extension.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: AbsorbPointer(
          absorbing: loginController.isLoading.value,
          child: Form(
            key: loginController.forgotPasswordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: HeadingTextOne(
                    text: "Forgot Password",
                    textAlign: TextAlign.center,
                    color: AppColors.secondary,
                  ),
                ),
                24.verticalSpace,
                Center(
                  child: HeadingTextTwo(
                    text:
                        "Please enter your email address. You\nwill receive a link to create a new\npassword via email.",
                    textAlign: TextAlign.center,
                    color: AppColors.darkGreyText,
                    fontSize: 16.sp,
                  ),
                ),
                48.verticalSpace,
                CustomTextFormField(
                  hintText: 'Email Address',
                  hintTextColor: AppColors.secondary,
                  controller: loginController.forgotPasswordEmailController,
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    } else if (!value.isValidEmail) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const Spacer(),
                Obx(() {
                  return CustomElevatedButton(
                    text: 'Send Email',
                    isLoading: loginController.isLoading.value,
                    onPressed: () {
                      loginController.sendResetPasswordEmail();
                    },
                  );
                }),
                24.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
