import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class TagWrap extends StatelessWidget {
  final List<String> tags;
  const TagWrap({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: tags.map((tag) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: CustomText(
          fontSize: 14.sp,
          text: tag,
          color: AppColors.secondary,
        ),
      )).toList(),
    );
  }
}
