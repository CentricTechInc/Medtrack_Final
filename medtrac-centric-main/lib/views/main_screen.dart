import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/balance_statistics_controller.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';
import 'package:medtrac/controllers/drawer_controller.dart';
import 'package:medtrac/controllers/home_controller.dart';
import 'package:medtrac/controllers/chat_inbox_controller.dart';
import 'package:medtrac/custom_widgets/bottom_navigation_bar.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:medtrac/views/Home/home_screen.dart';
import 'package:medtrac/views/appointments/appointments_tab.dart';
import 'package:medtrac/views/appointments/consultant_tab_view.dart';
import 'package:medtrac/views/chat/chat_inbox_screen.dart';
import 'package:medtrac/views/earnings/balance_statistics_screen.dart';
import 'package:medtrac/wrapper/drawer_wrapper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final BottomNavigationController _bottomNavController =
      Get.find<BottomNavigationController>();

  final CustomDrawerController _drawerController = Get.find<CustomDrawerController>();

  @override
  void initState() {
    super.initState();
    
    // Listen to bottom navigation changes
    _bottomNavController.selectedNavIndex.listen((index) {
      // Check if navigating to home tab (index 0)
      if (index == 0) {
        // Refresh upcoming appointments when navigating to home
        try {
          final homeController = Get.find<HomeController>();
          homeController.loadUpcomingAppointments();
        } catch (e) {
          // Controller might not be initialized yet, ignore
        }
      }
      
      // Check if navigating to balance statistics tab (index 2 for doctor)
      if (!HelperFunctions.isUser() && index == 2) {
        // Refresh balance statistics data when tab is selected
        try {
          final balanceController = Get.find<BalanceStatisticsController>();
          balanceController.refreshData();
        } catch (e) {
          // Controller might not be initialized yet, ignore
        }
      }
      
      // Check if navigating to chat tab (index 3)
      if (index == 3) {
        // Refresh conversations when navigating to chat tab
        try {
          final chatInboxController = Get.find<ChatInboxController>();
          print('💬 MainScreen: Chat tab activated - Refreshing conversations');
          chatInboxController.refreshConversationsOnTabSwitch();
        } catch (e) {
          // Controller might not be initialized yet, ignore
          print('⚠️ ChatInboxController not found: $e');
        }
      }
    });
    // Show incomplete profile sheet if needed (separate from daily check-in)
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (SharedPrefsService.isFirstLogin() && !HelperFunctions.isUser() && HelperFunctions.isPractitionerUnderReview()) {
        HelperFunctions.showIncompleteProfileBottomSheet(
          isReview: true,
        );
      } else if (!SharedPrefsService.isProfileComplete() && HelperFunctions.isUser() &&
          Get.context != null) {
        HelperFunctions.showIncompleteProfileBottomSheet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawerWrapper(
      child: Scaffold(
        body: Obx(() {
          return SafeArea(
            child: IndexedStack(
              index: _bottomNavController.selectedNavIndex.value,
              children: [
                HomeScreen(),
                AppointmentsTab(),
              if (HelperFunctions.isUser())
                ConsultantTabView()
              else
                BalanceStatsScreen(),
                ChatInboxScreen(),
              ],
            ),
          );
        }),
        bottomNavigationBar: Obx(() { return _drawerController.isDrawerOpen.value ? SizedBox() : BottomNavigation(controller: _bottomNavController);
        })),
    );
  }
}
