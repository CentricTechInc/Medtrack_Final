class ApiConstants {
  // Base URL - Replace with your actual URL
  static const String baseUrl = 'https://medtrac-api.centrictech.net/api/';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/doctor-registration';
  static const String verifyOtp = '/auth/verify-otp/';
  static const String forgotPassword = '/auth/forgot-password';
  static const String updatePassword = '/auth/update-password';

  
  // Doctor endpoints
  static const String changePassword = '/doctor/change-password';
  static const String deleteDoctor = '/doctor';
  static const String updateProfile = '/doctor';
  
  // Review endpoints
  static const String reviewListing = '/reviews/listing';
  
  // Wellness Hub endpoints
  static const String wellnessListing = '/wellness-hub/listing';
  static const String wellnessDetails = '/wellness-hub/details';
  
  // Banner endpoints
  static const String banners = '/banner';
  
  // Ticket endpoints
  static const String createTicket = '/ticket/create';
  
  // Notifications endpoints
  static const String notifications = '/notifications';
  
  // Transactions endpoints
  static const String withdrawal = '/transactions/withdrawal';
  
  // Add more endpoints as you need them
  // static const String newEndpoint = '/new-endpoint';
}
