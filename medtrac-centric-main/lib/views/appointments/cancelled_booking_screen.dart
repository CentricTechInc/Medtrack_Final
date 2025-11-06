import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/cancelled_booking_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/details_label_row_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class CancelledBookingScreen extends GetView<CancelledBookingController> {
  const CancelledBookingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Patient Details",
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => controller.loadAppointmentDetails(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  24.verticalSpace,
                  _buildDynamicUserInfo(),
                  16.verticalSpace,
                  DetailLabelRowWidget(
                    title: "Date",
                    value: controller.appointmentDate.isNotEmpty ? controller.appointmentDate : "N/A",
                  ),
                  16.verticalSpace,
                  Divider(
                    color: AppColors.offWhite,
                  ),
                  16.verticalSpace,
                  DetailLabelRowWidget(
                    title: "Slot",
                    value: controller.slot.isNotEmpty ? controller.slot : "N/A",
                  ),
                  16.verticalSpace,
                  Divider(
                    color: AppColors.offWhite,
                  ),
                  16.verticalSpace,
                  DetailLabelRowWidget(
                    title: "Time",
                    value: controller.timeRange.isNotEmpty ? controller.timeRange : controller.appointmentTime,
                  ),
                  16.verticalSpace,
                  Divider(
                    color: AppColors.offWhite,
                  ),
                  16.verticalSpace,
                  DetailLabelRowWidget(
                    title: "Type",
                    value: controller.appointmentType.isNotEmpty ? controller.appointmentType : "N/A",
                  ),
                  16.verticalSpace,
                  Divider(
                    color: AppColors.offWhite,
                  ),
                  16.verticalSpace,
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.bright,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Reason",
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondary,
                        ),
                        10.verticalSpace,
                        BodyTextOne(
                          text: controller.cancelReason.isNotEmpty 
                              ? controller.cancelReason
                              : "Unfortunately, your session with ${controller.doctorName} scheduled for ${controller.appointmentDate}, ${controller.timeRange} has been Canceled due to unforeseen circumstances.",
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 36.h,
              child: Container(
                height: 34.h,
                width: 120.w,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    bottomLeft: Radius.circular(8.r),
                  ),
                ),
                child: Center(
                  child: BodyTextOne(
                    text: "Canceled",
                    color: AppColors.bright,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDynamicUserInfo() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              image: DecorationImage(
                image: _getImageProvider(),
                fit: BoxFit.cover,
              ),
            ),
          ),
          8.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyTextOne(
                  text: _getDisplayName(),
                  fontWeight: FontWeight.bold,
                ),
                if (_getSubtitle().isNotEmpty) ...[
                  CustomText(
                    text: _getSubtitle(),
                    fontSize: 12.sp,
                    color: AppColors.darkGreyText,
                  ),
                ],
                if (_getDescription().isNotEmpty) ...[
                  Divider(
                    color: AppColors.offWhite,
                  ),
                  BodyTextTwo(
                    text: _getDescription(),
                    color: AppColors.darkGreyText,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider() {
    if (controller.isUser) {
      // Patient view - show doctor image
      String doctorImage = controller.doctorImage;
      if (doctorImage.isNotEmpty) {
        return NetworkImage(doctorImage);
      }
      return const AssetImage('assets/images/doctor_placeholder.png');
    } else {
      // Doctor view - show patient image
      String patientImage = controller.patientImage;
      if (patientImage.isNotEmpty) {
        return NetworkImage(patientImage);
      }
      return const AssetImage('assets/images/patient_placeholder.png');
    }
  }

  String _getDisplayName() {
    if (controller.isUser) {
      return controller.doctorName;
    } else {
      return controller.patientName;
    }
  }

  String _getSubtitle() {
    if (controller.isUser) {
      return "MBBS, M.D"; // Could be enhanced with API data
    } else {
      return ""; // Patients don't have subtitles
    }
  }

  String _getDescription() {
    if (controller.isUser) {
      return controller.doctorSpeciality.isNotEmpty 
          ? "${controller.doctorSpeciality} - Family Medicine"
          : "Specialist - Family Medicine";
    } else {
      return ""; // Patients don't have descriptions
    }
  }
}
