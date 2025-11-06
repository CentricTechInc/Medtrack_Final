import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/enums.dart';
import 'package:medtrac/views/Home/widgets/incomplete_profile_sheet.dart';

class HelperFunctions {
 static void goToMainAndRemoveAll(){
    Get.offAllNamed(AppRoutes.mainScreen);
  }

  static void popScreen(){
    Get.back();
    
  }

  static bool isUser(){
    final String role = SharedPrefsService.getRole();
    bool result = role == Role.user.name.toLowerCase();
    return result;
  }

  static bool shouldShowProfileCompletBottomSheet() {
    if (!SharedPrefsService.isProfileComplete() || isPractitionerUnderReview()) {
      return true;
    }
    return false;
  }

  static void showIncompleteProfileBottomSheet(
    {bool isReview = false}
  ) {
    if (Get.isBottomSheetOpen == true) {
      return;
    }

    Get.bottomSheet(
      IncompleteProfileSheet(
        isUnderReview: isReview || (isPractitionerUnderReview()),
      ),
      isDismissible: true,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
    );
  }

  static bool isPractitionerUnderReview() =>
      SharedPrefsService.getRole().toLowerCase() ==
          Role.practitioner.name.toLowerCase() &&
      !SharedPrefsService.isProfileApproved();


  static void showIndismissableLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Center(
        child: Platform.isIOS
            ? const CupertinoActivityIndicator(color: Colors.white)
            : const CircularProgressIndicator(
                color: Colors.black,
              ),
      ),
    );
  }
  
  
}