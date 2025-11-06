import 'package:get/get.dart';
import 'package:medtrac/bindings/bindings.dart';
import 'package:medtrac/views/Home/home_screen.dart';
import 'package:medtrac/views/about_us/about_us_screen.dart';
import 'package:medtrac/views/account_info/account_info_screen.dart';
import 'package:medtrac/views/account_info/add_new_account_screen.dart';
import 'package:medtrac/views/account_info_user/user_account_info_screen.dart';
import 'package:medtrac/views/account_info_user/user_add_new_payment_method_screen.dart';
import 'package:medtrac/views/add_notes/add_notes_screen.dart';
import 'package:medtrac/views/appointments/appointment_booking_screen.dart';
import 'package:medtrac/views/appointments/appointment_booking_summary_screen.dart';
import 'package:medtrac/views/appointments/appointment_details_screen.dart';
import 'package:medtrac/views/appointments/appointments_tab.dart';
import 'package:medtrac/views/appointments/user/user_appointment_details_screen.dart';
import 'package:medtrac/views/auth_screens/change_password_screen.dart';
import 'package:medtrac/views/appointments/appointment_summary_screen.dart';
import 'package:medtrac/views/appointments/cancel_booking_screen.dart';
import 'package:medtrac/views/appointments/cancelled_booking_screen.dart';
import 'package:medtrac/views/auth_screens/reset_password_screen.dart';
import 'package:medtrac/views/doctor_details/doctor_details_screen.dart';
import 'package:medtrac/views/earnings/balance_statistics_screen.dart';
import 'package:medtrac/views/customer_support/customer_support_screen.dart';
import 'package:medtrac/views/health_articles/health_article_detailed_screen.dart';
import 'package:medtrac/views/my_purchases/user_my_purchases_screen.dart';
import 'package:medtrac/views/my_reviews/my_reviews_screen.dart';
import 'package:medtrac/views/notifications/notification_screen.dart';
import 'package:medtrac/views/chat/chat_screen.dart';
import 'package:medtrac/views/onboarding/basic_info_screen.dart';
import 'package:medtrac/views/onboarding/mental_health_goal_screen.dart';
import 'package:medtrac/views/onboarding/mind_mood_checkin_screen.dart';
import 'package:medtrac/views/onboarding/mood_selection_screen.dart';
import 'package:medtrac/views/onboarding/sleep_quality_screen.dart';
import 'package:medtrac/views/onboarding/stress_level_screen.dart';
import 'package:medtrac/views/onboarding/tour_guide_screen.dart';
import 'package:medtrac/views/patient_details/patient_details_screen.dart';
import 'package:medtrac/views/payment_method/payment_method_screen.dart';
import 'package:medtrac/views/prescription/prescription_screen.dart';
import 'package:medtrac/views/presonal_info/personal_info_screen.dart';
import 'package:medtrac/views/presonal_info/availability_screen.dart';
import 'package:medtrac/views/auth_screens/forgot_password_screen.dart';
import 'package:medtrac/views/auth_screens/login_screen.dart';
import 'package:medtrac/views/auth_screens/onboarding_screen.dart';
import 'package:medtrac/views/auth_screens/otp_verification_screen.dart';
import 'package:medtrac/views/auth_screens/role_selection_screen.dart';
import 'package:medtrac/views/auth_screens/signup_screen.dart';
import 'package:medtrac/views/auth_screens/signup_professional_details_screen.dart';
import 'package:medtrac/views/main_screen.dart';
import 'package:medtrac/views/presonal_info_user/user_profile_screen.dart';
import 'package:medtrac/views/privacy_policy/privacy_policy_screen.dart';
import 'package:medtrac/views/review_doctor/review_doctor_screen.dart';
import 'package:medtrac/views/splash_screen/splash_screen.dart';
import 'package:medtrac/views/video_call/video_call_screen.dart';
import 'package:medtrac/views/wellness_hub/wellness_hub_screen.dart';
import 'package:medtrac/views/video_player/video_player_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onBoardingScreen = '/onBoardingScreen';
  static const String roleSelectionScreen = '/roleSelectionScreen';
  static const String loginScreen = '/loginScreen';
  static const String signupScreen = '/signupScreen';
  static const String forgotPasswordScreen = '/forgotPasswordScreen';
  static const String otpVerification = '/otpVerificationScreen';
  static const String resetPassword = '/resetPasswordScreen';
  static const String resetPasswordScreen = '/resetPasswordScreen';
  static const String homeScreen = '/homeScreen';
  static const String mainScreen = '/mainScreen';
  static const String personalInfoScreen = '/personalInfoScreen';
  static const String professionalInfoScreen = '/professionalInfoScreen';
  static const String availabilityInfoScreen = '/availabilityInfoScreen';
  static const String accountInfoScreen = '/accountInfoScreen';
  static const String addNewAccountScreen = '/addNewAccountScreen';
  static const String appointmentScreen = '/appointmentsScreen';
  static const String appointmentDetailsScreen = '/appointmentsDetailsScreen';
  static const String userAppointmentDetailsScreen ='/user-appointmentsDetailsScreen';
  static const String changePasswordScreen = '/changePasswordScreen';
  static const String aboutUsScreen = '/aboutUsScreen';
  static const String privacyPolicyScreen = '/privacyPolicyScreen';
  static const String notificationScreen = '/notificationScreen';
  static const String customerSupportScreen = "/customerSupportScreen";
  static const String balanceStatisticsScreen = "/balanceStatisticsScreen";
  static const String tourGuideScreen = "/tourGuideScreen";
  static const String professionalDetailsScreen =
      '/professional-details-screen';
  static const String cancelBookingScreen = '/cancel-booking-screen';
  static const String appointmentSummaryScreen = '/appointment-summary-screen';
  static const String cancelledBookingScreen = '/cancelled-booking-screen';
  static const String wellnessHubScreen = "/wellnessHubScreen";
  static const String chatScreen = '/chat-screen';
  static const String videoCallScreen = '/video-call-screen';
  static const String prescriptionScreen = '/prescription-screen';
  static const String addNotesScreen = '/add-notes-screen';
  static const String myReviewScreen = '/my_reviews_screen.dart';
  static const String healthArticcleDetailedScreen =
      '/health-article-detailed-screen';
  static const String basicInfoScreen = '/basic-info-screen';
  static const String mindMoodCheckinScreen = '/mind-mood-checkin-screen';
  static const String mentalHealthGoalSceen = '/mental-health-goal-screen';
  static const String sleepQualityScreen = '/sleep-quality-screen';
  static const String stressLevelScreen = '/stress-level-screen';
  static const String moodSelectionScreen = '/mood-selection-screen';
  static const String doctorDetailsScreen = '/doctor-details-screen';
  static const String appointmentBookingScreen = '/appointment-booking-screen';
  static const String patientDetailsScreen = '/pateint-details-screen';
  static const String paymentMethodScreen = '/payment-method-screen';
  static const String appointmentBookingSummaryScreen =
      '/appointment-booking-summary-screen';
  static const String reviewDoctorScreen = '/review-doctor-screen';
  static const String userProfileScreen = '/user-profile-screen';
  static const String userAccountInfoScreen = '/user-account-info-screen';
  static const String userAddNewPaymentMethodScreen = '/user-add-new-payment-method-screen';
  static const String userMyPurchasesScreen = '/user-my-purchases-screen';
  static const String videoPlayerScreen = '/video-player-screen';

  static final routes = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: onBoardingScreen,
      page: () => const OnBoardingScreen(),
    ),
    GetPage(
      name: roleSelectionScreen,
      page: () => const RoleSelectionScreen(),
    ),
    GetPage(
        name: loginScreen, page: () => LoginScreen(), binding: LoginBindings()),
    GetPage(
        name: signupScreen,
        page: () => SignupScreen(),
        binding: SignupBinding()),
    GetPage(
        name: professionalDetailsScreen,
        page: () => SignupProfessionalDetailsScreen()),
    GetPage(
        name: forgotPasswordScreen,
        page: () => ForgotPasswordScreen(),
        binding: LoginBindings()),
    GetPage(
        name: otpVerification,
        page: () => OtpVerificationScreen(),
        binding: LoginBindings()),
    GetPage(
        name: resetPasswordScreen,
        page: () => ResetPasswordScreen(),
        binding: ResetPasswordBinding()),
    GetPage(
        name: homeScreen,
        page: () => HomeScreen(),
        binding: BindingsBuilder(() {
          AppBarBinding().dependencies();
          HomeBinding().dependencies();
        })),
    GetPage(
      name: mainScreen,
      page: () => MainScreen(),
      binding: MainBinding(),
    ),
    GetPage(
      name: personalInfoScreen,
      page: () => PersonalInfoScreen(),
      binding: PersonalInfoBinding(),
    ),
    GetPage(
        name: availabilityInfoScreen,
        page: () => AvailabilityScreen(),
        binding: AvailabilityScreenBinding()),
    GetPage(
      name: accountInfoScreen,
      page: () => const AccountInfoScreen(),
      binding: AccountInfoBinding(),
    ),
    GetPage(
      name: addNewAccountScreen,
      page: () => const AddNewAccountScreen(),
      binding: AccountInfoBinding(),
    ),
    GetPage(
      name: appointmentDetailsScreen,
      page: () => const AppointmentDetailsScreen(),
      binding: AppointMentDetailsBinding(),
    ),
    GetPage(
      name: userAppointmentDetailsScreen,
      page: () => const UserAppointmentDetailsScreen(),
      binding: AppointMentDetailsBinding(),
    ),
    GetPage(
        name: changePasswordScreen,
        page: () => ChangePasswordScreen(),
        binding: ChangePasswordBinding()),
    GetPage(
      name: cancelBookingScreen,
      page: () => CancelBookingScreen(),
      binding: CancelBookingBinding(),
    ),
    GetPage(
      name: appointmentSummaryScreen,
      page: () => AppointmentSummaryScreen(),
      binding: AppointmentSummaryBinding(),
    ),
    GetPage(
      name: cancelledBookingScreen,
      page: () => const CancelledBookingScreen(),
      binding: CancelledBookingBinding(),
    ),
    GetPage(
        name: balanceStatisticsScreen,
        page: () => BalanceStatsScreen(),
        binding: BalanceStatisticsBinding()),
    GetPage(name: aboutUsScreen, page: () => AboutUsScreen()),
    GetPage(name: privacyPolicyScreen, page: () => PrivacyPolicyScreen()),
    GetPage(name: notificationScreen, page: () => NotificationScreen()),
    GetPage(
        name: AppRoutes.customerSupportScreen,
        page: () => CustomerSupportScreen(),
        binding: CustomerSupportBinding()),
    GetPage(
        name: AppRoutes.wellnessHubScreen,
        page: () => WellnessHubScreen(),
        binding: WellnessHubBinding()),
    GetPage(
      name: chatScreen,
      page: () => const ChatScreen(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: videoCallScreen,
      page: () => VideoCallScreen(),
      binding: VideoCallBinding(),
    ),
    GetPage(
      name: prescriptionScreen,
      page: () => const PrescriptionScreen(),
      binding: PrescriptionBinding(),
    ),
    GetPage(
      name: addNotesScreen,
      page: () => const AddNotesScreen(),
      binding: AddNotesBinding(),
    ),
    GetPage(
      name: myReviewScreen,
      page: () => const MyReviewsScreen(),
      binding: MyReviewBinding(),
    ),
    GetPage(
      name: appointmentScreen,
      page: () => AppointmentsTab(),
      binding: AppointmentsBinding(),
    ),
    GetPage(
      name: tourGuideScreen,
      page: () => TourGuideScreen(),
    ),
    GetPage(
      name: healthArticcleDetailedScreen,
      page: () => HealthArticleDetailedScreen(),
      binding: HealthArticleDetailsBinding(),
    ),
    GetPage(
      name: basicInfoScreen,
      page: () => BasicInfoScreen(),
      binding: BasicInfoBinding(),
    ),
    GetPage(
      name: mindMoodCheckinScreen,
      page: () => MindMoodCheckinScreen(),
    ),
    GetPage(
      name: mentalHealthGoalSceen,
      page: () => MentalHealthGoalScreen(),
    ),
    GetPage(
      name: sleepQualityScreen,
      page: () => SleepQualityScreen(),
    ),
    GetPage(
      name: stressLevelScreen,
      page: () => StressLevelScreen(),
    ),
    GetPage(
      name: moodSelectionScreen,
      page: () => MoodSelectionScreen(),
    ),
    GetPage(
      name: doctorDetailsScreen,
      page: () => DoctorDetailsScreen(),
      binding: DoctorDetailsBinding(),
    ),
    GetPage(
      name: appointmentBookingScreen,
      page: () => const AppointmentBookingScreen(),
      binding: AppointmentBookingBinding(),
    ),
    GetPage(
      name: patientDetailsScreen,
      page: () => const PatientDetailsScreen(),
      binding: PatientDetailsBinding(),
    ),
    GetPage(
      name: paymentMethodScreen,
      page: () => const PaymentMethodScreen(),
      binding: PaymentMethodBinding(),
    ),
    GetPage(
      name: appointmentBookingSummaryScreen,
      page: () => const AppointmentBookingSummaryScreen(),
      binding: AppointmentBookingSummaryBinding(),
    ),
    GetPage(
      name: reviewDoctorScreen,
      page: () => const ReviewDoctorScreen(),
      binding: ReviewDoctorBinding(),
    ),
    GetPage(
      name: userProfileScreen,
      page: () => const UserProfileScreen(),
      binding: UserProfileBinding(),
    ),
    GetPage(
      name: userAccountInfoScreen,
      page: () => const UserAccountInfoScreen(),
      binding: UserAccountInfoBinding(),
    ),
    GetPage(
      name: userAddNewPaymentMethodScreen,
      page: () => const UserAddNewPaymentMethodScreen(),
      binding: UserAddNewPaymentMethodBinding(),
    ),
    GetPage(
      name: userMyPurchasesScreen,
      page: () => const UserMyPurchasesScreen(),
      binding: UserMyPurchasesBinding(),
    ),
    GetPage(
      name: videoPlayerScreen,
      page: () => const VideoPlayerScreen(),
    ),
  ];
}
