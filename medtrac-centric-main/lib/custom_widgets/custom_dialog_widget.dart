import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/primary_secondary_button_group_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomSuccessDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final Color? primaryButtonTextColor;
  final Color? secondaryButtonTextColor;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final Widget? image; // Optional image or image

  const CustomSuccessDialog({
    super.key,
    required this.title,
    this.message,
    this.primaryButtonText,
    this.onPrimaryButtonPressed,
    this.onSecondaryButtonPressed,
    this.secondaryButtonText,
    this.image,
    this.primaryButtonTextColor,
    this.secondaryButtonTextColor
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      backgroundColor: AppColors.bright,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // image or Image at the Top
            if (image != null) ...[
              image!,
              24.h.verticalSpace,
            ],

            // Title Text
            HeadingTextTwo(
              text: title,
              textAlign: TextAlign.center,
            ),
            8.h.verticalSpace,
            // Message Text
            if (message != null)
              BodyTextOne(
                text: message!,
                textAlign: TextAlign.center,
              ),
            16.h.verticalSpace,

            PrimarySecondaryButtonGroup(
              primaryButtonText: primaryButtonText,
              onPrimaryButtonPressed: onPrimaryButtonPressed,
              secondaryButtonText: secondaryButtonText,
              onSecondaryButtonPressed: onSecondaryButtonPressed,
              secondaryButtonTextColor: secondaryButtonTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
