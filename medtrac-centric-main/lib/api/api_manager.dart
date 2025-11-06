import 'http_client.dart';
import 'services/auth_service.dart';
import 'services/wellness_service.dart';
import 'services/doctor_service.dart';
import 'services/review_service.dart';
import 'services/notification_service.dart';
import 'services/video_call_service.dart';

/// Simple API Manager
/// One place to access all your API services
class ApiManager {
  static final ApiManager _instance = ApiManager._internal();
  factory ApiManager() => _instance;
  ApiManager._internal();

  // Service instances
  static final AuthService auth = AuthService();
  static final WellnessService wellness = WellnessService();
  static final DoctorService doctor = DoctorService();
  static final ReviewService review = ReviewService();
  static final NotificationService notification = NotificationService();
  static final TicketService ticket = TicketService();
  static final VideoCallService videoCall = VideoCallService();

  /// Initialize the API client
  /// Call this once in your main.dart
  static void initialize() {
    HttpClient().initialize();
  }

  /// Easy access to services
  static AuthService get authService => auth;
  static WellnessService get wellnessService => wellness;
  static DoctorService get doctorService => doctor;
  static ReviewService get reviewService => review;
  static NotificationService get notificationService => notification;
  static TicketService get ticketService => ticket;
  static VideoCallService get videoCallService => videoCall;
}
