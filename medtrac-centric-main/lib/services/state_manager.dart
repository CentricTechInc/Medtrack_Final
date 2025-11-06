import 'package:get/get.dart';
import 'package:medtrac/controllers/home_controller.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';
import 'package:medtrac/controllers/appointments_controller.dart';
import 'package:medtrac/controllers/daily_checkin_controller.dart';

/// State Manager Service - Handles app state reset and cleanup
/// Used during logout to ensure clean state for next login
class StateManager {
  
  /// Reset all app state to initial values
  /// Call this method during logout to ensure clean state
  static Future<void> resetAppState() async {
    try {
      // Reset navigation state
      await _resetNavigationState();
      
      // Reset home controller state
      await _resetHomeControllerState();
      
      // Reset appointments state
      await _resetAppointmentsState();
      
      // Reset other controllers
      await _resetOtherControllers();
      
      // Clean up any persistent controllers that shouldn't persist
      await _cleanupControllers();
      
      print('✅ App state reset completed successfully');
    } catch (e) {
      print('❌ Error resetting app state: $e');
    }
  }

  /// Reset navigation-related state
  static Future<void> _resetNavigationState() async {
    if (Get.isRegistered<BottomNavigationController>()) {
      final navController = Get.find<BottomNavigationController>();
      navController.resetToHome();
    }
  }

  /// Reset home controller state to defaults
  static Future<void> _resetHomeControllerState() async {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      homeController.resetToDefaults();
    }
  }

  /// Reset appointments controller state
  static Future<void> _resetAppointmentsState() async {
    if (Get.isRegistered<AppointmentsController>()) {
      final appointmentsController = Get.find<AppointmentsController>();
      
      // Clear appointment lists
      appointmentsController.upcomingAppointments.clear();
      appointmentsController.completedAppointments.clear();
      appointmentsController.canceledAppointments.clear();
      
      // Reset loading states
      appointmentsController.isLoading.value = false;
      appointmentsController.isLoadingMore.value = false;
      appointmentsController.isSearching.value = false;
      
      // Reset tab controller
      appointmentsController.currentIndex.value = 0;
    }
  }

  /// Reset other controllers (daily check-in, etc.)
  static Future<void> _resetOtherControllers() async {
    // Reset daily check-in controller if it exists
    if (Get.isRegistered<DailyCheckinController>()) {
      final dailyCheckinController = Get.find<DailyCheckinController>();
      dailyCheckinController.isSubmitting.value = false;
    }
  }

  /// Clean up controllers that shouldn't persist between sessions
  static Future<void> _cleanupControllers() async {
    // Remove daily check-in controller as it's session-specific
    if (Get.isRegistered<DailyCheckinController>()) {
      Get.delete<DailyCheckinController>();
    }
  }

  /// Initialize fresh state for new login
  /// Call this after successful login to ensure proper initialization
  static Future<void> initializeLoginState() async {
    try {
      // Controllers should already be initialized by MainBinding with permanent: true
      // No need to create them here - they persist across app lifecycle
      
      print('✅ Login state initialized successfully');
    } catch (e) {
      print('❌ Error initializing login state: $e');
    }
  }

  /// Reset only UI state (useful for refresh scenarios)
  static void resetUIState() {
    _resetNavigationState();
  }

  /// Reset only data state (useful for user switching scenarios)
  static Future<void> resetDataState() async {
    await _resetHomeControllerState();
    await _resetAppointmentsState();
  }
}