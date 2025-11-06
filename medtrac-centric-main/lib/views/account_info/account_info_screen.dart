import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/account_info_controller.dart';
import 'package:medtrac/controllers/home_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/masked_account_info_tile.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/views/Home/widgets/info_bottom_sheet.dart';

class AccountInfoScreen extends GetView<AccountInfoController> {
  const AccountInfoScreen({super.key});

  // Method to show the complete profile bottom sheet
  void showCompleteProfileBottomSheet(BuildContext context) {
    final user = SharedPrefsService.getUserInfo;
    Get.bottomSheet(
      InfoBottomSheet(
        heading: "Welcome, Dr. ${user.name.split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' : '').join(' ')}",
        description:
            "Your profile and bank account have been successfully set up. You're now ready to receive appointments and payouts.",
        imageAsset: Assets.tickIcon,
      ),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(AppRoutes.mainScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool fromRegisteration = Get.arguments != null
        ? Get.arguments["fromRegisteration"] ?? false
        : false;
    return Scaffold(
      appBar: CustomAppBar(
        title: "Account Info",
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    44.verticalSpace,
                    Obx(
                      () {
                        if (controller.isLoadingAccounts.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Show friendly message when there are no accounts
                        if (controller.apiBankAccounts.isEmpty) {
                          return Align(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 8.h),
                                Icon(
                                  Icons.account_balance,
                                  size: 48.sp,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  "You don't have any accounts added.",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Add a bank account to receive payouts.",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: List.generate(
                            controller.apiBankAccounts.length,
                            (index) => Padding(
                                padding: EdgeInsets.only(bottom: 16.h),
                                child: MaskedAccountInfoTileWdiget(
                                  account: controller.apiBankAccounts[index],
                                  index: index,
                                )),
                          ),
                        );
                      },
                    ),
                    16.verticalSpace,
                    const Spacer(),
                    CustomElevatedButton(
                      onPressed: () =>
                          Get.toNamed(AppRoutes.addNewAccountScreen),
                      text: "Add Account",
                      isOutlined: true,
                    ),
                    16.verticalSpace,
                    Obx(
                      () {
                        return CustomElevatedButton(
                          onPressed: () {
                            // Check if disabled conditions
                            if (controller.apiBankAccounts.isEmpty || controller.isMarkingCurrent.value) {
                              return;
                            }
                            
                            final selectedAccountId = controller.getSelectedAccountId();
                            if (selectedAccountId != null) {
                              // Call mark current API
                              controller.markAccountAsCurrent(selectedAccountId, context).then((_) {

                                if (fromRegisteration) {
                                  showCompleteProfileBottomSheet(context);
                                } else {
                                  Get.back();
                                }
                              });
                            } else {
                              // Show error if no account is selected
                              Get.snackbar(
                                'Error',
                                'Please select an account to update',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                          text: controller.isMarkingCurrent.value ? "Updating..." : "Update",
                        );
                      },
                    ),
                    30.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
