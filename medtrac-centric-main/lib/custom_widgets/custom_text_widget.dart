import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/utils/app_colors.dart';

// //=================================HEADINGS=======================================================
class HeadingTextOne extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final TextOverflow? overflow;

  const HeadingTextOne({
    super.key,
    required this.text,
    this.textAlign,
    this.color,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      style: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.secondary,
      ),
    );
  }
}

class HeadingTextTwo extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final TextOverflow? overflow;
  final double? fontSize;
  final FontWeight? fontWeight;

  const HeadingTextTwo({
    super.key,
    required this.text,
    this.textAlign,
    this.color,
    this.overflow,
    this.fontSize,
    this.fontWeight

  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize ?? 24.sp,
        fontWeight: fontWeight ?? FontWeight.w800,
        color: color ?? AppColors.secondary,
      ),
    );
  }
}



//===================================BODY TEXTS=============================================================

class BodyTextOne extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;
  final double? lineHeight;
  final double? fontSize;

  const BodyTextOne({
    super.key,
    required this.text,
    this.textAlign,
    this.color,
    this.overflow,
    this.fontWeight = FontWeight.w500,
    this.lineHeight,
    this.fontSize
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize ?? 16.sp, 
        fontWeight: fontWeight,
        height: lineHeight,
        color: color ?? AppColors.secondary,
      ),
    );
  }
}

class BodyTextTwo extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const BodyTextTwo({
    super.key,
    required this.text,
    this.textAlign,
    this.color,
    this.overflow,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      style: TextStyle(
        fontSize: 14.sp, // Responsive font size
        fontWeight: fontWeight,
        color: color ?? AppColors.secondary, // Default white
      ),
    );
  }
}

// =================================BUTTON TEXT======================================================

class ButtonText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final TextOverflow? overflow;
  final double? fontSize;

  const ButtonText({
    super.key,
    required this.text,
    this.textAlign,
    this.color,
    this.overflow,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize ?? 18.sp,
        fontWeight: FontWeight.w700, // Bold weight
        color: color ?? AppColors.bright, // Default white
      ),
    );
  }
}

//================================================================================================
// CUSTOM HEADING AND BODY
//================================================================================================

class CustomText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final TextOverflow? overflow;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomText({
    super.key,
    required this.text,
    this.textAlign,
    this.color,
    this.overflow,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize ?? 32.sp,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: color ?? AppColors.secondary,
        overflow: overflow ?? TextOverflow.ellipsis,
      ),
    );
  }
}
