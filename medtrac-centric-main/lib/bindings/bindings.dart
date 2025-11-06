import 'package:get/get.dart';
import 'package:medtrac/controllers/account_info_controller.dart';
import 'package:medtrac/controllers/app_bar_contoller.dart';
import 'package:medtrac/controllers/add_notes_controller.dart';
import 'package:medtrac/controllers/appointment_booking_controller.dart';
import 'package:medtrac/controllers/appointment_booking_summary_controller.dart';
import 'package:medtrac/controllers/appointment_details_screen_controller.dart';
import 'package:medtrac/controllers/appointment_summary_controller.dart';
import 'package:medtrac/controllers/appointments_controller.dart';
import 'package:medtrac/controllers/auth_controllers/change_password_controller.dart';
import 'package:medtrac/controllers/auth_controllers/login_controller.dart';
import 'package:medtrac/controllers/auth_controllers/reset_password_controller.dart';
import 'package:medtrac/controllers/auth_controllers/signup_controller.dart';
import 'package:medtrac/controllers/balance_statistics_controller.dart';
import 'package:medtrac/controllers/basic_info_controller.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';
import 'package:medtrac/controllers/cancel_booking_controller.dart';
import 'package:medtrac/controllers/cancelled_booking_controller.dart';
import 'package:medtrac/controllers/consultant_tab_view_controller.dart';
import 'package:medtrac/controllers/customer_support_controller.dart';
import 'package:medtrac/services/incoming_call_service.dart';
import 'package:medtrac/services/pip_service.dart';
import 'package:medtrac/services/callkit_service.dart';
import 'package:medtrac/services/chat_service.dart';
import 'package:medtrac/controllers/doctor_details_controller.dart';
import 'package:medtrac/controllers/document_controller.dart';
import 'package:medtrac/controllers/drawer_controller.dart';
import 'package:medtrac/controllers/home_controller.dart';
import 'package:medtrac/controllers/reviews_controller.dart';
import 'package:medtrac/controllers/notification_controller.dart';
import 'package:medtrac/controllers/patient_details_controller.dart';
import 'package:medtrac/controllers/payment_method_controller.dart';
import 'package:medtrac/controllers/personal_info_controller.dart';
import 'package:medtrac/controllers/review_doctor_controller.dart';
import 'package:medtrac/controllers/user/user_account_info_controller.dart';
import 'package:medtrac/controllers/user/user_add_new_payment_method_controller.dart';
import 'package:medtrac/controllers/user/user_my_purchases_controller.dart';
import 'package:medtrac/controllers/user/user_profile_controller.dart';
import 'package:medtrac/controllers/wellness_hub_controller.dart';
import 'package:medtrac/controllers/chat_controller.dart';
import 'package:medtrac/controllers/chat_inbox_controller.dart';
import 'package:medtrac/controllers/prescription_controller.dart';
import 'package:medtrac/controllers/video_call_controller.dart';
import 'package:medtrac/services/agora_service.dart';

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}

class SignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignupController>(() => SignupController());
  }
}

class ResetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ResetPasswordController>(() => ResetPasswordController());
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Only create AppBarController here
    Get.lazyPut<AppBarContoller>(() => AppBarContoller());
  }
}

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Use put with permanent flag to survive hot reloads
    Get.put<BottomNavigationController>(
      BottomNavigationController(),
      permanent: true,
    );

    Get.put<HomeController>(
      HomeController(),
    );

    Get.put<AppointmentsController>(
      AppointmentsController(),
      permanent: true,
    );

    // Initialize ChatService BEFORE ChatInboxController (since it depends on it)
    Get.put<ChatService>(
      ChatService(),
      permanent: true,
    );

    Get.put<ChatInboxController>(
      ChatInboxController(),
      permanent: true,
    );

    Get.put<AppBarContoller>(
      AppBarContoller(),
      permanent: true,
    );

    Get.put<BalanceStatisticsController>(
      BalanceStatisticsController(),
      permanent: true,
    );

    // Get.put<AccountInfoController>(
    //   AccountInfoController(),
    //   permanent: false,
    // );

    Get.put<CustomDrawerController>(
      CustomDrawerController(),
      permanent: true,
    );

    Get.put<DocumentController>(
      DocumentController(),
      permanent: true,
    );

    Get.put<WellnessHubController>(
      WellnessHubController(),
      permanent: true,
    );

    Get.put<ConsultantTabViewController>(
      ConsultantTabViewController(),
      permanent: true,
    );
    
    // Initialize AgoraService for video calling
    Get.put<AgoraService>(
      AgoraService(),
      permanent: true,
    );
    
    // Initialize PipService for picture-in-picture functionality
    Get.put<PipService>(
      PipService(),
      permanent: true,
    );
    
    // Initialize IncomingCallService for handling incoming calls
    Get.put<IncomingCallService>(
      IncomingCallService(),
      permanent: true,
    );
    
    // Initialize CallKit service for native call UI
    Get.put<CallKitService>(
      CallKitService(),
      permanent: true,
    );
    
  }
}

class PersonalInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PersonalInfoController());
  }
}

class AccountInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AccountInfoController());
  }
}

class AppointMentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppointmentDetailsController());
  }
}

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChangePasswordController());
  }
}

class CancelBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CancelBookingController());
  }
}

class AppointmentSummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppointmentSummaryController());
  }
}

class CancelledBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CancelledBookingController());
  }
}

class BalanceStatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BalanceStatisticsController());
  }
}

class WellnessHubBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WellnessHubController());
  }
}

class CustomerSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CustomerSupportController());
  }
}

class AvailabilityScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PersonalInfoController());
  }
}

class AppBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppBarContoller());
  }
}

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatController());
  }
}

class VideoCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VideoCallController());
  }
}

class PrescriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PrescriptionController());
  }
}

class AddNotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AddNotesController());
  }
}

class MyReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReviewsController());
  }
}

class AppointmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppointmentsController());
  }
}

class HealthArticleDetailsBinding extends Bindings {
  @override
  void dependencies() {}
}

class BasicInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BasicInfoController());
  }
}

class NotfificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationController());
  }
}

class AvailabilityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PersonalInfoController());
  }
}

class DoctorDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DoctorDetailsController());
  }
}

class AppointmentBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppointmentBookingController());
  }
}

class PatientDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PatientDetailsController());
  }
}

class PaymentMethodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PaymentMethodController());
  }
}

class AppointmentBookingSummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppointmentBookingSummaryController());
  }
}

class ReviewDoctorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReviewDoctorController());
  }
}

class UserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserProfileController());
  }
}

class UserAccountInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserAccountInfoController());
  }
}

class UserAddNewPaymentMethodBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserAddNewPaymentMethodController());
  }
}

class UserMyPurchasesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserMyPurchasesController());
  }
}
