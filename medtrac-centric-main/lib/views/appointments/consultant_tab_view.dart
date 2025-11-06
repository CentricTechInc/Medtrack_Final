import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:medtrac/controllers/consultant_tab_view_controller.dart';
import 'package:medtrac/custom_widgets/appointment_tile_widget.dart';
import 'package:medtrac/custom_widgets/custom_appbar_with_icons.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/filter_tab_bar.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/helper_functions.dart';

class ConsultantTabView extends GetView<ConsultantTabViewController> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  ConsultantTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: [
          CustomAppBarWithIcons(
            scaffoldKey: _scaffoldKey,
          ),
          24.verticalSpace,

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextFormField(
                  hintText: "Search",
                  prefixIcon: Icons.search,
                  hasBorder: false,
                  fillColor: AppColors.lightGrey,
                  controller: _searchController,
                  onChanged: (value) => controller.searchAppointments(value),
                ),
                16.verticalSpace,
              ],
            ),
          ),
          // Filter Tabs
          Align(
            alignment: Alignment.centerRight,
            child: FilterTabBar(
              tabs: controller.specialtyTabs,
              selectedTab: controller.selectedSpecialty,
              onTabChanged: controller.onTabChanged,
            ),
          ),

          16.verticalSpace,

          // Emergency Services Switch
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BodyTextOne(
                  text: 'Emergency Services',
                  fontWeight: FontWeight.bold,
                ),
                Obx(() => Transform.scale(
                      scale: 1.2,
                      child: Switch(
                        value: controller.emergencyServicesOnly.value,
                        onChanged: controller.toggleEmergencyServices,
                        activeColor: Colors.white,
                        activeTrackColor: AppColors.primary,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppColors.lightGrey,
                      ),
                    )),
              ],
            ),
          ),
          24.verticalSpace,
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.filteredDoctors.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.filteredDoctors.isEmpty) {
                return const Center(
                  child: Text('No doctors found'),
                );
              }

              // Create RefreshController in build method to avoid conflicts
              final refreshController = RefreshController(initialRefresh: false);
              
              return SmartRefresher(
                key: ValueKey('consultant_smart_refresher_${DateTime.now().millisecondsSinceEpoch}'),
                controller: refreshController,
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: () => controller.onRefresh(refreshController),
                onLoading: () => controller.onLoading(refreshController),
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  separatorBuilder: (context, index) => 16.verticalSpace,
                  itemCount: controller.filteredDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = controller.filteredDoctors[index];
                    return AppointmentTileWidget(
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.doctorDetailsScreen,
                          arguments: doctor.id, // Pass doctor ID
                        );
                      },
                      isUser: HelperFunctions.isUser(),
                      isEmergency: doctor.isEmergency,
                      name: doctor.name,
                      date: doctor.dateAvailable,
                      duration: doctor.timeAvailable,
                      imageUrl: doctor.picture ?? "",
                      doctorRating: doctor.displayRating,
                      doctorType: doctor.speciality,
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
