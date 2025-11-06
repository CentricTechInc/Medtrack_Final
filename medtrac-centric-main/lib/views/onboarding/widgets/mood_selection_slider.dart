import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/basic_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class MoodSelectionSlider extends StatefulWidget {
  const MoodSelectionSlider({super.key});

  @override
  State<MoodSelectionSlider> createState() => _MoodSelectionSliderState();
}

class _MoodSelectionSliderState extends State<MoodSelectionSlider> {
  late PageController _pageController;
  final controller = Get.find<BasicInfoController>();
  final RxDouble currentPage = 0.0.obs;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: controller.selectedMoodIndex.value,
      viewportFraction: 0.4, // Increased for better scaling
    );
    currentPage.value = controller.selectedMoodIndex.value.toDouble();

    _pageController.addListener(() {
      currentPage.value = _pageController.page ?? 0.0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodIcons = [
      Assets.worstMoodDarkIcon,
      // Assets.poorMoodDarkIcon,
      Assets.fairMoodDarkIcon,
      // Assets.goodMoodDarkIcon,
      Assets.execellentMoodDarkIcon,
    ];

    final moodTexts = [
      "I'm feeling sad",
      "I'm feeling neutral",
      "I'm feeling good",
    ];

    return Column(
      children: [
        // Horizontal mood slider with border and arrows
        SizedBox(
          height: 200.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  controller.setSelectedMood(index);
                },
                itemCount: moodIcons.length,
                itemBuilder: (context, index) {
                  return Obx(() {
                    // Calculate distance from center for smooth transitions
                    final distance = (currentPage.value - index).abs();
                    final isCenter = distance < 0.5;

                    // Smooth scale transition based on distance
                    final scale = isCenter
                        ? 1.2 - (distance * 0.4) // Scale from 1.2 to 0.8
                        : 0.7;

                    // Smooth color transition based on distance
                    final colorOpacity = isCenter
                        ? 1.0 - (distance * 2.0) // Fade from 1.0 to 0.0
                        : 0.0;

                    final iconColor = Color.lerp(
                          AppColors.borderGrey,
                          AppColors.secondary,
                          colorOpacity.clamp(0.0, 1.0),
                        ) ??
                        AppColors.borderGrey;

                    return Transform.scale(
                      scale: scale,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isCenter ? 20.r : 0.r),
                          child: Image.asset(
                            moodIcons[index],
                            color: iconColor,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),

              // Border overlay for selected item
              IgnorePointer(
                child: Container(
                  width: 160.w,
                  height: 160.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.r),
                    border: Border.all(
                      color: AppColors.borderGrey,
                      width: 20.w,
                    ),
                  ),
                ),
              ),

              // Up arrow
              Positioned(
                top: 18.h,
                child: Image.asset(
                  Assets.arrowDownIcon,
                  height: 16.h,
                ),
              ),

              // Down arrow
              Positioned(
                bottom: 18.h,
                child: Image.asset(
                  Assets.arrowUpIcon,
                  height: 16.h,
                ),
              ),
            ],
          ),
        ),

        32.verticalSpace,

        // Dynamic mood text
        Obx(() {
          return BodyTextOne(
            text: moodTexts[controller.selectedMoodIndex.value],
            fontWeight: FontWeight.w900,
          );
        }),
      ],
    );
  }
}
