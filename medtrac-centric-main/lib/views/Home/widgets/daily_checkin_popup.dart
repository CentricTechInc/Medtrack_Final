import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/daily_checkin_controller.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/custom_widgets/custom_number_slider.dart';
class DailyCheckinPopup extends GetView<DailyCheckinController> {
  const DailyCheckinPopup({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(DailyCheckinController());
    return _DailyCheckinContent();
  }
}

class _DailyCheckinContent extends StatefulWidget {
  @override
  State<_DailyCheckinContent> createState() => _DailyCheckinContentState();
}

class _DailyCheckinContentState extends State<_DailyCheckinContent> {
  int selectedStressLevel = 1;
  // Mood options
  final List<Map<String, dynamic>> moods = [
    {
      'type': 'excellent',
      'label': 'Happy',
      'icon': Assets.execellentMoodIcon,
      'disabledIcon': Assets.disabledExecellentMoodIcon
    },
    {
      'type': 'good',
      'label': 'Calm',
      'icon': Assets.goodMoodIcon,
      'disabledIcon': Assets.disabledGoodMoodIcon
    },
    {
      'type': 'fair',
      'label': 'Neutral',
      'icon': Assets.fairMoodIcon,
      'disabledIcon': Assets.disabledFairMoodIcon
    },
    {
      'type': 'poor',
      'label': 'Sad',
      'icon': Assets.poorMoodIcon,
      'disabledIcon': Assets.disabledPoorMoodIcon
    },
    {
      'type': 'worst',
      'label': 'Angry',
      'icon': Assets.worstMoodIcon,
      'disabledIcon': Assets.disabledWorstMoodIcon
    },
  ];

  // Sleep quality options with enabled/disabled icons
  final List<Map<String, dynamic>> sleepOptions = [
    {
      'label': '7-9 hrs',
      'icon': Assets.execellentMoodIcon,
      'disabledIcon': Assets.disabledExecellentMoodIcon,
    },
    {
      'label': '6-7 hrs',
      'icon': Assets.goodMoodIcon,
      'disabledIcon': Assets.disabledGoodMoodIcon,
    },
    {
      'label': '5 hrs',
      'icon': Assets.fairMoodIcon,
      'disabledIcon': Assets.disabledFairMoodIcon,
    },
    {
      'label': '3-4 hrs',
      'icon': Assets.poorMoodIcon,
      'disabledIcon': Assets.disabledPoorMoodIcon,
    },
    {
      'label': '< 3hrs',
      'icon': Assets.worstMoodIcon,
      'disabledIcon': Assets.disabledWorstMoodIcon,
    },
  ];

  int selectedMood = 2; // Default to Neutral
  int selectedSleep = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Image.asset(
                  Assets.crossIcon,
                  width: 24.w,
                  height: 24.h,
                  color: Colors.black,
                ),
              ),
            ),
            const BodyTextOne(
              text: 'Current Mood',
              fontWeight: FontWeight.bold,
            ),
            16.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(moods.length, (i) {
                final mood = moods[i];
                final isSelected = selectedMood == i;
                return GestureDetector(
                  onTap: () => setState(() => selectedMood = i),
                  child: Column(
                    children: [
                      Image.asset(
                        isSelected ? mood['icon'] : mood['disabledIcon'],
                        width: 48.w,
                        height: 48.w,
                      ),
                      4.verticalSpace,
                      BodyTextOne(
                        text: mood['label'],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ],
                  ),
                );
              }),
            ),
            24.verticalSpace,
            const BodyTextOne(
              text: "Today's Sleep Quality",
              fontWeight: FontWeight.bold,
            ),
            16.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(sleepOptions.length, (i) {
                final sleep = sleepOptions[i];
                final isSelected = selectedSleep == i;
                return GestureDetector(
                  onTap: () => setState(() => selectedSleep = i),
                  child: Column(
                    children: [
                      Image.asset(
                        isSelected ? sleep['icon'] : sleep['disabledIcon'],
                        width: 48.w,
                        height: 48.h,
                      ),
                      4.verticalSpace,
                      BodyTextOne(
                        text: sleep['label'],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ],
                  ),
                );
              }),
            ),
            24.verticalSpace,
            const BodyTextOne(
              text: 'Current Stress Level',
              fontWeight: FontWeight.bold,
            ),
            CustomNumberSlider(
              value: selectedStressLevel,
              onChanged: (v) => setState(() => selectedStressLevel = v),
              min: 1,
              max: 5,
              divisions: 4,
            ),
            16.verticalSpace,
            GetBuilder<DailyCheckinController>(
              builder: (controller) {
                return Obx(() => CustomElevatedButton(
                  text: controller.isSubmitting.value ? "Submitting..." : "Submit",
                  isLoading: controller.isSubmitting.value,
                  onPressed: () {
                    if (!controller.isSubmitting.value) {
                      controller.submitEmotions(
                        selectedMood: selectedMood,
                        selectedSleep: selectedSleep,
                        selectedStressLevel: selectedStressLevel,
                      );
                    }
                  },
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
