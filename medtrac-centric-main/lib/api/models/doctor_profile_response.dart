import 'package:medtrac/utils/enums.dart';

class DoctorProfileData {
  final String certificate;
  final String picture;
  final int id;
  final String email;
  final String name;
  final String phoneNumber;
  final String gender;
  final String speciality;
  final String licenseNumber;
  final String aboutMe;
  final int totalExperience;
  final String averageRating;
  final int emergencyFees;
  final int regularFees;
  final bool isEmergencyFees;
  final ProfileApprovalStatus? isPending;
  final bool isProfileComplete;

  DoctorProfileData({
    required this.certificate,
    required this.picture,
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.gender,
    required this.speciality,
    required this.licenseNumber,
    required this.aboutMe,
    required this.totalExperience,
    required this.averageRating,
    required this.emergencyFees,
    required this.regularFees,
    required this.isEmergencyFees,
    required this.isProfileComplete,
    this.isPending,
  });

  factory DoctorProfileData.fromJson(Map<String, dynamic> json) {
    return DoctorProfileData(
      certificate: json['certificate'] ?? '',
      picture: json['picture'] ?? '',
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      gender: json['gender'] ?? '',
      speciality: json['speciality'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      aboutMe: json['about_me'] ?? '',
      totalExperience: json['total_experience'] ?? 0,
      averageRating: json['average_rating']?.toString() ?? '0.00',
      emergencyFees: json['emergency_fees'] ?? 0,
      regularFees: json['regular_fees'] ?? 0,
      isEmergencyFees: json['isEmergencyFees'] ?? false,
      isPending: json['isPending'] != null
          ? ProfileApprovalStatusExtension.fromString(json['isPending'])
          : null,
      isProfileComplete: json['isProfileCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificate': certificate,
      'picture': picture,
      'id': id,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'gender': gender,
      'speciality': speciality,
      'license_number': licenseNumber,
      'about_me': aboutMe,
      'total_experience': totalExperience,
      'average_rating': averageRating,
      'emergency_fees': emergencyFees,
      'regular_fees': regularFees,
      'isEmergencyFees': isEmergencyFees,
      'isPending': isPending?.name,
      'is_profile_completed': isProfileComplete,
    };
  }
}

class DoctorProfileResponse {
  final bool status;
  final String message;
  final DoctorProfileData? data;

  DoctorProfileResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory DoctorProfileResponse.fromJson(Map<String, dynamic> json) {
    return DoctorProfileResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? DoctorProfileData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}
