import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/services/auth_service.dart';
import 'package:medtrac/routes/app_routes.dart';

import 'package:medtrac/utils/snackbar.dart';

class SignupController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final genderController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  final signupFormKey = GlobalKey<FormState>();
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var selectedGender = Rxn<String>();
  var isLoading = false.obs;

  // List of available gender options
  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    genderController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void signup() async {
    if (signupFormKey.currentState?.validate() ?? false) {
      // Get.toNamed(AppRoutes.otpVerification, arguments: {
      //   "fromRegisteration": true,
      //   "email": emailController.text.trim(),
      // });
      isLoading.value = true;
      try {
        final response = await _authService.register(
          name: fullNameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneNumberController.text.trim(),
          password: passwordController.text.trim(),
          gender: selectedGender.value!.capitalizeFirst!,
        );

        // Check for status true
        if (response.status == true) {
          SnackbarUtils.showSuccess(
              response.message ?? "Registration successful");
          Get.toNamed(AppRoutes.otpVerification, arguments: {
            "fromRegisteration": true,
            "email": emailController.text.trim(),
          });
        } else {
          SnackbarUtils.showError(response.message ?? "Registration failed");
        }
      } catch (e) {
        SnackbarUtils.showError(e.toString());
      } finally {
        isLoading.value = false;
      }
    }
  }
}
