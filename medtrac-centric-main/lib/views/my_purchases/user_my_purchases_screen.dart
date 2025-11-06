import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/user/user_my_purchases_controller.dart';
import 'package:medtrac/custom_widgets/appointment_tile_widget.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserMyPurchasesScreen extends GetView<UserMyPurchasesController> {
  const UserMyPurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Purchases',
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Obx(() => CustomTextFormField(
                  hintText: "Search",
                  hintTextStyle: TextStyle(
                    color: AppColors.lightGreyText,
                    fontSize: 16.sp,
                  ),
                  prefixIcon: Icons.search,
                  hasBorder: false,
                  fillColor: AppColors.lightGrey,
                  controller: controller.searchController.value,
                )),
            16.verticalSpace,
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(16.r),
                  width: 185.w,
                  height: 122.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: AppColors.yellow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BodyTextOne(
                            text: "Appointments",
                            fontWeight: FontWeight.bold,
                            color: AppColors.bright,
                          ),
                          Icon(
                            Icons.check_circle,
                            color: AppColors.bright,
                            size: 24.r,
                          ),
                        ],
                      ),
                      20.verticalSpace,
                      HeadingTextOne(
                        text: controller.totalAppointments.value.toString(),
                        color: AppColors.bright,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.r),
                  width: 185.w,
                  height: 122.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    color: AppColors.green,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyTextOne(
                        text: "Total Spending",
                        fontWeight: FontWeight.bold,
                        color: AppColors.bright,
                      ),
                      20.verticalSpace,
                      HeadingTextOne(
                        text: "₹${controller.totalSpending.value.toStringAsFixed(0)}",
                        color: AppColors.bright,
                      ),
                    ],
                  ),
                ),
              ],
            )),
            24.verticalSpace,
            Obx(() {
              if (controller.isLoading.value && controller.appointments.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.appointments.isEmpty) {
                return Expanded(
                  child: Center(
                    child: Text(
                      'No purchases found',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              }

              return Expanded(
                child: SmartRefresher(
                  controller: controller.refreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  onRefresh: controller.onRefresh,
                  onLoading: controller.onLoadMore,
                  header: WaterDropHeader(
                    complete: Text(
                      'Refresh Completed',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    waterDropColor: AppColors.primary,
                  ),
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus? mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = Text("pull up load", style: TextStyle(color: Colors.grey));
                      } else if (mode == LoadStatus.loading) {
                        body = CircularProgressIndicator(color: AppColors.primary);
                      } else if (mode == LoadStatus.failed) {
                        body = Text("Load Failed! Click retry!", style: TextStyle(color: Colors.grey));
                      } else if (mode == LoadStatus.canLoading) {
                        body = Text("release to load more", style: TextStyle(color: Colors.grey));
                      } else {
                        body = Text("No more Data", style: TextStyle(color: Colors.grey));
                      }
                      return SizedBox(
                        height: 55.0,
                        child: Center(child: body),
                      );
                    },
                  ),
                  child: ListView.separated(
                    itemCount: controller.appointments.length,
                    separatorBuilder: (context, index) => 16.verticalSpace,
                    itemBuilder: (context, index) {
                      final appt = controller.appointments[index];
                      return SizedBox(
                        height: 150.h,
                        child: AppointmentTileWidget(
                          name: 'Dr. ${appt.doctor.name}',
                          date: appt.date,
                          duration: '', // Duration not provided in API
                          fee: appt.consultationFee.toString(),
                          isUser: true,
                          isEmergency: appt.doctor.isEmergencyFees,
                          imageUrl: appt.doctor.picture,
                          doctorRating: double.tryParse(appt.doctor.averageRating) ?? 0.0,
                          doctorType: appt.doctor.speciality,
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
