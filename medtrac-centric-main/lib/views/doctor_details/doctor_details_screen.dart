import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/doctor_details_controller.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/views/doctor_details/widgets/reviews_widget.dart';
import 'package:readmore/readmore.dart';

class DoctorDetailsScreen extends GetView<DoctorDetailsController> {
  const DoctorDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.doctor.value == null) {
          return const Center(
            child: Text('Doctor not found'),
          );
        }

        final doctor = controller.doctor.value!;

        return Stack(
          children: [
            Column(
              children: [
                // Doctor Image
                SizedBox(
                  width: double.infinity,
                  height: 405.h,
                  child: doctor.displayPicture.isNotEmpty
                      ? Image.network(
                          doctor.displayPicture,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.lightGrey,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            Assets.doctorImageLarge,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          Assets.doctorImageLarge,
                          fit: BoxFit.cover,
                        ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: HeadingTextTwo(text: doctor.displayName),
                              ),
                              HeadingTextTwo(
                                text: doctor.displayFees,
                              ),
                            ],
                          ),
                          12.verticalSpace,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: BodyTextOne(
                                  text: doctor.displaySpeciality,
                                  color: AppColors.darkGreyText,
                                ),
                              ),
                              BodyTextOne(
                                text: "/ Fee",
                                color: AppColors.darkGreyText,
                              ),
                            ],
                          ),
                          16.verticalSpace,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DoctorDetailIconWidget(
                                iconPath: Assets.starIcon,
                                label: "Rating",
                                value: "${doctor.displayRating.toStringAsFixed(1)} out of 5.0",
                              ),
                              DoctorDetailIconWidget(
                                iconPath: Assets.briefcaseIcon2,
                                label: "Patients",
                                value: "+${doctor.numberOfPatients}", // This could be added to the API later
                              ),
                              DoctorDetailIconWidget(
                                iconPath: Assets.personGroupIcon,
                                label: "Experience",
                                value: "+${doctor.displayExperience} years",
                              ),
                            ],
                          ),
                          32.verticalSpace,
                          BodyTextOne(
                            text: "About",
                            fontWeight: FontWeight.bold,
                          ),
                          16.verticalSpace,
                          ReadMoreText(
                            doctor.displayAbout,
                            trimLines: 3,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.darkGreyText,
                            ),
                            trimMode: TrimMode.Line,
                            trimCollapsedText: 'Read more',
                            trimExpandedText: 'Show less',
                            moreStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark),
                            lessStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dark,
                            ),
                          ),
                          32.verticalSpace,
                          ReviewsWidget(doctor: doctor),
                          42.verticalSpace,
                        ],
                      ),
                    ),
                  ),
                ),
                    Padding(
                    padding: EdgeInsets.all(24.w),
                    child: CustomElevatedButton(
                        text: "Book Appointment",
                        onPressed: () {
                          // Pass doctor details along so downstream screens can show them
                          Get.toNamed(
                            AppRoutes.appointmentBookingScreen,
                            arguments: {
                              'doctorId': controller.doctorId.value,
                              'doctorName': doctor.displayName,
                              'doctorSpeciality': doctor.displaySpeciality,
                              'doctorFees': doctor.displayFees,
                              'doctorProfilePic': doctor.picture,
                            },
                          );
                        }))
              ],
            ),
            Positioned(
              top: 62.h,
              left: 27.w,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class DoctorDetailIconWidget extends StatelessWidget {
  final String label;
  final String iconPath;
  final String value;

  const DoctorDetailIconWidget({
    super.key,
    required this.label,
    required this.iconPath,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Image.asset(
            iconPath,
            width: 24.w,
            height: 24.h,
          ),
        ),
        8.horizontalSpace,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: label,
              fontSize: 12,
              color: AppColors.darkGreyText,
              fontWeight: FontWeight.w600,
            ),
            4.verticalSpace,
            BodyTextTwo(
              text: value,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ],
    );
  }
}
