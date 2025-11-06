
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomAppBarIcon extends StatelessWidget {
  final String iconPath;
  final Function() onTap;
  final double scale;
  const CustomAppBarIcon({
    super.key,
    required this.iconPath,
    required this.onTap,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46.w,
        height: 46.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Image.asset(
          iconPath,
          scale: scale,
        ),
      ),
    );
  }
}