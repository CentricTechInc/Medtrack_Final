import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/services/auth_service.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'base_password_controller.dart';

class ResetPasswordController extends BasePasswordController {
  final resetPasswordFormKey = GlobalKey<FormState>();
    final AuthService _authService = AuthService();

  RxBool isLoading = false.obs;

  String email = '';
  String otp = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    email = args['email'] ?? "";
    otp = args['otp'] ?? "";
  }

  Future<void> resetPassword() async {
    if (resetPasswordFormKey.currentState?.validate() ?? false) {
      final newPassword = newPasswordController.text.trim();
      isLoading.value = true;
      try {
        final response = await _authService.createNewPassword(
          email: email,
          newPassword: newPassword,
          otp: otp,
        );
        if (response.status == false) {
          SnackbarUtils.showError(response.message ?? "Failed to change password");
          return;
        } else if (response.status == true) {
          SnackbarUtils.showSuccess("Password changed successfully");
          await showPasswordChangedSuccessSheet(); // Get.offAllNamed(AppRoutes.loginScreen); inside this sheet
        }
      } catch (e) {
        SnackbarUtils.showError("An error occurred while changing password");
      } finally {
        isLoading.value = false;
      }
    }

  }
}
