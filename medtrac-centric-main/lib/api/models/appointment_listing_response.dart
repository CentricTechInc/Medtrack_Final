class AppointmentListingResponse {
  final bool status;
  final String message;
  final AppointmentListingData? data;

  AppointmentListingResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AppointmentListingResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentListingResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? AppointmentListingData.fromJson(json['data']) 
          : null,
    );
  }
}

class AppointmentListingData {
  final int count;
  final List<AppointmentItem> rows;

  AppointmentListingData({
    required this.count,
    required this.rows,
  });

  factory AppointmentListingData.fromJson(Map<String, dynamic> json) {
    return AppointmentListingData(
      count: json['count'] ?? 0,
      rows: (json['rows'] as List<dynamic>?)
              ?.map((item) => AppointmentItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class AppointmentItem {
  final String date;
  final int id;
  final String time;
  final String status;
  final AppointmentDoctor doctor;
  final AppointmentPatient patient;
  final String? patientName;

  AppointmentItem({
    required this.date,
    required this.id,
    required this.time,
    required this.status,
    required this.doctor,
    required this.patient,
    this.patientName,
  });

  factory AppointmentItem.fromJson(Map<String, dynamic> json) {
    return AppointmentItem(
      date: json['date'] ?? '',
      id: json['id'] ?? 0,
      time: json['time'] ?? '',
      status: json['status'] ?? '',
      patientName: json['name'] ?? '',
      doctor: AppointmentDoctor.fromJson(json['doctor'] ?? {}),
      patient: AppointmentPatient.fromJson(json['patient'] ?? {}),
    );
  }
}

class AppointmentDoctor {
  final String picture;
  final int id;
  final String name;
  final String speciality;
  final String averageRating;
  final bool isEmergencyFees;

  AppointmentDoctor({
    required this.picture,
    required this.id,
    required this.name,
    required this.speciality,
    required this.averageRating,
    required this.isEmergencyFees,
  });

  factory AppointmentDoctor.fromJson(Map<String, dynamic> json) {
    return AppointmentDoctor(
      picture: json['picture'] ?? '',
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      speciality: json['speciality'] ?? '',
      averageRating: json['average_rating'] ?? '0.00',
      isEmergencyFees: json['isEmergencyFees'] ?? false,
    );
  }
}


class AppointmentPatient {
  final String picture;
  final int id;
  final String name;

  AppointmentPatient({
    required this.picture,
    required this.id,
    required this.name,
  });

  factory AppointmentPatient.fromJson(Map<String, dynamic> json) {
    return AppointmentPatient(
      picture: json['picture'] ?? '',
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}