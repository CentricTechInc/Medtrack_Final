import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/views/appointments/widgets/appointment_booked_bottom_sheet.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/controllers/patient_details_controller.dart';
import 'package:medtrac/api/services/doctor_service.dart';

class AppointmentBookingSummaryController extends GetxController {
  final DoctorService _doctorService = DoctorService();
  
  // Get reference to patient details controller
  PatientDetailsController? _patientDetailsController;
  
  // Appointment data from patient details
  final RxString doctorName = 'Dr. Neha Sharma'.obs; // TODO: Get from doctor details
  final RxString doctorSpecialty = 'Psychiatrist'.obs; // TODO: Get from doctor details
  final RxString doctorProfilePic = ''.obs; // TODO: Get from doctor details
  final RxString appointmentDate = ''.obs;
  final RxString consultationType = ''.obs;
  final RxDouble consultationFee = 0.0.obs;
  final RxString patientName = ''.obs;
  final RxList<String> primaryConcerns = <String>[].obs;
  
  // API call state
  final RxBool isSubmitting = false.obs;
  
  @override 
  void onInit() {
    super.onInit();
    
    // Get reference to patient details controller
    try {
      _patientDetailsController = Get.find<PatientDetailsController>();
      _loadDataFromPatientDetails();
    } catch (e) {
      // If controller not found, try to get data from arguments
      _loadDataFromArguments();
    }
  }
  
  void _loadDataFromPatientDetails() {
    if (_patientDetailsController != null) {
      // Format date from yyyy-MM-dd to readable format
      final dateStr = _patientDetailsController!.selectedDate ?? '';
      if (dateStr.isNotEmpty) {
        try {
          final date = DateTime.parse(dateStr);
          appointmentDate.value = "${date.day}/${date.month}/${date.year}";
        } catch (e) {
          appointmentDate.value = dateStr;
        }
      }
      
      consultationType.value = _patientDetailsController!.consultationType ?? '';
      consultationFee.value = _patientDetailsController!.consultationFee ?? 0.0;
      patientName.value = _patientDetailsController!.nameController.text.trim();
      primaryConcerns.assignAll(_patientDetailsController!.primaryConcerns.toList());
      doctorName.value = _patientDetailsController!.doctorName ?? doctorName.value;
      doctorSpecialty.value = _patientDetailsController!.doctorSpeciality ?? "";
      doctorProfilePic.value = _patientDetailsController!.doctorProfilePic ?? "";
    }
  }
  
  void _loadDataFromArguments() {
    // Fallback: Get appointment data from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['appointmentData'] != null) {
      final appointmentData = args['appointmentData'] as Map<String, dynamic>;
      appointmentDate.value = appointmentData['date'] ?? '';
      consultationType.value = appointmentData['consultationType'] ?? '';
      consultationFee.value = appointmentData['consultationFee'] ?? 0.0;
      patientName.value = appointmentData['patientName'] ?? '';
      if (appointmentData['primaryConcerns'] != null) {
        primaryConcerns.assignAll(List<String>.from(appointmentData['primaryConcerns']));
      }
    }
  }
  
  Future<void> createAppointment() async {
    if (isSubmitting.value) return;
    
    // Ensure we have patient details controller
    if (_patientDetailsController == null) {
      SnackbarUtils.showError('Patient details not found');
      return;
    }
    
    isSubmitting.value = true;
    
    try {
      // Validate required data
      if (_patientDetailsController!.doctorAvailabilitySlotId == null || 
          _patientDetailsController!.selectedDate == null) {
        SnackbarUtils.showError('Missing appointment booking data');
        return;
      }

      // Prepare questions from step 3 sliders
      final questions = [
        {
          "questions": "How are you feeling?",
          "answer": _patientDetailsController!.moodOptions[_patientDetailsController!.selectedMood.value]
        },
        {
          "questions": "How would you rate your sleep?", 
          "answer": _patientDetailsController!.sleepQualityOptions[_patientDetailsController!.selectedSleepOption.value]
        },
        {
          "questions": "How is your stress level?",
          "answer": _patientDetailsController!.stressLevelOptions[_patientDetailsController!.selectedStressLevel.value]
        },
        {
          "questions": "How often do you exercise?",
          "answer": _patientDetailsController!.excerciseOptions[_patientDetailsController!.selectedExcerciseOption.value]
        }
      ];

      // Call the API - ensure all parameters match the working Postman format
      final response = await _doctorService.createAppointment(
        doctorAvailabilitySlotId: _patientDetailsController!.doctorAvailabilitySlotId!,
        date: _patientDetailsController!.selectedDate!,
        consultationType: _patientDetailsController!.consultationType ?? 'Standard',
        consultationFee: (_patientDetailsController!.consultationFee ?? 0.0).round().toString(),
        primaryConcerns: _patientDetailsController!.primaryConcerns.toList(),
        medsPrescribed: _patientDetailsController!.medicationTags.isNotEmpty ? 'Yes' : 'No',
        name: _patientDetailsController!.nameController.text.trim(),
        bloodGroup: _patientDetailsController!.selectedBloodGroup.value,
        questions: questions,
        medicationTreatment: _patientDetailsController!.medicationTags.toList(),
        duration: _patientDetailsController!.selectedDuration.value,
        diagnosis: _patientDetailsController!.selectedDiagnosis.value,
        additionalInformation: _patientDetailsController!.additionalInfoController.text.trim().isEmpty 
            ? 'No additional information provided' 
            : _patientDetailsController!.additionalInfoController.text.trim(),
        gender: _patientDetailsController!.selectedGender.value,
        height: _patientDetailsController!.heightController.text.trim(),
        weight: _patientDetailsController!.weightController.text.trim(),
        age: _patientDetailsController!.ageController.text.trim(),
        file: _patientDetailsController!.uploadedFile.value,
      );
      
      if (response.success) {
        showAppointmentBookedBottomSheet();
      } else {
        SnackbarUtils.showError(response.message ?? 'Failed to create appointment');
      }
    } catch (e) {
      SnackbarUtils.showError('Failed to create appointment: ${e.toString()}');
    } finally {
      isSubmitting.value = false;
    }
  }
  void showAppointmentBookedBottomSheet() {
    if (Get.isBottomSheetOpen == true) {
      return;
    }

    Get.bottomSheet(
      AppointmentBookedBottomSheet(),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
    );
  }
}
