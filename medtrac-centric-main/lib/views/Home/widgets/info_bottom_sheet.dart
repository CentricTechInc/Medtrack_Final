import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/primary_secondary_button_group_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class InfoBottomSheet extends StatelessWidget {
  final String heading;
  final String description;
  final String imageAsset;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final Color? primaryButtonBgColor;
  final Color? secondaryButtonBgColor;
  final Color? primaryButtonTextColor;
  final Color? secondaryButtonTextColor;
  final bool havePrimaryAndSecondartButtons;

  const InfoBottomSheet(
      {super.key,
      required this.heading,
      required this.description,
      required this.imageAsset,
      this.primaryButtonText,
      this.secondaryButtonText,
      this.onPrimaryButtonPressed,
      this.onSecondaryButtonPressed,
      this.primaryButtonBgColor = AppColors.secondary,
      this.secondaryButtonBgColor = AppColors.bright,
      this.primaryButtonTextColor = AppColors.bright,
      this.secondaryButtonTextColor = AppColors.secondary,
      this.havePrimaryAndSecondartButtons = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Image.asset(
              imageAsset,
              width: 100.w,
              height: 100.w,
            ),
          ),
          24.verticalSpace,
          HeadingTextTwo(
            text: heading,
            textAlign: TextAlign.center,
          ),
          12.verticalSpace,
          BodyTextOne(
            text: description,
            textAlign: TextAlign.center,
            color: AppColors.darkGreyText,
          ),
          if (havePrimaryAndSecondartButtons) ...[
            24.verticalSpace,
            PrimarySecondaryButtonGroup(
              secondaryButtonTextColor: secondaryButtonTextColor,
              primaryButtonText: primaryButtonText,
              onPrimaryButtonPressed: () {
                Get.back();
                if (onPrimaryButtonPressed != null){
                  onPrimaryButtonPressed!();
                }
              },
              secondaryButtonText: secondaryButtonText,
              onSecondaryButtonPressed: () {
                Get.back();
                if (onSecondaryButtonPressed != null) {
                  onSecondaryButtonPressed!();
                }
              },
            ),
          ] else if (onPrimaryButtonPressed != null &&
              !havePrimaryAndSecondartButtons) ...[
            18.verticalSpace,
            CustomElevatedButton(
              text: primaryButtonText!,
              onPressed: () {
                Get.back();

                onPrimaryButtonPressed!();
              },
              isSecondary: true,
            ),
          ],
        ],
      ),
    );
  }
}
