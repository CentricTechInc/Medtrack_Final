import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_checkbox.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class MentalHealthGoalContainer extends StatelessWidget {
  final String iconPath;
  final String goalText;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;

  const MentalHealthGoalContainer({
    super.key,
    required this.iconPath,
    required this.goalText,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelectionChanged(!isSelected),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.bright,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderGrey,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  iconPath,
                  width: 24.w,
                  height: 24.h,
                  color: AppColors.primary,
                ),
                12.horizontalSpace,
                BodyTextOne(
                  text: goalText,
                  color: AppColors.secondary,
                ),
              ],
            ),
            CustomCheckbox(
              value: isSelected,
              isFilled: true,
              onChanged: onSelectionChanged,
            ),
          ],
        ),
      ),
    );
  }
}
