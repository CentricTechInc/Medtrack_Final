import 'package:get/get.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'package:medtrac/api/models/user_appointment_details.dart';
import 'package:medtrac/api/models/doctor_appointment_details.dart';
import 'package:medtrac/utils/helper_functions.dart';

class AppointmentSummaryController extends GetxController {
  final PatientService _patientService = PatientService();
  final DoctorService _doctorService = DoctorService();

  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Data holders
  final Rx<UserAppointmentDetails?> userAppointmentData = Rx<UserAppointmentDetails?>(null);
  final Rx<DoctorAppointmentDetails?> doctorAppointmentData = Rx<DoctorAppointmentDetails?>(null);

  int appointmentId = 0;
  bool get isUser => HelperFunctions.isUser();

  final List<String> primaryConcernTags = [
    "Social Withdrawel",
    "Feeling numbness",
    "PTSD",
  ];

  final List<String> medicationTags = [
    "Fluoxetine",
    "Zolpidern",
    "CBT",
  ];

  final List<String> doctorsAdviceList = [
    "CBT for trauma processing.",
    "Gradual exposure to social situations.",
    "Practice mindfulness and do daily exercise.",
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['appointmentId'] != null) {
      appointmentId = args['appointmentId'];
      loadAppointmentDetails();
    }
  }

  Future<void> loadAppointmentDetails() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      if (isUser) {
        final response = await _patientService.getUserAppointmentDetails(appointmentId);
        if (response.status && response.data != null) {
          userAppointmentData.value = response.data;
        } else {
          hasError.value = true;
          errorMessage.value = response.message;
        }
      } else {
        final response = await _doctorService.getDoctorAppointmentDetails(appointmentId);
        if (response.status && response.data != null) {
          doctorAppointmentData.value = response.data;
        } else {
          hasError.value = true;
          errorMessage.value = response.message;
        }
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load appointment details: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // Dynamic getters for UI
  String get doctorName => isUser 
      ? (userAppointmentData.value?.doctor?.name ?? 'Unknown Doctor')
      : 'Doctor'; // For doctors viewing their own appointments, we don't show doctor name
  
  String get patientName => isUser 
      ? 'Patient' // Users don't need to see their own name in this context
      : (doctorAppointmentData.value?.patient?.name ?? 'Unknown Patient');
  
  String get displayName => isUser ? doctorName : patientName;
  
  String get displayImage => isUser 
      ? (userAppointmentData.value?.doctor?.picture ?? '')
      : (doctorAppointmentData.value?.patient?.picture ?? '');
  
  String get displaySpeciality => isUser 
      ? (userAppointmentData.value?.doctor?.speciality ?? '')
      : ''; // Patients don't have speciality
  
  // Legacy getter for backward compatibility
  String get doctorImage => displayImage;
  
  String get appointmentDate => isUser 
      ? (userAppointmentData.value?.appointmentDate ?? '')
      : (doctorAppointmentData.value?.appointmentDate ?? '');
  
  String get appointmentTime => isUser 
      ? (userAppointmentData.value?.appointmentTime ?? '')
      : (doctorAppointmentData.value?.appointmentTime ?? '');

  // Patient/Doctor ID getters
  int get patientId => isUser 
      ? (userAppointmentData.value?.patient?.id ?? 0)
      : (doctorAppointmentData.value?.patient?.id ?? 0);
  
  int get doctorId => isUser 
      ? (userAppointmentData.value?.doctor?.id ?? 0) 
      : 0; // Doctors don't need their own ID in this context
  
  String get doctorSpeciality => isUser 
      ? (userAppointmentData.value?.doctor?.speciality ?? '')
      : ''; // Doctors don't see speciality about themselves
  
  String get doctorAdvice => isUser 
      ? (userAppointmentData.value?.doctorAdvice ?? '') 
      : (doctorAppointmentData.value?.doctorAdvice ?? '');
  
  String get prescription => isUser 
      ? (userAppointmentData.value?.prescription ?? '') 
      : (doctorAppointmentData.value?.prescription ?? '');
  
  List<String> get dynamicPrimaryConcernTags => isUser 
      ? (userAppointmentData.value?.primaryConcern ?? primaryConcernTags) 
      : (doctorAppointmentData.value?.primaryConcern ?? primaryConcernTags);
  
  List<String> get dynamicMedicationTags => isUser 
      ? (userAppointmentData.value?.medication ?? medicationTags) 
      : (doctorAppointmentData.value?.medication ?? medicationTags);

  // Split doctor advice by ". " for dynamic display
  List<String> get dynamicDoctorAdviceList {
    String advice = isUser 
        ? (userAppointmentData.value?.doctorAdvice ?? '') 
        : (doctorAppointmentData.value?.doctorAdvice ?? '');
    
    if (advice.isEmpty) return doctorsAdviceList;
    
    return advice.split('. ').where((item) => item.trim().isNotEmpty).map((item) => item.trim()).toList();
  }

  // Get prescription documents (multiple URLs separated by comma)
  List<String> get prescriptionDocuments {
    String prescriptionUrls = isUser 
        ? (userAppointmentData.value?.prescription ?? '') 
        : (doctorAppointmentData.value?.prescription ?? '');
    
    if (prescriptionUrls.isEmpty) return [];
    
    return prescriptionUrls.split(',').where((url) => url.trim().isNotEmpty).map((url) => url.trim()).toList();
  }

  // Get shared documents (multiple URLs separated by comma) 
  List<String> get sharedDocumentUrls {
    String sharedDocs = isUser 
        ? (userAppointmentData.value?.sharedDocuments ?? '') 
        : (doctorAppointmentData.value?.sharedDocuments ?? '');
    
    if (sharedDocs.isEmpty) return [];
    
    return sharedDocs.split(',').where((url) => url.trim().isNotEmpty).map((url) => url.trim()).toList();
  }

  // Get patient health data
  String get mood => isUser 
      ? (userAppointmentData.value?.patient?.mood ?? 'Good') 
      : (doctorAppointmentData.value?.patient?.mood ?? 'Good');

  String get sleepQuality => isUser 
      ? (userAppointmentData.value?.patient?.sleepQuality ?? 'Good') 
      : (doctorAppointmentData.value?.patient?.sleepQuality ?? 'Good');

  int get stressLevel => isUser 
      ? (userAppointmentData.value?.patient?.stressLevel ?? 2) 
      : (doctorAppointmentData.value?.patient?.stressLevel ?? 2);

  // Get patient history
  String get patientHistory => isUser 
      ? (userAppointmentData.value?.patientHistory ?? '') 
      : (doctorAppointmentData.value?.patientHistory ?? '');
}
