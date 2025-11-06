import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/models/user.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'package:medtrac/api/models/user_appointment_details.dart';
import 'package:medtrac/api/models/doctor_appointment_details.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:intl/intl.dart';

class AppointmentDetailsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final PatientService _patientService = PatientService();
  final DoctorService _doctorService = DoctorService();

  late TabController tabController;
  final currentIndex = 0.obs;

  // API Integration variables
  final isLoading = true.obs;
  final appointmentData = Rxn<Map<String, dynamic>>();
  final waitingTime = ''.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final RxBool appointmentTimePassed = false.obs;

  final User currentUser = SharedPrefsService.getUserInfo;
  int get currentUserId => currentUser.id;

  // New unified data holders
  final Rx<UserAppointmentDetails?> userAppointmentData = Rx<UserAppointmentDetails?>(null);
  final Rx<DoctorAppointmentDetails?> doctorAppointmentData = Rx<DoctorAppointmentDetails?>(null);

  Timer? _countdownTimer;
  int appointmentId = 0;
  String? patientNameFromArgs; // Store patient name from navigation arguments
  
  bool get isUser => HelperFunctions.isUser();

  // Status getter for appointment
  String get appointmentStatus => isUser 
      ? (userAppointmentData.value?.status ?? '') 
      : (doctorAppointmentData.value?.status ?? '');

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

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      currentIndex.value = tabController.index;
    });

    // Get appointment ID from arguments
    final args = Get.arguments;
    if (args != null && args['appointmentId'] != null) {
    log("AppointmentDetailsController initialized with appointmentId: $appointmentId");
      appointmentId = args['appointmentId'];
      patientNameFromArgs = args['patientName']; // Get patient name from arguments
      loadAppointmentDetails();
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    tabController.dispose();
    super.onClose();
  }

  Future<void> loadAppointmentDetails() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      if (isUser) {
        // Load user appointment details
        final response = await _patientService.getUserAppointmentDetails(appointmentId);
        if (response.status && response.data != null) {
          userAppointmentData.value = response.data;
          appointmentData.value = {
            'status': response.data!.status,
            'appointment_date': response.data!.appointmentDate,
            'appointment_time': response.data!.appointmentTime,
            'time_range': response.data!.timeRange,
            'type': response.data!.type,
            'consultation_type': response.data!.consultationType,
            'consultation_fee': response.data!.consultationFee,
            'doctor': {
              'name': response.data!.doctor?.name,
              'speciality': response.data!.doctor?.speciality,
              'picture': response.data!.doctor?.picture,
            }
          };
          if (appointmentStatus == 'Upcoming') {
            _startCountdown();
          }
        } else {
          hasError.value = true;
          errorMessage.value = response.message;
        }
      } else {
        // Load doctor appointment details
        final response = await _doctorService.getDoctorAppointmentDetails(appointmentId);
        if (response.status && response.data != null) {
          doctorAppointmentData.value = response.data;
          appointmentData.value = {
            'status': response.data!.status,
            'appointment_date': response.data!.appointmentDate,
            'appointment_time': response.data!.appointmentTime,
            'time_range': response.data!.timeRange,
            'type': response.data!.type,
            'consultation_type': response.data!.consultationType,
            'consultation_fee': response.data!.consultationFee,
            'patient_name': response.data!.patient?.name ?? patientNameFromArgs ?? 'Unknown Patient',
            'patient': {
              'picture': response.data!.patient?.picture,
            }
          };
          if (appointmentStatus == 'Upcoming') {
            _startCountdown();
          }
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

  void _startCountdown() {
    final data = appointmentData.value;
    if (data == null) return;

    try {
      final appointmentDate = data['appointment_date'] as String;
      final appointmentTime = data['appointment_time'] as String;

      // Parse the appointment date and time
      final dateFormat = DateFormat('dd MMM yyyy'); // Format: "23 Aug 2025"
      final timeFormat = DateFormat('HH:mm'); // Format: "09:00"

      final parsedDate = dateFormat.parse(appointmentDate);
      final parsedTime = timeFormat.parse(appointmentTime);

      final appointmentDateTime = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );

      _updateCountdown(appointmentDateTime);

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateCountdown(appointmentDateTime);
      });
    } catch (e) {
      waitingTime.value = 'Invalid appointment time';
      print('Error parsing appointment date/time: $e');
    }
  }

  void _updateCountdown(DateTime appointmentDateTime) {
    final now = DateTime.now();
    final difference = appointmentDateTime.difference(now);

    if (difference.isNegative) {
      waitingTime.value = 'Appointment time has passed';
      appointmentTimePassed.value = true;
      _countdownTimer?.cancel();
      return;
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    waitingTime.value =
        '${hours.toString().padLeft(2, '0')}hr. ${minutes.toString().padLeft(2, '0')}min. ${seconds.toString().padLeft(2, '0')}sec';
  }

  // Getters for UI - Updated to work with unified data
  String get doctorName => isUser 
      ? (userAppointmentData.value?.doctor?.name ?? 'Unknown Doctor')
      : 'Doctor'; // For doctors viewing their own appointments, we don't show doctor name
  
  String get patientName => isUser 
      ? 'Patient' // Users don't need to see their own name in this context
      : (doctorAppointmentData.value?.patient?.name ?? 
         patientNameFromArgs ?? 
         appointmentData.value?['patient_name'] ?? 
         'Unknown Patient');
  
  String get doctorSpeciality => isUser 
      ? (userAppointmentData.value?.doctor?.speciality ?? '')
      : ''; // Patients don't have speciality
  
  String get doctorImage => isUser 
      ? (userAppointmentData.value?.doctor?.picture ?? '')
      : (doctorAppointmentData.value?.patient?.picture ?? '');
  
  String get patientImage => isUser 
      ? '' // Users don't need patient image
      : (doctorAppointmentData.value?.patient?.picture ?? '');
  
  String get appointmentDate => isUser 
      ? (userAppointmentData.value?.appointmentDate ?? '')
      : (doctorAppointmentData.value?.appointmentDate ?? '');
  
  String get appointmentType => isUser 
      ? (userAppointmentData.value?.type ?? '')
      : (doctorAppointmentData.value?.type ?? '');
  
  String get consultationType => isUser 
      ? (userAppointmentData.value?.consultationType ?? '')
      : (doctorAppointmentData.value?.consultationType ?? '');
  
  double get consultationFee => isUser 
      ? (userAppointmentData.value?.consultationFee ?? 0.0)
      : (doctorAppointmentData.value?.consultationFee ?? 0.0);
  
  String get appointmentTime => isUser 
      ? (userAppointmentData.value?.appointmentTime ?? '')
      : (doctorAppointmentData.value?.appointmentTime ?? '');
  
  // Check if appointment time has passed
  bool get hasAppointmentPassed => appointmentStatus.toLowerCase() != 'upcoming';

  // Additional getters for completed and canceled appointments
  List<String> get doctorAdvice {
    final advice = isUser 
        ? (userAppointmentData.value?.doctorAdvice ?? '') 
        : (doctorAppointmentData.value?.doctorAdvice ?? '');
    
    if (advice.isEmpty) return [];
    
    // Split by " ." and clean up the results
    return advice.split(' .').map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
  }
  
  String get prescription => isUser 
      ? (userAppointmentData.value?.prescription ?? '') 
      : (doctorAppointmentData.value?.prescription ?? '');
  
  String get sharedDocuments => isUser 
      ? (userAppointmentData.value?.sharedDocuments ?? '') 
      : (doctorAppointmentData.value?.sharedDocuments ?? '');
  
  String get patientHistory => isUser 
      ? (userAppointmentData.value?.patientHistory ?? '') 
      : (doctorAppointmentData.value?.patientHistory ?? '');
  
  List<String> get primaryConcern => isUser 
      ? (userAppointmentData.value?.primaryConcern ?? []) 
      : (doctorAppointmentData.value?.primaryConcern ?? []);
  
  List<String> get medication => isUser 
      ? (userAppointmentData.value?.medication ?? []) 
      : (doctorAppointmentData.value?.medication ?? []);
  
  String get cancelReason => isUser 
      ? (userAppointmentData.value?.reason ?? '') 
      : (doctorAppointmentData.value?.reason ?? '');
  
  String get timeRange => isUser 
      ? (userAppointmentData.value?.timeRange ?? '') 
      : (doctorAppointmentData.value?.timeRange ?? '');

  // Payment details getters (mainly for doctor view)
  double get totalFee => isUser 
      ? (userAppointmentData.value?.consultationFee ?? 0.0)
      : (doctorAppointmentData.value?.totalFee ?? 0.0);
  
  double get platformFee => isUser 
      ? 0.0 // User view doesn't show platform fee breakdown
      : (doctorAppointmentData.value?.platformFee ?? 0.0);
  
  double get doctorFee => isUser 
      ? 0.0 // User view doesn't show doctor fee breakdown
      : (doctorAppointmentData.value?.doctorFee ?? 0.0);
  
  String get paymentMethod => isUser 
      ? '' // User view doesn't show payment method
      : (doctorAppointmentData.value?.paymentMethod ?? '');

  // Patient health information getters
  String get sleepQuality => isUser 
      ? (userAppointmentData.value?.patient?.sleepQuality ?? '') 
      : (doctorAppointmentData.value?.patient?.sleepQuality ?? '');
  
  int get stressLevel => isUser 
      ? (userAppointmentData.value?.patient?.stressLevel ?? 0) 
      : (doctorAppointmentData.value?.patient?.stressLevel ?? 0);
  
  String get mood => isUser 
      ? (userAppointmentData.value?.patient?.mood ?? '') 
      : (doctorAppointmentData.value?.patient?.mood ?? '');
}
