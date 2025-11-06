import 'dart:io';
import 'package:get/get.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'package:medtrac/controllers/personal_info_controller.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/snackbar.dart';

class AvailabilityController extends GetxController {
  RxList<DateTime> selectedDates = <DateTime>[].obs;
  RxList<String> selectedTimings = <String>[].obs;
  RxBool isLoading = false.obs;

  final DoctorService _doctorService = DoctorService();

  void handleContinue({required bool fromRegistration}) async {
    // Get the personal info controller to access validation data
    final PersonalInfoController personalInfoController = Get.find<PersonalInfoController>();
    
    // Validate that each slot has both date and time selected
    bool isValid = true;
  // removed unused missingSlots variable
    
    for (String slot in personalInfoController.slotOptions) {
      List<String> selectedTimings = personalInfoController.selectedTimingsForSlot[slot] ?? [];
      if (selectedTimings.isNotEmpty) {
        isValid = true;
        break;
      }
    }
    if (!isValid) {
      SnackbarUtils.showError("Please select at least one time for any slot (Morning, Afternoon, or Evening)");
      return;
    }

    if (fromRegistration) {
      // If this is from registration, call the update profile API
      await _updateProfile();
    } else {
      Get.back();
    }
  }

  Future<void> _updateProfile() async {
    try {
      isLoading.value = true;

      // Get the personal info controller to access all the form data
      final PersonalInfoController personalInfoController = Get.find<PersonalInfoController>();

      // Prepare profile picture
      File? profilePicture;
      if (personalInfoController.selectedImage.value != null) {
        profilePicture = personalInfoController.selectedImage.value!;
      }
      
      // Prepare certificate files
      List<File> certificateFiles = [];
      for (var doc in personalInfoController.certificationDocument) {
        if (doc != null && doc.path != null) {
          certificateFiles.add(File(doc.path!));
        }
      }

      // Prepare dates and slots data based on the new structure
      List<String> formattedDates = [];
      Map<String, List<String>> slotsMap = {
        'Morning': [],
        'Afternoon': [],
        'Evening': [],
      };

      // Collect data for each slot
      // Dates are now flat and independent of slot
      for (final selectedDate in personalInfoController.selectedDates) {
        DateTime fullDate = DateTime(
          personalInfoController.currentCalendarDate.value.year,
          personalInfoController.currentCalendarDate.value.month,
          selectedDate,
        );
        String formattedDate = "${fullDate.year}-${fullDate.month.toString().padLeft(2, '0')}-${fullDate.day.toString().padLeft(2, '0')}";
        if (!formattedDates.contains(formattedDate)) {
          formattedDates.add(formattedDate);
        }
      }
      slotsMap['Morning'] = personalInfoController.selectedTimingsForSlot['Morning'] ?? [];
      slotsMap['Afternoon'] = personalInfoController.selectedTimingsForSlot['Afternoon'] ?? [];
      slotsMap['Evening'] = personalInfoController.selectedTimingsForSlot['Evening'] ?? [];

      // Call the API
      final response = await _doctorService.updateProfile(
        picture: profilePicture,
        certificate: certificateFiles.isNotEmpty ? certificateFiles : null,
        speciality: personalInfoController.specialtySelectedValue.value,
        licenseNumber: personalInfoController.licenseNumberController.text,
        emergencyFees: personalInfoController.emergencyFeesController.text.replaceAll('₹', ''),
        regularFees: personalInfoController.regularFeesController.text.replaceAll('₹', ''),
        totalExperience: personalInfoController.experienceController.text,
        aboutMe: personalInfoController.aboutMeController.text,
        monthNumber: personalInfoController.currentCalendarDate.value.month,
        monthName: personalInfoController.currentMonthName,
        dates: formattedDates,
        slots: slotsMap,
        isEmergencyFees: personalInfoController.isEmergencyConsultation.value,
      );

      if (response.success) {
        SnackbarUtils.showSuccess(response.message ?? 'Profile updated successfully');
        SharedPrefsService.setProfileComplete(true);
        
        // Navigate to account info screen
        Get.toNamed(AppRoutes.accountInfoScreen, arguments: {
          "fromRegisteration": true,
        });
      } else {
        SnackbarUtils.showError(response.message ?? 'Failed to update profile');
      }

    } catch (e) {
      SnackbarUtils.showError('Error updating profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

}
