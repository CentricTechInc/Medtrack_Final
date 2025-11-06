import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/api/models/doctor_availability_response.dart';
import 'package:medtrac/controllers/appointments_controller.dart';

class AppointmentBookingController extends GetxController {
  final DoctorService _doctorService = DoctorService();
  final PatientService _patientService = PatientService();
  
  // Scroll controller for horizontal date scroll
  final ScrollController dateScrollController = ScrollController();
  
  // Doctor ID passed from doctor details screen
  final RxInt doctorId = 0.obs;
  
  // Reschedule mode variables
  final RxBool isRescheduleMode = false.obs;
  final RxInt rescheduleAppointmentId = 0.obs;
  
  // Consultation type selection
  final RxString selectedConsultationType = 'standard'.obs;
  // Doctor display info (optional) passed from DoctorDetailsScreen
  final RxString doctorDisplayName = ''.obs;
  final RxString doctorDisplaySpeciality = ''.obs;
  final RxString doctorDisplayFees = ''.obs;
  final RxString doctorProfilePic = ''.obs;
  // Month and calendar data
  final RxString selectedMonth = "".obs;
  final RxString selectedDateId = "".obs; // Changed to unique identifier
  final RxString selectedDateWithMonth = "".obs;
  final RxList<String> availableMonths = <String>[].obs;
  final RxList<AvailableDay> availableDays = <AvailableDay>[].obs;

  // Slot and time selection
  final RxString selectedSlot = "Morning".obs;
  final RxString selectedTime = "".obs;
  final RxList<String> slotOptions = <String>[].obs;
  final RxMap<String, List<TimeSlot>> slotTimeSlots = <String, List<TimeSlot>>{}.obs;

  // Busy days for different months (doctor's unavailable dates)
  final Map<String, List<int>> busyDays = {
    "March 2025": [1, 2, 5, 8, 12, 15, 19, 22, 26, 29],
    "April 2025": [3, 6, 9, 13, 16, 20, 23, 27, 30],
    "May 2025": [4, 7, 11, 14, 18, 21, 25, 28],
    "June 2025": [2, 5, 9, 12, 16, 19, 23, 26, 30],
    "July 2025": [1, 4, 8, 11, 15, 18, 22, 25, 29],
    "August 2025": [3, 6, 10, 13, 17, 20, 24, 27, 31],
  };

  final RxBool isLoadingSlots = false.obs;
  final RxString slotError = ''.obs;

// Fees from API
  final RxDouble regularFees = 0.0.obs;
  final RxDouble emergencyFees = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Get arguments from navigation
    final args = Get.arguments;
    if (args != null) {
      if (args is int) {
        // Coming from doctor details for new appointment
        doctorId.value = args;
      } else if (args is Map) {
        // Read optional doctor display info forwarded from DoctorDetailsScreen
        doctorDisplayName.value = args['doctorName'] ?? '';
        doctorDisplaySpeciality.value = args['doctorSpeciality'] ?? '';
        doctorDisplayFees.value = args['doctorFees'] ?? '';
        doctorProfilePic.value = args['doctorProfilePic'] ?? '';
        // Coming from reschedule with appointment details
        doctorId.value = args['doctorId'] ?? 0;
        isRescheduleMode.value = args['isReschedule'] ?? false;
        rescheduleAppointmentId.value = args['appointmentId'] ?? 0;
        
        // Set initial selected date if provided
        final initialDate = args['initialDate'] as String?;
        if (initialDate != null) {
          // Don't call _setInitialDateFromString here, do it after initialization
          _initialDateString = initialDate;
        }
      }
    }
    _initializeMonths();
    _initializeCalendarDays();
    
    // Set initial date after everything is initialized
    if (_initialDateString != null) {
      _setInitialDateFromString(_initialDateString!);
    }
  }

  @override
  void onClose() {
    dateScrollController.dispose();
    super.onClose();
  }

  String? _initialDateString;

  void _setInitialDateFromString(String dateString) {
    try {
      print('DEBUG: Setting initial date from string: $dateString');
      
      // Parse the date string (assuming format like "23 Aug 2025" or "2025-08-23")
      DateTime targetDate;
      
      if (dateString.contains('-')) {
        // Handle ISO format: "2025-08-23"
        targetDate = DateTime.parse(dateString);
      } else {
        // Handle display format: "23 Aug 2025"
        final dateParts = dateString.split(' ');
        if (dateParts.length >= 3) {
          final day = int.parse(dateParts[0]);
          final monthName = dateParts[1];
          final year = int.parse(dateParts[2]);
          targetDate = DateTime(year, _getMonthNumber(monthName), day);
        } else {
          throw Exception('Invalid date format');
        }
      }
      
      // Find the corresponding month
      final monthYear = DateFormat('MMMM yyyy').format(targetDate);
      print('DEBUG: Target month: $monthYear');
      
      // Set the month first if it exists in available months
      if (availableMonths.contains(monthYear)) {
        selectedMonth.value = monthYear;
        print('DEBUG: Selected month set to: ${selectedMonth.value}');
        
        // Reinitialize calendar days for the new month
        _initializeCalendarDays();
        
        // Then select the specific day
        final dayToSelect = availableDays.firstWhere(
          (d) => d.day == targetDate.day,
          orElse: () => availableDays.first,
        );
        
        print('DEBUG: Selecting day: ${dayToSelect.day}');
        selectDate(dayToSelect);
      } else {
        print('DEBUG: Month $monthYear not found in available months');
        // Fallback to first available day if month not found
        if (availableDays.isNotEmpty) {
          selectDate(availableDays.first);
        }
      }
    } catch (e) {
      print('Error setting initial date: $e');
      // Fallback to first available day
      if (availableDays.isNotEmpty) {
        selectDate(availableDays.first);
      }
    }
  }

  int _getMonthNumber(String monthName) {
    const months = {
      // Short month names
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      // Full month names
      'January': 1, 'February': 2, 'March': 3, 'April': 4, 'June': 6,
      'July': 7, 'August': 8, 'September': 9, 'October': 10, 'November': 11, 'December': 12
    };
    return months[monthName] ?? 1;
  }

  void _initializeMonths() {
    // TODO: TESTING - Show all months for testing purposes
    // When testing is done, uncomment the future months only logic below
    availableMonths.clear();
    final year = DateTime.now().year;
    for (int m = 1; m <= 12; m++) {
      final date = DateTime(year, m);
      final monthString = DateFormat('MMMM yyyy').format(date);
      availableMonths.add(monthString);
    }
    selectedMonth.value = availableMonths.first;
    
    /* UNCOMMENT THIS FOR PRODUCTION - FUTURE MONTHS ONLY:
    // Initialize available months starting from current month
    availableMonths.clear();
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;
    
    // Add months from current month to end of year
    for (int m = currentMonth; m <= 12; m++) {
      final date = DateTime(currentYear, m);
      final monthString = DateFormat('MMMM yyyy').format(date);
      availableMonths.add(monthString);
    }
    
    // Add next year months if needed
    for (int m = 1; m <= 12; m++) {
      final date = DateTime(currentYear + 1, m);
      final monthString = DateFormat('MMMM yyyy').format(date);
      availableMonths.add(monthString);
    }
    
    selectedMonth.value = availableMonths.first;
    */
    
    print('DEBUG: Initialized months starting with: ${selectedMonth.value}');
  }

  void _initializeCalendarDays() {
    // Initialize calendar days for the current month
    final date = DateFormat('MMMM yyyy').parse(selectedMonth.value);
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    
    availableDays.clear();
    for (int day = 1; day <= daysInMonth; day++) {
      final dayDate = DateTime(date.year, date.month, day);
      availableDays.add(AvailableDay(
        id: "${selectedMonth.value}_$day",
        day: day,
        weekday: DateFormat('E').format(dayDate).toUpperCase(),
        date: dayDate,
        monthYear: selectedMonth.value,
      ));
    }
    
    print('DEBUG: Calendar initialized with ${availableDays.length} days for ${selectedMonth.value}');
    
    // Auto-select first day and fetch its availability when screen loads
    // But only if not in reschedule mode (reschedule mode will set its own date)
    if (availableDays.isNotEmpty && !isRescheduleMode.value) {
      selectDate(availableDays.first);
    }
  }

  String get currentMonthName {
    return DateFormat('MMM')
        .format(DateFormat('MMMM yyyy').parse(selectedMonth.value));
  }

  void changeMonth(String month) {
    selectedMonth.value = month;
    selectedDateId.value = ""; // Reset selected date
    selectedDateWithMonth.value = "";
    selectedSlot.value = "";
    selectedTime.value = "";
    slotOptions.clear();
    slotTimeSlots.clear();
    _initializeCalendarDays();
  }

  Future<void> fetchAvailabilityForDate(String date) async {
    if (doctorId.value <= 0) {
      slotError.value = 'Invalid doctor ID';
      return;
    }
    
    isLoadingSlots.value = true;
    slotError.value = '';
    slotOptions.clear();
    slotTimeSlots.clear();
    selectedSlot.value = '';
    selectedTime.value = '';
    
    try {
      final response = await _doctorService.getDoctorAvailabilityDetails(
        doctorId: doctorId.value,
        date: date,
      );
      
      if (response.success && response.data != null) {
        final slots = response.data!.slots;
        slotOptions.assignAll(slots.availableSlotTypes);
        slotTimeSlots['Morning'] = slots.morning;
        slotTimeSlots['Afternoon'] = slots.afternoon;
        slotTimeSlots['Evening'] = slots.evening;

        // Set fees from API
        regularFees.value = response.data!.doctor.regularFees;
        emergencyFees.value = response.data!.doctor.emergencyFees;

        // Set default slot
        if (slotOptions.isNotEmpty) {
          selectedSlot.value = slotOptions.first;
        }
        
        // Hide any existing error snackbar
        if (Get.isSnackbarOpen) {
          Get.closeAllSnackbars();
        }
      } else {
        slotError.value = response.message ?? 'No availability for this date';
        // Don't show snackbar - let UI handle the display
      }
    } catch (e) {
      slotError.value = 'Failed to fetch availability';
      // Don't show snackbar - let UI handle the display
    } finally {
      isLoadingSlots.value = false;
    }
  }

  void selectDate(AvailableDay availableDay) {
    selectedDateId.value = availableDay.id;
    selectedDateWithMonth.value =
        "${availableDay.day} ${DateFormat('MMM').format(availableDay.date)}";
    
    // Clear previous selections
    selectedSlot.value = "";
    selectedTime.value = "";
    
    // Scroll to the selected date
    _scrollToSelectedDate(availableDay);
    
    // Fetch availability for the selected date
    final dateString = DateFormat('yyyy-MM-dd').format(availableDay.date);
    print('DEBUG: Selected date: ${availableDay.day}, formatted: $dateString');
    print('DEBUG: Doctor ID: ${doctorId.value}');
    fetchAvailabilityForDate(dateString);
  }

  void _scrollToSelectedDate(AvailableDay selectedDay) {
    // Find the index of the selected day
    final selectedIndex = availableDays.indexWhere((day) => day.id == selectedDay.id);
    if (selectedIndex == -1) return;
    
    // Wait for the next frame to ensure the scroll controller is attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!dateScrollController.hasClients) return;
      
      // Calculate scroll position
      // Each item width is 60.w + 12.w (separator) = 72.w
      final itemWidth = 60.0 + 12.0; // Using raw values since we can't use .w here
      final targetPosition = selectedIndex * itemWidth;
      
      // Get the current viewport width
      final viewportWidth = dateScrollController.position.viewportDimension;
      
      // Center the selected item in the viewport
      final centeredPosition = targetPosition - (viewportWidth / 2) + (itemWidth / 2);
      
      // Ensure we don't scroll beyond bounds
      final maxScroll = dateScrollController.position.maxScrollExtent;
      final minScroll = dateScrollController.position.minScrollExtent;
      final finalPosition = centeredPosition.clamp(minScroll, maxScroll);
      
      // Animate to the position
      dateScrollController.animateTo(
        finalPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void setSlot(String slot) {
    selectedSlot.value = slot;
    selectedTime.value = ""; // Reset selected time when slot changes
  }

  void selectTime(String time) {
    selectedTime.value = time;
  }

  List<TimeSlot> get currentSlotTimeSlots =>
      slotTimeSlots[selectedSlot.value] ?? [];

  bool get canContinue {
    return selectedDateId.value.isNotEmpty && selectedTime.value.isNotEmpty;
  }

  void continueToNextStep() {
    if (selectedDateId.value.isEmpty) {
      SnackbarUtils.showError("Please select a date",
          title: "Incomplete Selection");
      return;
    }

    if (selectedTime.value.isEmpty) {
      SnackbarUtils.showError("Please select a time slot",
          title: "Incomplete Selection");
      return;
    }
    
    // Find the selected TimeSlot to get its ID
    String? slotId;
    for (var timeSlot in currentSlotTimeSlots) {
      if (timeSlot.time == selectedTime.value) {
        slotId = timeSlot.id.toString();
        break;
      }
    }
    
    // Parse the selected date to get the proper format
    final selectedDay = availableDays.firstWhere((day) => day.id == selectedDateId.value);
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDay.date);
    
    // Get consultation fee based on type
    final fee = selectedConsultationType.value == 'emergency' 
        ? emergencyFees.value 
        : regularFees.value;
    
    if (isRescheduleMode.value) {
      // Handle reschedule
      _handleReschedule(slotId!, formattedDate, fee);
    } else {
      // Handle new appointment
      Get.toNamed(AppRoutes.patientDetailsScreen, arguments: {
        'slotId': slotId,
        'date': formattedDate,
        'consultationType': selectedConsultationType.value == 'emergency' ? 'Emergency' : 'Standard',
        'consultationFee': fee,
        // Forward doctor display info if available
        'doctorName': doctorDisplayName.value,
        'doctorSpeciality': doctorDisplaySpeciality.value,
        'doctorFees': doctorDisplayFees.value,
        'doctorProfilePic': doctorProfilePic.value,
      });
    }
  }

  Future<void> _handleReschedule(String slotId, String date, double fee) async {
    try {
      final response = await _patientService.rescheduleAppointment(
        appointmentId: rescheduleAppointmentId.value,
        doctorAvailabilitySlotId: int.parse(slotId),
        date: date,
        consultationType: selectedConsultationType.value == 'emergency' ? 'Emergency' : 'Standard',
        consultationFee: fee,
      );
      
      if (response.success) {
        SnackbarUtils.showSuccess(
          "Appointment rescheduled successfully",
          title: "Success"
        );
        
        // Force refresh appointments list if available
        try {
          final appointmentsController = Get.find<AppointmentsController>();
          appointmentsController.forceRefresh();
        } catch (e) {
          // AppointmentsController not found, ignore
        }
        
        // Go back to appointments screen
        Get.offAllNamed(AppRoutes.mainScreen);
        // You might want to navigate to appointments tab specifically
      } else {
        SnackbarUtils.showError(
          response.message ?? "Failed to reschedule appointment",
          title: "Error"
        );
      }
    } catch (e) {
      SnackbarUtils.showError(
        "Failed to reschedule appointment: ${e.toString()}",
        title: "Error"
      );
    }
  }
}

class AvailableDay {
  final String id; // Unique identifier
  final int day;
  final String weekday;
  final DateTime date;
  final String monthYear;

  AvailableDay({
    required this.id,
    required this.day,
    required this.weekday,
    required this.date,
    required this.monthYear,
  });
}
