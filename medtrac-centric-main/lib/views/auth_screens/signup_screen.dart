import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/auth_controllers/signup_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/validation_extension.dart';

class SignupScreen extends StatelessWidget {
  final SignupController signupController = Get.put(SignupController());

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: AbsorbPointer(
            absorbing: signupController.isLoading.value,
            child: Form(
              key: signupController.signupFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeadingTextTwo(
                    text: 'Let\'s Create an account!',
                    textAlign: TextAlign.center,
                    color: AppColors.secondary,
                  ),
                  40.verticalSpace,
                  CustomTextFormField(
                    hintText: 'Full Name',
                    controller: signupController.fullNameController,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return value?.validateNotEmpty();
                      }
                      return null;
                    },
                  ),
                  16.verticalSpace,
                  CustomTextFormField(
                    hintText: 'Email Address',
                    controller: signupController.emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return value?.validateNotEmpty();
                      } else if (!(value?.isValidEmail ?? false)) {
                        return value?.validateEmail();
                      }
                      return null;
                    },
                  ),
                  16.verticalSpace,
                  CustomTextFormField(
                    hintText: 'Phone No.',
                    controller: signupController.phoneNumberController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return value?.validateNotEmpty();
                      }
                      return null;
                    },
                  ),
                  16.verticalSpace,
                  _genderDropDownWidget(),
                  16.verticalSpace,
                  Obx(() => CustomTextFormField(
                        hintText: 'Password',
                        controller: signupController.passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        isPasswordVisible:
                            signupController.isPasswordVisible.value,
                        isPassword: true,
                        maxLines: 1,
                        onToggleVisibility:
                            signupController.togglePasswordVisibility,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return value?.validateNotEmpty();
                          }
                          return value?.validateStrongPassword();
                        },
                      )),
                  16.verticalSpace,
                  Obx(() => CustomTextFormField(
                      hintText: 'Confirm Password',
                      controller: signupController.confirmPasswordController,
                      keyboardType: TextInputType.text,
                      isPasswordVisible:
                          signupController.isConfirmPasswordVisible.value,
                      isPassword: true,
                      maxLines: 1,
                      onToggleVisibility:
                          signupController.toggleConfirmPasswordVisibility,
                      validator: (value) {
                        final error = value?.validateMatch(
                            signupController.passwordController.text);
                        return error?.isEmpty ?? true ? null : error;
                      })),
                  32.verticalSpace,
                  Obx(() => CustomElevatedButton(
                    text: 'Register',
                    onPressed: signupController.signup,
                        isLoading: signupController.isLoading.value,
                      )),
                  32.verticalSpace,
                  _orSignInWithRow(),
                  16.verticalSpace,
                  _googleAndAppleRow(),
                  16.verticalSpace,
                  _alreadyHaveAccountRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container _genderDropDownWidget() {
    return Container(
      color: AppColors.bright,
      child: Obx(() => DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Gender',
              fillColor: AppColors.bright,
              alignLabelWithHint: true,
              hintStyle:
                  TextStyle(fontSize: 16.sp, color: AppColors.dark),
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
              contentPadding: EdgeInsets.only(left: 16.w),
            ),
            isExpanded: true,
            icon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.keyboard_arrow_down,
                  color: AppColors.lightGreyText),
            ),
            value: signupController.selectedGender.value,
            items: signupController.genderOptions
                .map((gender) => DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender,
                          style: TextStyle(
                              color: AppColors.dark, fontSize: 16.sp)),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                signupController.selectedGender.value = value;
                signupController.genderController.text = value;
              }
            },
            hint: Text("Select Gender",
                style:
                    TextStyle(fontSize: 16.sp, color: AppColors.dark)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a gender';
              }
              return null;
            },
            dropdownColor: AppColors.bright,
            alignment: AlignmentDirectional.centerStart,
          )),
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
          text: 'Or sign up with',
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

  Row _alreadyHaveAccountRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BodyTextOne(
          text: 'Already have account?',
          color: AppColors.darkGreyText,
        ),
        TextButton(
          onPressed: () {
            Get.toNamed(AppRoutes.loginScreen);
          },
          child: HeadingTextTwo(
            text: 'Sign In',
            color: AppColors.primary,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }
}
