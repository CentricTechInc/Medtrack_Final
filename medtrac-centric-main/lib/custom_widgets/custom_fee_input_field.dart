import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomFeeInputField extends StatelessWidget {
  final TextEditingController controller;
  final double height;
  final double width;
  final String? hintText;

  const CustomFeeInputField({
    super.key,
    required this.controller,
    this.height = 60,   // Default values
    this.width = 150,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8.h),
        Container(
          height: height.h,
          width: width.w,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.bright,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppColors.lightGrey,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.secondary,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.symmetric(vertical: 18.h),
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.lightGrey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
