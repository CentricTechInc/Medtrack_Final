import 'package:get/get.dart';
import 'package:medtrac/controllers/daily_checkin_controller.dart';

class DailyCheckinBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyCheckinController>(() => DailyCheckinController());
  }
}