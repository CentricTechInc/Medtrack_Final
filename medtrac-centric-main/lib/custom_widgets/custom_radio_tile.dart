import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomRadioTile extends StatelessWidget {
  final Widget title;
  final bool isSelected;
  final Function() onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? selectedColor;
  final BorderRadius? borderRadius;
  final Border? border;

  const CustomRadioTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.padding,
    this.backgroundColor,
    this.selectedColor,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.bright,
          borderRadius: borderRadius ?? BorderRadius.circular(12.r),
          border: border ?? Border.all(
            color: isSelected 
                ? (selectedColor ?? AppColors.primary)
                : AppColors.borderGrey,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: title),
            12.horizontalSpace,
            _buildRadioButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton() {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? (selectedColor ?? AppColors.primary) : AppColors.lightGrey3,
          width: 2.0,
        ),
        color: AppColors.bright,
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selectedColor ?? AppColors.primary,
                ),
              ),
            )
          : null,
    );
  }
}
