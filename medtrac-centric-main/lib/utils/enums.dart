import 'package:flutter/material.dart';
import 'package:medtrac/utils/app_colors.dart';

enum MoodType {
  good,
  moderate,
  poor,
}

extension MoodTypeExtension on MoodType {
  String get name {
    switch (this) {
      case MoodType.good:
        return 'Good';
      case MoodType.moderate:
        return 'Moderate';
      case MoodType.poor:
        return 'Poor';
    }
  }

  Color get color {
    switch (this) {
      case MoodType.good:
        return AppColors.green;
      case MoodType.moderate:
        return AppColors.yellow;
      case MoodType.poor:
        return AppColors.error;
    }
  }

  static MoodType fromString(String mood) {
    if (mood.toLowerCase().contains('excellent') || mood.toLowerCase().contains('great') || mood.toLowerCase().contains('amazing') || mood.toLowerCase().contains('good') || mood.toLowerCase().contains('fine') || mood.toLowerCase().contains('well')) {
      return MoodType.good;
    } else if (mood.toLowerCase().contains('moderate') || mood.toLowerCase().contains('neutral') || mood.toLowerCase().contains('okay')) {
      return MoodType.moderate;
    } else if (mood.toLowerCase().contains('poor') || mood.toLowerCase().contains('bad') || mood.toLowerCase().contains('terrible') || mood.toLowerCase().contains('awful')) {
      return MoodType.poor;
    } else {
      return MoodType.moderate; // default
    }
  }
}


enum SleepQuality {
  excellent, // 1
  good,      // 2
  fair,      // 3
  poor,      // 4
  worst,     // 5
}

extension SleepQualityExtension on SleepQuality {
  String get name {
    switch (this) {
      case SleepQuality.excellent:
        return 'Excellent';
      case SleepQuality.good:
        return 'Good';
      case SleepQuality.fair:
        return 'Fair';
      case SleepQuality.poor:
        return 'Poor';
      case SleepQuality.worst:
        return 'Worst';
    }
  }

  int get index {
    switch (this) {
      case SleepQuality.excellent:
        return 1;
      case SleepQuality.good:
        return 2;
      case SleepQuality.fair:
        return 3;
      case SleepQuality.poor:
        return 4;
      case SleepQuality.worst:
        return 5;
    }
  }

  Color get color {
    switch (this) {
      case SleepQuality.excellent:
      case SleepQuality.good:
        return AppColors.green;
      case SleepQuality.fair:
        return AppColors.yellow;
      case SleepQuality.poor:
      case SleepQuality.worst:
        return AppColors.error;
    }
  }

  static SleepQuality fromString(String value) {
    switch (value.toLowerCase()) {
      case 'excellent':
        return SleepQuality.excellent;
      case 'good':
        return SleepQuality.good;
      case 'fair':
        return SleepQuality.fair;
      case 'poor':
        return SleepQuality.poor;
      case 'worst':
        return SleepQuality.worst;
      default:
        return SleepQuality.good; // Default fallback
    }
  }
}

enum StressLevel {
  veryLow,  // 1
  low,      // 2
  moderate, // 3
  high,     // 4
  veryHigh, // 5
}

extension StressLevelExtension on StressLevel {
  String get name {
    switch (this) {
      case StressLevel.veryLow:
        return 'Very Low';
      case StressLevel.low:
        return 'Low';
      case StressLevel.moderate:
        return 'Moderate';
      case StressLevel.high:
        return 'High';
      case StressLevel.veryHigh:
        return 'Very High';
    }
  }

  int get index {
    switch (this) {
      case StressLevel.veryLow:
        return 1;
      case StressLevel.low:
        return 2;
      case StressLevel.moderate:
        return 3;
      case StressLevel.high:
        return 4;
      case StressLevel.veryHigh:
        return 5;
    }
  }

  Color get color {
    switch (this) {
      case StressLevel.veryLow:
      case StressLevel.low:
        return AppColors.green;
      case StressLevel.moderate:
        return AppColors.yellow;
      case StressLevel.high:
      case StressLevel.veryHigh:
        return AppColors.error;
    }
  }

  static StressLevel fromInt(int value) {
    switch (value) {
      case 1:
        return StressLevel.veryLow;
      case 2:
        return StressLevel.low;
      case 3:
        return StressLevel.moderate;
      case 4:
        return StressLevel.high;
      case 5:
        return StressLevel.veryHigh;
      default:
        return StressLevel.moderate; // Default fallback
    }
  }
}

enum Role{
  user,
  practitioner,
}

extension RoleExtension on Role{
  String get name {
    switch (this) {
      case Role.user:
        return 'User';
      case Role.practitioner:
        return 'Practitioner';
    }
  }
}

enum ProfileApprovalStatus {
  approved,
  newRequest,
  denied,
}

extension ProfileApprovalStatusExtension on ProfileApprovalStatus {
  String get name {
    switch (this) {
      case ProfileApprovalStatus.approved:
        return 'Approve';
      case ProfileApprovalStatus.newRequest:
        return 'New Request';
      case ProfileApprovalStatus.denied:
        return 'Denied';
    }
  }

  static ProfileApprovalStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'approve':
        return ProfileApprovalStatus.approved;
      case 'new request':
        return ProfileApprovalStatus.newRequest;
      case 'denied':
        return ProfileApprovalStatus.denied;
      default:
        return ProfileApprovalStatus.newRequest; // Default fallback
    }
  }
}