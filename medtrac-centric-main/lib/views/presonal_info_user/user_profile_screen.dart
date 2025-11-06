import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/user/user_profile_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_tab_bar.dart';

class UserProfileScreen extends GetView<UserProfileController> {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Profile",
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTabBar(
                        tabs: ["Basic Info", "Medical History"],
                        currentIndex: RxInt(0),
                        onTabChanged: (index) =>
                            controller.onTabChanged(index)),
                    32.verticalSpace,
                    Obx(() {
                      return controller.tabs[controller.currentIndex.value];
                    }),
                    32.verticalSpace,
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.r),
              child: Obx(() => CustomElevatedButton(
                text: 'Update',
                isLoading: controller.isLoading.value,
                onPressed: () {
                  if (!controller.isLoading.value) {
                    controller.updateProfile();
                  }
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}
