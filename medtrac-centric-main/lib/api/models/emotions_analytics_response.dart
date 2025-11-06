class EmotionsAnalyticsResponse {
  final List<SleepAnalytics> sleep;
  final List<MoodAnalytics> mood;
  final List<StressAnalytics> stress;

  EmotionsAnalyticsResponse({
    required this.sleep,
    required this.mood,
    required this.stress,
  });

  factory EmotionsAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return EmotionsAnalyticsResponse(
      sleep: (data['sleep'] as List<dynamic>? ?? [])
          .map((e) => SleepAnalytics.fromJson(e))
          .toList(),
      mood: (data['mood'] as List<dynamic>? ?? [])
          .map((e) => MoodAnalytics.fromJson(e))
          .toList(),
      stress: (data['stress'] as List<dynamic>? ?? [])
          .map((e) => StressAnalytics.fromJson(e))
          .toList(),
    );
  }
}

class SleepAnalytics {
  final String dayName;
  final String sleepQuality; // e.g. "7-9 hrs"

  SleepAnalytics({required this.dayName, required this.sleepQuality});

  factory SleepAnalytics.fromJson(Map<String, dynamic> json) {
    return SleepAnalytics(
      dayName: json['day_name'] ?? '',
      sleepQuality: json['sleep_quality'] ?? '',
    );
  }

  // Returns the average of the range, or 0 if not parsable
  double get averageHours {
    final match = RegExp(r'(\d+)-(\d+)').firstMatch(sleepQuality);
    if (match != null) {
      final min = double.tryParse(match.group(1)!);
      final max = double.tryParse(match.group(2)!);
      if (min != null && max != null) {
        return (min + max) / 2.0;
      }
    }
    // Try to parse a single number
    final single = double.tryParse(sleepQuality.replaceAll(RegExp(r'[^\d.]'), ''));
    return single ?? 0.0;
  }
}

class MoodAnalytics {
  final String dayName;
  final String currentMood;

  MoodAnalytics({required this.dayName, required this.currentMood});

  factory MoodAnalytics.fromJson(Map<String, dynamic> json) {
    return MoodAnalytics(
      dayName: json['day_name'] ?? '',
      currentMood: json['current_mood'] ?? '',
    );
  }
}

class StressAnalytics {
  final String dayName;
  final int stressLevel;

  StressAnalytics({required this.dayName, required this.stressLevel});

  factory StressAnalytics.fromJson(Map<String, dynamic> json) {
    return StressAnalytics(
      dayName: json['day_name'] ?? '',
      stressLevel: json['stress_level'] ?? 0,
    );
  }
}
