import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class SnackbarUtils {
  static void showSuccess(String message, {String title = "Success"}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.green.shade400,
      icon: Icons.check_circle,
    );
  }

  static void showError(String message, {String title = "Error"}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.red.shade400,
      icon: Icons.error,
    );
  }

  static void showLoading(String message, {String title = "Loading"}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.blue.shade400,
      icon: Icons.hourglass_top,
      isLoading: true,
    );
  }

  static void showInfo(String message, {String title = "Info"}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.blue.shade400,
      icon: Icons.info,
    );
  }

  static void closeSnackbar() {
    if (Get.isSnackbarOpen) {
      Get.back();
    }
  }

  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    bool isLoading = false,
  }) {
    Get.snackbar(
      title,
      message,
      icon: Icon(icon, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: isLoading
          ? null
          : const Duration(seconds: 2), // Loading has no timeout
      showProgressIndicator: isLoading,
      progressIndicatorBackgroundColor: Colors.white,
      progressIndicatorValueColor: const AlwaysStoppedAnimation(Colors.white),
      isDismissible: !isLoading,
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 50.h),
      barBlur: 10,
      animationDuration: const Duration(milliseconds: 500), // Faster animation
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
    );
  }

  static void showCustom({
    required String message,
    String iconPath = Assets.snackBarSuccessIcon,
    Color backgroundColor = AppColors.secondary,
    Color iconColor = Colors.white,
    Color textColor = Colors.white,
    double borderRadius = 24,
    EdgeInsets margin =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    double iconSize = 20,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.closeAllSnackbars();
    Get.rawSnackbar(
      messageText: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: iconSize.r,
            height: iconSize.r,
            color: iconColor,
          ),
          24.horizontalSpace,
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      margin: margin,
      snackPosition: SnackPosition.BOTTOM,
      duration: duration,
      animationDuration: const Duration(milliseconds: 400),
      isDismissible: true,
      snackStyle: SnackStyle.FLOATING,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
    );
  }
}
