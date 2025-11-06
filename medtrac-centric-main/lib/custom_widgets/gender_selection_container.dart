import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class GenderSelectionContainer extends StatelessWidget {
  final String gender;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const GenderSelectionContainer({
    super.key,
    required this.gender,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.bright,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderGrey,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                icon,
                color: isSelected ? AppColors.primary : AppColors.secondary,
              ),
            ),
            16.verticalSpace,
            BodyTextOne(
              text: gender,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : AppColors.darkGrey,
            ),
          ],
        ),
      ),
    );
  }
}
