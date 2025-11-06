import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';

class NotificationReviewDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? image;

  const NotificationReviewDialog({
    super.key,
    required this.title, 
    required this.message,
    this.buttonText,
    this.onButtonPressed,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      backgroundColor: AppColors.bright,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image at the top
            if (image != null) ...[
              SizedBox(
                width: 180.w,
                height: 180.h,
                child: image,
              ),
              24.h.verticalSpace,
            ],

            // Title 
            HeadingTextTwo(
              text: title,
              textAlign: TextAlign.center,
            ),
            16.h.verticalSpace,
            
            // Message
            BodyTextOne(
              text: message,
              textAlign: TextAlign.center,
              color: AppColors.darkGreyText,
              lineHeight: 1.5,
            ),
            32.h.verticalSpace,

            // Button (optional)
            if (buttonText != null)
              CustomElevatedButton(
                text: buttonText!,
                onPressed: onButtonPressed ?? () => Get.back(),
              ),
          ],
        ),
      ),
    );
  }
}
