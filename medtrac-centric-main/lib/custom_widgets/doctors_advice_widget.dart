import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/controllers/appointment_summary_controller.dart';
import 'package:medtrac/custom_widgets/custom_checkbox.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class DoctorsAdviceWidget extends StatelessWidget {
  const DoctorsAdviceWidget({
    super.key,
    required this.controller,
  });

  final AppointmentSummaryController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "Doctor's Advice",
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
          16.verticalSpace,
          ...controller.dynamicDoctorAdviceList.map(
            (advice) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  CustomCheckbox(
                    value: true,
                    onChanged: (val) {},
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: CustomText(
                      text: advice,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
