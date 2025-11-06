
import 'package:intl/intl.dart';

class WellnessHubResponse {
  final bool status;
  final String? message;
  final WellnessHubData? data;
  final List<String>? errors;

  WellnessHubResponse({
    required this.status,
    this.message,
    this.data,
    this.errors,
  });

  factory WellnessHubResponse.fromJson(Map<String, dynamic> json) {
    return WellnessHubResponse(
      status: json['status'] ?? false,
      message: json['message'],
      data: json['data'] != null ? WellnessHubData.fromJson(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class WellnessHubData {
  final int count;
  final List<WellnessHubItem> rows;

  WellnessHubData({
    required this.count,
    required this.rows,
  });

  factory WellnessHubData.fromJson(Map<String, dynamic> json) {
    return WellnessHubData(
      count: json['count'] ?? 0,
      rows: json['rows'] != null
          ? (json['rows'] as List)
              .map((item) => WellnessHubItem.fromJson(item))
              .toList()
          : [],
    );
  }
}

class WellnessHubItem {
  final int id;
  final String assets;
  final String title;
  final String duration;
  final String type;
  final String description;
  final String createdAt;
  final String updatedAt;

  WellnessHubItem({
    required this.id,
    required this.assets,
    required this.title,
    required this.duration,
    required this.type,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WellnessHubItem.fromJson(Map<String, dynamic> json) {
    return WellnessHubItem(
      id: json['id'] ?? 0,
      assets: json['assets'] ?? '',
      title: json['title'] ?? '',
      duration: json['duration'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateFormat('dd MMM yyyy').format(DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now()),
      updatedAt: DateFormat('dd MMM yyyy').format(DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now()),
    );
  }
}