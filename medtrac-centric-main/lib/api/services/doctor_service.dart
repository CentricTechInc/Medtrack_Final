import 'dart:io';
import 'package:dio/dio.dart';
import 'package:medtrac/api/models/appointment_listing_response.dart';
import 'package:medtrac/api/models/doctor_response.dart';
import 'package:medtrac/api/models/doctor_availability_response.dart';
import 'package:medtrac/api/models/doctor_appointment_details.dart';
import 'package:medtrac/api/models/appointment_statistics_response.dart';
import 'package:medtrac/api/models/patient_profile_response.dart';
import 'package:medtrac/api/models/doctor_profile_response.dart';
import 'package:medtrac/api/models/transaction_response.dart';
import 'package:medtrac/api/models/user.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/enums.dart';
import 'package:medtrac/utils/helper_functions.dart';
import '../http_client.dart';
import '../constants/api_constants.dart';
import '../models/api_response.dart';
import 'dart:convert';

/// Doctor Service - Singleton
/// Handles doctor-related API calls
class DoctorService {
  static final DoctorService _instance = DoctorService._internal();
  factory DoctorService() => _instance;
  DoctorService._internal();

  final HttpClient _http = HttpClient();

  /// Change password
  Future<ApiResponse<String>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _http.post(
        ApiConstants.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': newPassword,
        },
      );

      return ApiResponse<String>.fromJson(response.data, null);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete user account
  Future<ApiResponse<String>> deleteDoctorAccount() async {
    try {
      final response = await _http.delete(ApiConstants.deleteDoctor);
      return ApiResponse<String>.fromJson(response.data, null);
    } catch (e) {
      rethrow;
    }
  }

  /// Update doctor profile info (without availability)
  Future<ApiResponse<String>> updateProfileInfo({
    File? picture,
    List<File>? certificate,
    required String speciality,
    required String licenseNumber,
    required String totalExperience,
    required String aboutMe,
  }) async {
    try {
      // Check file sizes before upload
      const int maxFileSize = 1 * 1024 * 1024; // 1MB limit

      if (picture != null) {
        final pictureSize = await picture.length();

        if (pictureSize > maxFileSize) {
          throw Exception(
              'Profile picture is too large. Please select a smaller image (max 1MB).');
        }
      }

      if (certificate != null && certificate.isNotEmpty) {
        for (var file in certificate) {
          final fileSize = await file.length();

          if (fileSize > maxFileSize) {
            throw Exception(
                'Certificate file is too large. Please select a smaller file (max 1MB).');
          }
        }
      }

      // Create FormData for multipart upload
      final formData = FormData();

      // Add profile picture if provided
      if (picture != null) {
        formData.files.add(MapEntry(
          'picture',
          await MultipartFile.fromFile(
            picture.path,
            filename: picture.path.split('/').last,
          ),
        ));
      }

      // Add certificate files if provided
      if (certificate != null && certificate.isNotEmpty) {
        for (var file in certificate) {
          formData.files.add(MapEntry(
            'certificate',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ));
        }
      }

      // Add basic profile data
      formData.fields.addAll([
        MapEntry('speciality', speciality),
        MapEntry('license_number', licenseNumber),
        MapEntry('total_experience', totalExperience),
        MapEntry('about_me', aboutMe),
      ]);

      final response = await _http.put(
        'doctor/update-profile',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      return ApiResponse<String>.fromJson(response.data, null);
    } catch (e) {
      rethrow;
    }
  }

  /// Update doctor profile
  Future<ApiResponse<String>> updateProfile({
    required File? picture,
    required List<File>? certificate,
    required String speciality,
    required String licenseNumber,
    required String emergencyFees,
    required String regularFees,
    required String totalExperience,
    required String aboutMe,
    required int monthNumber,
    required String monthName,
    required List<String> dates,
    required Map<String, List<String>> slots,
    required bool isEmergencyFees,
  }) async {
    try {
      // Check file sizes before upload
      const int maxFileSize = 1 * 1024 * 1024; // 1MB limit

      if (picture != null) {
        final pictureSize = await picture.length();

        if (pictureSize > maxFileSize) {
          throw Exception(
              'Profile picture is too large. Please select a smaller image (max 10MB).');
        }
      }

      if (certificate != null && certificate.isNotEmpty) {
        for (var file in certificate) {
          final fileSize = await file.length();

          if (fileSize > maxFileSize) {
            throw Exception(
                'Certificate file is too large. Please select a smaller file (max 10MB).');
          }
        }
      }

      // Create FormData for multipart upload
      final formData = FormData();

      // Add profile picture if provided
      if (picture != null) {
        formData.files.add(MapEntry(
          'picture',
          await MultipartFile.fromFile(
            picture.path,
            filename: picture.path.split('/').last,
          ),
        ));
      }

      // Add certificate files if provided
      if (certificate != null && certificate.isNotEmpty) {
        for (var file in certificate) {
          formData.files.add(MapEntry(
            'certificate',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ));
        }
      }

      // Add basic profile data
      formData.fields.addAll([
        MapEntry('speciality', speciality),
        MapEntry('license_number', licenseNumber),
        MapEntry('emergency_fees', emergencyFees),
        MapEntry('regular_fees', regularFees),
        MapEntry('total_experience', totalExperience),
        MapEntry('about_me', aboutMe),
      ]);

      // Add availability data
      formData.fields.addAll([
        MapEntry('availabilities[month_number]', monthNumber.toString()),
        MapEntry('availabilities[month_name]', monthName),
        MapEntry('availabilities[isEmergencyFees]', isEmergencyFees.toString()),
      ]);

      // Add dates
      for (int i = 0; i < dates.length; i++) {
        formData.fields.add(
          MapEntry('availabilities[dates][$i]', dates[i]),
        );
      }

      // Add slots for each time period
      slots.forEach((period, timeSlots) {
        for (int i = 0; i < timeSlots.length; i++) {
          formData.fields.add(
            MapEntry('availabilities[slots][$period][$i]', timeSlots[i]),
          );
        }
      });

      // Log total form data size for debugging

      final response = await _http.put(
        ApiConstants.updateProfile,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          // Increase timeout for large file uploads
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      return ApiResponse<String>.fromJson(response.data, null);
    } catch (e) {
      rethrow;
    }
  }

  /// Get doctors list with pagination and filters
  Future<ApiResponse<DoctorListResponse>> getDoctorsList({
    required int pageNumber,
    String? speciality,
    bool isEmergencyFees = false,
    String? search,
  }) async {
    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {};

      if (speciality != null && speciality.isNotEmpty) {
        queryParams['speciality'] = speciality;
      }

      queryParams['isEmergencyFees'] = isEmergencyFees.toString();

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _http.get(
        'appointments/all-doctors/$pageNumber',
        queryParameters: queryParams,
      );

      final doctorListResponse = DoctorListResponse.fromJson(response.data);

      return ApiResponse<DoctorListResponse>(
        data: doctorListResponse,
        message: doctorListResponse.message ?? 'Success',
        success: doctorListResponse.status,
      );
    } catch (e) {
      return ApiResponse<DoctorListResponse>(
        data: null,
        message: 'Failed to fetch doctors: ${e.toString()}',
        success: false,
      );
    }
  }

  /// Get doctor details by ID
  Future<ApiResponse<DoctorDetailsResponse>> getDoctorDetails({
    required int doctorId,
  }) async {
    try {
      final response = await _http.get(
        'appointments/doctorDetails/$doctorId',
      );

      final doctorDetailsResponse =
          DoctorDetailsResponse.fromJson(response.data);

      return ApiResponse<DoctorDetailsResponse>(
        data: doctorDetailsResponse,
        message: doctorDetailsResponse.message ?? 'Success',
        success: doctorDetailsResponse.status,
      );
    } catch (e) {
      return ApiResponse<DoctorDetailsResponse>(
        data: null,
        message: 'Failed to fetch doctor details: ${e.toString()}',
        success: false,
      );
    }
  }

  /// Get best health professionals
  Future<ApiResponse<List<Doctor>>> getBestHealthProfessionals() async {
    try {
      final response = await _http.get(
        'appointments/best-health-professionals',
      );

      if (response.data['status'] == true && response.data['data'] != null) {
        final List<Doctor> doctors = (response.data['data'] as List)
            .map((item) => Doctor.fromJson(item))
            .toList();

        return ApiResponse<List<Doctor>>(
          data: doctors,
          message: response.data['message'] ?? 'Success',
          success: response.data['status'],
        );
      } else {
        return ApiResponse<List<Doctor>>(
          data: [],
          message: response.data['message'] ?? 'No data found',
          success: false,
        );
      }
    } catch (e) {
      return ApiResponse<List<Doctor>>(
        data: [],
        message: 'Failed to fetch best health professionals: ${e.toString()}',
        success: false,
      );
    }
  }

  /// Get doctor availability for appointment booking
  Future<ApiResponse<DoctorAvailabilityData>> getDoctorAvailabilityDetails({
    required int doctorId,
    required String date,
  }) async {
    try {
      final response = await _http.get(
        '${ApiConstants.baseUrl}appointments/doctorAvailabilityDetails/$doctorId/$date',
      );

      if (response.data['status'] == true && response.data['data'] != null) {
        final availabilityData =
            DoctorAvailabilityData.fromJson(response.data['data']);
        return ApiResponse<DoctorAvailabilityData>(
          data: availabilityData,
          message: response.data['message'] ?? 'Success',
          success: true,
        );
      } else {
        return ApiResponse<DoctorAvailabilityData>(
          data: null,
          message: response.data['message'] ?? "No availability for this date",
          success: false,
        );
      }
    } catch (e) {
      return ApiResponse<DoctorAvailabilityData>(
        data: null,
        message: 'Failed to fetch doctor availability: ${e.toString()}',
        success: false,
      );
    }
  }

  /// Get doctor availability for a specific month
  Future<ApiResponse<DoctorAvailabilityData>> getDoctorAvailability({
    required int monthNumber,
  }) async {
    try {
      final response = await _http.get(
        '${ApiConstants.baseUrl}doctor-availibility/$monthNumber',
      );

      if (response.data['status'] == true && response.data['data'] != null) {
        final availabilityData =
            DoctorAvailabilityData.fromJson(response.data['data']);
        return ApiResponse<DoctorAvailabilityData>(
          data: availabilityData,
          message: response.data['message'] ?? 'Success',
          success: true,
        );
      } else {
        return ApiResponse<DoctorAvailabilityData>(
          data: null,
          message: response.data['message'] ?? "No Slots Available",
          success: false,
        );
      }
    } catch (e) {
      return ApiResponse<DoctorAvailabilityData>(
        data: null,
        message: 'Failed to fetch doctor availability: ${e.toString()}',
        success: false,
      );
    }
  }

  /// Set doctor availability
  Future<ApiResponse<String>> setAvailability({
    required int monthNumber,
    required String monthName,
    required List<String> dates,
    required Map<String, List<String>> slots,
    required bool isEmergencyFees,
    required String regularFees,
    required String emergencyFees,
  }) async {
    try {
      final response = await _http.post(
        '${ApiConstants.baseUrl}doctor-availibility/set-availibility',
        data: {
          'availabilities': {
            'month_number': monthNumber,
            'month_name': monthName,
            'dates': dates,
            'slots': slots,
            'isEmergencyFees': isEmergencyFees,
            'regular_fees': regularFees,
            'emergency_fees': emergencyFees,
          }
        },
      );

      if (response.data['status'] == true) {
        return ApiResponse<String>(
          data: null,
          message:
              response.data['message'] ?? 'Availability updated successfully',
          success: true,
        );
      } else {
        // Handle error response with validation errors
        String errorMessage = 'Failed to update availability';
        if (response.data['errors'] != null &&
            response.data['errors'] is List) {
          List<dynamic> errors = response.data['errors'];
          errorMessage = errors.join(', ');
        } else if (response.data['message'] != null) {
          errorMessage = response.data['message'];
        }

        return ApiResponse<String>(
          data: null,
          message: errorMessage,
          success: false,
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        data: null,
        message: 'Failed to set availability: ${e.toString()}',
        success: false,
      );
    }
  }

  /// Create appointment
  Future<ApiResponse<String>> createAppointment({
    required String doctorAvailabilitySlotId,
    required String date,
    required String consultationType,
    required String consultationFee,
    required List<String> primaryConcerns,
    required String medsPrescribed,
    required String name,
    required String bloodGroup,
    required List<Map<String, String>> questions,
    required List<String> medicationTreatment,
    required String duration,
    required String diagnosis,
    required String additionalInformation,
    required String gender,
    required String height,
    required String weight,
    required String age,
    required File? file,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'doctorAvailabilitySlotId': doctorAvailabilitySlotId,
        'date': date,
        'consultation_type': consultationType,
        'consultation_fee': consultationFee,
        'primary_concern': '[${primaryConcerns.map((e) => '"$e"').join(',')}]',
        'medsPrescribed': medsPrescribed,
        'name': name,
        'blood_group': bloodGroup,
        'questions':
            '[${questions.map((q) => '{"questions":"${q['questions']}","answer":"${q['answer']}"}').join(',')}]',
        'medication_treatment':
            '[${medicationTreatment.map((e) => '"$e"').join(',')}]',
        'duration': duration,
        'diagnosis': diagnosis,
        'additional_information': additionalInformation,
        'gender': gender,
        'height': height,
        'weight': weight,
        'age': age,
      });

      // Add files if provided
      if (file != null) {
        formData.files.addAll([
          MapEntry(
              'file',
              await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              )), // Add first file
        ]);
      }

      final response = await _http.post(
        'appointments/create',
        data: formData,
      );

      if (response.data['status'] == true) {
        return ApiResponse<String>(
          data: response.data['data']?.toString(),
          message:
              response.data['message'] ?? 'Appointment created successfully',
          success: true,
        );
      } else {
        return ApiResponse<String>(
          data: null,
          message: response.data['message'] ?? 'Failed to create appointment',
          success: false,
        );
      }
    } catch (e) {
      return ApiResponse<String>(
        data: null,
        message: 'Failed to create appointment: ${e.toString()}',
        success: false,
      );
    }
  }

  /// Get appointment listing with pagination, search and filtering
  Future<AppointmentListingResponse> getDoctorAppointmentListing({
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
        'appointments/doctor-appointment-listing/$page',
        queryParameters: queryParams,
      );

      return AppointmentListingResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get doctor appointment details by ID
  Future<DoctorAppointmentDetailsResponse> getDoctorAppointmentDetails(
      int appointmentId) async {
    try {
      final response = await _http
          .get('/appointments/doctor-appointment-details/$appointmentId');
      return DoctorAppointmentDetailsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get appointment statistics for doctors
  Future<AppointmentStatisticsResponse> getAppointmentStatistics({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _http.get(
        '/appointments/appointment-statistics',
        queryParameters: {
          'year': year.toString(),
          'month': month.toString(),
        },
      );
      return AppointmentStatisticsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get transaction data (earnings or withdrawals)
  Future<TransactionResponse> getTransactions({
    required String type, // 'Earning' or 'WithDrawal'
  }) async {
    try {
      final response = await _http.get(
        '/transactions/',
        queryParameters: {
          'type': type,
        },
      );
      return TransactionResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Submit withdrawal request
  Future<ApiResponse<String>> submitWithdrawal({
    required int bankId,
    required double amount,
  }) async {
    try {
      final response = await _http.post(
        ApiConstants.withdrawal,
        data: {
          'bank_id': bankId,
          'amount': amount,
        },
      );
      return ApiResponse<String>.fromJson(response.data, null);
    } catch (e) {
      rethrow;
    }
  }

  /// Get doctor profile details
  Future<DoctorProfileResponse> getDoctorProfile() async {
    try {
      final response = await _http.get('/doctor');
      final profileResponse = DoctorProfileResponse.fromJson(response.data);

      // Update SharedPreferences with the fetched data
      if (profileResponse.status && profileResponse.data != null) {
        await _updateSharedPrefsFromDoctorProfile(profileResponse.data!);
      }

      return profileResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Submit e-prescription and notes for an appointment
  Future<ApiResponse<String>> submitPrescription({
    required int appointmentId,
    String? prescriptionDate,
    String? drugStrengthFrequency,
    String? recommendedTests,
    String? notes,
    String? instructions,
    File? eSignature,
  }) async {
    try {
      print('📝 Submitting prescription for appointment: $appointmentId');
      
      FormData formData = FormData();
      
      // Add optional fields only if they have values
      if (prescriptionDate != null && prescriptionDate.isNotEmpty) {
        formData.fields.add(MapEntry('prescriptiondate', prescriptionDate));
      }
      
      if (drugStrengthFrequency != null && drugStrengthFrequency.isNotEmpty) {
        formData.fields.add(MapEntry('drugstrengthfrequency', drugStrengthFrequency));
      }
      
      if (recommendedTests != null && recommendedTests.isNotEmpty) {
        formData.fields.add(MapEntry('recommendedtests', recommendedTests));
      }
      
      if (notes != null && notes.isNotEmpty) {
        formData.fields.add(MapEntry('notes', notes));
      }
      
      if (instructions != null && instructions.isNotEmpty) {
        formData.fields.add(MapEntry('instructions', instructions));
      }
      
      // Add e-signature file if provided
      if (eSignature != null) {
        formData.files.add(
          MapEntry(
            'esignature',
            await MultipartFile.fromFile(
              eSignature.path,
              filename: 'signature.png',
            ),
          ),
        );
      }
      
      final response = await _http.put(
        'appointments/eprescription-appointment/$appointmentId',
        data: formData,
      );
      
      print('✅ Prescription submitted successfully');
      return ApiResponse<String>.fromJson(
        response.data,
        (data) => data.toString(),
      );
    } catch (e) {
      print('❌ Error submitting prescription: $e');
      rethrow;
    }
  }

  /// Update SharedPreferences with doctor profile data
  Future<void> _updateSharedPrefsFromDoctorProfile(
      DoctorProfileData profileData) async {
    try {
      // Update user info with doctor data
      final user = User(
        id: profileData.id,
        name: profileData.name,
        email: profileData.email,
        phone: profileData.phoneNumber,
        profilePicture: profileData.picture,
        role: Role.practitioner, // Assuming this is always a doctor
        isProfileComplete: profileData.isProfileComplete,
        age: '',
        gender: profileData.gender,
        speciality: profileData.speciality,
        licenseNumber: profileData.licenseNumber,
        aboutMe: profileData.aboutMe,
        totalExperience: profileData.totalExperience,
        averageRating: profileData.averageRating,
        emergencyFees: profileData.emergencyFees,
        regularFees: profileData.regularFees,
        isEmergencyFees: profileData.isEmergencyFees,
        certificate: profileData.certificate,
        isPending: profileData.isPending,
      );
      await SharedPrefsService.setUserInfo(jsonEncode(user.toJson()));
      await SharedPrefsService.setProfileApprovalStatus(profileData.isPending?.name ?? '');
    } catch (e) {
      // Log error but don't throw to prevent breaking the main flow
      print('Error updating SharedPrefs from doctor profile: $e');
    }
  }
}
