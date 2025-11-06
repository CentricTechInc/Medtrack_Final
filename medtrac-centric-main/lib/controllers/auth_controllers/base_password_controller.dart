import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/views/Home/widgets/info_bottom_sheet.dart';

abstract class BasePasswordController extends GetxController {
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isNewPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> showPasswordChangedSuccessSheet() async {
    // final lockIconWidget = Padding(
    //   padding: EdgeInsets.only(top: 24.h),
    //   child: Image.asset(
    //     Assets.lockIcon,
    //     width: 80.w,
    //     height: 80.h,
    //   ),
    // );
    

    Get.bottomSheet(
      InfoBottomSheet(heading: "Password Changed", description: "Your password has been updated successfully. You can now use your new password to log in.", imageAsset: Assets.lockIcon)
    );
    
    await Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(AppRoutes.loginScreen);
    });
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
