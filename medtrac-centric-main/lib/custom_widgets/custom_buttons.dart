import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final bool isSecondary;
  final bool? elevation;
  final String? imagePath;
  final double? imageWidth;
  final double? imageHeight;
  final double imagePadding;
  final bool isOutlined;
  final double width;
  final double? height;
  final double? fontSize;
  final bool isLoading;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.isSecondary = false,
    this.elevation = false,
    this.imagePath,
    this.imageWidth,
    this.imageHeight,
    this.height,
    this.fontSize,
    this.imagePadding = 8.0,
    this.isOutlined = false,
    this.width = double.infinity,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor =
        isSecondary ? AppColors.secondary : AppColors.primary;

    return SizedBox(
      height: height ?? 56.h,
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : buttonColor,
          foregroundColor: isOutlined ? buttonColor : AppColors.bright,
          side: isOutlined ? BorderSide(color: buttonColor, width: 0.5) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: elevation! ? 2 : 0,
          padding: padding,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      isOutlined ? buttonColor : AppColors.bright),
                  strokeWidth: 2.5,
                ),
              )
            : imagePath != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        imagePath!,
                        width: imageWidth ?? 20,
                        height: imageHeight ?? 20,
                        color: isOutlined ? buttonColor : AppColors.bright,
                      ),
                      SizedBox(width: imagePadding),
                      ButtonText(
                        text: text,
                        fontSize: fontSize,
                        color: isOutlined ? buttonColor : AppColors.bright,
                      ),
                    ],
                  )
                : ButtonText(
                    text: text,
                    fontSize: fontSize,
                    color: isOutlined ? buttonColor : AppColors.bright,
                  ),
      ),
    );
  }
}

//================================================================================================

class CustomOutlineButton extends StatelessWidget {
  final String text; // Optional text for default usage
  final Widget? child; // Optional custom widget as child
  final VoidCallback onPressed;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double? height;
  final String? imagePath; // Path to the image asset
  final double? imageWidth; // Optional width for the image
  final double? imageHeight; // Optional height for the image
  final double imagePadding; // Space between image and text
  final Color? buttonTextColor;

  const CustomOutlineButton({
    super.key,
    required this.text, // Default text
    this.child, // Custom widget
    required this.onPressed,
    this.color = AppColors.primary, // Border and text color
    this.padding = const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    this.height,
    this.imagePath,
    this.imageWidth,
    this.imageHeight,
    this.imagePadding = 8.0,
    this.buttonTextColor
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 64.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Transparent background
          shadowColor: Colors.transparent, // Removes button shadow
          side: BorderSide(color: color, width: 0.5), // Border with color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          padding: padding,
        ),
        child: imagePath != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    imagePath!,
                    width: imageWidth ?? 20,
                    height: imageHeight ?? 20,
                  ),
                  SizedBox(width: imagePadding),
                  ButtonText(text: text),
                ],
              )
            : ButtonText(text: text , color: buttonTextColor,),
      ),
    );
  }
}

//================================================================================================

class CustomSkipButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;
  final double? fontSize;
  final BorderRadius? borderRadius;

  const CustomSkipButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.padding,
    this.height,
    this.width,
    this.fontSize,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = color ?? AppColors.primary;
    
    return SizedBox(
      height: height ?? 36.h,
      width: width ?? 96.w,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bright,
          foregroundColor: AppColors.bright,
          shadowColor: Colors.transparent,
          side: BorderSide(color: buttonColor.withValues(alpha: 0.3), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius!,
          ),
          padding: padding ?? EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonText(
              text: text,
              fontSize: fontSize ?? 14.sp,
              color: buttonColor,
            ),
            4.horizontalSpace,
            Icon(
              Icons.arrow_forward,
              color: buttonColor,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
