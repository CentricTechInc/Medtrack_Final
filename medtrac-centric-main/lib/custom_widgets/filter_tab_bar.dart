import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/utils/app_colors.dart';

class FilterTabBar extends StatelessWidget {
  final List<String> tabs;
  final RxString selectedTab;
  final Function(String) onTabChanged;
  final EdgeInsets? padding;
  final double? height;

  const FilterTabBar({
    super.key,
    required this.tabs,
    required this.selectedTab,
    required this.onTabChanged,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 50.h,
      padding: EdgeInsets.zero,
      width: MediaQuery.sizeOf(context).width - 20.w,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r), bottomLeft: Radius.circular(16.r)),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          return Obx(() {
            final isSelected = selectedTab.value == tab;
            return GestureDetector(
              onTap: () => onTabChanged(tab),
              child: Container(
                constraints: BoxConstraints(
                  minWidth: 78.w,
                  minHeight: 40.h,
                ),
                padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.darkGreyText,
                      fontSize: 14.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
