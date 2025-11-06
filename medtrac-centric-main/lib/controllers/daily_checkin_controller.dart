import 'package:get/get.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/controllers/home_controller.dart';

class DailyCheckinController extends GetxController {
  final PatientService _patientService = PatientService();

  // Loading state
  final RxBool isSubmitting = false.obs;

  // Mood options mapping (matching UI labels exactly)
  final List<String> moodLabels = ['Happy', 'Calm', 'Neutral', 'Sad', 'Angry'];

  // Sleep options mapping (matching UI labels exactly)
  final List<String> sleepLabels = [
    '7-9 hrs',
    '6-7 hrs',
    '5 hrs',
    '3-4 hrs',
    '< 3hrs'
  ];

  /// Submit daily emotions to API
  Future<void> submitEmotions({
    required int selectedMood,
    required int selectedSleep,
    required int selectedStressLevel,
  }) async {
    if (isSubmitting.value) return;

    try {
      isSubmitting.value = true;

      // Map indices to actual values
      final currentMood = moodLabels[selectedMood];
      final sleepQuality = sleepLabels[selectedSleep];

      final response = await _patientService.submitEmotions(
        sleepQuality: sleepQuality,
        stressLevel: selectedStressLevel,
        currentMood: currentMood,
      );

      if (response.success) {
        // Mark check-in as done for today
        await SharedPrefsService.setLastDailyCheckinDateToToday();

        // Reload emotions analytics in HomeController to update charts
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          await homeController.loadEmotionsAnalytics();
        }

        Get.back();
        SnackbarUtils.showSuccess(
          response.message ?? 'Daily check-in submitted successfully!',
        );
        Future.delayed(const Duration(seconds: 1), () {
          SnackbarUtils.closeSnackbar();
        });
      } else {
        SnackbarUtils.showError(
          response.message ?? 'Failed to submit daily check-in',
        );
      }
    } catch (e) {
      SnackbarUtils.showError(
        'Error submitting daily check-in: ${e.toString()}',
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
