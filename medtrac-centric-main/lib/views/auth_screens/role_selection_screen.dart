import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/enums.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  Future<void> _selectRole(Role selectedRole) async {
    try {
      await SharedPrefsService.setRole(selectedRole.name.toLowerCase());
      log('Role saved: ${selectedRole.name}');
      Get.toNamed(AppRoutes.signupScreen);
    } catch (e) {
      log('Error saving role: $e');
      Get.toNamed(AppRoutes.signupScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HeadingTextOne(
                    text: 'Choose your role',
                    textAlign: TextAlign.center,
                  ),
                  16.verticalSpace,
                  BodyTextOne(
                    text:
                        "'User' for general use, 'Practitioner' for\nprofessional features.",
                    textAlign: TextAlign.center,
                  ),
                  16.verticalSpace,
                ],
              ),
              GestureDetector(
                onTap: () => _selectRole(Role.user),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.userAvatar,
                      scale: 2,
                    ),
                    8.verticalSpace,
                    HeadingTextOne(text: 'User', textAlign: TextAlign.center),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _selectRole(Role.practitioner),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Assets.practitionerAvatar,
                      scale: 2,
                    ),
                    8.verticalSpace,
                    HeadingTextOne(
                        text: 'Practitioner', textAlign: TextAlign.center),
                  ],
                ),
              ),
              40.verticalSpace
            ],
          ),
        ),
      ),
    );
  }
}
