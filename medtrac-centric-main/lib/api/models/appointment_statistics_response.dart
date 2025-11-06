class AppointmentStatisticsResponse {
  final bool status;
  final String message;
  final AppointmentStatisticsData? data;

  AppointmentStatisticsResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory AppointmentStatisticsResponse.fromJson(Map<String, dynamic> json) {
    return AppointmentStatisticsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? AppointmentStatisticsData.fromJson(json['data'])
          : null,
    );
  }
}

class AppointmentStatisticsData {
  final int total;
  final int completed;
  final int canceled;
  final List<WeeklyStatistics> statistics;

  AppointmentStatisticsData({
    required this.total,
    required this.completed,
    required this.canceled,
    required this.statistics,
  });

  factory AppointmentStatisticsData.fromJson(Map<String, dynamic> json) {
    return AppointmentStatisticsData(
      total: json['total'] ?? 0,
      completed: json['completed'] ?? 0,
      canceled: json['canceled'] ?? 0,
      statistics: json['statistics'] != null
          ? (json['statistics'] as List)
              .map((item) => WeeklyStatistics.fromJson(item))
              .toList()
          : [],
    );
  }
}

class WeeklyStatistics {
  final Map<String, int> completedAppointments;
  final Map<String, int> canceledAppointments;

  WeeklyStatistics({
    required this.completedAppointments,
    required this.canceledAppointments,
  });

  factory WeeklyStatistics.fromJson(Map<String, dynamic> json) {
    return WeeklyStatistics(
      completedAppointments: Map<String, int>.from(
        json['completed_appointments'] ?? {}
      ),
      canceledAppointments: Map<String, int>.from(
        json['canceled_appointments'] ?? {}
      ),
    );
  }
}
