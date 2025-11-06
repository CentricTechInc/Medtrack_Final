import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(),
            Image.asset(
              Assets.landingPage,
              scale: 2,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HeadingTextOne(
                  text: 'Virtual Health & \nPrescriptions',
                  textAlign: TextAlign.center,
                  color: AppColors.bright,
                ),
                16.verticalSpace,
                BodyTextOne(
                  text: 'Find best doctor for your best \nhealthcare routine',
                  textAlign: TextAlign.center,
                  color: AppColors.bright,
                ),
                16.verticalSpace,
                _buttonWidget(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container _buttonWidget(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75, // 80% of screen width
      height: 56.h, // Using ScreenUtil for responsive height
      decoration: BoxDecoration(
        color: Colors.black, // Button color
        borderRadius: BorderRadius.circular(16), // Border radius (16px)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: () {
              Get.offNamed(
                  AppRoutes.roleSelectionScreen); // Navigate to register screen
            },
            child: ButtonText(
              text: 'Register',
              color: AppColors.bright,
            ),
          ),
          Container(
            width: 1.w,
            height: 20.h,
            color: Colors.white, // Divider between buttons
          ),
          TextButton(
            onPressed: () {
              Get.offNamed(
                  AppRoutes.loginScreen);
            },
            child: ButtonText(
              text: 'Sign in',
              color: AppColors.bright,
            ),
          ),
        ],
      ),
    );
  }
}
