import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/services/general_service.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/constants.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/views/Home/widgets/info_bottom_sheet.dart';

class CustomerSupportController extends GetxController {
  final explainProblemController = TextEditingController();
  final titleController = TextEditingController();
  final GeneralService _generalService = GeneralService();
  
  RxBool isLoading = false.obs;

  @override
  void onClose() {
    explainProblemController.dispose();
    titleController.dispose();
    super.onClose();
  }

  void onSubmitButtonPressed() async {
    if (!validateForm()) return;
    
    try {
      isLoading.value = true;
      
      final response = await _generalService.createSupportTicket(
        subject: titleController.text.trim(),
        message: explainProblemController.text.trim(),
      );
      
      if (response.success) {
        // Show success bottom sheet
        Get.bottomSheet(
          InfoBottomSheet(
            heading: "Congratulations",
            imageAsset: Assets.congratulations,
            description: response.message ?? querySendMessage,
          ),
        );
        
        // Clear form
        explainProblemController.clear();
        titleController.clear();
      } else {
        SnackbarUtils.showError(response.message ?? 'Failed to submit ticket');
      }
    } catch (e) {
      SnackbarUtils.showError('Error submitting ticket: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
bool validateForm() {
  final title = titleController.text.trim();
  final explanation = explainProblemController.text.trim();

  if (title.isEmpty) {
    SnackbarUtils.showError("Please enter a title");
    return false;
  } else if (title.length < 5) {
    SnackbarUtils.showError("Title should be at least 5 characters long");
    return false;
  }

  if (explanation.isEmpty) {
    SnackbarUtils.showError("Please explain the problem");
    return false;
  } else if (explanation.length < 15) {
    SnackbarUtils.showError("Explanation should be at least 15 characters long");
    return false;
  }

  return true;
}


}


