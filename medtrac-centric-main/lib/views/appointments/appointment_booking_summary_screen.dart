import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/appointment_booking_summary_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/details_label_row_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class AppointmentBookingSummaryScreen
    extends GetView<AppointmentBookingSummaryController> {
  const AppointmentBookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Summary',
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.h,
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        image: DecorationImage(
                          image: controller.doctorProfilePic.value.isNotEmpty
                            ? NetworkImage(controller.doctorProfilePic.value)
                            : AssetImage(Assets.avatar) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                        ),
                    ),
                    8.horizontalSpace,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => BodyTextOne(
                          text: controller.doctorName.value,
                          fontWeight: FontWeight.w900,
                        )),
                        Obx(() => BodyTextTwo(
                            text: controller.doctorSpecialty.value, 
                            fontWeight: FontWeight.w600))
                      ],
                    ),
                  ],
                ),
                24.verticalSpace,
                Obx(() => DetailLabelRowWidget(
                    title: "Patient Name", 
                    value: controller.patientName.value.isNotEmpty 
                        ? controller.patientName.value 
                        : "Not provided")),
                16.verticalSpace,
                Divider(
                  color: AppColors.offWhite,
                ),
                16.verticalSpace,
                Obx(() => DetailLabelRowWidget(
                    title: "Date", 
                    value: controller.appointmentDate.value.isNotEmpty 
                        ? controller.appointmentDate.value 
                        : "Not selected")),
                16.verticalSpace,
                Divider(
                  color: AppColors.offWhite,
                ),
                16.verticalSpace,
                Obx(() => DetailLabelRowWidget(
                    title: "Primary Concerns", 
                    value: controller.primaryConcerns.isNotEmpty 
                        ? controller.primaryConcerns.join(", ") 
                        : "None specified")),
                16.verticalSpace,
                Divider(
                  color: AppColors.offWhite,
                ),
                16.verticalSpace,
                Obx(() => DetailLabelRowWidget(
                    title: "Consultation Type", 
                    value: controller.consultationType.value.isNotEmpty 
                        ? controller.consultationType.value 
                        : "Standard")),
                16.verticalSpace,
                Divider(
                  color: AppColors.offWhite,
                ),
                12.verticalSpace,
                Obx(() => DetailLabelRowWidget(
                  title: "Consultation Fee",
                  value: "₹${controller.consultationFee.value.toStringAsFixed(0)}",
                  isValueBold: true,
                )),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 24.w),
              child: Obx(() => CustomElevatedButton(
                text: "Continue",
                onPressed: controller.isSubmitting.value ? () {} : controller.createAppointment,
                isLoading: controller.isSubmitting.value,
              )),
            )
          ],
        ),
      ),
    );
  }
}
