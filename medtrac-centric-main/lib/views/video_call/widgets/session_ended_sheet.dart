import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';
import 'package:medtrac/controllers/appointments_controller.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/helper_functions.dart';

class SessionEndedSheet extends StatelessWidget {
  final int doctorId;
  final String doctorName;
  final int callDuration;
  final String doctorImage;
  final int appointmentId;
  final bool hasPrescription;
  
  const SessionEndedSheet({
    super.key,
    this.doctorId = 0,
    this.doctorName = '',
    this.callDuration = 0,
    this.doctorImage = '',
    this.appointmentId = 0,
    this.hasPrescription = false,
  });

  @override
  Widget build(BuildContext context) {
    // For doctors, automatically navigate after a brief delay
    if (!HelperFunctions.isUser()) {
      Future.delayed(const Duration(seconds: 2), () {
        // Close the bottom sheet
        Get.back();
        
        if (!hasPrescription) {
          // Navigate to prescription screen if no prescription written yet
          Get.toNamed(
            AppRoutes.prescriptionScreen,
            arguments: {
              'appointmentId': appointmentId,
              'fromCall': true,
            },
          );
        } else {
          // Pop video call screen and navigate to completed appointments
          Get.back(); // Close video call screen
          
          // Navigate to appointments tab with completed appointments selected
          final bottomBarController = Get.find<BottomNavigationController>();
          bottomBarController.selectedNavIndex.value = 1; // Appointments tab
          
          // Navigate to main screen
          Get.offAllNamed(AppRoutes.mainScreen);
          
          // Set completed tab (index 1)
          try {
            final appointmentsController = Get.find<AppointmentsController>();
            appointmentsController.currentIndex.value = 1; // Completed tab
            appointmentsController.tabController.animateTo(1);
          } catch (e) {
            print('Error setting completed tab: $e');
          }
        }
      });
    }
    
    return Container(
      height: HelperFunctions.isUser() ? 400.h : 387.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tick icon
          Center(
            child: Image.asset(
              Assets.tickIcon,
              width: 100.w,
              height: 100.w,
            ),
          ),

          24.verticalSpace,

          // Welcome heading
          HeadingTextTwo(
            text: "Session Ended",
            textAlign: TextAlign.center,
          ),

          12.verticalSpace,

          // Description text
          BodyTextOne(
            text:
                "Your session has ended. Thank you for your time. You will receive a notification regarding any further steps.",
            textAlign: TextAlign.center,
            color: AppColors.darkGreyText,
          ),
          if (HelperFunctions.isUser()) ...[
            24.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    text: "Later",
                    isOutlined: true,
                    isSecondary: true,
                    onPressed: () {
                      // Close both the bottom sheet and video call screen
                      Get.back(); // Close bottom sheet
                      Get.back(); // Close video call screen
                      
                      // Navigate to appointments tab with completed appointments selected
                      final bottomBarController =
                          Get.find<BottomNavigationController>();
                      bottomBarController.selectedNavIndex.value = 1; // Appointments tab
                      
                      // Navigate to main screen
                      Get.offAllNamed(AppRoutes.mainScreen);
                      
                      // Set completed tab (index 1)
                      try {
                        final appointmentsController = Get.find<AppointmentsController>();
                        appointmentsController.currentIndex.value = 1; // Completed tab
                        appointmentsController.tabController.animateTo(1);
                      } catch (e) {
                        print('Error setting completed tab: $e');
                      }
                    },
                  ),
                ),
                20.horizontalSpace,
                Expanded(
                  child: CustomElevatedButton(
                    text: "Leave Review",
                    isSecondary: true,
                    onPressed: () {
                      // Close both the bottom sheet and video call screen
                      Get.back(); // Close bottom sheet
                      Get.back(); // Close video call screen
                      
                      // Navigate to review screen
                      Get.toNamed(
                        AppRoutes.reviewDoctorScreen,
                        arguments: {
                          'doctorId': doctorId,
                          'doctorName': doctorName,
                          'callDuration': callDuration,
                          'doctorImage': doctorImage,
                        },
                      );
                    },
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
}
