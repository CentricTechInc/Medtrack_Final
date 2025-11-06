import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:medtrac/api/api_manager.dart';
import 'package:medtrac/api/services/auth_service.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/services/notification_service.dart';
import 'package:medtrac/utils/enums.dart';
import 'package:medtrac/services/app_procedures.dart';
import 'package:medtrac/services/state_manager.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();
  bool fromRegistration = false;
  String email = "";
  final RxBool isLoading = false.obs;

  void initialise() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    fromRegistration = args['fromRegisteration'] ?? false;
    email = args['email'] ?? "";
  }

  // ==================== Login Screen ====================
  final loginFormKey = GlobalKey<FormState>();
  var isPasswordVisible = false.obs;
  var rememberMe = false.obs;

  // TextEditingControllers for Login
  final usernameController = TextEditingController(text: "hassansiddiqui@yopmail.com");
  final passwordController = TextEditingController(text: "1234");

  // Validation error messages for Login
  var usernameErrorText = ''.obs;
  var passwordErrorText = ''.obs;

  // ==================== Forgot Password Screen ====================
  var isValidForgotPasswordEmail = false.obs;
  final forgotPasswordEmailController = TextEditingController();
  final forgotPasswordFormKey = GlobalKey<FormState>();

  // ==================== OTP Verification Screen ====================
  final List<TextEditingController> otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  var otpValue = ''.obs;

  // ==================== Login Screen Methods ====================
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  Future<void> login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (loginFormKey.currentState?.validate() ?? false) {
      isLoading.value = true;
      try {
        // Get the real FCM token with fallback handling
        String fcmToken = NotificationService().fcmToken ?? "pending-token-generation";
        
        // If token is null, try to wait a bit and retry once
        if (fcmToken == "pending-token-generation") {
          print('⏳ FCM token not ready, waiting briefly...');
          await Future.delayed(const Duration(seconds: 2));
          fcmToken = NotificationService().fcmToken ?? "token-generation-failed";
        }
        
        print('🔑 Using FCM Token for login: $fcmToken');
        
        final response = await _authService.login(
          email: username,
          password: password,
          fcmToken: fcmToken,
        );

        if (response.status == false) {
          if (response.message == "We have sent an OTP to your email. Please check your email to verify your account") {
            Get.toNamed(AppRoutes.otpVerification, arguments: {
              "email": username,
              "fromRegistration": true,
            });
            SnackbarUtils.showSuccess(response.message!);
            return;
          }
          SnackbarUtils.showError(response.message ?? "Login failed");
        } else if (response.status == true) {
          if (response.token != null) {
            await SharedPrefsService.setAccessToken(response.token!);
          }
          if (response.refreshToken != null) {
            await SharedPrefsService.setRefreshToken(response.refreshToken!);
            ApiManager.initialize();
          }
          if (response.user != null) {
            await SharedPrefsService.setUserInfo(jsonEncode(response.user!.toJson()));

            // If user is a patient, fetch their profile details
            if (response.user!.role == Role.user) {
              final patientService = PatientService();
              await patientService.getPatientProfile();
              await SharedPrefsService.setRole(Role.user.name.toLowerCase());
            } else {
              final doctorService = DoctorService();
              await doctorService.getDoctorProfile();
              await SharedPrefsService.setRole(Role.practitioner.name.toLowerCase());
              
              // Save doctor's profile approval status
              if (response.user!.isPending != null) {
                await SharedPrefsService.setProfileApprovalStatus(response.user!.isPending!.name);
              }
            }

            _navigate(response.user!.role);
            SnackbarUtils.showSuccess("Login successful");
          }
        }
      } catch (e) {
        SnackbarUtils.showError("Error logging in: $e");
      } finally {
        isLoading.value = false;
      }
    }
    // // Check for hardcoded credentials
    // if (username == "user@test.com" && password == "User@123") {
    //   // Save user role to shared preferences
    //   _saveRoleAndNavigate(Role.user);
    // } else if (username == "doctor@test.com" && password == "Doctor@123") {
    //   // Save practitioner role to shared preferences
    //   _saveRoleAndNavigate(Role.practitioner);
    // } else {
    //   SnackbarUtils.showError(
    //       "Invalid credentials. Use:\nuser@test.com / User@123\ndoctor@test.com / Doctor@123");
    // }
  }

  // Helper method to save role and navigate
  Future<void> _navigate(Role role) async {
    try {
      ApiManager.initialize();
      
      // Initialize fresh state for new login
      await StateManager.initializeLoginState();
      
      // Execute post-login procedures
      await AppProcedures.executePostLoginProcedures();
      
      Get.offAllNamed(AppRoutes.mainScreen);
    } catch (e) {
      SnackbarUtils.showError("Error navigating $e");
      Get.offAllNamed(AppRoutes.mainScreen);
    }
  }

  // ==================== Forgot Password Methods ====================

  void sendResetPasswordEmail() async {
    if (forgotPasswordFormKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        final response = await _authService.forgotPassword(
          email: forgotPasswordEmailController.text.trim(),
        );
        if (response.status == false) {
          SnackbarUtils.showError(
              response.message ?? "Failed to send reset email");
        } else {
          SnackbarUtils.showSuccess("An OTP has been sent to your email");
          Get.toNamed(AppRoutes.otpVerification, arguments: {
            "email": forgotPasswordEmailController.text.trim(),
          });
        }
      } catch (e) {
        SnackbarUtils.showError("Error sending reset email: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }

  // ==================== OTP Verification Methods ====================
  void updateOtpValue() {
    otpValue.value = otpControllers.map((e) => e.text).join();
  }

  void verifyOtp({required String emailPassed, required bool fromRegistration}) async {
    if (otpValue.value.length < 4) {
      SnackbarUtils.showError("Please enter a valid OTP");
      return;
    }
    try {
      isLoading.value = true;
      final response =
          await _authService.verifyOtp(otp: otpValue.value, email: email.isEmpty ? emailPassed : email);

      if (response.status == false) {
        SnackbarUtils.showError(response.message ?? "OTP verification failed");
      } else if (response.status == true) {
        if (fromRegistration) {
          // After successful registration verification, navigate based on role.
          // The verifyOtp flow now persists user & token into SharedPrefsService.
          final role = SharedPrefsService.getRole();
            try {
              ApiManager.initialize();
              await StateManager.initializeLoginState();
              await AppProcedures.executePostLoginProcedures();
            } catch (e) {
              // If initialization fails, still navigate to main screen
            }
          if (Role.user.name.toLowerCase() == role.toLowerCase()) {
            // New patient -> take them through the tour guide
            Get.offAllNamed(AppRoutes.tourGuideScreen);
          } else {
            Get.offAllNamed(AppRoutes.mainScreen);
          }
        } else {
          Get.offAndToNamed(AppRoutes.resetPassword,
              arguments: {"email": email.isEmpty ? emailPassed : email, 'otp': otpValue.value});
        }
        SnackbarUtils.showSuccess("OTP verified successfully");
      }
    } catch (e) {
      SnackbarUtils.showError("Error verifying OTP: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void resendOtp() {
    SnackbarUtils.showSuccess("OTP has been resent to your email");
  }
}
