import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/appointments_controller.dart';
import 'package:medtrac/custom_widgets/appointment_tile_widget.dart';
import 'package:medtrac/custom_widgets/custom_appbar_with_icons.dart';
import 'package:medtrac/custom_widgets/custom_tab_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:medtrac/api/models/appointment_listing_response.dart';
import 'dart:async';

class AppointmentsTab extends StatefulWidget {
  const AppointmentsTab({super.key});

  @override
  State<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AppointmentsController? _controller;
  Timer? _debounceTimer;
  
  // Create refresh controllers locally
  late RefreshController _upcomingRefreshController;
  late RefreshController _completedRefreshController;
  late RefreshController _canceledRefreshController;

  AppointmentsController get controller {
    _controller ??= Get.find<AppointmentsController>();
    return _controller!;
  }

  @override
  void initState() {
    super.initState();
    _upcomingRefreshController = RefreshController(initialRefresh: false);
    _completedRefreshController = RefreshController(initialRefresh: false);
    _canceledRefreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _upcomingRefreshController.dispose();
    _completedRefreshController.dispose();
    _canceledRefreshController.dispose();
    super.dispose();
  }

  void _debounceSearch(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      controller.searchAppointments(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Unfocus search field when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: SafeArea(
          child: Column(
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
                      controller: controller.searchController,
                      onChanged: (value) {
                        // Add debouncing to avoid too many API calls
                        _debounceSearch(value);
                      },
                      suffixIcon: Obx(() {
                        if (controller.isSearching.value) {
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.blue50,
                                ),
                              ),
                            ),
                          );
                        }
                        return controller.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  controller.clearSearch();
                                  FocusScope.of(context).unfocus();
                                },
                              )
                            : const SizedBox.shrink();
                      }),
                    ),
                  16.verticalSpace,
                  CustomTabBar(
                    tabs: ["Upcoming", "Completed", "Canceled"],
                    currentIndex: controller.currentIndex,
                    onTabChanged: (index) {
                      controller.changeTab(index);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Upcoming appointments
                  _buildAppointmentList('Upcoming'),
                  // Completed appointments  
                  _buildAppointmentList('Completed'),
                  // Canceled appointments
                  _buildAppointmentList('Canceled'),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildAppointmentList(String status) {
    // Get static RefreshController
    RefreshController refreshController;
    switch (status) {
      case 'Upcoming':
        refreshController = _upcomingRefreshController;
        break;
      case 'Completed':
        refreshController = _completedRefreshController;
        break;
      case 'Canceled':
        refreshController = _canceledRefreshController;
        break;
      default:
        refreshController = _upcomingRefreshController;
    }

    return Obx(() {
      List<AppointmentItem> appointments;
      
      switch (status) {
        case 'Upcoming':
          appointments = controller.upcomingAppointments;
          break;
        case 'Completed':
          appointments = controller.completedAppointments;
          break;
        case 'Canceled':
          appointments = controller.canceledAppointments;
          break;
        default:
          appointments = controller.upcomingAppointments;
      }

      final hasMoreData = controller.hasMoreData(status);
      final isLoadingMore = controller.isLoadingMore.value;
      
      print('🔍 $status: ${appointments.length} items, hasMoreData=$hasMoreData, isLoadingMore=$isLoadingMore');

      // Show loading indicator during initial load or search
      if ((controller.isLoading.value && appointments.isEmpty) || controller.isSearching.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      if (appointments.isEmpty && !controller.isLoading.value) {
        return Center(
          child: Text(
            'No ${status.toLowerCase()} appointments found',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
        );
      }

      return SmartRefresher(
        controller: refreshController,
        enablePullDown: true,
        enablePullUp: hasMoreData && !isLoadingMore,
        onRefresh: () => _onRefresh(status, refreshController),
        onLoading: () => _onLoading(status, refreshController),
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          separatorBuilder: (context, index) => 16.verticalSpace,
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            final isUser = HelperFunctions.isUser();
            return AppointmentTileWidget(
              onTap: () => _handleAppointmentTap(status, appointment),
              onReschedule: () => _handleReschedule(appointment),
              isUpcoming: status == 'Upcoming',
              isUser: isUser,
              currentUserId: controller.currentUser.id,
              receiverId: isUser ? appointment.doctor.id : appointment.patient.id,
              isEmergency: isUser ? appointment.doctor.isEmergencyFees : false,
              isCancelled: status == 'Canceled',
              name: isUser
                  ? 'Dr. ${appointment.doctor.name}'
                  : appointment.patientName ?? 'Unknown Patient',
              date: appointment.date,
              doctorRating: double.tryParse(appointment.doctor.averageRating) ?? 0.0,
              doctorType: appointment.doctor.speciality,
              duration: appointment.time,
              imageUrl: isUser ? appointment.doctor.picture : appointment.patient.picture,
              appointmentId: appointment.id,
              doctorSpecialityFull: appointment.doctor.speciality,
            );
          },
        ),
      );
    });
  }

  void _onRefresh(String status, RefreshController refreshController) async {
    controller.onRefresh(status);
    refreshController.refreshCompleted();
  }

  void _onLoading(String status, RefreshController refreshController) async {
    print('🔄 _onLoading called for status: $status');
    await controller.onLoading(status);
    
    // Check if there's more data after loading completes
    if (controller.hasMoreData(status)) {
      print('✅ Load complete - has more data');
      refreshController.loadComplete();
    } else {
      print('🔚 Load complete - no more data');
      refreshController.loadNoData();
    }
  }

  void _handleAppointmentTap(String status, [AppointmentItem? appointment]) {
    if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
      HelperFunctions.showIncompleteProfileBottomSheet();
      return;
    }

    switch (status) {
      case 'Upcoming':
        controller.onUpcomingAppointmentTap(
          appointmentId: appointment?.id,
          patientName: appointment?.patientName,
        );
        break;
      case 'Completed':
        Get.toNamed(AppRoutes.appointmentSummaryScreen, arguments: {
          'appointmentId': appointment?.id,
        });
        break;
      case 'Canceled':
        Get.toNamed(AppRoutes.cancelledBookingScreen, arguments: {
          'appointmentId': appointment?.id,
        });
        break;
    }
  }

  void _handleReschedule(AppointmentItem appointment) {
    if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
      HelperFunctions.showIncompleteProfileBottomSheet();
      return;
    }

    Get.toNamed(AppRoutes.appointmentBookingScreen, arguments: {
      'doctorId': controller.isUser ? appointment.doctor.id : controller.currentUser.id,
      'isReschedule': true,
      'appointmentId': appointment.id,
      'initialDate': appointment.date, // Pass current appointment date
    });
  }
}