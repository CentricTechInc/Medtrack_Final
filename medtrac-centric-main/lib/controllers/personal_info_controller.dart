import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:medtrac/api/models/user.dart';
import 'package:medtrac/api/models/doctor_availability_response.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/views/presonal_info/personal_info_tab.dart';
import 'package:medtrac/views/presonal_info/professional_info_tab.dart';

class PersonalInfoController extends GetxController {
  // Text controllers for form fields
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final genderController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final experienceController = TextEditingController();
  final aboutMeController = TextEditingController();
  final regularFeesController = TextEditingController(text: '₹50');
  final emergencyFeesController = TextEditingController(text: '₹100');
  final bool fromRegisteration = (Get.arguments?['fromRegisteration'] ?? false);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Doctor service for API calls
  final DoctorService _doctorService = DoctorService();

  // Loading state
  final RxBool isLoading = false.obs;

  final RxString specialtySelectedValue = ''.obs;

  // Profile image
  final Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  final RxBool isSpecialtyReadOnly = false.obs;
  final RxBool isLicenseReadOnly = false.obs;

  final List<String> specialtyOptions = [
    'Psychiatrist',
    'Psychologist',
    'Therapist',
  ];

  late final RxList<Widget> tabs;

  // Availability selection
  final Rx<DateTime> currentCalendarDate = DateTime.now().obs;
  // (removed duplicate declaration of selectedDates)
  final RxInt daysInMonth = 31.obs;
  final RxInt firstWeekdayOfMonth = 1.obs; // 1 for Monday, 7 for Sunday

  // API-based availability data
  final Rx<DoctorAvailabilityData?> availabilityData =
      Rx<DoctorAvailabilityData?>(null);
  final RxBool isLoadingAvailability = false.obs;
  final RxBool hasAvailabilityError = false.obs;
  final RxString availabilityErrorMessage = ''.obs;

  // Time slots - now dynamic from API
  final RxString selectedSlot = 'Morning'.obs; // Default to Morning
  final RxList<String> availableSlotTypes = <String>[].obs; // Dynamic from API

  final RxList<String> selectedTimings = <String>[].obs;

  // Default dummy slots to fall back to when API returns empty
  static const Map<String, List<String>> defaultDummySlots = {
    'Morning': [
      '7AM - 8AM',
      '8AM - 9AM',
      '9AM - 10AM',
      '10AM - 11AM',
      '11AM - 12PM',
    ],
    'Afternoon': [
      '12PM - 1PM',
      '1PM - 2PM',
      '2PM - 3PM',
      '3PM - 4PM',
      '4PM - 5PM',
      '5PM - 6PM',
    ],
    'Evening': [
      '6PM - 7PM',
      '7PM - 8PM',
      '8PM - 9PM',
      '9PM - 10PM',
      '10PM - 11PM',
    ],
  };

  // Dynamic getters for slot options and time slots
  List<String> get slotOptions => availableSlotTypes.isNotEmpty
      ? availableSlotTypes
      : ['Morning', 'Afternoon', 'Evening']; // Fallback

  Map<String, List<String>> get timeSlots {
    // If there's an error or no data, return empty slots
    // If there's an error (network or server error), return empty to show message
    if (hasAvailabilityError.value) {
      return {
        'Morning': [],
        'Afternoon': [],
        'Evening': [],
      };
    }

    // If API provided slots data use it, otherwise fallback to defaultDummySlots
    if (availabilityData.value?.slots == null) {
      return defaultDummySlots.map((k, v) => MapEntry(k, List<String>.from(v)));
    }

    final slots = availabilityData.value!.slots;
    return {
      'Morning': slots
          .getSlotsForType('Morning')
          .where((slot) => slot.status == 'Available')
          .map((slot) => slot.time)
          .toList(),
      'Afternoon': slots
          .getSlotsForType('Afternoon')
          .where((slot) => slot.status == 'Available')
          .map((slot) => slot.time)
          .toList(),
      'Evening': slots
          .getSlotsForType('Evening')
          .where((slot) => slot.status == 'Available')
          .map((slot) => slot.time)
          .toList(),
    };
  }

  // Gender selection
  final RxString selectedGender = 'Male'.obs;
  final List<String> genderOptions = ['Male', 'Female', 'Other'];

  // Store a single certification document
  RxList<PlatformFile?> certificationDocument = <PlatformFile>[].obs;

  // Store selected dates (flat, independent of slot)
  final RxList<int> selectedDates = <int>[].obs;
  // Store selected timings for each slot
  final RxMap<String, List<String>> selectedTimingsForSlot =
      <String, List<String>>{
    'Morning': <String>[],
    'Afternoon': <String>[],
    'Evening': <String>[],
  }.obs;

  // Emergency consultation
  final RxBool isEmergencyConsultation = true.obs;

  // Make user data reactive
  late Rx<User> user;

  // Check if user has certificate from API
  bool get hasCertificateFromAPI => user.value.certificate.isNotEmpty;
  String get certificateURL => user.value.certificate;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize user as reactive
    user = Rx<User>(SharedPrefsService.getUserInfo);
    
    fullNameController.text = user.value.name;
    emailController.text = user.value.email;
    phoneController.text = user.value.phone;
    selectedGender.value = 'Male';

    // Initialize calendar data
    _updateCalendarData();

    // Load availability for current month
    loadAvailability();
    _loadProfessionalInfo();
    tabs = [
      PersonalInfoTab(controller: this, fromRegistration: fromRegisteration),
      ProfessionalInfoTab(
          controller: this, fromRegistration: fromRegisteration),
    ].obs;
  }

  // Initialize calendar data
  void _updateCalendarData() {
    // Calculate days in the current month
    daysInMonth.value = DateTime(
      currentCalendarDate.value.year,
      currentCalendarDate.value.month + 1,
      0,
    ).day;

    // Calculate the weekday of the first day (1 = Monday, 7 = Sunday)
    firstWeekdayOfMonth.value = DateTime(
      currentCalendarDate.value.year,
      currentCalendarDate.value.month,
      1,
    ).weekday;
  }

  // Get current month name
  String get currentMonthName =>
      DateFormat('MMMM').format(currentCalendarDate.value);

  // Get current year
  String get currentYear =>
      DateFormat('yyyy').format(currentCalendarDate.value);

  // Gender selection
  void setGender(String? gender) {
    if (gender != null) {
      selectedGender.value = gender;
    }
  }

  // Change selected slot (Morning, Afternoon, Evening)
  void setSlot(String slot) {
    selectedSlot.value = slot;
  }

  // Toggle time selection for current slot
  void toggleTimeSelection(String time) {
    String currentSlot = selectedSlot.value;
    List<String> currentTimings =
        List<String>.from(selectedTimingsForSlot[currentSlot] ?? []);

    if (currentTimings.contains(time)) {
      currentTimings.remove(time);
    } else {
      currentTimings.add(time);
    }

    selectedTimingsForSlot[currentSlot] = currentTimings;
    selectedTimingsForSlot.refresh();

    // Update the overall selectedTimings for backward compatibility
    selectedTimings.clear();
    selectedTimingsForSlot.values.forEach((timings) {
      selectedTimings.addAll(timings);
    });
  }

  // Toggle date selection (independent of slot)
  void toggleDateSelection(int date) {
    final today = DateTime.now();
    final selectedDateTime = DateTime(
      currentCalendarDate.value.year,
      currentCalendarDate.value.month,
      date,
    );
    // Only allow dates from today onwards
    if (selectedDateTime.isBefore(DateTime(today.year, today.month, today.day))) {
      return;
    }
    if (selectedDates.contains(date)) {
      selectedDates.remove(date);
    } else {
      selectedDates.add(date);
    }
    selectedDates.refresh();
  }

  // Load availability data from API
  Future<void> loadAvailability() async {
    try {
      isLoadingAvailability.value = true;
      hasAvailabilityError.value = false;
      availabilityErrorMessage.value = '';

      final monthNumber = currentCalendarDate.value.month;
      final response =
          await _doctorService.getDoctorAvailability(monthNumber: monthNumber);

      if (response.success && response.data != null) {
        availabilityData.value = response.data;

        // Update available slot types from API response
        availableSlotTypes.clear();
        // If API provides availableSlotTypes and it's non-empty use it, otherwise fallback
        if (response.data!.slots.availableSlotTypes.isNotEmpty) {
          availableSlotTypes.addAll(response.data!.slots.availableSlotTypes);
        } else {
          // Fallback to default keys so UI can show dummy times
          availableSlotTypes.addAll(defaultDummySlots.keys.toList());
        }

        // Set default slot to first available if current is not available
        if (!availableSlotTypes.contains(selectedSlot.value)) {
          selectedSlot.value = availableSlotTypes.first;
        }

        // Update fees if provided
        regularFeesController.text = '₹${response.data!.doctor.regularFees}';
        emergencyFeesController.text =
            '₹${response.data!.doctor.emergencyFees}';
        isEmergencyConsultation.value = response.data!.doctor.isEmergencyFees;
        } else if (!response.success && response.data == null) {
          // API returned a failure but with no data — treat this as "no slots" and
          // fall back to dummy/default slots so UI remains usable.
          availabilityData.value = null;
          availableSlotTypes.clear();
          availableSlotTypes.addAll(defaultDummySlots.keys.toList());

          // Ensure selected slot is valid
          if (!availableSlotTypes.contains(selectedSlot.value)) {
            selectedSlot.value = availableSlotTypes.first;
          }

          // Do not mark as an availability error — this was an empty/no-data response
          // but not an unrecoverable error. We keep availabilityErrorMessage for
          // diagnostics but don't show the error UI.
          availabilityErrorMessage.value = response.message ?? 'No slots available for this month';
        } else {
          // Handle API error response (true errors)
          hasAvailabilityError.value = true;
          availabilityErrorMessage.value = response.message ?? 'No slots available for this month';
          availabilityData.value = null;
          availableSlotTypes.clear();
        }
    } catch (e) {
      hasAvailabilityError.value = true;
      availabilityErrorMessage.value = 'Failed to load availability';
      availabilityData.value = null;
      availableSlotTypes.clear();
      SnackbarUtils.showError('Failed to load availability: ${e.toString()}');
    } finally {
      isLoadingAvailability.value = false;
    }
  }

  // Get selected dates (independent of slot)
  List<int> get selectedDatesForCurrentSlot => selectedDates;

  // Get selected timings for current slot
  List<String> get selectedTimingsForCurrentSlot =>
      selectedTimingsForSlot[selectedSlot.value] ?? [];

  // Check if a slot has any timings selected (for highlighting in UI)
  bool isSlotActive(String slot) {
    return (selectedTimingsForSlot[slot]?.isNotEmpty ?? false);
  }

  // Toggle emergency consultation
  void toggleEmergencyConsultation() {
    isEmergencyConsultation.value = !isEmergencyConsultation.value;
  }

  // Change month
  void changeMonth(int change) {
    final newDate = DateTime(
      currentCalendarDate.value.year,
      currentCalendarDate.value.month + change,
      1,
    );
    final currentMonth = DateTime.now();
    final currentMonthStart = DateTime(currentMonth.year, currentMonth.month, 1);
    // Don't allow going back beyond current month
    if (newDate.isBefore(currentMonthStart)) {
      return;
    }
    // Update the current calendar date
    currentCalendarDate.value = newDate;
    // Clear selected dates for the new month (since day numbers won't match)
    selectedDates.clear();
    selectedDates.refresh();
    // Update calendar data for the new month
    _updateCalendarData();
    // Load availability for the new month
    loadAvailability();
  }

  // Method for picking profile image
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

  // Method to pick a single document/file
  Future<void> pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        // Set the single file
        certificationDocument.addAll(result.files);
      }
    } catch (e) {
      SnackbarUtils.showError('Failed to pick document: $e');
    }
  }

  // Method to remove the document
  void removeDocument() {
    certificationDocument.removeLast();
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

  // Method to save personal info and mark progress
  void savePersonalInfo() {
    // In a real app, validate and save to API
    // For now, just navigate back with success indication
    // Get.back(result: true);
    // Get.snackbar('Success', 'Personal information saved successfully');
  }

  RxInt currentIndex = RxInt(0);

  void onTabChanged(int index) {
    currentIndex.value = index;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    genderController.dispose();
    licenseNumberController.dispose();
    experienceController.dispose();
    aboutMeController.dispose();
    regularFeesController.dispose();
    emergencyFeesController.dispose();
    super.dispose();
  }

  void _loadProfessionalInfo() {
    String storedSpecialty = SharedPrefsService.getString(
      SharedPrefsService.specialty,
    );
    if (storedSpecialty.isNotEmpty) {
      specialtySelectedValue.value = storedSpecialty;
    } else if (user.value.speciality.isNotEmpty) {
      // Load from user profile if available
      specialtySelectedValue.value = user.value.speciality;
    }

    String storedLicense = SharedPrefsService.getString(
      SharedPrefsService.licenseNumber,
    );
    if (storedLicense.isNotEmpty) {
      licenseNumberController.text = storedLicense;
    } else if (user.value.licenseNumber.isNotEmpty) {
      // Load from user profile if available
      licenseNumberController.text = user.value.licenseNumber;
    }

    // Load other professional info from user profile
    if (user.value.aboutMe.isNotEmpty) {
      aboutMeController.text = user.value.aboutMe;
    }
    if (user.value.totalExperience > 0) {
      experienceController.text = user.value.totalExperience.toString();
    }
    if (user.value.regularFees > 0) {
      regularFeesController.text = '₹${user.value.regularFees}';
    }
    if (user.value.emergencyFees > 0) {
      emergencyFeesController.text = '₹${user.value.emergencyFees}';
    }
    isEmergencyConsultation.value = user.value.isEmergencyFees;
  }

  /// Refresh user data from SharedPreferences
  void refreshUserData() {
    user.value = SharedPrefsService.getUserInfo;
    _loadProfessionalInfo();
  }

  Future<void> saveProfessionalInfo() async {
    if (!isSpecialtyReadOnly.value) {
      await SharedPrefsService.setString(
        SharedPrefsService.specialty,
        specialtySelectedValue.value,
      );
    }

    if (!isLicenseReadOnly.value) {
      await SharedPrefsService.setString(
        SharedPrefsService.licenseNumber,
        licenseNumberController.text,
      );
    }
  }

  /// Update profile info (without availability) - for when fromRegistration is false
  Future<void> updateProfessionalProfileInfo() async {
    try {
      isLoading.value = true;

      // Prepare profile picture
      File? profilePicture;
      if (selectedImage.value != null) {
        profilePicture = selectedImage.value!;
      }

      // Prepare certificate files
      List<File> certificateFiles = [];
      for (var doc in certificationDocument) {
        if (doc != null && doc.path != null) {
          certificateFiles.add(File(doc.path!));
        }
      }

      // Call the API
      final response = await _doctorService.updateProfileInfo(
        picture: profilePicture,
        certificate: certificateFiles.isNotEmpty ? certificateFiles : null,
        speciality: specialtySelectedValue.value,
        licenseNumber: licenseNumberController.text,
        totalExperience: experienceController.text,
        aboutMe: aboutMeController.text,
      );

      if (response.success) {
        SnackbarUtils.showSuccess(response.message ?? 'Profile updated successfully');
        // Refresh the doctor profile to update SharedPreferences
        await _doctorService.getDoctorProfile();
        // Refresh user data in controller
        refreshUserData();
      } else {
        SnackbarUtils.showError(response.message ?? 'Failed to update profile');
      }
    } catch (e) {
      SnackbarUtils.showError('Error updating profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

// Availability handling methods (moved from AvailabilityController)
  void handleContinue({required bool fromRegistration}) async {
    // Only show error if no timings are selected for any slot
    bool hasAtLeastOneCompleteSlot = false;
    for (String slot in slotOptions) {
      List<String> selectedTimings = selectedTimingsForSlot[slot] ?? [];
      if (selectedTimings.isNotEmpty) {
        hasAtLeastOneCompleteSlot = true;
        break;
      }
    }
    if (!hasAtLeastOneCompleteSlot) {
      SnackbarUtils.showError(
        "Please select at least one time for any slot (Morning, Afternoon, or Evening)"
      );
      return;
    }
    if (fromRegistration) {
      await _updateProfile();
    } else {
      await _setAvailability();
    }
  }

  Future<void> _updateProfile() async {
    try {
      isLoading.value = true;
      // Prepare profile picture
      File? profilePicture;
      if (selectedImage.value != null) {
        profilePicture = selectedImage.value!;
      }
      // Prepare certificate files
      List<File> certificateFiles = [];
      for (var doc in certificationDocument) {
        if (doc != null && doc.path != null) {
          certificateFiles.add(File(doc.path!));
        }
      }
      // Prepare dates (flat, independent of slot)
      List<String> formattedDates = [];
      for (final selectedDate in selectedDates) {
        DateTime fullDate = DateTime(
          currentCalendarDate.value.year,
          currentCalendarDate.value.month,
          selectedDate,
        );
        String formattedDate = "${fullDate.year}-${fullDate.month.toString().padLeft(2, '0')}-${fullDate.day.toString().padLeft(2, '0')}";
        if (!formattedDates.contains(formattedDate)) {
          formattedDates.add(formattedDate);
        }
      }
      // Prepare slots map (timings per slot)
      Map<String, List<String>> slotsMap = {
        'Morning': selectedTimingsForSlot['Morning'] ?? [],
        'Afternoon': selectedTimingsForSlot['Afternoon'] ?? [],
        'Evening': selectedTimingsForSlot['Evening'] ?? [],
      };
      // Call the API
      final response = await _doctorService.updateProfile(
        picture: profilePicture,
        certificate: certificateFiles.isNotEmpty ? certificateFiles : null,
        speciality: specialtySelectedValue.value,
        licenseNumber: licenseNumberController.text,
        emergencyFees: emergencyFeesController.text.replaceAll('₹', ''),
        regularFees: regularFeesController.text.replaceAll('₹', ''),
        totalExperience: experienceController.text,
        aboutMe: aboutMeController.text,
        monthNumber: currentCalendarDate.value.month,
        monthName: currentMonthName,
        dates: formattedDates,
        slots: slotsMap,
        isEmergencyFees: isEmergencyConsultation.value,
      );
      if (response.success) {
        SnackbarUtils.showSuccess(response.message ?? 'Profile updated successfully');
        SharedPrefsService.setProfileComplete(true);
        await _doctorService.getDoctorProfile();
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

// Set availability method (for updating availability without profile changes)
  Future<void> _setAvailability() async {
    try {
      isLoading.value = true;
      // Prepare dates (flat, independent of slot)
      List<String> formattedDates = [];
      for (final selectedDate in selectedDates) {
        DateTime fullDate = DateTime(
          currentCalendarDate.value.year,
          currentCalendarDate.value.month,
          selectedDate,
        );
        String formattedDate = "${fullDate.year}-${fullDate.month.toString().padLeft(2, '0')}-${fullDate.day.toString().padLeft(2, '0')}";
        if (!formattedDates.contains(formattedDate)) {
          formattedDates.add(formattedDate);
        }
      }
      // Prepare slots map (timings per slot)
      Map<String, List<String>> slotsMap = {
        'Morning': selectedTimingsForSlot['Morning'] ?? [],
        'Afternoon': selectedTimingsForSlot['Afternoon'] ?? [],
        'Evening': selectedTimingsForSlot['Evening'] ?? [],
      };
      // Call the set availability API
      final response = await _doctorService.setAvailability(
        monthNumber: currentCalendarDate.value.month,
        monthName: currentMonthName,
        dates: formattedDates,
        slots: slotsMap,
        isEmergencyFees: isEmergencyConsultation.value,
        regularFees: regularFeesController.text.replaceAll('₹', ''),
        emergencyFees: emergencyFeesController.text.replaceAll('₹', ''),
      );
      if (response.success) {
        isLoading.value = false;
        SnackbarUtils.showSuccess(response.message ?? 'Availability updated successfully');
        await Future.delayed(Duration(seconds: 3));
        Get.back();
      } else {
        SnackbarUtils.showError(
            response.message ?? 'Failed to update availability');
      }
    } catch (e) {
      SnackbarUtils.showError('Error updating availability: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
