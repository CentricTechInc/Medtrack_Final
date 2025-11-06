import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomReviewTile extends StatelessWidget {
  final VoidCallback? onTap;
  final String name;
  final String imagePath;
  final String time;
  final String rating;

  const CustomReviewTile({
    super.key,
    this.onTap,
    required this.name,
    required this.imagePath,
    required this.time,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 285.w,
        height: 150.w,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.bright,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                8.horizontalSpace,
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BodyTextOne(
                              text: name,
                              fontWeight: FontWeight.w900,
                            ),
                            BodyTextTwo(
                              text: time,
                              color: AppColors.lightGreyText,
                              fontWeight: FontWeight.w900,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          BodyTextTwo(
                            text: rating,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                          4.horizontalSpace,
                          Icon(Icons.star, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            8.verticalSpace,
            Expanded(
              child: BodyTextTwo(
                text:
                    "Really good doctor! I love how he checks and his diet chart is awesome, He is perfect for depressed patient.",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
