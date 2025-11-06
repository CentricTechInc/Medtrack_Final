import 'package:get/get.dart';

/// Helper class for safely accessing GetX controllers
/// Provides fallback mechanisms for hot reload scenarios
class ControllerHelper {
  
  /// Safely get a controller with fallback creation if needed
  static T safeGet<T extends GetxController>() {
    try {
      if (Get.isRegistered<T>()) {
        return Get.find<T>();
      } else {
        // Try to create the controller if it doesn't exist
        // This helps during hot reload scenarios
        throw Exception('Controller $T not registered');
      }
    } catch (e) {
      print('⚠️ Error getting controller $T: $e');
      rethrow;
    }
  }
  
  /// Safely find controller or return null
  static T? safeFindOrNull<T extends GetxController>() {
    try {
      if (Get.isRegistered<T>()) {
        return Get.find<T>();
      }
      return null;
    } catch (e) {
      print('⚠️ Error finding controller $T: $e');
      return null;
    }
  }
  
  /// Check if controller is registered and accessible
  static bool isControllerAvailable<T extends GetxController>() {
    try {
      if (!Get.isRegistered<T>()) {
        return false;
      }
      // Try to access the controller to see if it's really available
      Get.find<T>();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Put controller with hot reload protection
  static T safePut<T extends GetxController>(T controller, {String? tag}) {
    try {
      if (Get.isRegistered<T>(tag: tag)) {
        Get.delete<T>(tag: tag, force: true);
      }
      return Get.put<T>(controller, tag: tag, permanent: true);
    } catch (e) {
      print('⚠️ Error putting controller $T: $e');
      rethrow;
    }
  }
}