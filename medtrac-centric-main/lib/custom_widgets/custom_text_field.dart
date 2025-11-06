import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextStyle? textStyle;
  final bool obscureText;
  final Widget? suffixIcon;
  final IconData? prefixIcon; // New Prefix Icon
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onToggleVisibility;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged; // onChanged callback for search
  final bool hasBorder; // New border option
  final ValueChanged<String?>? onSubmitted;
  final int? maxLines;
  final Color fillColor;
  final double? borderRadius; // New border radius property
  final Color? hintTextColor;
  final  bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final TextStyle? hintTextStyle;
  

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textStyle,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onToggleVisibility,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.validator,
    this.onChanged,
    this.hasBorder = true,
    this.onSubmitted, // Default: No Border
    this.maxLines = 1,
    this.fillColor = AppColors.bright,
    this.borderRadius,
    this.hintTextColor,
    this.readOnly = false,
    this.inputFormatters, this.hintTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: inputFormatters,
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      obscureText: isPassword && !isPasswordVisible,
      cursorColor: AppColors.darkGreyText,
      style: textStyle ?? TextStyle(fontSize: 16.sp, color: AppColors.dark),
      validator: validator,
      onChanged: onChanged, // Calls function on user input
      onFieldSubmitted: onSubmitted,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintTextStyle ?? TextStyle(fontSize: 16.sp, color: hintTextColor ?? AppColors.dark),
        filled: true,
        fillColor: fillColor, 
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColors.lightGreyText)
            : null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.lightGreyText,
                ),
                onPressed: onToggleVisibility,
              )
            : suffixIcon,
        border: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
                borderSide: const BorderSide(color: AppColors.borderGrey),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
                borderSide: BorderSide.none,
              ),
        enabledBorder: hasBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
                borderSide: const BorderSide(color: AppColors.borderGrey),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
                borderSide: BorderSide.none,
              ),
       focusedBorder: hasBorder
    ? OutlineInputBorder(
        borderSide: BorderSide(
          color: readOnly ? AppColors.borderGrey : AppColors.primary,
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
      )
    : OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
        borderSide: BorderSide(
          color: readOnly ? AppColors.borderGrey : Colors.transparent,
        ),
      ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        alignLabelWithHint: true,
      ),
      // Adjusting font size for obscured text
      obscuringCharacter:
          '*', // You can change this if you want a different character
      textAlign: TextAlign.start,
    );
  }
}
