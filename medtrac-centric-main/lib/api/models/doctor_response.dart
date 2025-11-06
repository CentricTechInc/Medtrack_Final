import 'review.dart';

class DoctorListResponse {
  final bool status;
  final List<Doctor> data;
  final String? message;
  final List<String>? errors;

  DoctorListResponse({
    required this.status,
    required this.data,
    this.message,
    this.errors,
  });

  factory DoctorListResponse.fromJson(Map<String, dynamic> json) {
    return DoctorListResponse(
      status: json['status'] ?? false,
      data: json['data'] != null
          ? ((json['data'] as Map<String, dynamic>)['rows'] as List).map((item) => Doctor.fromJson(item)).toList()
          : [],
      message: json['message'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class DoctorDetailsResponse {
  final bool status;
  final Doctor? data;
  final String? message;
  final List<String>? errors;

  DoctorDetailsResponse({
    required this.status,
    this.data,
    this.message,
    this.errors,
  });

  factory DoctorDetailsResponse.fromJson(Map<String, dynamic> json) {
    return DoctorDetailsResponse(
      status: json['status'] ?? false,
      data: json['data'] != null ? Doctor.fromJson(json['data']) : null,
      message: json['message'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class Doctor {
  final int id;
  final String email;
  final String name;
  final String phoneNumber;
  final String gender;
  final String? speciality;
  final String? licenseNumber;
  final String? aboutMe;
  final int? totalExperience;
  final String averageRating;
  final double emergencyFees;
  final double regularFees;
  final String? certificate;
  final String? picture;
  // Additional fields with default values
  final String dateAvailable;
  final String timeAvailable;
  final bool isEmergency;
  final int numberOfPatients;
  final int? patientCount; // New field from API
  final List<Review>? reviews; // New field from API

  Doctor(
      {required this.id,
      required this.email,
      required this.name,
      required this.phoneNumber,
      required this.gender,
      this.speciality,
      this.licenseNumber,
      this.aboutMe,
      this.totalExperience,
      required this.averageRating,
      required this.emergencyFees,
      required this.regularFees,
      this.certificate,
      this.picture,
      required this.dateAvailable,
      required this.timeAvailable,
      required this.isEmergency,
      required this.numberOfPatients,
      this.patientCount,
      this.reviews});

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      gender: json['gender'] ?? '',
      speciality: json['speciality'],
      licenseNumber: json['license_number'],
      aboutMe: json['about_me'],
      totalExperience: json['total_experience'],
      averageRating: json['average_rating'] ?? '0.00',
      emergencyFees: (json['emergency_fees'] ?? 0).toDouble(),
      regularFees: (json['regular_fees'] ?? 0).toDouble(),
      certificate: json['certificate'],
      picture: json['picture'],
      // Default values for missing fields
      dateAvailable: json['date_available'] ?? _getDefaultDate(),
      timeAvailable: json['time_available'] ?? '10am - 6pm',
      isEmergency: json['isEmergencyFees'] ?? true,
      numberOfPatients: json['number_of_patients'] ?? json['patient_count'] ?? 120,
      patientCount: json['patient_count'],
      reviews: json['reviews'] != null 
          ? (json['reviews'] as List).map((item) => Review.fromJson(item)).toList()
          : null,
    );
  }

  // Helper method to get default date
  static String _getDefaultDate() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${tomorrow.day} ${months[tomorrow.month - 1]}, ${tomorrow.year}';
  }

  // Helper methods for UI
  String get displayName => name.isEmpty ? 'Dr. Unknown' : name;
  String get displaySpeciality => speciality ?? 'N/A';
  String get displayAbout => aboutMe ?? 'N/A';
  int get displayExperience => totalExperience ?? 5;
  String get displayPicture => picture?.isNotEmpty == true ? picture! : '';
  double get displayRating => double.tryParse(averageRating) ?? 0.0;
  String get displayFees => emergencyFees > 0
      ? '₹ ${emergencyFees.toInt()}'
      : '₹ ${regularFees.toInt()}';
  int get displayPatientCount => patientCount ?? numberOfPatients;
  List<Review> get displayReviews => reviews ?? [];
}
