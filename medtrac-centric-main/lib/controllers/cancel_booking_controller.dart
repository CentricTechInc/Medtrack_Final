import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/controllers/appointments_controller.dart';
import 'package:medtrac/views/appointments/widgets/cancel_appointment_bottom_sheet.dart';

class CancelBookingController extends GetxController {
  final PatientService _patientService = PatientService();
  
  RxList<String> cancelReasons = <String>[
    'Unexpected Work',
    'Technical Difficulties',
    'Health Issues',
    'Other',
  ].obs;

  RxString selectedReason = ''.obs;
  final TextEditingController reasonTextController = TextEditingController();
  
  // Loading state
  final isLoading = false.obs;
  
  // Doctor information from arguments
  int appointmentId = 0;
  String doctorName = '';
  String doctorImage = '';
  String doctorSpeciality = '';
  String appointmentDate = '';
  String appointmentTime = '';

  @override
  void onInit() {
    super.onInit();
    
    // Get data from arguments
    final args = Get.arguments;
    if (args != null) {
      appointmentId = args['appointmentId'] ?? 0;
      doctorName = args['doctorName'] ?? 'Unknown Doctor';
      doctorImage = args['doctorImage'] ?? '';
      doctorSpeciality = args['doctorSpeciality'] ?? '';
      appointmentDate = args['appointmentDate'] ?? '';
      appointmentTime = args['appointmentTime'] ?? '';
    }
  }

  @override
  void onClose() {
    reasonTextController.dispose();
    super.onClose();
  }

  void showCancelConfirmation() {
    if (!_validateForm()) return;
    
    Get.bottomSheet(
      CancelAppointmentBottomSheet(
        doctorName: doctorName,
        onConfirm: () {
          Get.back(); // Close bottom sheet
          cancelAppointment(); // Proceed with cancellation
        },
        onCancel: () {
          Get.back(); // Just close bottom sheet
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> cancelAppointment() async {
    if (!_validateForm()) return;
    
    try {
      isLoading.value = true;
      
      // Format reason as "radio option:text entered in the field"
      String reason = selectedReason.value;
      if (reasonTextController.text.isNotEmpty) {
        reason += ':${reasonTextController.text}';
      }
      
      final response = await _patientService.cancelAppointment(
        appointmentId: appointmentId,
        reason: reason,
      );
      
      if (response.success) {
        Get.back();
        
        // Force refresh appointments list if available
        try {
          final appointmentsController = Get.find<AppointmentsController>();
          appointmentsController.forceRefresh();
        } catch (e) {
          // AppointmentsController not found, ignore
        }
        
        Get.snackbar(
          'Success',
          'Appointment cancelled successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to cancel appointment',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel appointment: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (selectedReason.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a reason for cancellation',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }
    
    if (reasonTextController.text.trim().isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter additional details',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }
    
    return true;
  }

  // Qualifications stay hardcoded as requested
  String get doctorQualifications => 'MBBS, M.D (Psychiatry)';
}