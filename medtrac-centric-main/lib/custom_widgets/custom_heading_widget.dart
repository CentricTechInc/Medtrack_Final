import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomHeadingWidget extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String? subtitle;

  const CustomHeadingWidget({
    super.key,
    required this.onTap,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 12.0 , bottom: 0.0 , left: 8.0 , right: 8.0),
  color: Colors.transparent,
      child: Column(
        children: [
          30.verticalSpace,
          SizedBox(
            height: 40.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 1.w,
                  child: IconButton(onPressed: onTap, icon: Icon( Icons.arrow_back_ios_new , color: AppColors.dark,)),
                ),
                Center(
                  child: HeadingTextTwo(text: title),
                ),
              ],
            ),
          ),
          if (subtitle != null)
            Column(
              children: [
                8.verticalSpace,
                BodyTextTwo(text: subtitle!),
              ],
            ),
          30.verticalSpace,
        ],
      ),
    );
  }
}
