import 'dart:convert';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:medtrac/api/models/user.dart';
import 'package:medtrac/api/models/user_medical_history.dart';
import 'package:medtrac/utils/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  // Key prefix for daily check-in date (will be combined with user ID)
  static const String _keyLastDailyCheckinDatePrefix = 'last_daily_checkin_date_';

  /// Get the user-specific key for daily check-in
  static String _getDailyCheckinKey() {
    try {
      final user = getUserInfo;
      return '$_keyLastDailyCheckinDatePrefix${user.id}';
    } catch (e) {
      // If user info is not available, fall back to a default key
      return '${_keyLastDailyCheckinDatePrefix}default';
    }
  }

  /// Set the last daily check-in date to today (yyyy-MM-dd) for current user
  static Future<bool> setLastDailyCheckinDateToToday() async {
    if (_prefs == null) {
      await init();
    }
    final today = DateTime.now();
    final todayStr = "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final key = _getDailyCheckinKey();
    return await _prefs!.setString(key, todayStr);
  }

  /// Returns true if the last daily check-in was done today (calendar day, not 24h) for current user
  static bool isDailyCheckinDoneToday() {
    if (_prefs == null) {
      return false;
    }
    final key = _getDailyCheckinKey();
    final lastDate = _prefs!.getString(key) ?? '';
    if (lastDate.isEmpty) return false;
    final today = DateTime.now();
    final todayStr = "${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    return lastDate == todayStr;
  }
  static SharedPrefsService? _instance;
  static SharedPreferences? _prefs;

  // Private constructor
  SharedPrefsService._();

  // Singleton getter
  static SharedPrefsService get instance {
    _instance ??= SharedPrefsService._();
    return _instance!;
  }

  // 🚀 Call this once in main() before using any method
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 🔑 Centralized keys
  static const String role = 'role';
  static const String specialty = 'specialty';
  static const String licenseNumber = 'licenseNumber';
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userInfo = 'user_info';
  static const String userMedicalHistory = 'user_medical_history';
  static const String keyIsFirstLogin = 'is_first_login';
  static const String keyIsProfileComplete = 'is_profile_complete';
  static const String keyIsProfileApproved = 'is_profile_approved';

  // ✅ Generic Setters
  static Future<bool> setString(String key, String value) async =>
      await _prefs?.setString(key, value) ?? false;

  static Future<bool> setInt(String key, int value) async =>
      await _prefs?.setInt(key, value) ?? false;

  static Future<bool> setDouble(String key, double value) async =>
      await _prefs?.setDouble(key, value) ?? false;

  static Future<bool> setBool(String key, bool value) async =>
      await _prefs?.setBool(key, value) ?? false;

  // ✅ Generic Getters with Fallbacks
  static String getString(String key, {String defaultValue = ''}) =>
      _prefs?.getString(key) ?? defaultValue;

  static int getInt(String key, {int defaultValue = 0}) =>
      _prefs?.getInt(key) ?? defaultValue;

  static double getDouble(String key, {double defaultValue = 0.0}) =>
      _prefs?.getDouble(key) ?? defaultValue;

  static bool getBool(String key, {bool defaultValue = false}) =>
      _prefs?.getBool(key) ?? defaultValue;

  // ✅ Remove specific key
  static Future<bool> remove(String key) async =>
      await _prefs?.remove(key) ?? false;

  // ✅ Clear all prefs
  static Future<bool> clearAll() async => await _prefs?.clear() ?? false;

  // ✅ Key existence check
  static bool containsKey(String key) => _prefs?.containsKey(key) ?? false;

  // ✅ Convenience methods
  static String getRole() => getString(role);

  static Future<bool> setRole(String roleValue) async =>
      await setString(role, roleValue);

  // ✅ Token management
  static String getAccessToken() => getString(accessToken);
  static Future<bool> setAccessToken(String token) async =>
      await setString(accessToken, token);

  static String getRefreshToken() => getString(refreshToken);
  static Future<bool> setRefreshToken(String token) async =>
      await setString(refreshToken, token);

  // ✅ User info management
  static User get getUserInfo {
    try {
      final userInfoJson = getString(userInfo);
      
      // Check if JSON string is empty or null
      if (userInfoJson.isEmpty || userInfoJson.trim().isEmpty) {
        print('⚠️ User info is empty, returning default user');
        return _getDefaultUser();
      }
      
      // Try to decode JSON
      try {
        final decodedJson = jsonDecode(userInfoJson);
        if (decodedJson is Map<String, dynamic>) {
          return User.fromJson(decodedJson);
        } else {
          print('⚠️ User info is not a valid JSON object, returning default user');
          return _getDefaultUser();
        }
      } catch (e) {
        print('❌ Error decoding user info JSON: $e');
        print('❌ JSON string: $userInfoJson');
        return _getDefaultUser();
      }
    } catch (e) {
      print('❌ Error getting user info: $e');
      return _getDefaultUser();
    }
  }
  
  /// Get default user object when user info is not available
  static User _getDefaultUser() {
    return User(
      id: 0,
      name: '',
      email: '',
      phone: '',
      profilePicture: '',
      role: Role.user,
      isProfileComplete: false,
      age: '',
      gender: '',
    );
  }
  
  static Future<bool> setUserInfo(String userJson) async => await setString(userInfo, userJson);

  // ✅ User medical history management
  static UserMedicalHistory get getUserMedicalHistory {
    final historyJson = getString(userMedicalHistory);
    if (historyJson.isEmpty) {
      return UserMedicalHistory(
        bloodGroup: '',
        weight: '',
        primaryConcerns: [],
        medications: [],
      );
    }
    return UserMedicalHistory.fromJson(jsonDecode(historyJson));
  }
  
  static Future<bool> setUserMedicalHistory(UserMedicalHistory history) async {
    return await setString(userMedicalHistory, jsonEncode(history.toJson()));
  }

  // ✅ Check if user is logged in
  static bool isLoggedIn() {
    return getString(accessToken).isNotEmpty;
  }

  // ✅ Enhanced login state check with user validation
  static bool isUserAuthenticated() {
    final token = getString(accessToken);
    final user = getUserInfo;
    return token.isNotEmpty && user.id != 0;
  }
  
  // ✅ Clear auth data
  static Future<bool> clearAuthData() async {
    final results = await Future.wait([
      remove(accessToken),
      remove(refreshToken),
      remove(userInfo),
    ]);
    return results.every((success) => success);
  }


  static Future<bool> setProfileComplete(bool isComplete) async {
    if (_prefs == null) {
      await init();
    }
    return await _prefs!.setBool(keyIsProfileComplete, isComplete);
  }


  static bool isProfileComplete() {
    if (HelperFunctions.isUser()) {
      return true;
    }
    if (_prefs == null) {
      return false;
    }
    
    // For doctors, check if profile is approved
    final user = getUserInfo;
    final isProfileApprovedV = isProfileApproved();
    if (user.role == Role.practitioner) {
      return isProfileApprovedV;
    }
    
    return user.isProfileComplete || (_prefs!.getBool(keyIsProfileComplete) ?? false);
  }

  static bool isDoctorProfileCompelete() {
    if (_prefs == null) {
      return false;
    }

    // For doctors, check if profile is approved
    final user = getUserInfo;

    return user.isProfileComplete ||
        (_prefs!.getBool(keyIsProfileComplete) ?? false);
  }

  static bool isUserProfileComplete() {
    if (_prefs == null) {
      return false;
    }
    
    return getUserInfo.isProfileComplete || (_prefs!.getBool(keyIsProfileComplete) ?? false);
  }

  // ✅ First login management
  static Future<bool> setFirstLogin(bool isFirstLogin) async {
    if (_prefs == null) {
      await init();
    }
    return await _prefs!.setBool(keyIsFirstLogin, isFirstLogin);
  }

  static bool isFirstLogin() {
    if (_prefs == null) {
      return true; // Default to true if prefs not initialized
    }
    return _prefs!.getBool(keyIsFirstLogin) ?? true; // Default to true for first-time users
  }

  // ✅ Mark first login as complete
  static Future<bool> markFirstLoginComplete() async {
    return await setFirstLogin(false);
  }

  // ✅ Profile approval status management (for doctors)
  static Future<bool> setProfileApprovalStatus(String status) async {
    if (_prefs == null) {
      await init();
    }
    return await _prefs!.setString(keyIsProfileApproved, status);
  }

  static String getProfileApprovalStatus() {
    if (_prefs == null) {
      return '';
    }
    return _prefs!.getString(keyIsProfileApproved) ?? '';
  }

  static bool isProfileApproved() {
    final status = getProfileApprovalStatus();
    return status.toLowerCase() == 'approve';
  }
}
