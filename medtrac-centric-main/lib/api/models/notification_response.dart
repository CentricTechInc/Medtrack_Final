import '../../../utils/assets.dart';


class NotificationResponse {
  final bool status;
  final String? message;
  final NotificationDataWrapper? data;
  final List<String>? errors;

  NotificationResponse({
    required this.status,
    this.message,
    this.data,
    this.errors,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      status: json['status'] ?? false,
      message: json['message'],
      data: json['data'] != null ? NotificationDataWrapper.fromJson(json['data']) : null,
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
    );
  }
}

class NotificationDataWrapper {
  final int unReadCount;
  final NotificationData? data;

  NotificationDataWrapper({
    required this.unReadCount,
    this.data,
  });

  factory NotificationDataWrapper.fromJson(Map<String, dynamic> json) {
    return NotificationDataWrapper(
      unReadCount: json['unReadCount'] ?? 0,
      data: json['data'] != null ? NotificationData.fromJson(json['data']) : null,
    );
  }
}

class NotificationData {
  final int count;
  final List<NotificationItem> rows;

  NotificationData({
    required this.count,
    required this.rows,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      count: json['count'] ?? 0,
      rows: json['rows'] != null
          ? (json['rows'] as List)
              .map((item) => NotificationItem.fromJson(item))
              .toList()
          : [],
    );
  }
}

class NotificationItem {
  final int id;
  final String subject;
  final String message;
  final String modelType;
  final int modelId;
  final int notifiedTo;
  final bool isRead;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.subject,
    required this.message,
    required this.modelType,
    required this.modelId,
    required this.notifiedTo,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      modelType: json['modelType'] ?? '',
      modelId: json['modelId'] ?? 0,
      notifiedTo: json['notifiedTo'] ?? 0,
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  // Helper method to get icon based on model type
  String get iconPath {
    switch (modelType.toLowerCase()) {
      case 'appointment':
        return Assets.appointmentSuccessIcon; // Use calendar icon for appointments
      case 'ticket':
        return Assets.ticketClosedIcon; // Use ticket icon for tickets
      default:
        return Assets.calanderIcon; // Default to calendar icon
    }
  }

  // Helper method to format time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  // Helper method to get date section
  String get dateSection {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
    
    if (notificationDate == today) {
      return 'TODAY';
    } else if (notificationDate == yesterday) {
      return 'YESTERDAY';
    } else {
      // Format as "DD MMM YYYY"
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
    }
  }
}
