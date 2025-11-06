import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/constants.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title:  "About Us",),
      body: Column(
        children: [
          20.verticalSpace,
          
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Image.asset(
                    Assets.logo,
                    color: AppColors.primary,
                    scale: 0.5,
                    width: 0.6.sw,
                  ),
                  20.verticalSpace,
                  Text(aboutUsContent , style: TextStyle(color: AppColors.dark),),
                  20.verticalSpace,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
