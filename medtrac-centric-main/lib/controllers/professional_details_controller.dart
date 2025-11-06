import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/personal_info_controller.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/views/Home/widgets/info_bottom_sheet.dart';

class ProfessionalDetailsController extends GetxController {
  // Form key to handle validation
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final specializationController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final PersonalInfoController personalInfoController = PersonalInfoController();

  // Observables
  final RxBool consentToBackgroundCheck = false.obs;
  final RxString selectedFileName = 'No File Chosen'.obs;
  final Rxn<PlatformFile> selectedFile = Rxn<PlatformFile>();
  final RxBool isLoading = false.obs;

  // Validation status
  final RxBool isFormValid = false.obs;
  final RxBool showFileValidationError = false.obs;

  // Dropdown items for specialization
  final List<String> specializations = [
    'General Practice',
    'Cardiology',
    'Dermatology',
    'Endocrinology',
    'Gastroenterology',
    'Neurology',
    'Oncology',
    'Pediatrics',
    'Psychiatry',
    'Radiology',
    'Surgery',
    'Urology',
    'Other'
  ];

  // Method to select a file
  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        selectedFile.value = result.files.first;
        selectedFileName.value = result.files.first.name;
        // Reset validation error since we now have a file
        showFileValidationError.value = false;
        formKey.currentState!.validate();
      }
    } catch (e) {
      SnackbarUtils.showError('Error picking file: ${e.toString()}');
    }
  }

  // Method to toggle consent checkbox
  void toggleConsent(bool? value) {
    if (value != null) {
      consentToBackgroundCheck.value = value;
    }
  }

  // Method to handle form submission
  Future<void> submitForm() async {
    // Check if file is selected, if not, show the validation error
    if (selectedFile.value == null) {
      showFileValidationError.value = true;
    }
    // Validate form fields
    final bool formFieldsValid = formKey.currentState!.validate();
    final bool fileSelected = selectedFile.value != null;
    // Check if form is completely valid (form fields and file)
    if (formFieldsValid && fileSelected) {
      if (!consentToBackgroundCheck.value) {
        SnackbarUtils.showError('Please consent to the background check');
        return;
      }
      // Show loading indicator
      isLoading.value = true;
      try {
        // Simulate API call with delay
        await Future.delayed(const Duration(seconds: 2));
        // Show success dialog
        Get.bottomSheet(
          InfoBottomSheet(
            heading: 'Your Profile is Under Review',
            description:
                'Thank you for submitting your profile.\nWe will notify you via email.',
            imageAsset: Assets.underReview
    
          ),
          isDismissible: true,
        );

        Future.delayed(const Duration(seconds: 3), () {
          Get.offAllNamed(AppRoutes.mainScreen);
        });
      } catch (e) {
        SnackbarUtils.showError('Failed to submit: ${e.toString()}');
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    specializationController.dispose();
    licenseNumberController.dispose();
    super.onClose();
  }
}
