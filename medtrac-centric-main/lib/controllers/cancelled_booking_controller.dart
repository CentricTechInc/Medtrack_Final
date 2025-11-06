import 'package:get/get.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'package:medtrac/api/models/user_appointment_details.dart';
import 'package:medtrac/api/models/doctor_appointment_details.dart';
import 'package:medtrac/utils/helper_functions.dart';

class CancelledBookingController extends GetxController {
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
      : (doctorAppointmentData.value?.patient?.name ?? 'Patient');
  
  String get appointmentDate => isUser 
      ? (userAppointmentData.value?.appointmentDate ?? '')
      : (doctorAppointmentData.value?.appointmentDate ?? '');
  
  String get appointmentTime => isUser 
      ? (userAppointmentData.value?.appointmentTime ?? '')
      : (doctorAppointmentData.value?.appointmentTime ?? '');
  
  String get timeRange => isUser 
      ? (userAppointmentData.value?.timeRange ?? '')
      : (doctorAppointmentData.value?.timeRange ?? '');
  
  String get appointmentType => isUser 
      ? (userAppointmentData.value?.type ?? '')
      : (doctorAppointmentData.value?.type ?? '');
  
  String get cancelReason => isUser 
      ? (userAppointmentData.value?.reason ?? '') 
      : (doctorAppointmentData.value?.reason ?? '');
  
  String get slot => isUser 
      ? (userAppointmentData.value?.slot ?? '') 
      : (doctorAppointmentData.value?.slot ?? '');

  // Patient health information getters (for doctors viewing patient data)
  String get patientName => isUser 
      ? 'Patient' // Users don't need to see their own name in this context
      : (doctorAppointmentData.value?.patient?.name ?? 'Unknown Patient');
  
  String get patientImage => isUser 
      ? '' // Users don't need patient image
      : (doctorAppointmentData.value?.patient?.picture ?? '');
  
  String get patientSleepQuality => isUser 
      ? '' // Users don't see patient health data about themselves
      : (doctorAppointmentData.value?.patient?.sleepQuality ?? '');
  
  int get patientStressLevel => isUser 
      ? 0 // Users don't see patient health data about themselves
      : (doctorAppointmentData.value?.patient?.stressLevel ?? 0);
  
  String get patientMood => isUser 
      ? '' // Users don't see patient health data about themselves
      : (doctorAppointmentData.value?.patient?.mood ?? '');

  // Doctor information getters (for patients viewing doctor data)  
  String get doctorSpeciality => isUser 
      ? (userAppointmentData.value?.doctor?.speciality ?? '')
      : ''; // Doctors don't see speciality about themselves
  
  String get doctorImage => isUser 
      ? (userAppointmentData.value?.doctor?.picture ?? '')
      : ''; // Doctors use patient image instead
  
  double get doctorAverageRating => isUser 
      ? 0.0 // Rating not available in current models, would need API enhancement
      : 0.0;
}
