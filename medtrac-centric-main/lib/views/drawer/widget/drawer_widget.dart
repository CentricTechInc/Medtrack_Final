import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/app_bar_contoller.dart';
import 'package:medtrac/controllers/appointments_controller.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';
import 'package:medtrac/controllers/drawer_controller.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/constants.dart';
import 'package:medtrac/utils/helper_functions.dart';

import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/services/state_manager.dart';
import 'package:medtrac/views/Home/widgets/info_bottom_sheet.dart';
import 'package:medtrac/views/drawer/widget/drawer_item_widget.dart';
import 'package:medtrac/api/services/doctor_service.dart';

class DrawerWidget extends GetWidget<AppBarContoller> {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent, // Let the background show through
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: drawerItemsTitle.length, // Use the list count, not the map
              itemBuilder: (context, index) {
                final title = drawerItemsTitle[index];
                return DrawerItem(
                    title: title,
                    onTap: () {
                      final isProfileComplete = SharedPrefsService.isProfileComplete();
                      if (!isProfileComplete &&
                          title != 'Profile' &&
                          title != 'Logout') {
                        HelperFunctions.showIncompleteProfileBottomSheet(
                          isReview: HelperFunctions.isPractitionerUnderReview(),
                        );
                        return;
                      } else if (title == 'Delete Account') {
                        // Close drawer first
                        Get.find<CustomDrawerController>().closeDrawer();
                        // Show bottom sheet after drawer closes
                        Future.delayed(const Duration(milliseconds: 200), () {
                          Get.bottomSheet(
                            InfoBottomSheet(
                              havePrimaryAndSecondartButtons: true,
                              imageAsset: Assets.delete,
                              heading: 'Delete Account?',
                              description:
                                  'Are you sure you want to delete your account? This action cannot be undone.',
                              secondaryButtonText: 'Delete',
                              secondaryButtonTextColor: AppColors.dark,
                              onSecondaryButtonPressed: () async {
                                Get.back(); // Close the bottom sheet
                                HelperFunctions.showIndismissableLoader(context);
                                try {
                                  final doctorService = Get.put(DoctorService());
                                  final response = await doctorService.deleteDoctorAccount();
                                  Get.back(); // Close loader
                                  if (response.success) {
                                    SnackbarUtils.showSuccess("Account deleted successfully");
                                    await StateManager.resetAppState();
                                    await SharedPrefsService.clearAll();
                                    Get.find<BottomNavigationController>().selectedNavIndex.value = 0;
                                    Get.find<AppointmentsController>().currentIndex.value = 0;
                                    Get.find<AppointmentsController>().tabController.animateTo(0);
                                    Get.find<CustomDrawerController>().isDrawerOpen.value = false;
                                    Get.offAllNamed(AppRoutes.loginScreen);
                                  } else {
                                    SnackbarUtils.showError(response.message ?? "Failed to delete account");
                                  }
                                } catch (e) {
                                  Get.back(); // Close loader
                                  SnackbarUtils.showError("Failed to delete account: ${e.toString()}");
                                }
                              },
                              primaryButtonText: 'Cancel',
                              onPrimaryButtonPressed: () {
                                Get.back();
                              },
                            ),
                          );
                        });
                      } else if (title == 'Logout') {
                        Future.delayed(const Duration(milliseconds: 200), () {
                          Get.bottomSheet(
                          InfoBottomSheet(
                            imageAsset: Assets.logout,
                            heading: 'Logout',
                            description:
                                'Are you sure you want to logout your account?',
                            havePrimaryAndSecondartButtons: true,
                            secondaryButtonText: 'Logout',
                            secondaryButtonTextColor: AppColors.dark,
                            onSecondaryButtonPressed: () async {
                              HelperFunctions.showIndismissableLoader(context);
                              
                              // Reset app state before clearing storage
                              await StateManager.resetAppState();
                              
                              // Clear shared preferences
                              await SharedPrefsService.clearAll();
                              
                              Get.back(); // Close the loader
                              Get.find<CustomDrawerController>().isDrawerOpen.value = false;
                              Get.offAllNamed(AppRoutes.loginScreen);
                              SnackbarUtils.showSuccess("Logged out successfully");
                            },
                            primaryButtonText: 'Cancel',
                            onPrimaryButtonPressed: () {
                              Get.back();
                            },
                          ));
                        });
                      } else {
                        // Close the custom drawer first
                        Get.find<CustomDrawerController>().closeDrawer();
                        // Then navigate after a small delay to ensure drawer closes
                        Future.delayed(const Duration(milliseconds: 100), () {
                          final route = drawerRoutes[title];
                          print('Navigating to: $title -> $route'); // Debug log
                          if (route != null) {
                            Get.toNamed(
                              route,
                              arguments: {"fromRegisteration": false},
                            );
                          } else {
                            print('Route not found for: $title'); // Debug log
                          }
                        });
                      }
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}

final Widget deleteImageWiddget = Padding(
  padding: EdgeInsets.only(top: 24.h),
  child: Image.asset(
    Assets.delete,
    width: 80.w,
    height: 80.h,
  ),
);

final Widget logoutImageWidget = Padding(
  padding: EdgeInsets.only(top: 24.h),
  child: Image.asset(
    Assets.logout,
    width: 80.w,
    height: 80.h,
  ),
);
