import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/home_controller.dart';
import 'package:medtrac/custom_widgets/custom_appbar_with_icons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/views/Home/widgets/best_health_professionals_widget.dart.dart';
import 'package:medtrac/views/Home/widgets/health_articles_section.dart';
import 'package:medtrac/views/Home/widgets/recent_appointments_widget.dart';
import 'package:medtrac/views/Home/widgets/sleep_chart_widget.dart';
import 'package:medtrac/views/Home/widgets/statistics_widget.dart';
import 'package:medtrac/views/Home/widgets/upcoming_appointments_widget.dart';
import 'package:medtrac/views/Home/widgets/wellness_banner.dart';
import 'package:medtrac/views/Home/widgets/wellness_hub_section.dart';
import 'package:medtrac/views/Home/widgets/mood_chart_widget.dart';
import 'package:medtrac/views/Home/widgets/stress_bar_chart_widget.dart';
import 'package:medtrac/views/Home/widgets/your_doctors_widget.dart.dart';

class HomeScreen extends GetView<HomeController> {
  HomeScreen({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBarWithIcons(
              scaffoldKey: _scaffoldKey,
            ),
            20.verticalSpace,
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BodyTextOne(text: 'Good Morning! ${controller.isUser ? '' : 'Dr. '}${SharedPrefsService.getUserInfo.name.split(' ').first}'),
                    HeadingTextTwo(text: 'Wishing you a great day!'),
                  ],
                )),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      16.verticalSpace,
                      const WellnessBanner(),
                      32.verticalSpace,
                      UpcomingAppointmentsWidget(
                        isUser: controller.isUser,
                      ),
                      if (controller.isUser) ...[
                        32.verticalSpace,
                        MoodChartWidget(controller: controller),
                        32.verticalSpace,
                        SleepChart(),
                        32.verticalSpace,
                        StressBarChart(),
                      ],
                      if (controller.isUser) ...[
                        32.verticalSpace,
                        BestHealthProfessionalsWidget(),
                      ],
                      if (!controller.isUser) ...[
                        32.verticalSpace,
                        StatisticsWidget(controller: controller),
                        32.verticalSpace,
                        RecentAppointmentsWidget()
                      ],
                      32.verticalSpace,
                      WellnessHubSection(),
                      if (controller.isUser) ...[
                        32.verticalSpace,
                        YourDoctorsWidget(),
                      ],
                      32.verticalSpace,
                      HealthArticlesSection(),
                      32.verticalSpace,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
