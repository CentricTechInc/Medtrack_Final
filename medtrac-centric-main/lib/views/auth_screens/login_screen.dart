import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/auth_controllers/login_controller.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/validation_extension.dart';
import 'package:medtrac/views/auth_screens/forgot_password_screen.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';

class LoginScreen extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    100.h, // 2 x padding
              ),
              child: AbsorbPointer(
                absorbing: loginController.isLoading.value,
                child: Form(
                  key: loginController.loginFormKey,
                  autovalidateMode:
                      AutovalidateMode.disabled, // Disable auto-validation
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeadingTextTwo(
                        text: "Let`s sign you in",
                        textAlign: TextAlign.center,
                        color: AppColors.secondary,
                      ),
                      40.verticalSpace,
                      CustomTextFormField(
                        hintText: 'Phone, email or username',
                        hintTextColor: AppColors.secondary,
                        controller: loginController.usernameController,
                        keyboardType: TextInputType.text,
                        obscureText: false,
                        validator: (value) => value?.validateNotEmpty(),
                      ),
                      24.verticalSpace,
                      Obx(
                        () => CustomTextFormField(
                            hintText: 'Password',
                            hintTextColor: AppColors.secondary,
                            controller: loginController.passwordController,
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: !loginController.isPasswordVisible.value,
                            isPassword: true,
                            isPasswordVisible:
                                loginController.isPasswordVisible.value,
                            onToggleVisibility:
                                loginController.togglePasswordVisibility,
                            maxLines: 1,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return value?.validateNotEmpty();
                              }
                              return null;
                              // return value?.validateStrongPassword();
                            }),
                      ),
                      32.verticalSpace,
                      _remeberAndForgetPassRow(),
                      32.verticalSpace,
                      Obx(() {
                        return CustomElevatedButton(
                          text: 'Sign In',
                          isLoading: loginController.isLoading.value,
                          onPressed: () async {
                            if (loginController.loginFormKey.currentState!
                                .validate()) {
                              await loginController.login();
                            }
                          },
                        );
                      }),
                      32.verticalSpace,
                      _orSignInWithRow(),
                      32.verticalSpace,
                      _googleAndAppleRow(),
                      32.verticalSpace,
                      _dontHaveAccountRow(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row _remeberAndForgetPassRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Transform.translate(
          offset: Offset(-12.0.w, 0.0), // Move leftward by 12 logical pixels
          child: Obx(() => Row(
                children: [
                  Checkbox(
                    value: loginController.rememberMe.value,
                    onChanged: (value) => loginController.toggleRememberMe(),
                    checkColor: AppColors.bright,
                    activeColor: AppColors.secondary,
                  ),
                  InkWell(
                    onTap: () => loginController.toggleRememberMe(),
                    child: BodyTextOne(
                      text: 'Remember me',
                      color: AppColors.darkGreyText,
                    ),
                  ),
                ],
              )),
        ),
        TextButton(
          onPressed: () => Get.to(() => ForgotPasswordScreen()),
          child: HeadingTextTwo(
            text: 'Forgot Password?',
            color: AppColors.error,
            fontSize: 15.sp,
          ),
        ),
      ],
    );
  }

  Row _orSignInWithRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 75.w,
          height: 1.h,
          color: AppColors.darkGreyText,
          margin: EdgeInsets.symmetric(horizontal: 10.w),
        ),
        BodyTextOne(
          text: 'Or sign in with',
          color: AppColors.darkGreyText,
        ),
        Container(
          width: 75.w,
          height: 1.h,
          color: AppColors.darkGreyText,
          margin: EdgeInsets.symmetric(horizontal: 10.w),
        ),
      ],
    );
  }

  Row _googleAndAppleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (Platform.isIOS) ...[
          Image.asset(
            'assets/icons/apple_icon.png',
            scale: 2,
          ),
          16.horizontalSpace,
        ],
        Image.asset(
          'assets/icons/google_icon.png',
          scale: 2,
        ),
      ],
    );
  }

  Row _dontHaveAccountRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BodyTextOne(
          text: 'Don’t have an account?',
          color: AppColors.darkGreyText,
        ),
        TextButton(
          onPressed: () {
            Get.toNamed(
                AppRoutes.roleSelectionScreen); // Navigate to the signup screen
          },
          child: HeadingTextTwo(
            text: 'Sign Up',
            color: AppColors.primary,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }
}
