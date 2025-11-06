import 'package:flutter/material.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;
  final bool isFilled;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 28,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color fillColor = isFilled
        ? (value ? AppColors.primary : AppColors.bright)
        : AppColors.bright;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(
            color: value ? AppColors.primary : AppColors.primary,
            width: 2.2.w,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: value
            ? Center(
                child: Icon(
                  Icons.check,
                  size: size * 0.7,
                  color: isFilled ? AppColors.bright : AppColors.primary,
                ),
              )
            : null,
      ),
    );
  }
}
