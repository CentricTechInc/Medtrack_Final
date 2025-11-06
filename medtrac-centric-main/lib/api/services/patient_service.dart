
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:medtrac/api/http_client.dart';
import 'package:medtrac/api/models/api_response.dart';
import 'package:medtrac/api/models/appointment_listing_response.dart';
import 'package:medtrac/api/models/user_appointment_details.dart';
import 'package:medtrac/api/models/patient_profile_response.dart';
import 'package:medtrac/api/models/user.dart';
import 'package:medtrac/api/models/user_medical_history.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:medtrac/utils/enums.dart';
import 'dart:convert';
import 'package:medtrac/api/models/emotions_analytics_response.dart';
import 'package:medtrac/api/models/my_purchases_response.dart';

class PatientService {

  /// Get emotions analytics (sleep, mood, stress) for the week
  Future<EmotionsAnalyticsResponse?> getEmotionsAnalytics() async {
    try {
      final response = await _http.get('patient/emotions-analytics');
      if (response.data != null) {
        return EmotionsAnalyticsResponse.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Failed to fetch emotions analytics: $e');
      return null;
    }
  }
  static final PatientService _instance = PatientService._internal();
  factory PatientService() => _instance;
  PatientService._internal();

  final HttpClient _http = HttpClient();

  /// Update basic info for patient
  Future<ApiResponse<String>> updateBasicInfo({
    String? age,
    String? weight,
    String? gender,
    String? sleepQuality,
    int? stressLevel,
    String? mood,
    List<String>? mentalHealthGoals,
    List<Map<String, String>>? questions,
    File? picture,
    // Additional fields for user profile update
    String? name,
    String? email,
    String? phone,
    String? phoneNumber,
    String? bloodGroup,
    String? primaryConcern,
    String? medication,
  }) async {
    try {
      // Create the JSON payload
      final Map<String, dynamic> data = {};

      // Add basic info fields (for onboarding)
      if (age != null) {
        data['age'] = age;
      }
      if (weight != null && weight.isNotEmpty) {
        data['weight'] = weight;
      }
      if (gender != null && gender.isNotEmpty) {
        data['gender'] = gender;
      }
      if (sleepQuality != null && sleepQuality.isNotEmpty) {
        data['sleep_quality'] = sleepQuality;
      }
      if (stressLevel != null) {
        data['stress_level'] = stressLevel;
      }
      if (mood != null && mood.isNotEmpty) {
        data['mood'] = mood;
      }
      if (mentalHealthGoals != null && mentalHealthGoals.isNotEmpty) {
        data['mental_health_goals'] = mentalHealthGoals;
      }
      if (questions != null && questions.isNotEmpty) {
        data['Questions'] = questions;
      }

      // Add user profile fields
      if (name != null && name.isNotEmpty) {
        data['name'] = name;
      }
      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }
      if (phone != null && phone.isNotEmpty) {
        data['phone_number'] = phone;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        data['phone_number'] = phoneNumber;
      }
      if (bloodGroup != null && bloodGroup.isNotEmpty) {
        data['blood_group'] = bloodGroup;
      }
      if (primaryConcern != null && primaryConcern.isNotEmpty) {
        data['primary_concern'] = primaryConcern;
      }
      if (medication != null && medication.isNotEmpty) {
        data['medication'] = medication;
      }

      // If there's a picture, use FormData, otherwise use JSON
        final formData = FormData();

        // Add JSON data as fields
        data.forEach((key, value) {
          if (value is List) {
            // Convert arrays to proper JSON format
            formData.fields.add(MapEntry(key, jsonEncode(value)));
          } else {
            formData.fields.add(MapEntry(key, value.toString()));
          }
        });

        if(picture != null) {
          // Add picture
        formData.files.add(MapEntry(
          'picture',
          await MultipartFile.fromFile(
            picture.path,
            filename: picture.path.split('/').last,
          ),
        ));
        }

        final response = await _http.put(
          '/patient',
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
          ),
        );

        final apiResponse = ApiResponse<String>.fromJson(response.data, null);

        // If update was successful and user is a patient, fetch updated profile
        if (apiResponse.success && HelperFunctions.isUser()) {
          try {
            await getPatientProfile();
          } catch (e) {
            // Don't throw error for profile fetch failure
            print('Failed to fetch updated profile: $e');
          }
        }

        return apiResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Get appointment listing with pagination, search and filtering
  Future<AppointmentListingResponse> getPatientAppointmentListing({
    required int page,
    required String status, // "Upcoming", "Completed", "Canceled"
    String? searchQuery,
    int pageLimit = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'status': status,
        'pageLimit': pageLimit.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final response = await _http.get(
        'appointments/listing/$page',
        queryParameters: queryParams,
      );

      return AppointmentListingResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get appointment details by ID (supports both user and doctor views)
  Future<UserAppointmentDetailsResponse> getUserAppointmentDetails(
      int appointmentId) async {
    try {
      final response = await _http.get('/appointments/details/$appointmentId');
      return UserAppointmentDetailsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get appointment details by ID (legacy method - kept for backward compatibility)
  Future<ApiResponse<Map<String, dynamic>>> getAppointmentDetails(
      int appointmentId) async {
    try {
      final isUser = HelperFunctions.isUser();
      final endpoint = isUser
          ? '/appointments/details/$appointmentId'
          : '/appointments/doctor-appointment-details/$appointmentId';

      final response = await _http.get(endpoint);
      return ApiResponse<Map<String, dynamic>>.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel appointment with reason
  Future<ApiResponse<String>> cancelAppointment({
    required int appointmentId,
    required String reason,
  }) async {
    try {
      final formData = FormData();
      formData.fields.add(MapEntry('reason', reason));

      final response = await _http.put(
        '/appointments/cancel-appointment/$appointmentId',
        data: formData,
      );

      return ApiResponse<String>.fromJson(
        response.data,
        (data) => data.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reschedule appointment
  Future<ApiResponse<String>> rescheduleAppointment({
    required int appointmentId,
    required int doctorAvailabilitySlotId,
    required String date,
    required String consultationType,
    required double consultationFee,
  }) async {
    try {
      final data = {
        "doctorAvailabilitySlotId": doctorAvailabilitySlotId,
        "date": date,
        "consultation_type": consultationType,
        "consultation_fee": consultationFee
      };

      final response = await _http.put(
        '/appointments/update-appointment/$appointmentId',
        data: data,
      );

      return ApiResponse<String>.fromJson(
        response.data,
        (data) => data.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get patient profile details
  Future<PatientProfileResponse> getPatientProfile() async {
    try {
      final response = await _http.get('/patient');
      final profileResponse = PatientProfileResponse.fromJson(response.data);

      // Update SharedPreferences with the fetched data
      if (profileResponse.status && profileResponse.data != null) {
        await _updateSharedPrefsFromProfile(profileResponse.data!);
      }

      return profileResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Update SharedPreferences with patient profile data
  Future<void> _updateSharedPrefsFromProfile(
      PatientProfileData profileData) async {
    try {
      // Update user info
      final user = User(
        id: profileData.id,
        name: profileData.name,
        email: profileData.email,
        phone: profileData.phoneNumber,
        profilePicture: profileData.picture,
        role: Role.user, // Assuming this is always a user/patient
        isProfileComplete: true, // If we have profile data, consider it complete
        age: profileData.age.toString(),
        gender: profileData.gender,
        sleepQuality: profileData.sleepQuality,
        mood: profileData.mood,
        stressLevel: profileData.stressLevel,
        mentalHealthGoal: profileData.mentalHealthGoal,
      );

      await SharedPrefsService.setUserInfo(jsonEncode(user.toJson()));

      // Update medical history
      final medicalHistory = UserMedicalHistory(
        bloodGroup: profileData.bloodGroup ?? '',
        weight: profileData.weight,
        primaryConcerns: profileData.primaryConcern != null
            ? profileData.primaryConcern!
            : [],
        medications: profileData.medication != null
            ? profileData.medication!
            : [],
      );

      await SharedPrefsService.setUserMedicalHistory(medicalHistory);
    } catch (e) {
      // Log error but don't throw to prevent breaking the main flow
      print('Error updating SharedPrefs from profile: $e');
    }
  }

  /// Submit daily emotions/check-in data
  Future<ApiResponse<String>> submitEmotions({
    required String sleepQuality,
    required int stressLevel,
    required String currentMood,
  }) async {
    try {
      final data = {
        'sleep_quality': sleepQuality,
        'stress_level': stressLevel,
        'current_mood': currentMood,
      };

      final response = await _http.post(
        'patient/emotions',
        data: data,
      );

      return ApiResponse<String>.fromJson(
        response.data,
        (data) => data.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get patient's my purchases data
  Future<MyPurchasesResponse> getMyPurchases({
    required int pageNumber,
    String? searchQuery,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final response = await _http.get(
        'patient/my-purchases/$pageNumber',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return MyPurchasesResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Submit doctor review
  Future<ApiResponse<String>> submitReview({
    required int doctorId,
    required double rating,
    required String description,
    required bool recommended,
  }) async {
    try {
      final data = {
        'doctor_id': doctorId.toString(),
        'rating': rating.toString(),
        'description': description,
        'recommended': recommended,
      };

      print('📝 Submitting review: $data');

      final response = await _http.post(
        'reviews',
        data: data,
      );

      return ApiResponse<String>.fromJson(
        response.data,
        (data) => data.toString(),
      );
    } catch (e) {
      print('❌ Error submitting review: $e');
      rethrow;
    }
  }

  // /// Helper method to parse string list fields
  // List<String> _parseStringListField(String field) {
  //   if (field.isEmpty) return [];
  //   return field
  //       .split(',')
  //       .map((s) => s.trim())
  //       .where((s) => s.isNotEmpty)
  //       .toList();
  // }
}
