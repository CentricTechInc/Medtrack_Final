import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/tag_wrap.dart';
import 'package:medtrac/utils/app_colors.dart';

class PatientsHistoryWidget extends StatelessWidget {
  final List<String> primaryConcernTags;
  final List<String> medicationTags;
  final String patientHistory;
  const PatientsHistoryWidget({
    super.key,
    required this.primaryConcernTags,
    required this.patientHistory,
    required this.medicationTags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: "Patient's History",
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
          8.verticalSpace,
          BodyTextOne(
            text: patientHistory.isNotEmpty
                ? patientHistory
                : "No patient history available",
            color: AppColors.lightGreyText,
          ),
          10.verticalSpace,
          CustomText(
            text: "Primary Concern",
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
          4.verticalSpace,
          TagWrap(
            tags: primaryConcernTags,
          ),
          10.verticalSpace,
          CustomText(
            text: "Medication",
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
          4.verticalSpace,
          TagWrap(tags: medicationTags),
        ],
      ),
    );
  }
}
