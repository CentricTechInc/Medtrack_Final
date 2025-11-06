import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:medtrac/services/shared_preference_service.dart';

/// Service to handle patient profile operations
class PatientProfileService extends GetxService {
  static PatientProfileService get instance => Get.find<PatientProfileService>();
  
  final PatientService _patientService = PatientService();
  final RxBool isLoading = false.obs;

  /// Fetch patient profile if user is logged in and is a patient
  Future<void> fetchPatientProfileIfNeeded() async {
    try {
      // Only fetch if user is logged in and is a patient
      if (!SharedPrefsService.isLoggedIn() || !HelperFunctions.isUser()) {
        return;
      }

      isLoading.value = true;
      await _patientService.getPatientProfile();
    } catch (e) {
      // Don't throw error to prevent breaking app flow
      print('Failed to fetch patient profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Initialize the service when app starts
  @override
  void onInit() {
    super.onInit();
    // Fetch profile when service initializes if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPatientProfileIfNeeded();
    });
  }
}
