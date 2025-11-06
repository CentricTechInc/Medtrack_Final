import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_emergency_tag_shape.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class CustomDoctorTile extends StatelessWidget {
  final bool isEmergency;
  final bool isYourDoctor;
  final VoidCallback? onTap;
  final String name;
  final String age;
  final String fee;
  final String specialty;
  final String profilePictureURL;
  final String rating;

  const CustomDoctorTile({
    super.key,
    this.isEmergency = false,
    this.onTap,
    required this.name,
    required this.age,
    required this.fee,
    this.isYourDoctor = false,
    required this.specialty,
    required this.profilePictureURL,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: isYourDoctor ? 270.w : null,
            height: isYourDoctor ? 90.h : null,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.bright,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: isYourDoctor ? 64.w : 90.w,
                  height: isYourDoctor ? 64.w : 90.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: profilePictureURL.isNotEmpty
                      ? Image.network(
                          profilePictureURL,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              Assets.vermaImage2,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(Assets.vermaImage2, fit: BoxFit.cover),
                ),
                8.horizontalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BodyTextOne(
                      text: name,
                      fontWeight: FontWeight.w900,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        BodyTextTwo(
                            text: specialty, fontWeight: FontWeight.w600),
                        16.horizontalSpace,
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
                    if (!isYourDoctor) ...[
                      16.verticalSpace,
                      Row(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGrey,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Image.asset(
                                  Assets.briefcaseIcon,
                                  width: 20.w,
                                  height: 20.h,
                                ),
                              ),
                              10.horizontalSpace,
                              BodyTextTwo(
                                text: '$age years',
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                          24.horizontalSpace,
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGrey,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Image.asset(
                                  Assets.doctorIcon,
                                  width: 20.h,
                                  height: 20.w,
                                ),
                              ),
                              10.horizontalSpace,
                              BodyTextTwo(
                                text: "₹$fee",
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
          if (isEmergency)
            Positioned(
              top: 10.h,
              right: 0.w,
              child: SizedBox(
                width: 75.w,
                height: 32.h,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(75, 32),
                      painter: RPSCustomPainter(),
                    ),
                    Positioned.fill(
                      bottom: 9.h,
                      left: 6.w,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE74C3C),
                              shape: BoxShape.circle,
                            ),
                          ),
                          4.horizontalSpace,
                          FittedBox(
                            child:  Text(
                              'Emergency',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
