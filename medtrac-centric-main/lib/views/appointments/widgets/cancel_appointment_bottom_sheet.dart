import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';

class CancelAppointmentBottomSheet extends StatelessWidget {
  final String doctorName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CancelAppointmentBottomSheet({
    super.key,
    required this.doctorName,
    required this.onConfirm,
    required this.onCancel,
  });

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
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.cancel_outlined,
              size: 56.w,
              color: Colors.red,
            ),
          ),
          24.verticalSpace,
          HeadingTextTwo(
            text: "Cancel Appointment?",
            textAlign: TextAlign.center,
          ),
          12.verticalSpace,
          BodyTextOne(
            text: "Are you sure you want to cancel your appointment with $doctorName?",
            textAlign: TextAlign.center,
            color: AppColors.darkGreyText,
          ),
          32.verticalSpace,
          Row(
            children: [
              Expanded(
                child: CustomElevatedButton(
                  text: "No, Keep It",
                  onPressed: onCancel,
                  isOutlined: true,
                ),
              ),
              16.horizontalSpace,
              Expanded(
                child: SizedBox(
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: BodyTextOne(
                      text: "Yes, Cancel",
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          16.verticalSpace,
          BodyTextOne(
            text: "Note: Cancellation may be subject to fees based on timing",
            textAlign: TextAlign.center,
            color: AppColors.lightGreyText,
            fontSize: 12.sp,
          ),
        ],
      ),
    );
  }
}
