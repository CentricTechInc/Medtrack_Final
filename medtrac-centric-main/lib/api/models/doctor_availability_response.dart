class DoctorAvailabilityResponse {
  final bool status;
  final String message;
  final DoctorAvailabilityData data;

  DoctorAvailabilityResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DoctorAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return DoctorAvailabilityResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: DoctorAvailabilityData.fromJson(json['data'] ?? {}),
    );
  }
}

class DoctorAvailabilityData {
  final int id;
  final int doctorId;
  final int monthNumber;
  final String monthName;
  final String date;
  final AvailabilitySlots slots;
  final DoctorFeesInfo doctor;

  DoctorAvailabilityData({
    required this.id,
    required this.doctorId,
    required this.monthNumber,
    required this.monthName,
    required this.date,
    required this.slots,
    required this.doctor,
  });

  factory DoctorAvailabilityData.fromJson(Map<String, dynamic> json) {
    return DoctorAvailabilityData(
      id: json['id'] ?? 0,
      doctorId: json['doctor_id'] ?? 0,
      monthNumber: json['month_number'] ?? 0,
      monthName: json['month_name'] ?? '',
      date: json['date'] ?? '',
      slots: AvailabilitySlots.fromJson(json['slots'] ?? {}),
      doctor: DoctorFeesInfo.fromJson(json['doctor'] ?? {}),
    );
  }
}

class AvailabilitySlots {
  final List<TimeSlot> morning;
  final List<TimeSlot> afternoon;
  final List<TimeSlot> evening;

  AvailabilitySlots({
    required this.morning,
    required this.afternoon,
    required this.evening,
  });

  factory AvailabilitySlots.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlots(
      morning: (json['Morning'] as List<dynamic>?)
              ?.map((item) => TimeSlot.fromJson(item))
              .toList() ??
          [],
      afternoon: (json['Afternoon'] as List<dynamic>?)
              ?.map((item) => TimeSlot.fromJson(item))
              .toList() ??
          [],
      evening: (json['Evening'] as List<dynamic>?)
              ?.map((item) => TimeSlot.fromJson(item))
              .toList() ??
          [],
    );
  }

  List<String> get availableSlotTypes {
    List<String> slots = [];
    if (morning.isNotEmpty) slots.add('Morning');
    if (afternoon.isNotEmpty) slots.add('Afternoon');
    if (evening.isNotEmpty) slots.add('Evening');
    return slots;
  }

  List<TimeSlot> getSlotsForType(String slotType) {
    switch (slotType) {
      case 'Morning':
        return morning;
      case 'Afternoon':
        return afternoon;
      case 'Evening':
        return evening;
      default:
        return [];
    }
  }

  List<TimeSlot> getAvailableSlotsForType(String slotType) {
    return getSlotsForType(slotType)
        .where((slot) => slot.status.toLowerCase() == 'available')
        .toList();
  }
}

class TimeSlot {
  final int id;
  final int doctorAvailabilityId;
  final String slot;
  final String time;
  final String status;
  final int doctorId;

  TimeSlot({
    required this.id,
    required this.doctorAvailabilityId,
    required this.slot,
    required this.time,
    required this.status,
    required this.doctorId,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'] ?? 0,
      doctorAvailabilityId: json['doctorAvailbilityId'] ?? 0,
      slot: json['slot'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
      doctorId: json['doctor_id'] ?? 0,
    );
  }

  bool get isAvailable => status.toLowerCase() == 'available';
}

class DoctorFeesInfo {
  final double emergencyFees;
  final double regularFees;
  final bool isEmergencyFees;

  DoctorFeesInfo({
    required this.emergencyFees,
    required this.regularFees,
    required this.isEmergencyFees,
  });

  factory DoctorFeesInfo.fromJson(Map<String, dynamic> json) {
    return DoctorFeesInfo(
      emergencyFees: (json['emergency_fees'] ?? 0).toDouble(),
      regularFees: (json['regular_fees'] ?? 0).toDouble(),
      isEmergencyFees: json['isEmergencyFees'] ?? false,
    );
  }
}
