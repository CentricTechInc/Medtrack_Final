import 'package:get/get.dart';
import 'package:medtrac/controllers/drawer_controller.dart';

class AppBarContoller extends GetxController {
  void onTapMenuIcon() {
    if (Get.isRegistered<CustomDrawerController>()) {
      final drawerController = Get.find<CustomDrawerController>();
      // Only open drawer if it's properly initialized
      if (drawerController.isInitialized.value) {
        drawerController.openDrawer();
      }
    }
  }
}
