import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomDropdownButtonFormField<T> extends StatelessWidget {
  final String hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;
  final bool hasBorder;
  final Color fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Widget? prefixIcon;
  final Color iconColor;
  final Color dropdownColor;

  const CustomDropdownButtonFormField({
    super.key,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.hasBorder = true,
    this.fillColor = AppColors.bright,
    this.contentPadding,
    this.hintStyle,
    this.textStyle,
    this.prefixIcon,
    this.iconColor = AppColors.darkGreyText,
    this.dropdownColor = AppColors.scaffoldBackground,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle ??
            TextStyle(fontSize: 16.sp, color: AppColors.lightGreyText),
        filled: true,
        fillColor: fillColor,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: prefixIcon,
        border: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderGrey),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
        enabledBorder: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderGrey),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
        focusedBorder: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      isExpanded: true,
      icon: Icon(Icons.keyboard_arrow_down, color: iconColor),
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      dropdownColor: dropdownColor,
      style: textStyle ??
          TextStyle(fontSize: 16.sp, color: AppColors.darkGreyText),
    );
  }
}