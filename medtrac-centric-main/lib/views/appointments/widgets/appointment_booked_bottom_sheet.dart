import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';
import 'package:medtrac/controllers/appointments_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class AppointmentBookedBottomSheet extends StatelessWidget {
  AppointmentBookedBottomSheet({super.key});
  final BottomNavigationController _bottomNavBarcontroller = Get.find<BottomNavigationController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
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
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Image.asset(
              Assets.calanderIcon,
              width: 56.w,
              height: 56.w,
              color: Colors.white,
            ),
          ),
          24.verticalSpace,
          HeadingTextTwo(
            text: "Congratulations",
            textAlign: TextAlign.center,
          ),
          12.verticalSpace,
          BodyTextOne(
            text: "Your appointment has been successfully booked. The doctor will join you within 10 to 15 minutes.",
            textAlign: TextAlign.center,
            color: AppColors.darkGreyText,
          ),
          32.verticalSpace,
          CustomElevatedButton(
            text: "View Appointment",
            onPressed: () {
              // Force refresh appointments list if available
              try {
                final appointmentsController = Get.find<AppointmentsController>();
                appointmentsController.forceRefresh();
              } catch (e) {
                // AppointmentsController not found, ignore
              }
              
              Get.offAllNamed(AppRoutes.mainScreen);
              _bottomNavBarcontroller.selectedNavIndex.value = 1;
            },
            isSecondary: true,
          )
        ],
      ),
    );
  }
}
