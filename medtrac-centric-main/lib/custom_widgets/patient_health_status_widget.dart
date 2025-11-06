import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/mood_container.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/enums.dart';

class PatientHealthStatusWidget extends StatelessWidget {
  final MoodType feeling;
  final SleepQuality sleepQuality;
  final StressLevel stressLevel;

  const PatientHealthStatusWidget({
    super.key,
    required this.feeling,
    required this.sleepQuality,
    required this.stressLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            text: "Patient's Health Status",
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.secondary,
          ),
          16.verticalSpace,
          MoodContainer(
            label: "Feeling",
            moodType: feeling,
          ),
          16.verticalSpace,
          _buildHealthStatusContainer("Sleep Quality", sleepQuality.name, sleepQuality.color),
          16.verticalSpace,
          _buildHealthStatusContainer("Stress Level", stressLevel.name, stressLevel.color),
        ],
      ),
    );
  }

  Widget _buildHealthStatusContainer(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "$label:",
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.secondary,
        ),
        8.verticalSpace,
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: BodyTextOne(
            text: value,
            fontWeight: FontWeight.w700,
            color: AppColors.bright,
          ),
        ),
      ],
    );
  }
}
