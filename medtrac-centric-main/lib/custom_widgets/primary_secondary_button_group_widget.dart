import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';

class PrimarySecondaryButtonGroup extends StatelessWidget {
  final String? primaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;
  final Color? secondaryButtonTextColor;

  const PrimarySecondaryButtonGroup({
    super.key,
    this.primaryButtonText,
    this.onPrimaryButtonPressed,
    this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    this.secondaryButtonTextColor,
  });

  @override
  Widget build(BuildContext context) {
    if (primaryButtonText != null &&
        onPrimaryButtonPressed != null &&
        secondaryButtonText != null &&
        onSecondaryButtonPressed != null) {
      // Both buttons provided — show in Row
      return Row(
        children: [
          Expanded(
            child: CustomOutlineButton(
              text: secondaryButtonText!,
              onPressed: onSecondaryButtonPressed!,
              color: AppColors.dark,
              buttonTextColor: secondaryButtonTextColor,
              height: 56.h,
            ),
          ),
          12.w.horizontalSpace,
          Expanded(
            child: CustomElevatedButton(
              text: primaryButtonText!,
              onPressed: onPrimaryButtonPressed!,
              isSecondary: true,
              height: 56.h,
            ),
          ),
        ],
      );
    } else {
      // Show buttons vertically if only one provided
      return Column(
        children: [
          if (secondaryButtonText != null && onSecondaryButtonPressed != null)
            CustomOutlineButton(
              text: secondaryButtonText!,
              onPressed: onSecondaryButtonPressed!,
              buttonTextColor: secondaryButtonTextColor,
              height: 56.h,
            ),
          if (primaryButtonText != null && onPrimaryButtonPressed != null)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: CustomElevatedButton(
                text: primaryButtonText!,
                onPressed: onPrimaryButtonPressed!,
                isSecondary: true,
                height: 56.h,
              ),
            ),
        ],
      );
    }
  }
}
