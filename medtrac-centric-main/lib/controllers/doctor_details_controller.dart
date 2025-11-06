import 'package:get/get.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import '../api/models/doctor_response.dart';
import '../utils/snackbar.dart';

class DoctorDetailsController extends GetxController {
  final DoctorService _doctorService = DoctorService();
  
  // Observable variables
  var isLoading = false.obs;
  var doctor = Rx<Doctor?>(null);
  var doctorId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Get doctor ID from arguments
    final args = Get.arguments;
    if (args != null && args is int) {
      doctorId.value = args;
      loadDoctorDetails();
    }
  }

  /// Load doctor details
  Future<void> loadDoctorDetails() async {
    if (doctorId.value <= 0) {
      SnackbarUtils.showError('Invalid doctor ID', title: 'Error');
      return;
    }

    isLoading.value = true;
    
    try {
      final response = await _doctorService.getDoctorDetails(
        doctorId: doctorId.value,
      );

      if (response.success && response.data != null) {
        doctor.value = response.data!.data;
      } else {
        SnackbarUtils.showError(
          response.message ?? 'Failed to load doctor details',
          title: 'Error'
        );
        Get.back(); // Go back if failed to load
      }
    } catch (e) {
      SnackbarUtils.showError(
        'Failed to load doctor details: ${e.toString()}',
        title: 'Error'
      );
      Get.back(); // Go back if failed to load
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh doctor details
  Future<void> refreshDoctorDetails() async {
    await loadDoctorDetails();
  }
}