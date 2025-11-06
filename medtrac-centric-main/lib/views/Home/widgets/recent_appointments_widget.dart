import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/appointments_controller.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';
import 'package:medtrac/custom_widgets/appointment_tile_widget.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/helper_functions.dart';
 

class RecentAppointmentsWidget extends StatelessWidget {
  final BottomNavigationController _bottomNavBarcontroller =
      Get.find<BottomNavigationController>();
  final AppointmentsController _appointmentsController =
      Get.find<AppointmentsController>();
  RecentAppointmentsWidget({
    super.key,
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BodyTextOne(
              text: 'Recent Appointments',
              fontWeight: FontWeight.w700,
            ),
            GestureDetector(
              onTap: () {
                if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                  HelperFunctions.showIncompleteProfileBottomSheet();
                  return;
                }
                _bottomNavBarcontroller.selectedNavIndex.value = 1;
                _appointmentsController.currentIndex.value = 1;
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
          final completed = _appointmentsController.completedAppointments;
          if (completed.isEmpty) {
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
                      text: 'No recent appointments',
                      color: Colors.grey[600]!,
                    ),
                  ],
                ),
              ),
            );
          }

          final displayCount = completed.length >= 3 ? 3 : completed.length;

          return SizedBox(
            height: 160.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: displayCount,
              separatorBuilder: (context, index) => 12.horizontalSpace,
              itemBuilder: (context, index) {
                final appointment = completed[index];
                final isUser = _appointmentsController.isUser;
                final name = isUser
                    ? (appointment.doctor.name.isNotEmpty
                        ? 'Dr. ${appointment.doctor.name}'
                        : 'Dr. Unknown')
                    : (appointment.patientName != null && appointment.patientName!.isNotEmpty
                        ? appointment.patientName!
                        : appointment.patient.name);

                final imageUrl = isUser ? appointment.doctor.picture : appointment.patient.picture;
                final date = _formatDate(appointment.date);
                final duration = appointment.time.isNotEmpty ? _formatTime(appointment.time) : 'Time TBD';

                return SizedBox(
                  width: MediaQuery.of(context).size.width - 48.w,
                  child: AppointmentTileWidget(
                    name: name,
                    date: date,
                    duration: duration,
                    imageUrl: imageUrl,
                    appointmentId: appointment.id,
                    currentUserId: _appointmentsController.currentUser.id,
                    receiverId:
                        isUser ? appointment.doctor.id : appointment.patient.id,
                    onTap: () {
                      if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                        HelperFunctions.showIncompleteProfileBottomSheet();
                        return;
                      }
                      Get.toNamed(AppRoutes.appointmentSummaryScreen,
                          arguments: {
                            'appointmentId': appointment.id,
                          });
                    },
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
