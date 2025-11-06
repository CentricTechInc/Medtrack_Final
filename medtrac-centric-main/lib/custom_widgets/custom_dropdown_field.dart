import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomDropdownField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String?>? onChanged;
  final List<String> items;
  final String? value;
  final String? Function(String?)? validator;
  final bool hasBorder;
  final Color? iconColor;
  final Color? selectedItemColor;
  final Color? dropdownColor;
  final double? iconSize;
  final Widget? icon;
  final bool isOutlined;
  final double? iconPadding;
  final EdgeInsetsGeometry? buttonPadding;
  final bool readOnly;
  final FontWeight? fontWeight;
  final double? height;

  const CustomDropdownField(
      {super.key,
      required this.hintText,
      this.onChanged,
      required this.items,
      this.value,
      this.validator,
      this.hasBorder = true,
      this.iconColor,
      this.selectedItemColor,
      this.dropdownColor,
      this.iconSize,
      this.icon,
      this.isOutlined = true,
      this.iconPadding,
      this.buttonPadding,
      this.readOnly = false,
      this.fontWeight,
      this.height});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: readOnly,
      child: Container(
        height: height ?? (isOutlined ? 56.h : null),
        decoration: isOutlined
            ? BoxDecoration(
                color: AppColors.bright,
                borderRadius: BorderRadius.circular(12),
                border: hasBorder
                    ? Border.all(color: AppColors.greyBackgroundColor)
                    : null,
              )
            : null,
        child: ButtonTheme(
          alignedDropdown: !isOutlined,
          materialTapTargetSize:
              MaterialTapTargetSize.shrinkWrap, // Reduces the tap target size
          padding: EdgeInsets.zero,
          child: DropdownButtonFormField<String>(
            value: value,
            icon: Padding(
              padding:
                  EdgeInsets.only(left: iconPadding ?? (isOutlined ? 8.w : 0)),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: iconColor ??
                    (isOutlined ? AppColors.secondary : AppColors.primary),
                size: iconSize ?? (isOutlined ? 24.sp : 20.sp),
              ),
            ),
            iconSize: iconSize ?? (isOutlined ? 24.sp : 20.sp),
            elevation: 0,
            isDense: true,
            isExpanded: true,
            itemHeight: isOutlined ? kMinInteractiveDimension : null,
            dropdownColor: dropdownColor ?? AppColors.bright,
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: fontWeight,
                color: isOutlined ? AppColors.secondary : AppColors.primary),
            validator: validator,
            decoration: InputDecoration(
              filled: isOutlined,
              fillColor: isOutlined ? AppColors.bright : Colors.transparent,
              contentPadding: buttonPadding ??
                  (isOutlined
                      ? EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                      : EdgeInsets.zero),
              border: isOutlined
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    )
                  : InputBorder.none,
              enabledBorder: isOutlined
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    )
                  : InputBorder.none,
              focusedBorder: isOutlined
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    )
                  : InputBorder.none,
              errorBorder: isOutlined
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    )
                  : InputBorder.none,
              focusedErrorBorder: isOutlined
                  ? OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    )
                  : InputBorder.none,
              alignLabelWithHint: true,
            ),
            // Add hint here
            hint: Text(
              hintText,
              style: TextStyle(
                  fontSize: 16.sp,
                  color: isOutlined ? AppColors.dark : AppColors.primary),
            ),
            menuMaxHeight: 200.h,
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String itemValue) {
              final isSelected = value == itemValue;
              return DropdownMenuItem<String>(
                value: itemValue,
                child: Text(
                  itemValue,
                  style: TextStyle(
                    fontSize: isOutlined ? 16.sp : 14.sp,
                    color: isSelected || !isOutlined
                        ? (selectedItemColor ??
                            (isOutlined
                                ? AppColors.secondary
                                : AppColors.primary))
                        : AppColors.secondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
