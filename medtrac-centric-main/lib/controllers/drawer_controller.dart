import 'package:get/get.dart';
import 'package:medtrac/api/models/user.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/enums.dart';

class CustomDrawerController extends GetxController {
  final RxBool isDrawerOpen = false.obs;
  final RxBool isInitialized = false.obs;

  User get user {
    try {
      return SharedPrefsService.getUserInfo;
    } catch (e) {
      print('❌ Error getting user in drawer controller: $e');
      // Return default user if there's an error
      return User(
        id: 0,
        name: '',
        email: '',
        phone: '',
        profilePicture: '',
        role: Role.user,
        isProfileComplete: false,
        age: '',
        gender: '',
      );
    }
  }

  String get userName => user.name.isEmpty ? 'User' : user.name;
  String get userEmail => user.email.isEmpty ? '' : user.email;
  String get userProfilePhoto => user.profilePicture;

  @override
  void onInit() {
    super.onInit();
    // Drawer controller initialization - no need to initialize reviews controller here
    // as it will be created by the binding when needed
  }

  @override
  void onReady() {
    super.onReady();
    // Mark as initialized after the widget tree is built
    Future.delayed(Duration(milliseconds: 100), () {
      isInitialized.value = true;
    });
  }

  void onDrawerStateChange() {
    if (!isInitialized.value) return;
    isDrawerOpen.value = !isDrawerOpen.value;
  }

  void openDrawer() {
    if (!isInitialized.value) return;
    isDrawerOpen.value = true;
  }

  void closeDrawer() {
    if (!isInitialized.value) return;
    isDrawerOpen.value = false;
  }

  void toggleDrawer() {
    if (!isInitialized.value) return;
    onDrawerStateChange();
  }

  void setInitialized() {
    isInitialized.value = true;
  }
}
