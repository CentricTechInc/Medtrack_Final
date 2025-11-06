import 'package:get/get.dart';
import 'package:medtrac/controllers/home_controller.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:medtrac/api/services/auth_service.dart';
import 'package:medtrac/services/notification_service.dart';
import 'package:medtrac/services/shared_preference_service.dart';

/// App Procedures - Centralized API call management
/// Contains procedures for different app lifecycle events
class AppProcedures {
  
  /// Procedures to run during app startup (splash screen)
  static List<Future<void> Function()> get postStartupProcedures => [
    _updateFcmToken,
    _loadBanners,
    _loadBestHealthProfessionals,
    _loadUpcomingAppointments,
    _loadStatistics,
  ];

  /// Procedures to run after successful login
  static List<Future<void> Function()> get postLoginProcedures => [
    _updateFcmToken,
    _loadUpcomingAppointments,
    _loadStatistics,
    _loadBanners,
    _loadBestHealthProfessionals,
  ];

  /// Execute a list of procedures sequentially
  static Future<void> executeProcedures(List<Future<void> Function()> procedures, {String? logPrefix}) async {
    for (int i = 0; i < procedures.length; i++) {
      try {
        await procedures[i]();
      } catch (e) {
        // Continue with other procedures even if one fails
      }
    }
  }

  /// Execute startup procedures
  static Future<void> executeStartupProcedures() async {
    await executeProcedures(postStartupProcedures, logPrefix: 'Startup');
  }

  /// Execute post-login procedures
  static Future<void> executePostLoginProcedures() async {
    await executeProcedures(postLoginProcedures, logPrefix: 'Post-Login');
  }

  // ==================== Individual Procedures ====================

  /// Update FCM token on app startup
  static Future<void> _updateFcmToken() async {
    try {
      print('🔔 Starting FCM token update procedure...');
      
      // Check if user is logged in
      if (!SharedPrefsService.isLoggedIn()) {
        print('⚠️ User not logged in, skipping FCM token update');
        return;
      }

      // Get user ID from SharedPreferences
      final user = SharedPrefsService.getUserInfo;
      if (user.id == 0) {
        print('⚠️ Invalid user ID, skipping FCM token update');
        return;
      }

      // Get FCM token
      String? fcmToken = NotificationService().fcmToken;
      
      if (fcmToken == null || fcmToken.isEmpty) {
        print('⏳ FCM token not ready yet, waiting...');
        // Wait a bit for FCM token to be generated
        await Future.delayed(const Duration(seconds: 2));
        fcmToken = NotificationService().fcmToken;
      }

      if (fcmToken == null || fcmToken.isEmpty) {
        print('❌ FCM token still not available, skipping update');
        return;
      }

      print('📱 Updating FCM token for user ID: ${user.id}');
      print('🔑 FCM Token: $fcmToken');

      // Call the API
      final authService = AuthService();
      final response = await authService.updateFcmToken(
        userId: user.id,
        fcmToken: fcmToken,
      );

      if (response.status) {
        print('✅ FCM token updated successfully!');
      } else {
        print('⚠️ FCM token update returned: ${response.message}');
      }
    } catch (e) {
      print('❌ Error updating FCM token: $e');
      // Don't rethrow - we don't want to break app startup if this fails
    }
  }

  /// Load banners for wellness banner widget
  static Future<void> _loadBanners() async {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      await homeController.loadBanners();
    }
  }

  /// Load best health professionals
  static Future<void> _loadBestHealthProfessionals() async {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      await homeController.loadBestHealthProfessionals();
    }
  }

  /// Load upcoming appointments for home screen
  static Future<void> _loadUpcomingAppointments() async {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      await homeController.loadUpcomingAppointments();
    }
  }

  /// Load appointment statistics (for doctors only)
  static Future<void> _loadStatistics() async {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      if (!HelperFunctions.isUser()) {
        await homeController.loadApiStatistics();
      }
    }
  }

  // ==================== Refresh Procedures ====================

  /// Refresh all data (useful for pull-to-refresh)
  static Future<void> refreshAllData() async {
    await executeProcedures([
      ...postStartupProcedures,
      ...postLoginProcedures,
    ], logPrefix: 'Refresh');
  }

  /// Refresh only user-specific data
  static Future<void> refreshUserData() async {
    await executeProcedures(postLoginProcedures, logPrefix: 'User Refresh');
  }

  /// Refresh statistics when month changes
  static Future<void> refreshStatistics() async {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      await homeController.loadApiStatistics();
    }
  }

  /// Refresh chart data specifically
  static void refreshChartData() {
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      homeController.updateChartYAxisMax();
      homeController.update(); // Force UI update
    }
  }
}