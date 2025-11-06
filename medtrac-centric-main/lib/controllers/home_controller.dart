
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medtrac/api/models/user.dart';
import 'package:medtrac/api/services/general_service.dart';
import 'package:medtrac/controllers/wellness_hub_controller.dart';
import 'package:medtrac/controllers/appointments_controller.dart';
import 'package:medtrac/controllers/daily_checkin_controller.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/api/services/wellness_service.dart';
import 'package:medtrac/api/models/doctor_response.dart';
import 'package:medtrac/api/models/appointment_statistics_response.dart';
import 'package:medtrac/api/models/appointment_listing_response.dart';
import 'package:medtrac/api/models/banner_response.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/routes/app_routes.dart';
import '../models/appointment_statistics.dart';
import 'package:medtrac/views/Home/widgets/daily_checkin_popup.dart';
import 'package:medtrac/api/models/emotions_analytics_response.dart';

class HomeController extends WellnessHubController {
  // Stress analytics for the week (Sun-Sat)
  final RxList<StressAnalytics> stressAnalytics = <StressAnalytics>[].obs;
  // Mood analytics for the week (Sun-Sat)
  final RxList<MoodAnalytics> moodAnalytics = <MoodAnalytics>[].obs;
  /// Load sleep/mood/stress analytics for the week
  Future<void> loadEmotionsAnalytics() async {
    try {
      final analytics = await PatientService().getEmotionsAnalytics();
      if (analytics != null) {
        sleepAnalytics.assignAll(analytics.sleep);
        moodAnalytics.assignAll(analytics.mood);
        stressAnalytics.assignAll(analytics.stress);
      } else {
        sleepAnalytics.clear();
        moodAnalytics.clear();
        stressAnalytics.clear();
      }
    } catch (e) {
      sleepAnalytics.clear();
      print('Failed to load emotions analytics: $e');
    }
  }

  /// Returns a list of hours for the sleep chart, filling missing days with 0
  List<double> get sleepChartHours {
    // Map day names to index (Sun=0, ..., Sat=6)
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final Map<String, double> dayToHours = { for (var d in days) d: 0.0 };
    for (final entry in sleepAnalytics) {
      if (days.contains(entry.dayName)) {
        dayToHours[entry.dayName] = entry.averageHours;
      }
    }
    // Return hours in order Sun-Sat
    return days.map((d) => dayToHours[d] ?? 0.0).toList();
  }

  // Sleep analytics for the week (Sun-Sat)
  final RxList<SleepAnalytics> sleepAnalytics = <SleepAnalytics>[].obs;
  final DoctorService _doctorService = DoctorService();
  final WellnessService _wellnessService = WellnessService();

  final RxInt selectedNavIndex = 0.obs;
  bool get isUser => HelperFunctions.isUser();
  final User currentUser = SharedPrefsService.getUserInfo;
  int get currentUserId => currentUser.id;
  final RxList<AppointmentStatistics> appointmentStatistics =
      <AppointmentStatistics>[].obs;

  // Best health professionals
  final RxList<Doctor> bestHealthProfessionals = <Doctor>[].obs;
  final RxBool isLoadingProfessionals = false.obs;

  // API Statistics data
  final RxBool isLoadingStatistics = false.obs;
  final Rx<AppointmentStatisticsData?> apiStatisticsData =
      Rx<AppointmentStatisticsData?>(null);

  // Month selection
  final RxString selectedMonth = "".obs;
  final RxList<String> months = <String>[].obs;

  // Chart data
  RxDouble maxYValue = 50.0.obs;
  RxDouble targetLine = 28.0.obs;

  // User profile status
  RxBool isProfileComplete = false.obs; // Will be fetched from API in future

  // Upcoming appointments for home screen
  final RxList<AppointmentItem> upcomingAppointments = <AppointmentItem>[].obs;
  final RxBool isLoadingUpcomingAppointments = false.obs;

  // Banner data for wellness banner
  final RxList<BannerItem> banners = <BannerItem>[].obs;
  final RxBool isLoadingBanners = false.obs;

  // Dummy mood data for each day of the week
  // Map weekday (Mon-Sun) to mood type (can be null for no response)
  final RxMap<String, String?> weeklyMood = <String, String?>{
    'Mon': 'excellent',
    'Tue': 'good',
    'Wed': 'fair',
    'Thu': 'good',
    'Fri': 'fair',
    'Sat': 'worst',
    'Sun': 'good',
  }.obs;


  @override
  void onInit() {
    super.onInit();
    initializeMonths();
    initializeDefaultChartData();
    checkProfileCompletion();
    loadEmotionsAnalytics();

    // Load statistics data for doctors immediately
    if (!isUser) {
      print('📊 HomeController: Loading statistics for doctor on init');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        loadApiStatistics();
      });
    }

    // API calls moved to AppProcedures - will be called from splash and post-login

    // Show daily check-in popup after all initial loading is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(!SharedPrefsService.isDailyCheckinDoneToday()) {
        Future.delayed(const Duration(milliseconds: 800), () {
        if (Get.context != null) {
          if (isUser) {
            // Initialize the DailyCheckinController before showing popup
            Get.put(DailyCheckinController());
            Get.bottomSheet(
              const DailyCheckinPopup(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          }
        }
      });
      }
    });
  }

  // Check profile completion and show bottom sheet if needed
  void checkProfileCompletion() {
    // In a real app, this would be an API call to check if:
    // 1. Personal info is complete
    // 2. At least one bank account is added

    // Get the profile completion status from shared preferences
    bool sharedPrefsValue = SharedPrefsService.isProfileComplete();

    // Update the controller state from SharedPrefs
    isProfileComplete.value = sharedPrefsValue;

    // For testing purposes, you can force it to false to test the flow
    // Uncomment the line below to force showing the bottom sheet
    // isProfileComplete.value = false;

    // The actual bottom sheet will be shown in the onInit method if needed
  }

  void initializeMonths() {
    // Get all month names (only month, no year)
    months.value = List.generate(12, (index) {
      final date = DateTime(DateTime.now().year, index + 1);
      return DateFormat('MMM').format(date).toUpperCase();
    });

    // Set the current month as selected
    selectedMonth.value =
        DateFormat('MMM').format(DateTime.now()).toUpperCase();
  }

  void initializeDefaultChartData() {
    // Initialize with default/empty chart data
    appointmentStatistics.value = [
      AppointmentStatistics(week: 'Week 1', completed: 0, canceled: 0),
      AppointmentStatistics(week: 'Week 2', completed: 0, canceled: 0),
      AppointmentStatistics(week: 'Week 3', completed: 0, canceled: 0),
      AppointmentStatistics(week: 'Week 4', completed: 0, canceled: 0),
    ];
    updateChartYAxisMax();
  }

  // Update chart Y-axis maximum value based on the current data
  void updateChartYAxisMax() {
    double maxCompleted = 0;
    double maxCanceled = 0;

    for (var stat in appointmentStatistics) {
      if (stat.completed > maxCompleted) {
        maxCompleted = stat.completed.toDouble();
      }
      if (stat.canceled > maxCanceled) {
        maxCanceled = stat.canceled.toDouble();
      }
    }

    // Set maxYValue to be 10 units more than the highest value for better visual
    // If both are 0, set a minimum of 10 to show empty chart properly
    final maxValue = maxCompleted > maxCanceled ? maxCompleted : maxCanceled;
    final newMaxY = (maxValue == 0 ? 10 : maxValue + 10).roundToDouble();

    print(
        '📊 Updating chart Y-axis: maxCompleted=$maxCompleted, maxCanceled=$maxCanceled, newMaxY=$newMaxY');
    maxYValue.value = newMaxY;
  }

  // Change selected month
  void changeSelectedMonth(String? month) {
    if (month != null) {
      selectedMonth.value = month;

      if (!isUser) {
        // For doctors, load API statistics when month changes and update chart
        loadApiStatistics();
      }
    }
  }

  void onNavItemTapped(int index) {
    selectedNavIndex.value = index;
  }

  void markProfileAsComplete() async {
    isProfileComplete.value = true;

    // In a real app, you would make an API call here
    // to update the profile status on the server

    // Save the profile completion status to shared preferences
    await SharedPrefsService.setProfileComplete(true);

    // Update the UI
    update(); // Trigger UI update
  }

  // Reset profile completion for testing
  void resetProfileCompletion() async {
    isProfileComplete.value = false;
    await SharedPrefsService.setProfileComplete(false);
    update();
  }

  // Test SharedPreferences functionality
  void testSharedPreferences() async {
    // Test 4: Update the controller state
    isProfileComplete.value = SharedPrefsService.isProfileComplete();
  }

  /// Load best health professionals from API
  Future<void> loadBestHealthProfessionals() async {
    try {
      isLoadingProfessionals.value = true;

      final response = await _doctorService.getBestHealthProfessionals();

      if (response.success && response.data != null) {
        bestHealthProfessionals.assignAll(response.data!);
      } else {
        SnackbarUtils.showError(
            response.message ?? 'Failed to load health professionals',
            title: 'Error');
      }
    } catch (e) {
      SnackbarUtils.showError(
          'Failed to load health professionals: ${e.toString()}',
          title: 'Error');
    } finally {
      isLoadingProfessionals.value = false;
    }
  }

  /// Navigate to doctor details when a professional is tapped
  void onProfessionalTap(Doctor doctor) {
    // Navigate to doctor details screen with the doctor ID
    Get.toNamed(AppRoutes.doctorDetailsScreen, arguments: doctor.id);
  }

  /// Load appointment statistics from API for doctors
  Future<void> loadApiStatistics() async {
    print(
        '📊 loadApiStatistics: Starting API call for month ${selectedMonth.value}');
    try {
      isLoadingStatistics.value = true;

      // Parse month name to get month number
      final currentYear = DateTime.now().year;

      final monthIndex = months.indexOf(selectedMonth.value) +
          1; // +1 because months are 1-indexed

      final response = await _doctorService.getAppointmentStatistics(
        year: currentYear,
        month: monthIndex,
      );

      if (response.status && response.data != null) {
        apiStatisticsData.value = response.data;

        // Update chart data based on API response
        if (response.data!.statistics.isNotEmpty) {
          final weeklyStats = response.data!.statistics.first;

          // Create completely new list to ensure reactivity
          final newStatistics = <AppointmentStatistics>[
            AppointmentStatistics(
                week: 'Week 1',
                completed: weeklyStats.completedAppointments['week_1'] ?? 0,
                canceled: weeklyStats.canceledAppointments['week_1'] ?? 0),
            AppointmentStatistics(
                week: 'Week 2',
                completed: weeklyStats.completedAppointments['week_2'] ?? 0,
                canceled: weeklyStats.canceledAppointments['week_2'] ?? 0),
            AppointmentStatistics(
                week: 'Week 3',
                completed: weeklyStats.completedAppointments['week_3'] ?? 0,
                canceled: weeklyStats.canceledAppointments['week_3'] ?? 0),
            AppointmentStatistics(
                week: 'Week 4',
                completed: weeklyStats.completedAppointments['week_4'] ?? 0,
                canceled: weeklyStats.canceledAppointments['week_4'] ?? 0),
          ];

          // Clear and reassign to force update
          appointmentStatistics.clear();
          appointmentStatistics.assignAll(newStatistics);

          // Force observable to notify listeners
          appointmentStatistics.refresh();
        } else {
          // Clear chart data when statistics array is empty
          final defaultStatistics = <AppointmentStatistics>[
            AppointmentStatistics(week: 'Week 1', completed: 0, canceled: 0),
            AppointmentStatistics(week: 'Week 2', completed: 0, canceled: 0),
            AppointmentStatistics(week: 'Week 3', completed: 0, canceled: 0),
            AppointmentStatistics(week: 'Week 4', completed: 0, canceled: 0),
          ];

          appointmentStatistics.clear();
          appointmentStatistics.assignAll(defaultStatistics);
          appointmentStatistics.refresh();
        }

        // Update chart Y-axis after data changes
        updateChartYAxisMax();
      } else {
        SnackbarUtils.showError(response.message, title: 'Error');
      }
    } catch (e) {
      SnackbarUtils.showError(
          'Failed to load appointment statistics: ${e.toString()}',
          title: 'Error');
    } finally {
      isLoadingStatistics.value = false;
    }
  }

  /// Load upcoming appointments for home screen
  Future<void> loadUpcomingAppointments() async {
    try {
      isLoadingUpcomingAppointments.value = true;

      // Try to get data from AppointmentsController if it exists
      if (Get.isRegistered<AppointmentsController>()) {
        final appointmentsController = Get.find<AppointmentsController>();

        // If the appointments controller already has data, use it
        if (appointmentsController.upcomingAppointments.isNotEmpty) {
          // Take only first 3 appointments for home screen
          final limitedAppointments =
              appointmentsController.upcomingAppointments.take(3).toList();
          upcomingAppointments.assignAll(limitedAppointments);
        } else {
          // Load fresh data
          await appointmentsController.loadAppointments('Upcoming');
          final limitedAppointments =
              appointmentsController.upcomingAppointments.take(3).toList();
          upcomingAppointments.assignAll(limitedAppointments);
        }
      } else {
        // AppointmentsController not registered, load data directly
        await _loadUpcomingAppointmentsDirect();
      }
    } catch (e) {
      // Don't show error to user on home screen, just log it
      print('Failed to load upcoming appointments: $e');
    } finally {
      isLoadingUpcomingAppointments.value = false;
    }
  }

  /// Load upcoming appointments directly (fallback method)
  Future<void> _loadUpcomingAppointmentsDirect() async {
    if (isUser) {
      final patientService = PatientService();
      final response = await patientService.getPatientAppointmentListing(
        page: 1,
        status: 'Upcoming',
        pageLimit: 3, // Only get 3 for home screen
      );

      if (response.status && response.data != null) {
        upcomingAppointments.assignAll(response.data!.rows);
      }
    } else {
      final response = await _doctorService.getDoctorAppointmentListing(
        page: 1,
        status: 'Upcoming',
        pageLimit: 3, // Only get 3 for home screen
      );

      if (response.status && response.data != null) {
        upcomingAppointments.assignAll(response.data!.rows);
      }
    }
  }

  /// Refresh upcoming appointments (useful when called from other screens)
  Future<void> refreshUpcomingAppointments() async {
    await loadUpcomingAppointments();
  }

  /// Reset controller state to defaults (used during logout/login)
  void resetToDefaults() {
    // Reset month selection to current month
    initializeMonths();

    // Clear data lists
    appointmentStatistics.clear();
    bestHealthProfessionals.clear();
    upcomingAppointments.clear();
    banners.clear();

    // Reinitialize default chart data
    initializeDefaultChartData();

    // Reset loading states
    isLoadingProfessionals.value = false;
    isLoadingStatistics.value = false;
    isLoadingUpcomingAppointments.value = false;
    isLoadingBanners.value = false;

    // Reset API data
    apiStatisticsData.value = null;

    // Reset profile status
    isProfileComplete.value = false;

    // Reset mood data to defaults
    weeklyMood.value = {
      'Mon': 'excellent',
      'Tue': 'good',
      'Wed': 'fair',
      'Thu': 'good',
      'Fri': 'fair',
      'Sat': 'worst',
      'Sun': 'good',
    };
  }

  /// Load banners for wellness banner widget
  Future<void> loadBanners() async {
    try {
      isLoadingBanners.value = true;

      final response = await GeneralService().getBanners();

      if (response.status && response.data != null) {
        // Filter only visible banners
        final visibleBanners =
            response.data!.where((banner) => banner.visibility).toList();
        banners.assignAll(visibleBanners);
      } else {
        // Don't show error to user on home screen, just log it
        print('Failed to load banners: ${response.message}');
      }
    } catch (e) {
      // Don't show error to user on home screen, just log it
      print('Failed to load banners: $e');
    } finally {
      isLoadingBanners.value = false;
    }
  }
}
