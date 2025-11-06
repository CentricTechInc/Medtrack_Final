class DoctorAppointmentDetailsResponse {
  final bool status;
  final String message;
  final DoctorAppointmentDetails? data;

  DoctorAppointmentDetailsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory DoctorAppointmentDetailsResponse.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentDetailsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? DoctorAppointmentDetails.fromJson(json['data'])
          : null,
    );
  }
}

class DoctorAppointmentDetails {
  final int id;
  final String status;
  final String? appointmentDate;
  final String? type;
  final String? consultationType;
  final double? consultationFee;
  final String? appointmentTime;
  final String? timeRange;
  final String? slot;
  final String? reason;

  // Completed appointment fields
  final String? doctorAdvice;
  final String? prescription;
  final String? sharedDocuments;
  final String? patientHistory;
  final List<String>? primaryConcern;
  final List<String>? medication;
  final PatientDetailsInfo? patient;

  // Payment details
  final double? totalFee;
  final double? platformFee;
  final double? doctorFee;
  final String? paymentMethod;

  DoctorAppointmentDetails({
    required this.id,
    required this.status,
    this.appointmentDate,
    this.type,
    this.consultationType,
    this.consultationFee,
    this.appointmentTime,
    this.timeRange,
    this.slot,
    this.reason,
    this.doctorAdvice,
    this.prescription,
    this.sharedDocuments,
    this.patientHistory,
    this.primaryConcern,
    this.medication,
    this.patient,
    this.totalFee,
    this.platformFee,
    this.doctorFee,
    this.paymentMethod,
  });

  factory DoctorAppointmentDetails.fromJson(Map<String, dynamic> json) {
    print(json['shared_documents']);
    return DoctorAppointmentDetails(
      id: json['id'] ?? 0,
      status: json['status'] ?? '',
      appointmentDate: json['appointment_date'],
      type: json['type'],
      consultationType: json['consultation_type'],
      consultationFee: json['consultation_fee']?.toDouble(),
      appointmentTime: json['appointment_time'],
      timeRange: json['time_range'],
      slot: json['slot'],
      reason: json['reason'],
      doctorAdvice: json['doctor_advice'],
      prescription: json['prescription'],
      sharedDocuments: json['shared_documents'],
      patientHistory: json['patient_history'],
      primaryConcern: json['primary_concern'] != null
          ? List<String>.from(json['primary_concern'])
          : null,
      medication: json['medication'] != null
          ? List<String>.from(json['medication'])
          : null,
      patient: json['patient'] != null
          ? PatientDetailsInfo.fromJson(json['patient'], json['patient_name'])
          : null,
      totalFee: json['total_fee']?.toDouble(),
      platformFee: json['platform_fee']?.toDouble(),
      doctorFee: json['doctor_fee']?.toDouble(),
      paymentMethod: json['payment_method'],
    );
  }
}

class PatientDetailsInfo {
  final String? picture;
  final int? id;
  final String? sleepQuality;
  final int? stressLevel;
  final String? mood;
  final String? name;
  final String? patientName;

  PatientDetailsInfo({
    this.picture,
    this.id,
    this.sleepQuality,
    this.stressLevel,
    this.mood,
    this.name,
    this.patientName,
  });

  factory PatientDetailsInfo.fromJson(Map<String, dynamic> json, String patientName) {
    return PatientDetailsInfo(
        picture: json['picture'],
        id: json['id'],
        sleepQuality: json['sleep_quality'],
        stressLevel: json['stress_level'],
        mood: json['mood'],
        name: json['name'],
        patientName: patientName);
        
  }
}
