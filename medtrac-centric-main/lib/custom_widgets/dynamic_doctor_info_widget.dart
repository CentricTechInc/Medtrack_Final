import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class DynamicDoctorInfoWidget extends StatelessWidget {
  final String doctorName;
  final String doctorImage;
  final String doctorQualifications;
  final String doctorSpeciality;

  const DynamicDoctorInfoWidget({
    super.key,
    required this.doctorName,
    required this.doctorImage,
    required this.doctorQualifications,
    required this.doctorSpeciality,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              image: doctorImage.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(doctorImage),
                      fit: BoxFit.cover,
                    )
                  : DecorationImage(
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
                  text: doctorName,
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                  text: doctorQualifications,
                  fontSize: 12.sp,
                  color: AppColors.darkGreyText,
                ),
                Divider(
                  color: AppColors.offWhite,
                ),
                BodyTextTwo(
                  text: doctorSpeciality,
                  color: AppColors.darkGreyText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
