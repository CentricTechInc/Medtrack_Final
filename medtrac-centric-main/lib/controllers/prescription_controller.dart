import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';
import 'package:medtrac/controllers/appointments_controller.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class PrescriptionController extends GetxController {
  final DoctorService _doctorService = DoctorService();
  
  // Form controllers
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController instructionsController = TextEditingController();
  final TextEditingController recommendedTestsController = TextEditingController();
  
  // Rx variables
  Rx<Uint8List?> signatureImage = Rx<Uint8List?>(null);
  final RxString selectedGender = ''.obs;
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString drugName = ''.obs;
  final RxString strength = ''.obs;
  final RxString frequency = ''.obs;
  final RxBool isSubmitting = false.obs;
  
  // Appointment info from navigation
  RxInt appointmentId = 0.obs;
  RxBool isComingFromCall = false.obs; // Track if coming from video call

  @override
  void onInit() {
    super.onInit();
    
    // Get appointment ID from arguments
    final arguments = Get.arguments;
    print('📝 Prescription screen onInit called');
    print('   Arguments: $arguments');
    
    if (arguments != null) {
      appointmentId.value = arguments['appointmentId'] ?? 0;
      isComingFromCall.value = arguments['fromCall'] ?? false;
      
      print('📝 Prescription screen initialized:');
      print('   Appointment ID: ${appointmentId.value}');
      print('   From Call: ${isComingFromCall.value}');
    } else {
      print('⚠️ WARNING: No arguments provided to prescription screen!');
    }
  }

  void setGender(String? gender) {
    if (gender != null) {
      selectedGender.value = gender;
    }
  }

  void setDate(DateTime date) {
    selectedDate.value = date;
  }

  void setDrugDetails(String name, String str, String freq) {
    drugName.value = name;
    strength.value = str;
    frequency.value = freq;
  }
  
  /// Validate prescription form
  bool validateForm() {
    // Patient name is required
    if (patientNameController.text.trim().isEmpty) {
      SnackbarUtils.showError('Please enter patient name');
      return false;
    }
    
    // Age is required
    if (ageController.text.trim().isEmpty) {
      SnackbarUtils.showError('Please enter patient age');
      return false;
    }
    
    // Gender is required
    if (selectedGender.value.isEmpty) {
      SnackbarUtils.showError('Please select gender');
      return false;
    }
    
    // At least drug name or instructions should be provided
    if (drugName.value.isEmpty && instructionsController.text.trim().isEmpty) {
      SnackbarUtils.showError('Please provide at least drug details or instructions');
      return false;
    }
    
    // E-signature is required
    if (signatureImage.value == null) {
      SnackbarUtils.showError('Please add your signature');
      return false;
    }
    
    return true;
  }
  
  /// Submit prescription to API
  Future<void> submitPrescription() async {
    if (!validateForm()) return;
    
    print('📝 Submitting prescription...');
    print('   Appointment ID: ${appointmentId.value}');
    print('   From Call: ${isComingFromCall.value}');
    
    if (appointmentId.value == 0) {
      print('⚠️ ERROR: Appointment ID is 0!');
      SnackbarUtils.showError('Appointment information missing');
      return;
    }
    
    try {
      isSubmitting.value = true;
      
      // Build drug strength frequency string
      String drugStrengthFrequency = '';
      if (drugName.value.isNotEmpty) {
        drugStrengthFrequency = '${drugName.value}/ ${strength.value} / ${frequency.value}';
      }
      
      // Format date
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      
      // Convert signature to file
      File? signatureFile;
      if (signatureImage.value != null) {
        signatureFile = await _convertSignatureToFile(signatureImage.value!);
      }
      
      final response = await _doctorService.submitPrescription(
        appointmentId: appointmentId.value,
        prescriptionDate: formattedDate,
        drugStrengthFrequency: drugStrengthFrequency.isNotEmpty ? drugStrengthFrequency : null,
        recommendedTests: recommendedTestsController.text.trim().isNotEmpty 
            ? recommendedTestsController.text.trim() 
            : null,
        instructions: instructionsController.text.trim().isNotEmpty 
            ? instructionsController.text.trim() 
            : null,
        eSignature: signatureFile,
      );
      
      if (response.success) {
        SnackbarUtils.showCustom(
          iconPath: Assets.snackBarSuccessIcon,
          message: 'Prescription submitted successfully',
        );
        
        // Only navigate to completed appointments if coming from call end
        // If written during call, just go back to video call screen
        if (isComingFromCall.value) {
          // Coming from session ended sheet after call - navigate to completed appointments
          Future.delayed(
            const Duration(seconds: 2),
            () {
              // Navigate to main screen
              Get.offAllNamed(AppRoutes.mainScreen);
              
              // Set appointments tab (index 1)
              final bottomNavbarController = Get.find<BottomNavigationController>();
              bottomNavbarController.selectedNavIndex.value = 1;
              
              // Set completed tab (index 1)
              try {
                final appointmentsController = Get.find<AppointmentsController>();
                appointmentsController.currentIndex.value = 1; // Completed tab
                appointmentsController.tabController.animateTo(1);
              } catch (e) {
                print('Error setting completed tab: $e');
              }
            },
          );
        } else {
          // Written during call - just go back to video call screen
          Future.delayed(
            const Duration(seconds: 2),
            () {
              Get.back(); // Return to video call screen
            },
          );
        }
      } else {
        SnackbarUtils.showError(response.message ?? 'Failed to submit prescription');
      }
    } catch (e) {
      print('❌ Error submitting prescription: $e');
      SnackbarUtils.showError('Failed to submit prescription. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }
  
  /// Convert signature bytes to file
  Future<File> _convertSignatureToFile(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  void onClose() {
    patientNameController.dispose();
    ageController.dispose();
    instructionsController.dispose();
    recommendedTestsController.dispose();
    super.onClose();
  }
}
