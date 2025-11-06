import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medtrac/api/models/user.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/views/presonal_info_user/user_basic_info_tab.dart';
import 'package:medtrac/views/presonal_info_user/user_medical_history_tab.dart';

class UserProfileController extends GetxController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final genderController = TextEditingController();
  final phoneController = TextEditingController();
  final numberController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final TextEditingController primaryConcernController = TextEditingController();
  final TextEditingController medicationController = TextEditingController();
  
  // Make currentUser reactive so it updates when SharedPrefs changes
  late Rx<User> currentUser;

  final SharedPrefsService prefs = SharedPrefsService.instance;
  final PatientService _patientService = PatientService();

  // Loading state
  final RxBool isLoading = false.obs;

  RxInt currentIndex = RxInt(0);
  final Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();
  final RxString selectedGender = 'Male'.obs;
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final RxString selectedBloodGroup = 'A+'.obs;

  RxList<Widget> tabs = RxList();
  final RxList<String> medicationTags =
      <String>['Paracetamol', 'Vitamin D'].obs;
  final RxList<String> primaryConcerns =
      <String>['Headache', 'Back Pain', 'Fatigue'].obs;

  @override
  void onInit() {
    // Initialize currentUser as reactive
    currentUser = Rx<User>(SharedPrefsService.getUserInfo);
    
    tabs = <Widget>[
      UserBasicInfoTab(controller: this),
      UserMedicalHistoryTab(controller: this),
    ].obs;
    
    _loadUserData();
    super.onInit();
  }

  void _loadUserData() {
    // Load basic user info from currentUser
    fullNameController.text = currentUser.value.name;
    emailController.text = currentUser.value.email;
    phoneController.text = currentUser.value.phone;
    ageController.text = currentUser.value.age; // age is already a String
    selectedGender.value = currentUser.value.gender.isEmpty ? 'Male' : currentUser.value.gender;

    // Load medical history
    final medicalHistory = SharedPrefsService.getUserMedicalHistory;
    selectedBloodGroup.value = medicalHistory.bloodGroup.isEmpty ? 'A+' : medicalHistory.bloodGroup;
    weightController.text = medicalHistory.weight;
    medicationTags.assignAll(medicalHistory.medications);
    primaryConcerns.assignAll(medicalHistory.primaryConcerns);
  }

  /// Refresh currentUser data from SharedPreferences
  void refreshUserData() {
    currentUser.value = SharedPrefsService.getUserInfo;
    _loadUserData();
  }

  void onPrimaryConcernChanged(String value) {
    if (value.endsWith(',')) {
      final tag = value.substring(0, value.length - 1).trim();
      if (tag.isNotEmpty) {
        primaryConcerns.add(tag);
      }
      primaryConcernController.clear();
    }
  }

  void onMedicationChanged(String value) {
    if (value.endsWith(',')) {
      final tag = value.substring(0, value.length - 1).trim();
      if (tag.isNotEmpty) {
        medicationTags.add(tag);
      }
      medicationController.clear();
    }
  }

  void removePrimaryConcern(String tag) {
    primaryConcerns.remove(tag);
  }

  void removeMedicationTag(String tag) {
    medicationTags.remove(tag);
  }

  void setGender(String? gender) {
    if (gender != null) {
      selectedGender.value = gender;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      SnackbarUtils.showError('Failed to pick image: $e');
    }
  }

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

  void setBloodGroup(String? bloodGroup) {
    if (bloodGroup != null) {
      selectedBloodGroup.value = bloodGroup;
    }
  }

  void showImageSourceSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Get.back();
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Get.back();
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onTabChanged(int index) {
    currentIndex.value = index;
  }

  // Update user profile
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      // Prepare data for API call
      final response = await _patientService.updateBasicInfo(
        picture: selectedImage.value,
        name: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        age: ageController.text.trim(),
        weight: weightController.text.trim(),
        gender: selectedGender.value,
        bloodGroup: selectedBloodGroup.value,
        primaryConcern: primaryConcerns.join(','),
        medication: medicationTags.join(','),
      );

      if (response.success) {
        // The PatientService.updateBasicInfo method will automatically call getPatientProfile()
        // to update SharedPreferences, so we just need to refresh our local data
        refreshUserData();
        
        SnackbarUtils.showSuccess(response.message ?? 'Profile updated successfully');
        // Get.back();
      } else {
        SnackbarUtils.showError(response.message ?? 'Failed to update profile');
      }
    } catch (e) {
      SnackbarUtils.showError('Error updating profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    genderController.dispose();
    phoneController.dispose();
    ageController.dispose();
    weightController.dispose();
    primaryConcernController.dispose();
    medicationController.dispose();
    super.dispose();
  }
}
