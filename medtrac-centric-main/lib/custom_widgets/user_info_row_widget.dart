import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/helper_functions.dart';

class UserInfoRowWidget extends StatelessWidget {
  const UserInfoRowWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return HelperFunctions.isUser()
        ? Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.bright,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    image: DecorationImage(
                      image: AssetImage(Assets.vermaImage2),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                8.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyTextOne(
                        text: "Dr. Karan Verma",
                        fontWeight: FontWeight.bold,
                      ),
                      CustomText(
                        text: "MBBS, M.D (Psychiatry)",
                        fontSize: 12.sp,
                        color: AppColors.darkGreyText,
                      ),
                      Divider(
                        color: AppColors.offWhite,
                      ),
                      BodyTextTwo(
                        text: "Psychiatrist - Family Medicine",
                        color: AppColors.darkGreyText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.bright,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    image: DecorationImage(
                      image: AssetImage('assets/images/arjun.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                8.horizontalSpace,
                HeadingTextTwo(
                  text: "Arjun Sharma",
                ),
              ],
            ),
          );
  }
}
