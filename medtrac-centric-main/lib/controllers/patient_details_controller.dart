import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/views/patient_details/widgets/patient_details_step_one.dart';
import 'package:medtrac/views/patient_details/widgets/patient_details_step_three.dart';
import 'package:medtrac/views/patient_details/widgets/patient_details_step_two.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'dart:io';

class PatientDetailsController extends GetxController {
  final GlobalKey<FormState> formKeyStepOne = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyStepTwo = GlobalKey<FormState>();

  // Text controllers for form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController additionalInfoController = TextEditingController();
  
  // Appointment booking data (passed from appointment booking screen)
  String? doctorAvailabilitySlotId;
  String? selectedDate;
  String? consultationType;
  double? consultationFee;
  // Optional doctor display info forwarded from booking
  String? doctorName;
  String? doctorSpeciality;
  String? doctorFees;
  String? doctorProfilePic;

  // File upload - single file only
  final Rx<File?> uploadedFile = Rx<File?>(null);
  
  // Loading state
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get data from appointment booking screen
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      doctorAvailabilitySlotId = args['slotId'];
      selectedDate = args['date']; 
      consultationType = args['consultationType'];
      consultationFee = args['consultationFee'];
      // Read optional doctor display info
      doctorName = args['doctorName'];
      doctorSpeciality = args['doctorSpeciality'];
      doctorFees = args['doctorFees'];
      doctorProfilePic = args['doctorProfilePic'];
    }
    
    // Initialize sliders to 0
    selectedMood.value = 0;
    selectedSleepOption.value = 0;
    selectedStressLevel.value = 0;
    selectedExcerciseOption.value = 0;
  }
  // Mood slider state for step three - initialize to 0
  final RxList<String> medicationTags = <String>[].obs;
  final TextEditingController medicationController = TextEditingController();
  final RxInt selectedMood = 0.obs;
  final RxInt selectedSleepOption = 0.obs;
  final RxInt selectedStressLevel = 0.obs;
  final RxInt selectedExcerciseOption = 0.obs;

  void setMood(int value) => selectedMood.value = value;
  void setSleep(int value) => selectedSleepOption.value = value;
  void setStressLevel(int value) => selectedStressLevel.value = value;
  void setExcercise(int value) => selectedExcerciseOption.value = value;

  void onMedicationChanged(String value) {
    if (value.endsWith(',')) {
      final tag = value.substring(0, value.length - 1).trim();
      if (tag.isNotEmpty) {
        medicationTags.add(tag);
      }
      medicationController.clear();
    }
  }

  void removeMedicationTag(String tag) {
    medicationTags.remove(tag);
  }

  // Primary concern tags
  final RxList<String> primaryConcerns = <String>[].obs;
  final TextEditingController primaryConcernController =TextEditingController();

  void onPrimaryConcernChanged(String value) {
    if (value.endsWith(',')) {
      final tag = value.substring(0, value.length - 1).trim();
      if (tag.isNotEmpty) {
        primaryConcerns.add(tag);
      }
      primaryConcernController.clear();
    }
  }

  void removePrimaryConcern(String tag) {
    primaryConcerns.remove(tag);
  }

  RxInt currentStep = 1.obs;
  final RxString selectedGender = ''.obs;
  final RxString selectedBloodGroup = ''.obs;
  final RxString selectedDuration = '1-3 Months'.obs;
  final RxString selectedDiagnosis = 'Yes'.obs;
  // Restrict gender options to Male/Female only
  // Note: Update this list if you want to allow other options again
  final List<String> genderOptions = ['Male', 'Female'];
  final List<String> durationOptions = [
    '1 Week',
    '2 Weeks',
    '3 Weeks',
    '4 Weeks',
    '1-3 Months'
  ];
  final List<String> diagnosisOptions = [
    'Yes',
    'No',
  ];
  final List<String> bloodGroupOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  final List<String> moodOptions = [
    'Very Poor',
    'Poor',
    'Neutral',
    'Good',
    'Excellent'
  ];

  final List<String> sleepQualityOptions = [
    'Very Poor',
    'Poor',
    'Fair',
    'Good',
    'Excellent'
  ];

  final List<String> stressLevelOptions = [
    'Very Low',
    'Low',
    'Moderate',
    'High',
    'Very High'
  ];

  final List<String> excerciseOptions = [
    'Never',
    'Rarely',
    'Sometimes',
    'Often',
    'Daily'
  ];

  List<Widget> steps = [
    const PatientDetailsStepOne(),
    const PatientDetailsStepTwo(),
    const PatientDetailsStepThree(),
  ];

  void onContinuePressed() {
    if (isSubmitting.value) return; // Prevent multiple submissions
    
    switch (currentStep.value) {
      case 1:
        if (_validateStepOne()) {
          currentStep.value++;
        }
        break;
      case 2:
        if (_validateStepTwo()) {
          currentStep.value++;
        }
        break;
      case 3:
        _submitAppointment();
        break;
    }
  }

  bool _validateStepOne() {
    bool isFormValid = formKeyStepOne.currentState?.validate() ?? false;
    
    // Additional validation for dropdowns
    if (selectedGender.value.isEmpty) {
      SnackbarUtils.showError('Please select your gender');
      return false;
    }
    if (selectedBloodGroup.value.isEmpty) {
      SnackbarUtils.showError('Please select your blood group');
      return false;
    }
    
    return isFormValid;
  }

  bool _validateStepTwo() {
    if (primaryConcerns.isEmpty) {
      SnackbarUtils.showError('Please add at least one primary concern');
      return false;
    }
    if (selectedDuration.value.isEmpty) {
      SnackbarUtils.showError('Please select duration');
      return false;
    }
    if (selectedDiagnosis.value.isEmpty) {
      SnackbarUtils.showError('Please select diagnosis option');
      return false;
    }
    return true;
  }

  Future<void> _submitAppointment() async {
    if (isSubmitting.value) return; // Prevent double submission
    
    // Validate required data from appointment booking
    if (doctorAvailabilitySlotId == null || selectedDate == null) {
      SnackbarUtils.showError('Missing appointment booking data');
      return;
    }

    // Navigate to summary screen - API will be called there
    Get.toNamed(AppRoutes.appointmentBookingSummaryScreen, arguments: {
      'slotId': doctorAvailabilitySlotId,
      'date': selectedDate,
      'consultationType': consultationType,
      'consultationFee': consultationFee,
      'doctorName': doctorName,
      'doctorSpeciality': doctorSpeciality,
      'doctorFees': doctorFees,
      'doctorProfilePic': doctorProfilePic,
    });
  }

  void setGender(String? gender) {
    if (gender != null) {
      selectedGender.value = gender;
    }
  }

  void setBloodGroup(String? bloodGroup) {
    if (bloodGroup != null) {
      selectedBloodGroup.value = bloodGroup;
    }
  }

  void setDuration(String? duration) {
    if (duration != null) {
      selectedDuration.value = duration;
    }
  }

  void setDiagnosis(String? diagnosis) {
    if (diagnosis != null) {
      selectedDiagnosis.value = diagnosis;
    }
  }

  void onBackPressed() {
    if (currentStep.value > 1) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  // File handling methods
  void addFile(File file) {
    uploadedFile.value = file;
  }

  void removeFile() {
    uploadedFile.value = null;
  }

  void clearFiles() {
    uploadedFile.value = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    additionalInfoController.dispose();
    medicationController.dispose();
    primaryConcernController.dispose();
    super.onClose();
  }
}
