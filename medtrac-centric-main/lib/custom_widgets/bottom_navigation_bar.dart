import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/helper_functions.dart';

class BottomNavigation extends StatelessWidget {
  final BottomNavigationController controller;

  const BottomNavigation({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 4,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                iconPath: Assets.homeIcon,
                label: 'Home',
                index: 0,
                isSelected: controller.selectedNavIndex.value == 0,
              ),
              _buildNavItem(
                iconPath: Assets.appointmentsIcon,
                label: 'Appointments',
                index: 1,
                isSelected: controller.selectedNavIndex.value == 1,
              ),
              if (HelperFunctions.isUser())
                _buildNavItem(
                  iconPath: Assets.consultantIcon,
                  label: 'Consultant',
                  index: 2,
                  isSelected: controller.selectedNavIndex.value == 2,
                )
              else
                _buildNavItem(
                  iconPath: Assets.earningIcon,
                  label: 'Earning',
                  index: 2,
                  isSelected: controller.selectedNavIndex.value == 2,
                ),
              _buildNavItem(
                iconPath: Assets.chatIcon,
                label: 'Chat',
                index: 3,
                isSelected: controller.selectedNavIndex.value == 3,
              ),
            ],
      )),
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.onNavItemTapped(index),
      child: Container(
        padding:  EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        child: isSelected
            ? Container(
                padding:  EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      iconPath,
                      color: Colors.white,
                      width: 24.w,
                      height: 24.h,
                    ),
                    6.horizontalSpace,
                    Text(
                      label,
                      style:  TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : Image.asset(
                iconPath,
                color: isSelected ? AppColors.primary : AppColors.lightGreyText,
                width: 24.w,
                height: 24.h,
              ),
      ),
    );
  }
}