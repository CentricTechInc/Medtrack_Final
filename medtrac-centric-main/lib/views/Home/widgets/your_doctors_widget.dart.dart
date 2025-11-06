import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/home_controller.dart';
import 'package:medtrac/custom_widgets/custom_doctor_tile.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';

class YourDoctorsWidget extends StatelessWidget {
  const YourDoctorsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BodyTextOne(
                  text: 'Your Doctors',
                  fontWeight: FontWeight.w700,
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to doctors list screen when available
                    // For now, just do nothing or navigate to search
                  },
                  child: const BodyTextOne(
                    text: 'see all',
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightGreyText,
                  ),
                ),
              ],
            ),
            16.verticalSpace,
            Obx(() {
              if (homeController.isLoadingUpcomingAppointments.value) {
                return SizedBox(
                  height: 135.h,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Get unique doctors from upcoming appointments
              final uniqueDoctors = <int, dynamic>{};
              for (var appointment in homeController.upcomingAppointments) {
                if (!uniqueDoctors.containsKey(appointment.doctor.id)) {
                  uniqueDoctors[appointment.doctor.id] = appointment.doctor;
                }
              }

              final doctorsList = uniqueDoctors.values.toList();

              if (doctorsList.isEmpty) {
                return Container(
                  height: 135.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                        4.verticalSpace,
                        BodyTextTwo(
                          text: 'No doctors found',
                          color: Colors.grey[600]!,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 135.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: doctorsList.length > 3 ? 3 : doctorsList.length, // Limit to 3 doctors
                  separatorBuilder: (context, index) => 16.horizontalSpace,
                  itemBuilder: (context, index) {
                    final doctor = doctorsList[index];
                    return CustomDoctorTile(
                      name: doctor.name.isNotEmpty ? doctor.name : "Unknown Doctor",
                      age: "", // Age not available in appointment doctor data
                      fee: "0.00", // Fee not available in appointment doctor data, would need separate API call
                      specialty: doctor.speciality.isNotEmpty ? doctor.speciality : "General",
                      profilePictureURL: doctor.picture ?? "",
                      rating: doctor.averageRating.isNotEmpty ? doctor.averageRating : "0.0",
                      isYourDoctor: true,
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.doctorDetailsScreen,
                          arguments: doctor.id,
                        );
                      },
                    );
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
