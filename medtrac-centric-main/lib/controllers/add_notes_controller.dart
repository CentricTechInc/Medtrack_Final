import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/utils/snackbar.dart';

class AddNotesController extends GetxController {
  final notesController = TextEditingController();
  final RxBool isSubmitting = false.obs;
  
  void submitNotes() {
    // Validate if notes are not empty
    if (notesController.text.trim().isEmpty) {
    SnackbarUtils.showError('Please write some notes before submitting');

      return;
    }
    
    // Show loading state
    isSubmitting.value = true;
    
    // Simulate API call with a delay
    Future.delayed(const Duration(seconds: 1), () {
      // Reset loading state
      isSubmitting.value = false;
      
      // Show success message and go back
      Get.back();
    SnackbarUtils.showSuccess('Notes submitted successfully');

    });
  }
  
  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}