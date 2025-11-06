import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';
import 'package:medtrac/controllers/home_controller.dart';
import 'package:medtrac/custom_widgets/appointment_tile_widget.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:intl/intl.dart';

class UpcomingAppointmentsWidget extends StatelessWidget {
  final bool isUser;
  final BottomNavigationController _controller =
      Get.find<BottomNavigationController>();
  UpcomingAppointmentsWidget({
    super.key,
    required this.isUser,
  });

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString; // Return original string if parsing fails
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return 'Time TBD';
    }
    try {
      final time = DateFormat('HH:mm:ss').parse(timeString);
      return DateFormat('h:mm a').format(time);
    } catch (e) {
      return timeString; // Return original string if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (homeController) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BodyTextOne(
                  text: isUser ? "Your Appointments" : 'Upcoming Appointments',
                  fontWeight: FontWeight.w700,
                ),
                GestureDetector(
                  onTap: () {
                    if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                      HelperFunctions.showIncompleteProfileBottomSheet();
                      return;
                    }
                    _controller.selectedNavIndex.value = 1;
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
                  height: 120.h,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (homeController.upcomingAppointments.isEmpty) {
                return Container(
                  height: 120.h,
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
                          Icons.calendar_today_outlined,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                        4.verticalSpace,
                        BodyTextTwo(
                          text: 'No upcoming appointments',
                          color: Colors.grey[600]!,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 155.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: homeController.upcomingAppointments.length,
                  separatorBuilder: (context, index) => 12.horizontalSpace,
                  itemBuilder: (context, index) {
                    final appointment = homeController.upcomingAppointments[index];
                    return SizedBox(
                      width: 295.w,
                      child: AppointmentTileWidget(
                        appointmentId: appointment.id,
                        currentUserId: homeController.currentUserId,
                        receiverId: isUser 
                            ? appointment.doctor.id 
                            : appointment.patient.id,
                        doctorRating: double.tryParse(appointment.doctor.averageRating) ?? 0.0,
                        doctorType: appointment.doctor.speciality,
                        onTap: () {
                          if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                            HelperFunctions.showIncompleteProfileBottomSheet();
                            return;
                          }
                          
                          // Navigate to appointment details
                          if (isUser) {
                            Get.toNamed(
                              AppRoutes.userAppointmentDetailsScreen,
                              arguments: {'appointmentId': appointment.id},
                            );
                          } else {
                            Get.toNamed(
                              AppRoutes.appointmentDetailsScreen,
                              arguments: {
                                'appointmentId': appointment.id,
                                'patientName': appointment.patientName ?? appointment.patient.name,
                              },
                            );
                          }
                        },
                        name: isUser
                            ? (appointment.doctor.name.isNotEmpty 
                                ? 'Dr. ${appointment.doctor.name}' 
                                : 'Dr. Unknown')
                            : (appointment.patientName != null
                                ? appointment.patientName.toString() 
                                : 'Unknown Patient'),
                        date: _formatDate(appointment.date),
                        duration: appointment.time.isNotEmpty 
                            ? _formatTime(appointment.time)
                            : 'Time TBD',
                        isUser: isUser,
                        imageUrl: isUser 
                            ? appointment.doctor.picture
                            : appointment.patient.picture,
                      ),
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
