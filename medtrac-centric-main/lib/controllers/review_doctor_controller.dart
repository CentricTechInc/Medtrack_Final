import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';
import 'package:medtrac/controllers/appointments_controller.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/snackbar.dart';

class ReviewDoctorController extends GetxController {
  final PatientService _patientService = PatientService();
  
  TextEditingController reviewController = TextEditingController();
  RxBool wouldRecommend = true.obs;
  RxDouble rating = 0.0.obs;
  RxBool isSubmitting = false.obs;
  
  // Doctor info from arguments
  RxInt doctorId = 0.obs;
  RxString doctorName = ''.obs;
  RxInt callDuration = 0.obs;
  RxString doctorImage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Get arguments passed from video call
    final arguments = Get.arguments;
    if (arguments != null) {
      doctorId.value = arguments['doctorId'] ?? 0;
      doctorName.value = arguments['doctorName'] ?? '';
      callDuration.value = arguments['callDuration'] ?? 0;
      doctorImage.value = arguments['doctorImage'] ?? '';
      
      print('📝 Review screen initialized:');
      print('   Doctor ID: ${doctorId.value}');
      print('   Doctor Name: ${doctorName.value}');
      print('   Call Duration: ${callDuration.value} seconds');
      print('   Doctor Image: ${doctorImage.value}');
    }
  }
  
  /// Submit review to the API
  Future<void> submitReview() async {
    // Validate rating
    if (rating.value == 0.0) {
      SnackbarUtils.showCustom(
        iconPath: Assets.snackBarSuccessIcon,
        message: 'Please provide a rating',
      );
      return;
    }
    
    // Validate review text
    if (reviewController.text.trim().isEmpty) {
      SnackbarUtils.showCustom(
        iconPath: Assets.snackBarSuccessIcon,
        message: 'Please write a review',
      );
      return;
    }
    
    // Validate doctor ID
    if (doctorId.value == 0) {
      SnackbarUtils.showCustom(
        iconPath: Assets.snackBarSuccessIcon,
        message: 'Doctor information missing',
      );
      return;
    }
    
    try {
      isSubmitting.value = true;
      
      final response = await _patientService.submitReview(
        doctorId: doctorId.value,
        rating: rating.value,
        description: reviewController.text.trim(),
        recommended: wouldRecommend.value,
      );
      
      if (response.success) {
        SnackbarUtils.showCustom(
          iconPath: Assets.snackBarSuccessIcon,
          message: 'We appreciate your feedback',
        );
        
        // Navigate to appointments tab with completed appointments selected
        Future.delayed(
          const Duration(seconds: 2),
          () {
            // Navigate to main screen
            Get.offAllNamed(AppRoutes.mainScreen);
            
            // Set appointments tab (index 1)
            final bottomNavbarController = Get.find<BottomNavigationController>();
            bottomNavbarController.selectedNavIndex.value = 1;
            
            // Set completed tab (index 1)
            try {
              final appointmentsController = Get.find<AppointmentsController>();
              appointmentsController.currentIndex.value = 1; // Completed tab
              appointmentsController.tabController.animateTo(1);
            } catch (e) {
              print('Error setting completed tab: $e');
            }
          },
        );
      } else {
        SnackbarUtils.showCustom(
          iconPath: Assets.snackBarSuccessIcon,
          message: response.message ?? 'Failed to submit review',
        );
      }
    } catch (e) {
      print('❌ Error submitting review: $e');
      SnackbarUtils.showCustom(
        iconPath: Assets.snackBarSuccessIcon,
        message: 'Failed to submit review. Please try again.',
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}