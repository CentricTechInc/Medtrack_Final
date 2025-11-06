import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/home_controller.dart';

class MoodChartWidget extends StatelessWidget {
  final HomeController controller;
  MoodChartWidget({super.key, required this.controller});

  // Map mood type to asset path (API: Happy, Calm, Neutral, Sad, Angry)
  static const Map<String, String> moodAssets = {
    'happy': Assets.execellentMoodIcon,
    'calm': Assets.goodMoodIcon,
    'neutral': Assets.fairMoodIcon, // true neutral icon
    'sad': Assets.poorMoodIcon,
    'angry': Assets.worstMoodIcon,
    'missing': Assets.disabledFairMoodIcon, // Use fair icon for missing days
  };

  // Map mood type to color
  static const Map<String, Color> moodColors = {
    'angry': Color(0xFFE74C3C),
    'sad': Color(0xFFF1C40F),
    'missing': Colors.grey,
    'calm': Color(0xFF27AE60),
    'happy': Color(0xFF27AE60),
    'neutral': Color(0xFFBDBDBD),
};

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
    // Build a map of day -> mood from the API (controller.moodAnalytics)
    final moodApiList = controller.moodAnalytics;
    final Map<String, String> moodMap = { for (var m in moodApiList) m.dayName: m.currentMood.toLowerCase() };
      return Column(
        children: [
          16.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyTextOne(
                text: 'Analytics',
                fontWeight: FontWeight.w700,
              ),
              GestureDetector(
                onTap: () {},
                child: const BodyTextOne(
                  text: 'Weekly',
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightGreyText,
                ),
              ),
            ],
          ),
          16.verticalSpace,
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyTextOne(
                  text: 'Mood Chart',
                  fontWeight: FontWeight.w900,
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.map((day) {
                    // Normalize mood string from API (case-insensitive)
                    String moodRaw = moodMap[day] ?? '';
                    String mood = moodRaw.toLowerCase();
                    // Map API moods to our keys
                    switch (mood) {
                      case 'happy':
                        mood = 'happy';
                        break;
                      case 'calm':
                        mood = 'calm';
                        break;
                      case 'neutral':
                        mood = 'neutral';
                        break;
                      case 'sad':
                        mood = 'sad';
                        break;
                      case 'angry':
                        mood = 'angry';
                        break;
                      default:
                        mood = 'missing';
                    }
                    final asset = moodAssets[mood] ?? moodAssets['missing']!;
                    final color = moodColors[mood] ?? moodColors['missing']!;
                    return Column(
                      children: [
                        Image.asset(
                          asset,
                          width: 36.w,
                          height: 36.w,
                          color: mood == 'missing' ? color : null,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          day,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
