import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/appointment_details_screen_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_tab_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/views/appointments/patient_history_tab_view_widget.dart';
import 'package:medtrac/views/appointments/payment_details_tab_view_widget.dart';

class AppointmentDetailsScreen extends GetView<AppointmentDetailsController> {
  const AppointmentDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Appointment',
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
                  36.verticalSpace,
                  Row(
                    children: [
                      Container(
                        width: 64.w,
                        height: 64.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          image: (controller.isUser
                                      ? controller.doctorImage
                                      : controller.patientImage)
                                  .isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(controller.isUser
                                      ? controller.doctorImage
                                      : controller.patientImage),
                                  fit: BoxFit.cover,
                                )
                              : const DecorationImage(
                                  image: AssetImage('assets/images/arjun.png'),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      8.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeadingTextTwo(
                              text: controller.isUser
                                  ? (controller.doctorName.isNotEmpty
                                      ? controller.doctorName
                                      : "Doctor Name")
                                  : (controller.patientName.isNotEmpty
                                      ? controller.patientName
                                      : "Patient Name"),
                            ),
                            if (controller.isUser &&
                                controller.doctorSpeciality.isNotEmpty) ...[
                              4.verticalSpace,
                              BodyTextOne(
                                text: controller.doctorSpeciality,
                                color: AppColors.lightGreyText,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  16.verticalSpace,
                  BodyTextOne(
                    text: "Your approximate waiting time is",
                    color: AppColors.lightGreyText,
                  ),
                  16.verticalSpace,
                  HeadingTextOne(
                    text: controller.waitingTime.value,
                  ),
                  16.verticalSpace,
                  CustomTabBar(
                    tabs: ['Patient History', 'Payment Details'],
                    currentIndex: controller.currentIndex,
                    onTabChanged: (index) {
                      controller.currentIndex.value = index;
                      controller.tabController.animateTo(index);
                    },
                  ),
                  16.verticalSpace,
                  Expanded(
                    child: TabBarView(
                      controller: controller.tabController,
                      children: [
                        PatientHistoryTabViewWidget(controller: controller),
                        PaymentDetailsTabViewWidget(controller: controller),
                      ],
                    ),
                  ),
                  16.verticalSpace,
                  // Chat button for doctors
                  if (!controller.isUser) ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            text: "Chat",
                            imagePath: Assets.chatIcon,
                            onPressed: () {
                              Get.toNamed(
                                AppRoutes.chatScreen,
                                arguments: {
                                  'otherUserId': controller.doctorAppointmentData.value?.patient?.id ?? 0,
                                  'otherUserName': controller.patientName,
                                  'otherUserProfilePicture': controller.patientImage,
                                },
                              );
                            },
                            isSecondary: true,
                            isOutlined: true,
                          ),
                        ),
                      ],
                    ),
                    16.verticalSpace,
                  ],
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 36.h,
              child: Container(
                height: 34.h,
                width: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.r),
                    bottomLeft: Radius.circular(8.r),
                  ),
                ),
                child: Center(
                  child: BodyTextOne(
                    text: "Paid",
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
}
