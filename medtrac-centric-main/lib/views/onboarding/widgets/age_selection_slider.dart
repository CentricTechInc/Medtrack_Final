import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/basic_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class AgeSelectionSlider extends GetView<BasicInfoController> {
  const AgeSelectionSlider({super.key});

  @override
  Widget build(BuildContext context) {
    // Age range
    const int minAge = 10;
    const int maxAge = 100;

    final ageList =
        List.generate(maxAge - minAge + 1, (index) => minAge + index);
    final scrollController = FixedExtentScrollController(
      initialItem: controller.selectedAge.value - minAge,
    );

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderGrey,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: BodyTextOne(
              text: "Age",
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          8.verticalSpace,

          SizedBox(
            height: 100.h,
            width: double.infinity, // Take full width
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Black container behind selected age
                Positioned(
                  top: (100.h - 60.h) / 2, // Center vertically
                  left: (MediaQuery.of(context).size.width - 144.w) /
                      2, // Center horizontally
                  child: Container(
                    width: 90.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                // Rotated CupertinoPicker
                SizedBox(
                  width: double.infinity,
                  height: 80.h,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: CupertinoPicker(
                      scrollController: scrollController,
                      itemExtent: 90.0,
                      diameterRatio: 1.8,
                      magnification: 1.7,
                      squeeze: 1,
                      useMagnifier: true,
                      onSelectedItemChanged: (index) {
                        controller.setSelectedAge(ageList[index]);
                      },
                      selectionOverlay: Container(
                        color: Colors.transparent,
                      ),
                      children: ageList.map((age) {
                        return Obx(() {
                          return RotatedBox(
                            quarterTurns: 1,
                            child: Center(
                              child: CustomText(
                                text: age.toString(),
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                                color: controller.selectedAge.value == age
                                    ? AppColors.bright
                                    : AppColors.secondary,
                              ),
                            ),
                          );
                        }
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          16.verticalSpace,
          Align(child: Image.asset(Assets.arrowUpIcon)),
        ],
      ),
    );
  }
}
