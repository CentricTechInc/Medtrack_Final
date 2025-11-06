import '../http_client.dart';
import '../constants/api_constants.dart';
import '../models/api_response.dart';
import '../models/notification_response.dart';

/// Notification Service - Singleton
/// Handles notification-related API calls
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final HttpClient _http = HttpClient();

  /// Get notifications with pagination
  Future<ApiResponse<NotificationResponse>> getNotifications({
    required int pageNumber,
  }) async {
    try {
      final response = await _http.get(
        'notifications/$pageNumber',
      );

      final notificationResponse = NotificationResponse.fromJson(response.data);
      
      return ApiResponse<NotificationResponse>(
        data: notificationResponse,
        message: notificationResponse.message ?? 'Success',
        success: notificationResponse.status,
      );
    } catch (e) {
      return ApiResponse<NotificationResponse>(
        data: null,
        message: 'Failed to fetch notifications: ${e.toString()}',
        success: false,
      );
    }
  }

  /// Mark all notifications as read
  Future<ApiResponse<void>> markAllAsRead() async {
    try {
      final response = await _http.get(
        '/notifications/markAllRead',
      );

      return ApiResponse<void>(
        data: null,
        message: response.data['message'] ?? 'All notifications marked as read',
        success: response.data['status'] ?? true,
      );
    } catch (e) {
      return ApiResponse<void>(
        data: null,
        message: 'Failed to mark all notifications as read: ${e.toString()}',
        success: false,
      );
    }
  }
}

/// Ticket Service - Singleton
/// Handles support ticket API calls
class TicketService {
  static final TicketService _instance = TicketService._internal();
  factory TicketService() => _instance;
  TicketService._internal();

  final HttpClient _http = HttpClient();

  /// Create support ticket
  Future<ApiResponse<dynamic>> createTicket({
    required String subject,
    required String description,
    String? priority,
  }) async {
    try {
      final response = await _http.post(
        ApiConstants.createTicket,
        data: {
          'subject': subject,
          'description': description,
          if (priority != null) 'priority': priority,
        },
      );

      return ApiResponse<dynamic>.fromJson(response.data, null);
    } catch (e) {
      rethrow;
    }
  }
}
