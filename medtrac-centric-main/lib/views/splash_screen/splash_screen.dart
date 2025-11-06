import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:get/get.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:medtrac/services/app_procedures.dart';
import 'package:medtrac/services/state_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _navigationTimer;

  // Adjust this duration based on your GIF length
  static const Duration _splashDuration = Duration(seconds: 11);

  @override
  void initState() {
    super.initState();

    // Initialize fresh app state
    if (SharedPrefsService.isLoggedIn()) {
      StateManager.initializeLoginState();
    }

    // Start navigation timer for GIF duration
    _navigationTimer = Timer(_splashDuration, () {
      if (mounted) {
        _initializeApp();
      }
    });
  }

  /// Initialize app with startup procedures
  Future<void> _initializeApp() async {
    try {
      // Execute startup procedures (banners, health professionals)
      if (SharedPrefsService.isLoggedIn()) {
        await AppProcedures.executeStartupProcedures();

        if (!HelperFunctions.isUser()) {
          // Fetch doctor profile if user is a doctor and logged in
          await _fetchDoctorProfileIfNeeded();
        } else {
          // Fetch patient profile if user is a patient and logged in
          await _fetchPatientProfileIfNeeded();
        }
      }

      _checkAuthAndNavigate();
    } catch (e) {
      log('App initialization error: $e');
      _checkAuthAndNavigate();
    }
  }

  /// Check authentication status and navigate accordingly
  void _checkAuthAndNavigate() async {
    try {
      // Check if user is authenticated (has valid token and user data)
      final isAuthenticated = SharedPrefsService.isUserAuthenticated();
      final isUser = HelperFunctions.isUser();
      final isProfileComplete = SharedPrefsService.isUserProfileComplete();
      final isFirstLogin = SharedPrefsService.isFirstLogin();

      if (isAuthenticated) {
        await AppProcedures.executePostLoginProcedures();
        // if (isUser) {
        //   if (isFirstLogin) {
        //     Get.offAllNamed(AppRoutes.tourGuideScreen);
        //   } else if (!isProfileComplete) {
        //     Get.offAllNamed(AppRoutes.basicInfoScreen);
        //   } else {
        //     Get.offAllNamed(AppRoutes.mainScreen);
        //   }
        // } else {
          Get.offAllNamed(AppRoutes.mainScreen);
        // }
      } else {
        // User not logged in, go to onboarding
        log('User not authenticated, navigating to onboarding');
        Get.offAllNamed(AppRoutes.onBoardingScreen);
      }
    } catch (e) {
      // If error occurs, default to onboarding
      log('Auth check error: $e');
      Get.offAllNamed(AppRoutes.onBoardingScreen);
    }
  }

  Future<void> _fetchPatientProfileIfNeeded() async {
    try {
      if (SharedPrefsService.isLoggedIn() && HelperFunctions.isUser()) {
        final patientService = PatientService();
        await patientService.getPatientProfile();
      }
    } catch (e) {
      log('Failed to fetch patient profile: $e');
    }
  }

  /// Fetch doctor profile if user is a doctor and logged in
  Future<void> _fetchDoctorProfileIfNeeded() async {
    try {
      if (SharedPrefsService.isLoggedIn() && !HelperFunctions.isUser()) {
        final doctorService = DoctorService();
        await doctorService.getDoctorProfile();
      }
    } catch (e) {
      log('Failed to fetch doctor profile: $e');
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: _hasError
          ? _buildFallbackUI()
          : Stack(
              fit: StackFit.expand,
              children: [
                // GIF Background
                Image.asset(
                  Assets.splashGif,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // If GIF fails to load, show fallback UI
                    debugPrint("GIF Error: $error");
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _hasError = true;
                          _errorMessage = error.toString();
                          log(_errorMessage);
                        });
                      }
                    });
                    return Container(color: AppColors.primary);
                  },
                ),
                // Optional: Add a loading indicator while GIF loads
                // You can remove this if you don't want a loading indicator
                // Positioned(
                //   bottom: 50,
                //   left: 0,
                //   right: 0,
                //   child: Center(
                //     child: CircularProgressIndicator(
                //       color: AppColors.bright,
                //     ),
                //   ),
                // ),
              ],
            ),
    );
  }

  Widget _buildFallbackUI() {
    // Fallback to static splash screen if video fails
    return Stack(
      children: [
        // Background diagonal shapes
        Positioned.fill(
          child: CustomPaint(
            painter: DiagonalBackgroundPainter(),
          ),
        ),
        // Center logo
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                Assets.logo,
                width: 120,
              ),
              const SizedBox(height: 20),
              Text(
                "Loading...",
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DiagonalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = AppColors.primary;

    final pathTop = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height * 0.35)
      ..close();

    final pathBottom = Path()
      ..moveTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height * 0.65)
      ..close();

    canvas.drawPath(pathTop, paint);
    canvas.drawPath(pathBottom, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
