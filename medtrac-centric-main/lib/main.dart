import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/api_manager.dart';
import 'package:medtrac/firebase_options.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/services/thumbnail_cache_service.dart';
import 'package:medtrac/services/notification_service.dart';
import 'package:medtrac/services/callkit_service.dart';
import 'package:medtrac/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPrefsService.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize CallKit service early (before notification service)
  Get.put<CallKitService>(CallKitService(), permanent: true);
  
  // Initialize notification service (handles all FCM messages including background)
  await NotificationService().initialize();
  
  ApiManager.initialize();
  
  Get.put(ThumbnailCacheService());
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Medtrac',
          debugShowCheckedModeBanner: false,
          defaultTransition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 300),
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.routes,
          theme: AppTheme.lightTheme,
        );
      },
    );
  }
}