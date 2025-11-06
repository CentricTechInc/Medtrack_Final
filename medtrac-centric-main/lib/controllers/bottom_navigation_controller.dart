import 'package:get/get.dart';
import 'package:medtrac/controllers/home_controller.dart';


class BottomNavigationController extends GetxController {
  var selectedNavIndex = 0.obs;

  void onNavItemTapped(int index) {
    selectedNavIndex.value = index;

    // If user navigated to Home tab, trigger banner reload
    if (index == 0) {
      try {
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          homeController.loadBanners();
        }
      } catch (e) {
        // ignore errors to avoid breaking navigation
        print('Error triggering loadBanners on nav: $e');
      }
    }
  }

  /// Reset navigation to home tab
  void resetToHome() {
    selectedNavIndex.value = 0;
  }
}
