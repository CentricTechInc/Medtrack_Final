import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart'; // <-- for BodyTextOne/Two

class NotificationTile extends StatelessWidget {
  final String iconPath;
  final String title;
  final String body;
  final String timeAgo;
  final bool isRead;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.iconPath,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = true, // Default to read
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isRead ? Colors.white : const Color(0xFFEEF0F2), // Unread: #EEF0F2, Read: white
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: .1),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                height: 40.h,
                width: 40.h,
                decoration: BoxDecoration(
                  color: AppColors.bright,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Image.asset(
                    iconPath,
                    height: 40.h,
                    width: 40.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              12.horizontalSpace,
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyTextOne(
                      text: title,
                      fontWeight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.verticalSpace,
                    BodyTextTwo(
                      text: body,
                    ),
                  ],
                ),
              ),

              Text(
                timeAgo,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.secondary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
