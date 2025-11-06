import 'package:medtrac/utils/enums.dart';

/// Simple User model
class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String profilePicture;
  final Role role;
  final bool isProfileComplete;
  final String age;
  final String gender;
  final String sleepQuality;
  final String mood;
  final int stressLevel;
  final List<String> mentalHealthGoal;
  // Doctor-specific fields
  final String speciality;
  final String licenseNumber;
  final String aboutMe;
  final int totalExperience;
  final String averageRating;
  final int emergencyFees;
  final int regularFees;
  final bool isEmergencyFees;
  final String certificate;
  final ProfileApprovalStatus? isPending; // Doctor profile approval status

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePicture,
    required this.role,
    required this.isProfileComplete,
    required this.age,
    required this.gender,
    this.sleepQuality = '',
    this.mood = '',
    this.stressLevel = 0,
    this.mentalHealthGoal = const [],
    this.speciality = '',
    this.licenseNumber = '',
    this.aboutMe = '',
    this.totalExperience = 0,
    this.averageRating = '0.00',
    this.emergencyFees = 0,
    this.regularFees = 0,
    this.isEmergencyFees = false,
    this.certificate = '',
    this.isPending,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? json['phone_number'] ?? "",
      profilePicture: json['profile_picture'] ?? json['avatar'] ?? json['picture'] ?? "",
      role: Role.values.firstWhere(
        (e) => e.toString() == 'Role.${json['role'].toString().toLowerCase()}',
        orElse: () => Role.user,
      ),
      isProfileComplete: json['is_profile_completed'] ?? false,
      age: json['age']?.toString() ?? '',
      gender: json['gender'] ?? "",
      sleepQuality: json['sleep_quality'] ?? '',
      mood: json['mood'] ?? '',
      stressLevel: json['stress_level'] ?? 0,
      mentalHealthGoal: json['mental_health_goal'] is List
          ? List<String>.from(json['mental_health_goal'])
          : [],
      speciality: json['speciality'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      aboutMe: json['about_me'] ?? '',
      totalExperience: json['total_experience'] ?? 0,
      averageRating: json['average_rating']?.toString() ?? '0.00',
      emergencyFees: json['emergency_fees'] ?? 0,
      regularFees: json['regular_fees'] ?? 0,
      isEmergencyFees: json['isEmergencyFees'] ?? false,
      certificate: json['certificate'] ?? '',
      isPending: json['isPending'] != null 
          ? ProfileApprovalStatusExtension.fromString(json['isPending'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_picture': profilePicture,
      'role': role.toString().split('.').last,
      'is_profile_completed': isProfileComplete,
      'age': age,
      'gender': gender,
      'sleep_quality': sleepQuality,
      'mood': mood,
      'stress_level': stressLevel,
      'mental_health_goal': mentalHealthGoal,
      'speciality': speciality,
      'license_number': licenseNumber,
      'about_me': aboutMe,
      'total_experience': totalExperience,
      'average_rating': averageRating,
      'emergency_fees': emergencyFees,
      'regular_fees': regularFees,
      'isEmergencyFees': isEmergencyFees,
      'certificate': certificate,
      'isPending': isPending?.name,
    };
  }
}
