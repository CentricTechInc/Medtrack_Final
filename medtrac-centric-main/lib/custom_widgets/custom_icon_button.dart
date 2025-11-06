import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomIconButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onPressed;
  final double scale;
  final double? height;
  final double? width;
  final Color backgroundColor;
  const CustomIconButton({
    super.key,
    required this.iconPath,
    required this.onPressed,
    this.scale = 2.0,
    this.height,
    this.width,
    this.backgroundColor = AppColors.lightGreyText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: height ?? 60.h,
        width: width ?? 60.w,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Image.asset(
          iconPath,
          scale: scale,
        ),
      ),
    );
  }
}
