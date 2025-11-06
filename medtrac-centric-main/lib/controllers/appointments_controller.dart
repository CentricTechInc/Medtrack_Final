import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/models/user.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'package:medtrac/controllers/home_controller.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/api/models/appointment_listing_response.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';

class AppointmentsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final PatientService _patientService = PatientService();
  final DoctorService _doctorService = DoctorService();

  bool get isUser =>  HelperFunctions.isUser();
  User get currentUser =>  SharedPrefsService.getUserInfo;

  late TabController tabController;
  final currentIndex = 0.obs;
  bool _isDisposed = false;
  Worker? _bottomNavWorker;
  DateTime? _lastRefreshTime;

  // Appointment data
  final RxList<AppointmentItem> upcomingAppointments = <AppointmentItem>[].obs;
  final RxList<AppointmentItem> completedAppointments = <AppointmentItem>[].obs;
  final RxList<AppointmentItem> canceledAppointments = <AppointmentItem>[].obs;

  // Pagination
  final Map<String, int> _currentPages = {
    'Upcoming': 1,
    'Completed': 1,
    'Canceled': 1,
  };

  final Map<String, bool> _hasMoreData = {
    'Upcoming': true,
    'Completed': true,
    'Canceled': true,
  };
  

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isSearching = false.obs;

  // Search
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // Status mapping
  final List<String> _statuses = ['Upcoming', 'Completed', 'Canceled'];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      if (!_isDisposed) {
        currentIndex.value = tabController.index;
      }
    });

    // Listen to bottom navigation changes to refresh data when appointments tab becomes active
    try {
      final bottomNavController = Get.find<BottomNavigationController>();
      _bottomNavWorker = ever(bottomNavController.selectedNavIndex, (navIndex) {
        if (navIndex == 1 && !_isDisposed) {
          // Index 1 is the appointments tab
          // Only refresh if it's been more than 5 seconds since last refresh
          final now = DateTime.now();
          if (_lastRefreshTime == null ||
              now.difference(_lastRefreshTime!).inSeconds > 5) {
            _lastRefreshTime = now;
            // Refresh current tab data when appointments tab becomes active
            final currentStatus = _statuses[currentIndex.value];
            if (!isLoading.value) {
              loadAppointments(currentStatus);
            }
          }
        }
      });
    } catch (e) {
      // BottomNavigationController not found, continue without listener
    }

    // Load initial data
    loadAppointments('Upcoming');
  }

  Future<void> loadAppointments(String status) async {
    if (isLoading.value) return;

    isLoading.value = true;
    _currentPages[status] = 1;
    _hasMoreData[status] = true;
    AppointmentListingResponse response;

    try {
      if (isUser) {
        response = await _patientService.getPatientAppointmentListing(
          page: 1,
          status: status,
          searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
          pageLimit: 10,
        );
      } else {
        response = await _doctorService.getDoctorAppointmentListing(
          page: 1,
          status: status,
          searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
          pageLimit: 10,
        );
      }

      if (response.status && response.data != null) {
        _updateAppointmentsList(status, response.data!.rows, isRefresh: true);
        _hasMoreData[status] = response.data!.rows.isNotEmpty && response.data!.rows.length >= 10; // Assuming pageLimit is 10
        print('Initial load for $status: ${response.data!.rows.length} items, hasMore: ${_hasMoreData[status]}');
      }
    } catch (e) {
      // Handle error
      print('Error loading appointments: $e');
    } finally {
      isLoading.value = false;
    }
    
    // Sync with home controller after loading
    _syncWithHomeController();
  }

  void _updateAppointmentsList(
      String status, List<AppointmentItem> newAppointments,
      {bool isRefresh = false}) {
    switch (status) {
      case 'Upcoming':
        if (isRefresh) {
          upcomingAppointments.clear();
        }
        upcomingAppointments.addAll(newAppointments);
        break;
      case 'Completed':
        if (isRefresh) {
          completedAppointments.clear();
        }
        completedAppointments.addAll(newAppointments);
        break;
      case 'Canceled':
        if (isRefresh) {
          canceledAppointments.clear();
        }
        canceledAppointments.addAll(newAppointments);
        break;
    }
  }

  Future<void> loadMoreAppointments(String status) async {
    if (isLoadingMore.value || !_hasMoreData[status]!) {
      print('Load more cancelled: isLoadingMore=${isLoadingMore.value}, hasMoreData=${_hasMoreData[status]}');
      return;
    }

    print('Loading more appointments for status: $status, page: ${_currentPages[status]! + 1}');
    isLoadingMore.value = true;
    _currentPages[status] = _currentPages[status]! + 1;
    AppointmentListingResponse response;

    try {
      if (isUser) {
        response = await _patientService.getPatientAppointmentListing(
          page: _currentPages[status]!,
          status: status,
          searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
          pageLimit: 10,
        );
      } else {
        response = await _doctorService.getDoctorAppointmentListing(
          page: _currentPages[status]!,
          status: status,
          searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
          pageLimit: 10,
        );
      }

      if (response.status && response.data != null) {
        if (response.data!.rows.isEmpty) {
          _hasMoreData[status] = false;
          print('No more data available for status: $status');
        } else {
          _updateAppointmentsList(status, response.data!.rows);
          print('Loaded ${response.data!.rows.length} more appointments for status: $status');
        }
      }
    } catch (e) {
      // Handle error
      print('Error loading more appointments: $e');
      _currentPages[status] =
          _currentPages[status]! - 1; // Revert page increment
    } finally {
      isLoadingMore.value = false;
      print('Load more completed for status: $status, hasMore: ${_hasMoreData[status]}');
    }
  }

  void onRefresh(String status) async {
    loadAppointments(status);
  }

  Future<void> onLoading(String status) async {
    await loadMoreAppointments(status);
  }

  List<AppointmentItem> getCurrentAppointments() {
    switch (_statuses[currentIndex.value]) {
      case 'Upcoming':
        return upcomingAppointments;
      case 'Completed':
        return completedAppointments;
      case 'Canceled':
        return canceledAppointments;
      default:
        return upcomingAppointments;
    }
  }

  void onUpcomingAppointmentTap({int? appointmentId, String? patientName}) {
    if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
      HelperFunctions.showIncompleteProfileBottomSheet(
        
      );
      return;
    }
    
    // Navigate to appropriate appointment details screen based on user type
    if (isUser) {
      Get.toNamed(
        AppRoutes.userAppointmentDetailsScreen,
        arguments: appointmentId != null ? {'appointmentId': appointmentId} : null,
      );
    } else {
      Get.toNamed(
        AppRoutes.appointmentDetailsScreen,
        arguments: appointmentId != null ? {
          'appointmentId': appointmentId,
          'patientName': patientName,
        } : null,
      );
    }
  }


  void changeTab(int index) {
    if (!_isDisposed && tabController.index != index) {
      currentIndex.value = index;
      tabController.animateTo(index);

      // Load data for the new tab if not already loaded
      final status = _statuses[index];
      if (getCurrentAppointments().isEmpty && !isLoading.value) {
        loadAppointments(status);
      }
    }
  }

  void searchAppointments(String query) async {
    searchQuery.value = query;
    isSearching.value = true;

    try {
      // Reload current tab with search query
      final currentStatus = _statuses[currentIndex.value];
      await loadAppointments(currentStatus);
    } catch (e) {
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() async {
    if (_isDisposed) return;
    
    searchQuery.value = '';
    
    try {
      searchController.clear();
    } catch (e) {
      // Controller might be disposed
      print('SearchController clear error: $e');
    }
    
    isSearching.value = true;

    try {
      // Reload current tab without search query
      final currentStatus = _statuses[currentIndex.value];
      await loadAppointments(currentStatus);
    } catch (e) {
    } finally {
      isSearching.value = false;
    }
  }

  bool hasMoreData(String status) {
    return _hasMoreData[status] ?? false;
  }

  /// Force refresh appointments (useful after cancel/reschedule operations)
  void forceRefresh() {
    _lastRefreshTime = null;
    final currentStatus = _statuses[currentIndex.value];
    loadAppointments(currentStatus);
    
    // Also refresh home controller's upcoming appointments if it exists
    try {
      final homeController = Get.find<HomeController>();
      homeController.refreshUpcomingAppointments();
    } catch (e) {
      // HomeController not found, continue normally
    }
  }

  /// Sync upcoming appointments with home controller
  void _syncWithHomeController() {
    try {
      final homeController = Get.find<HomeController>();
      // Update home controller's upcoming appointments with our data
      final limitedAppointments = upcomingAppointments.take(3).toList();
      homeController.upcomingAppointments.assignAll(limitedAppointments);
    } catch (e) {
      // HomeController not found, continue normally
    }
  }

  @override
  @override
  void onClose() {
    _isDisposed = true;
    _bottomNavWorker?.dispose();
    
    // Safely dispose TabController
    try {
      tabController.dispose();
    } catch (e) {
      // TabController already disposed
      print('TabController disposal error: $e');
    }
    
    // Safely dispose TextEditingController
    try {
      searchController.dispose();
    } catch (e) {
      // TextEditingController already disposed
      print('SearchController disposal error: $e');
    }
    
    super.onClose();
  }
}
