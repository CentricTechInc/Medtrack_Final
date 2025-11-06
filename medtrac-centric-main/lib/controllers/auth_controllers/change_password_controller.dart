import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/services/auth_service.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'base_password_controller.dart';

class ChangePasswordController extends BasePasswordController {
  final changePasswordFormKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final currentPasswordController = TextEditingController();
  var isCurrentPasswordVisible = false.obs;
  RxBool isLoading = false.obs;

  String email = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    email = args['email'] ?? "";
  }

  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  }

  Future<void> changePassword() async {
    if (changePasswordFormKey.currentState?.validate() ?? false) {
      final currentPassword = currentPasswordController.text.trim();
      final newPassword = newPasswordController.text.trim();
          isLoading.value = true; // Start loading
      try {
        final doctorService = Get.put(DoctorService());
        final response = await doctorService.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
            if (response.success) {
              isLoading.value = false;
              SnackbarUtils.showSuccess("Password changed successfully");
              // Clear all password fields
              currentPasswordController.clear();
              newPasswordController.clear();
              confirmPasswordController.clear();
              // Unfocus all fields to prevent validation errors
              FocusManager.instance.primaryFocus?.unfocus();
              await Future.delayed(const Duration(seconds: 4));
              Get.back();
            } else {
              isLoading.value = false;
              SnackbarUtils.showError(response.message ?? "PAdo@Failed to change password");
            }
      } catch (e) {
              isLoading.value = false; // Set loading to false on exception
              SnackbarUtils.showError("An error occurred while changing password");
      } finally {
              // isLoading.value = false; // This line is now redundant
      }
    }
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    super.onClose();
  }
}
