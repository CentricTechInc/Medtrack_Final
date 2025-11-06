import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GeneralNotification extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final String imagePath;

  const GeneralNotification({
    super.key,
    required this.message,
    this.backgroundColor = const Color(0xFF0D0D15),
    this.textColor = Colors.white,
    this.imagePath = 'assets/icons/check.png',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white10,
            ),
            child: Image.asset(
              imagePath,
              width: 24.w,
              height: 24.w,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 16.w),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
