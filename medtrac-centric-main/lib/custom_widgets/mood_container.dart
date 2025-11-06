import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/enums.dart';

class MoodContainer extends StatelessWidget {
  final String label;
  final MoodType moodType;
  final double? width;

  const MoodContainer({
    super.key,
    required this.label,
    required this.moodType,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
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
            color: moodType.color,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: BodyTextOne(
            text: moodType.name,
            fontWeight: FontWeight.w700,
            color: AppColors.bright,
          ),
        ),
      ],
    );
  }
}
