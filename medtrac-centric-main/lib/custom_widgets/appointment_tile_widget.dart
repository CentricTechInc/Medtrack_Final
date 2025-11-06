import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/custom_widgets/custom_emergency_tag_shape.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/helper_functions.dart';

class AppointmentTileWidget extends StatelessWidget {
  final bool isUpcoming;
  final bool isCancelled;
  final VoidCallback? onTap;
  final VoidCallback? onReschedule; // Add reschedule callback
  final String name;
  final String date;
  final String duration;
  final bool isUser;
  final bool isEmergency;
  final String? fee;
  final String? doctorType;
  final double? doctorRating;
  final String imageUrl;
  final String? doctorSpecialityFull; // Add doctor speciality parameter
  final int? appointmentId; // Add appointmentId parameter
  final int? currentUserId;
  final int? receiverId;

  const AppointmentTileWidget({
    super.key,
    this.isUpcoming = false,
    this.isEmergency = false,
    this.isCancelled = false,
    this.isUser = false,
    this.onTap,
    this.onReschedule, // Add to constructor
    required this.name,
    required this.date,
    required this.duration,
    this.fee,
    this.doctorType,
    this.doctorRating,
    required this.imageUrl,
    this.appointmentId,
    this.currentUserId,
    this.receiverId, // Add doctor speciality to constructor
    this.doctorSpecialityFull, 
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.bright,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        image: DecorationImage(
                          image: (imageUrl.trim().isNotEmpty)
                              ? NetworkImage(imageUrl)
                              : AssetImage(Assets.avatar) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    8.horizontalSpace,
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 190.w,
                                child: BodyTextOne(
                                  text: name,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              if (isUser)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    BodyTextTwo(
                                        text: doctorType != null
                                            ? doctorType.toString()
                                            : '',
                                        fontWeight: FontWeight.w600),
                                    16.horizontalSpace,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        BodyTextTwo(
                                          text: doctorRating != null
                                              ? doctorRating.toString()
                                              : '0.0',
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        4.horizontalSpace,
                                        Icon(Icons.star,
                                            color: AppColors.primary),
                                      ],
                                    ),
                                  ],
                                )
                            ],
                          ),
                          if (fee != null) HeadingTextTwo(text: "₹$fee"),
                        ],
                      ),
                    ),
                  ],
                ),
                16.verticalSpace,
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            Assets.calanderIcon,
                            width: 18,
                            height: 18,
                          ),
                          10.horizontalSpace,
                          BodyTextTwo(
                            text: date,
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            Assets.clockIcon,
                            width: 18,
                            height: 18,
                          ),
                          10.horizontalSpace,
                          BodyTextTwo(
                            text: duration,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isUpcoming) ...[
                  16.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CustomElevatedButton(
                        text: isUser ? "Reschedule" : "Cancel",
                        isOutlined: true,
                        width: 164.w,
                        height: 44.h,
                        fontSize: 16.sp,
                        onPressed: () {
                          if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                            HelperFunctions.showIncompleteProfileBottomSheet();
                            return;
                          }
                          if (isUser) {
                            if (onReschedule != null) {
                              onReschedule!();
                            } else {
                              Get.toNamed(AppRoutes.appointmentBookingScreen);
                            }
                          } else {
                            Get.toNamed(
                              AppRoutes.cancelBookingScreen,
                              arguments: {
                                'appointmentId': appointmentId,
                                'doctorName': name,
                                'doctorImage': imageUrl,
                                'doctorSpeciality': doctorSpecialityFull ?? doctorType ?? '',
                                'appointmentDate': date,
                                'appointmentTime': duration,
                              },
                            );
                          }
                        },
                      ),
                      CustomElevatedButton(
                        text: isUser ? "Join Session" : "Start Session",
                        width: 164.w,
                        height: 44.h,
                        fontSize: 16.sp,
                        onPressed: () {
                          if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                            HelperFunctions.showIncompleteProfileBottomSheet();
                            return;
                          }
                          Get.toNamed(AppRoutes.videoCallScreen,
                              arguments: {
                                "fromAppointment": true,
                                "doctorName": name,
                                "doctorImage": imageUrl,
                                "doctorSpeciality": doctorSpecialityFull ?? doctorType ?? '',
                                'appointmentId': appointmentId,
                                'callerId': currentUserId,
                                'receiverId': receiverId,
                                'doctorId': isUser ? receiverId : currentUserId
                              });
                        },
                      )
                    ],
                  )
                ],
                if (isCancelled) ...[
                  16.verticalSpace,
                  Align(
                    alignment: Alignment.center,
                    child: CustomElevatedButton(
                      text: "Reschedule",
                      width: 164.w,
                      height: 44.h,
                      fontSize: 16.sp,
                      onPressed: () {
                        if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                          HelperFunctions.showIncompleteProfileBottomSheet();
                          return;
                        }
                        if (onReschedule != null) {
                          onReschedule!();
                        } else {
                          Get.toNamed(AppRoutes.appointmentBookingScreen);
                        }
                      },
                    ),
                  ),
                ]
              ],
            ),
          ),
          if (isEmergency)
            Positioned(
              top: 0.h,
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
                          Text(
                            'Emergency',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10.sp,
                              letterSpacing: 0.2,
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
