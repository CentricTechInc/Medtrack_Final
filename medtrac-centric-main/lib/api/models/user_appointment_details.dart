class UserAppointmentDetailsResponse {
  final bool status;
  final String message;
  final UserAppointmentDetails? data;

  UserAppointmentDetailsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory UserAppointmentDetailsResponse.fromJson(Map<String, dynamic> json) {
    return UserAppointmentDetailsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? UserAppointmentDetails.fromJson(json['data'])
          : null,
    );
  }
}

class UserAppointmentDetails {
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
  final String? patientName;
  final List<String>? primaryConcern;
  final List<String>? medication;
  final PatientInfo? patient;
  final DoctorInfo? doctor;

  UserAppointmentDetails({
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
    this.patientName,
    this.primaryConcern,
    this.medication,
    this.patient,
    this.doctor,
  });

  factory UserAppointmentDetails.fromJson(Map<String, dynamic> json) {
    return UserAppointmentDetails(
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
      patientName: json['patient_name'],
      primaryConcern: json['primary_concern'] != null 
          ? List<String>.from(json['primary_concern'])
          : null,
      medication: json['medication'] != null 
          ? List<String>.from(json['medication'])
          : null,
      patient: json['patient'] != null 
          ? PatientInfo.fromJson(json['patient'])
          : null,
      doctor: json['doctor'] != null 
          ? DoctorInfo.fromJson(json['doctor'])
          : null,
    );
  }
}

class PatientInfo {
  final String? picture;
  final int? id;
  final String? sleepQuality;
  final int? stressLevel;
  final String? mood;

  PatientInfo({
    this.picture,
    this.id,
    this.sleepQuality,
    this.stressLevel,
    this.mood,
  });

  factory PatientInfo.fromJson(Map<String, dynamic> json) {
    return PatientInfo(
      picture: json['picture'],
      id: json['id'],
      sleepQuality: json['sleep_quality'],
      stressLevel: json['stress_level'],
      mood: json['mood'],
    );
  }
}

class DoctorInfo {
  final String? picture;
  final int id;
  final String name;
  final String? gender;
  final String speciality;

  DoctorInfo({
    this.picture,
    required this.id,
    required this.name,
    this.gender,
    required this.speciality,
  });

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      picture: json['picture'],
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      gender: json['gender'],
      speciality: json['speciality'] ?? '',
    );
  }
}
