import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/controllers/appointment_details_screen_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/details_label_row_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class PaymentDetailsTabViewWidget extends StatelessWidget {
  const PaymentDetailsTabViewWidget({
    super.key,
    this.controller,
  });

  final AppointmentDetailsController? controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380.h,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            24.verticalSpace,
            BodyTextOne(
              text: "Appointment",
              fontWeight: FontWeight.w700,
            ),
            24.verticalSpace,
            DetailLabelRowWidget(
              title: "Date",
              value: controller?.appointmentDate ?? "N/A",
            ),
            16.verticalSpace,
            Divider(
              color: AppColors.offWhite,
            ),
            16.verticalSpace,
            DetailLabelRowWidget(
              title: "Time",
              value: controller?.timeRange ?? controller?.appointmentTime ?? "N/A",
            ),
            16.verticalSpace,
            Divider(
              color: AppColors.offWhite,
            ),
            16.verticalSpace,
            DetailLabelRowWidget(
              title: "Type",
              value: controller?.appointmentType ?? "N/A",
            ),
            16.verticalSpace,
            Divider(
              color: AppColors.offWhite,
            ),
            16.verticalSpace,
            DetailLabelRowWidget(
              title: "Consultation Type",
              value: controller?.consultationType ?? "N/A",
            ),
            32.verticalSpace,
            BodyTextOne(
              text: "Payment Summary",
              fontWeight: FontWeight.w700,
            ),
            24.verticalSpace,
            DetailLabelRowWidget(
              title: "Total Fee",
              value: "\$${(controller?.totalFee ?? 0.0).toStringAsFixed(2)}",
            ),
            16.verticalSpace,
            Divider(
              color: AppColors.offWhite,
            ),
            16.verticalSpace,
            DetailLabelRowWidget(
              title: "Platform Fee",
              value: "\$${(controller?.platformFee ?? 0.0).toStringAsFixed(2)}",
            ),
            16.verticalSpace,
            Divider(
              color: AppColors.offWhite,
            ),
            16.verticalSpace,
            DetailLabelRowWidget(
              title: "Doctor's Fee",
              value: "\$${(controller?.doctorFee ?? 0.0).toStringAsFixed(2)}",
            ),
            16.verticalSpace,
            Divider(
              color: AppColors.offWhite,
            ),
            16.verticalSpace,
            DetailLabelRowWidget(
              title: "Payment Method",
              value: controller?.paymentMethod ?? "N/A",
            ),
            32.verticalSpace,
          ],
        ),
      ),
    );
  }
}