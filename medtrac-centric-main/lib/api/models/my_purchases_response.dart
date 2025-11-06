class MyPurchasesResponse {
  final bool status;
  final String message;
  final MyPurchasesData? data;

  MyPurchasesResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory MyPurchasesResponse.fromJson(Map<String, dynamic> json) {
    return MyPurchasesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? MyPurchasesData.fromJson(json['data'])
          : null,
    );
  }
}

class MyPurchasesData {
  final int totalAppointments;
  final double totalSpending;
  final List<PurchaseAppointmentItem> appointments;

  MyPurchasesData({
    required this.totalAppointments,
    required this.totalSpending,
    required this.appointments,
  });

  factory MyPurchasesData.fromJson(Map<String, dynamic> json) {
    return MyPurchasesData(
      totalAppointments: json['totalAppointments'] ?? 0,
      totalSpending: (json['totalSpending'] ?? 0).toDouble(),
      appointments: (json['appointment'] as List<dynamic>?)
              ?.map((item) => PurchaseAppointmentItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class PurchaseAppointmentItem {
  final String date;
  final int consultationFee;
  final PurchaseDoctor doctor;

  PurchaseAppointmentItem({
    required this.date,
    required this.consultationFee,
    required this.doctor,
  });

  factory PurchaseAppointmentItem.fromJson(Map<String, dynamic> json) {
    return PurchaseAppointmentItem(
      date: json['date'] ?? '',
      consultationFee: (json['consultation_fee'] ?? 0),
      doctor: PurchaseDoctor.fromJson(json['doctor'] ?? {}),
    );
  }
}

class PurchaseDoctor {
  final int id;
  final String name;
  final String picture;
  final String speciality;
  final String averageRating;
  final bool isEmergencyFees;
  final double regularFees;
  final double emergencyFees;

  PurchaseDoctor({
    required this.id,
    required this.name,
    required this.picture,
    required this.speciality,
    required this.averageRating,
    required this.isEmergencyFees,
    required this.regularFees,
    required this.emergencyFees,
  });

  factory PurchaseDoctor.fromJson(Map<String, dynamic> json) {
    return PurchaseDoctor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      picture: json['picture'] ?? '',
      speciality: json['speciality'] ?? '',
      averageRating: json['average_rating'] ?? '0.00',
      isEmergencyFees: json['isEmergencyFees'] ?? false,
      regularFees: (json['regular_fees'] ?? 0).toDouble(),
      emergencyFees: (json['emergency_fees'] ?? 0).toDouble(),
    );
  }
}
