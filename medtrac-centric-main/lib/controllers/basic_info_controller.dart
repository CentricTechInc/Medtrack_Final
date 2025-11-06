import 'package:get/get.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/routes/app_routes.dart';

class BasicInfoController extends GetxController {
  RxList<String> activityOptions = [
    "Not At All",
    "A Little",
    "Quite A Bit",
    "Nearly Every Day",
  ].obs;

  RxString selectedActivityReason = 'Not At All'.obs;

  // Second question - Do you feel you have someone to talk to when you're feeling down?
  RxList<String> supportOptions = [
    "Always",
    "Sometimes",
    "Rarely",
    "No, I feel alone",
  ].obs;

  RxString selectedSupportResponse = 'Always'.obs;

  // Third question - How often have you felt tired or had little energy?
  RxList<String> energyOptions = [
    "Not at all",
    "Several days",
    "More than half the days",
    "Nearly every day",
  ].obs;

  RxString selectedEnergyResponse = 'Not at all'.obs;

  // Fourth question - How often have you had trouble concentrating on things, like reading or watching TV?
  RxList<String> concentrationOptions = [
    "Not at all",
    "Several days",
    "More than half the days",
    "Nearly every day",
  ].obs;

  RxString selectedConcentrationResponse = 'Not at all'.obs;

  // Mental health goals
  var isManageAnxietySelected = false.obs;
  var isReduceStressSelected = false.obs;
  var isImproveMoodSelected = false.obs;
  var isBoostConfidenceSelected = false.obs;
  var isImproveSleepSelected = false.obs;

  // Sleep quality
  var selectedSleepQuality =
      2.obs;

  // Stress level
  var selectedStressLevel = 5.obs;

  // Observable for selected gender
  var selectedGender = 'Male'.obs;

  // Observable for weight
  var selectedWeight = 50.0.obs;

  // Observable for weight unit (true = kg, false = lbs)
  var isKg = true.obs;

  // Observable for age
  var selectedAge = 25.obs;

  // Method to set selected gender
  void setSelectedGender(String gender) {
    selectedGender.value = gender;
  }

  // Method to check if a gender is selected
  bool isGenderSelected(String gender) {
    return selectedGender.value == gender;
  }

  // Method to set selected weight
  void setSelectedWeight(double weight) {
    selectedWeight.value = weight;
  }

  // Method to set weight unit
  void setWeightUnit(bool isKgUnit) {
    isKg.value = isKgUnit;
  }

  // Method to set selected age
  void setSelectedAge(int age) {
    selectedAge.value = age;
  }

  // Method to toggle manage anxiety selection
  void setManageAnxietySelection(bool isSelected) {
    isManageAnxietySelected.value = isSelected;
  }

  // Method to toggle reduce stress selection
  void setReduceStressSelection(bool isSelected) {
    isReduceStressSelected.value = isSelected;
  }

  // Method to toggle improve mood selection
  void setImproveMoodSelection(bool isSelected) {
    isImproveMoodSelected.value = isSelected;
  }

  // Method to toggle boost confidence selection
  void setBoostConfidenceSelection(bool isSelected) {
    isBoostConfidenceSelected.value = isSelected;
  }

  // Method to toggle improve sleep selection
  void setImproveSleepSelection(bool isSelected) {
    isImproveSleepSelected.value = isSelected;
  }

  // Method to set sleep quality
  void setSleepQuality(int quality) {
    selectedSleepQuality.value = quality;
  }

  // Method to set stress level
  void setStressLevel(int level) {
    selectedStressLevel.value = level;
  }

  // Selected mood
  var selectedMoodIndex =
      2.obs; // 0: Worst, 1: Poor, 2: Fair, 3: Good, 4: Excellent

  // Method to set selected mood
  void setSelectedMood(int index) {
    selectedMoodIndex.value = index;
  }

  String getStressLevelText() {
    switch (selectedStressLevel.value) {
      case 1:
        return "You are not stressed at all";
      case 2:
        return "You have minimal stress";
      case 3:
        return "You have moderate stress";
      case 4:
        return "You are quite stressed";
      case 5:
        return "You are extremely stressed";
      default:
        return "You are not stressed at all";
    }
  }

  // Service instance
  final PatientService _patientService = PatientService();
  
  // Loading state
  var isLoading = false.obs;

  /// Get selected mental health goals as a list
  List<String> getSelectedMentalHealthGoals() {
    List<String> goals = [];
    if (isManageAnxietySelected.value) goals.add('Manage Anxiety');
    if (isReduceStressSelected.value) goals.add('Reduce Stress');
    if (isImproveMoodSelected.value) goals.add('Improve Mood');
    if (isBoostConfidenceSelected.value) goals.add('Boost Confidence');
    if (isImproveSleepSelected.value) goals.add('Improve Sleep');
    return goals;
  }

  /// Get formatted weight string
  String getFormattedWeight() {
    return '${selectedWeight.value.toInt()}${isKg.value ? 'kg' : 'lbs'}';
  }

  /// Get sleep quality text
  String getSleepQualityText() {
    switch (selectedSleepQuality.value) {
      case 4:
        return "Worst";
      case 3:
        return "Poor";
      case 2:
        return "Fair";
      case 1:
        return "Good";
      case 0:
        return "Excellent";
      default:
        return "Fair";
    }
  }

  /// Get mood text
  String getMoodText() {
    switch (selectedMoodIndex.value) {
      case 0:
        return "I'm feeling sad";
      case 1:
        return "I'm feeling neutral";
      case 2:
        return "I'm feeling good";
      default:
        return "I'm feeling neutral";
    }
  }

  /// Get questions and answers
  List<Map<String, String>> getQuestions() {
    return [
      {
        'question': 'Have you lost interest or pleasure in activities you usually enjoy?',
        'answer': selectedActivityReason.value,
      },
      {
        'question': 'Do you feel you have someone to talk to when you\'re feeling down?',
        'answer': selectedSupportResponse.value,
      },
      {
        'question': 'How often have you felt tired or had little energy?',
        'answer': selectedEnergyResponse.value,
      },
      {
        'question': 'How often have you had trouble concentrating on things, like reading or watching TV?',
        'answer': selectedConcentrationResponse.value,
      },
    ];
  }

  /// Submit all basic info to API
  Future<void> submitBasicInfo() async {
    try {
      isLoading.value = true;
      final sleepQuality = getSleepQualityText();

      final response = await _patientService.updateBasicInfo(
        age: selectedAge.value.toString(),
        weight: getFormattedWeight(),
        gender: selectedGender.value,
        sleepQuality: sleepQuality,
        stressLevel: selectedStressLevel.value,
        mood: getMoodText(),
        mentalHealthGoals: getSelectedMentalHealthGoals(),
        questions: getQuestions(),
      );

      if (response.success) {
        // Mark first login as complete since onboarding is done
        await SharedPrefsService.markFirstLoginComplete();
        
        SnackbarUtils.showSuccess(
          response.message ?? 'Basic info updated successfully'
        );
        
        // Navigate to main screen
        Get.offAllNamed(AppRoutes.mainScreen);
      } else {
        SnackbarUtils.showError(
          response.message ?? 'Failed to update basic info'
        );
      }
    } catch (e) {
      SnackbarUtils.showError(
        'An error occurred: ${e.toString()}'
      );
    } finally {
      isLoading.value = false;
    }
  }
}
