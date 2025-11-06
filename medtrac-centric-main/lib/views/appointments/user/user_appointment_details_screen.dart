import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/appointment_details_screen_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/details_label_row_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class UserAppointmentDetailsScreen
    extends GetView<AppointmentDetailsController> {
  const UserAppointmentDetailsScreen({super.key});

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
                          image: controller.doctorImage.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(controller.doctorImage),
                                  fit: BoxFit.cover,
                                )
                              : DecorationImage(
                                  image: AssetImage(Assets.vermaImage2),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      8.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 245.w,
                              child: FittedBox(
                                child: HeadingTextTwo(
                                  text: controller.doctorName,
                                ),
                              ),
                            ),
                            if (controller.doctorSpeciality.isNotEmpty) ...[
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
                  if (!controller.appointmentTimePassed.value) ...[
                    BodyTextOne(
                      text: "Your approximate waiting time is",
                      color: AppColors.lightGreyText,
                    ),
                    16.verticalSpace
                  ],
                  Obx(() => HeadingTextOne(
                        text: controller.waitingTime.value.isNotEmpty
                            ? controller.waitingTime.value
                            : "Loading...",
                        textAlign: TextAlign.center,
                      )),
                  16.verticalSpace,
                  DetailLabelRowWidget(
                    title: "Date",
                    value: controller.appointmentDate,
                  ),
                  16.verticalSpace,
                  Divider(
                    color: AppColors.offWhite,
                  ),
                  16.verticalSpace,
                  DetailLabelRowWidget(
                    title: "Time",
                    value: controller.appointmentTime,
                  ),
                  16.verticalSpace,
                  Divider(
                    color: AppColors.offWhite,
                  ),
                  16.verticalSpace,
                  DetailLabelRowWidget(
                    title: "Type",
                    value: controller.appointmentType,
                  ),
                  16.verticalSpace,
                  Divider(
                    color: AppColors.offWhite,
                  ),
                  16.verticalSpace,
                  DetailLabelRowWidget(
                    title: "Consultation Type",
                    value: controller.consultationType,
                  ),
                  16.verticalSpace,
                  Divider(
                    color: AppColors.offWhite,
                  ),
                  16.verticalSpace,
                  DetailLabelRowWidget(
                    title: "Fee",
                    value: "\$${controller.consultationFee.toStringAsFixed(2)}",
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomElevatedButton(
                        text: "Chat",
                        imagePath: Assets.chatIcon,
                        width: 184.w,
                        onPressed: () {
                          Get.toNamed(AppRoutes.chatScreen);
                        },
                        isSecondary: true,
                        isOutlined: true,
                      ),
                      CustomElevatedButton(
                        text: "Join Session",
                        imagePath: Assets.videoIcon,
                        width: 184.w,
                        isSecondary: true,
                        onPressed: () {
                          Get.toNamed(
                            AppRoutes.videoCallScreen,
                            arguments: {
                              'fromAppointment': true,
                              'doctorName': controller.doctorName,
                              'doctorImage': controller.doctorImage,
                              'appointmentId': controller.appointmentId,
                              'callerId': controller.currentUserId,
                              'receiverId': controller.userAppointmentData.value?.doctor?.id ?? 0,
                              'doctorId': controller.userAppointmentData.value?.doctor?.id ?? 0,
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  16.verticalSpace,
                  CustomElevatedButton(
                    text: "Cancel",
                    onPressed: () {
                      Get.toNamed(
                        AppRoutes.cancelBookingScreen,
                        arguments: {
                          'appointmentId': controller.appointmentId,
                          'doctorName': controller.doctorName,
                          'doctorImage': controller.doctorImage,
                          'doctorSpeciality': controller.doctorSpeciality,
                          'appointmentDate': controller.appointmentDate,
                          'appointmentTime': controller.appointmentTime,
                        },
                      );
                    },
                  ),
                  32.verticalSpace,
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
