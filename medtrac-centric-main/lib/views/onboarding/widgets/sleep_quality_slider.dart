import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/basic_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class CustomSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final double rotationDegrees;

  const CustomSliderThumbShape({
    this.thumbRadius = 28.0,
    this.rotationDegrees = 0.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius + 4);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationDegrees * 3.1415926535 / 180);
    canvas.translate(-center.dx, -center.dy);

    // Draw outer white border (larger)
    final Paint outerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius + 4, outerBorderPaint);

    // Draw border ring
    final Paint borderPaint = Paint()
      ..color = AppColors.lightGrey
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius + 2, borderPaint);

    // Draw main thumb circle
    final Paint thumbPaint = Paint()
      ..color = sliderTheme.thumbColor ?? AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, thumbPaint);

    // Draw icon representation - curved brackets like letter "C" rotated 90 degrees
    final Paint iconPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw C-shaped brackets rotated 90 degrees
    final double bracketRadius = thumbRadius * 0.2;
    final double spacing = thumbRadius * 0.15;

    // Left C-shaped bracket (opening right)
    final Path leftBracket = Path();
    leftBracket.addArc(
      Rect.fromCenter(
        center: Offset(center.dx - spacing, center.dy),
        width: bracketRadius * 2,
        height: bracketRadius * 2,
      ),
      1.5708, // Start from bottom (π/2 radians)
      3.14159, // Draw half circle (π radians)
    );
    canvas.drawPath(leftBracket, iconPaint);

    // Right C-shaped bracket (opening left)
    final Path rightBracket = Path();
    rightBracket.addArc(
      Rect.fromCenter(
        center: Offset(center.dx + spacing, center.dy),
        width: bracketRadius * 2,
        height: bracketRadius * 2,
      ),
      -1.5708, // Start from top (-π/2 radians)
      3.14159, // Draw half circle (π radians)
    );
    canvas.drawPath(rightBracket, iconPaint);
  }
}

class SleepQualitySlider extends GetView<BasicInfoController> {
  const SleepQualitySlider({super.key});

  @override
  Widget build(BuildContext context) {
    final sleepOptions = [
      {
        'icon': Assets.execellentMoodIcon,
        'label': 'Excellent',
        'hours': '7-9 HOURS',
        'color': Colors.green
      },
      {
        'icon': Assets.goodMoodIcon,
        'label': 'Good',
        'hours': '6-7 HOURS',
        'color': Colors.lightGreen
      },
      {
        'icon': Assets.fairMoodIcon,
        'label': 'Fair',
        'hours': '5 HOURS',
        'color': Colors.blue
      },
      {
        'icon': Assets.poorMoodIcon,
        'label': 'Poor',
        'hours': '3-4 HOURS',
        'color': Colors.orange
      },
      {
        'icon': Assets.worstMoodIcon,
        'label': 'Worst',
        'hours': '<3 HOURS',
        'color': Colors.red
      },
    ];

    return Container(
      width: double.infinity,
      height: 400.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Row(
        children: [
          // Mood labels and hours column on the left
          Expanded(
            flex: 2,
            child: Column(
              children: sleepOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;

                return Expanded(
                  child: Obx(() {
                    final isSelected =
                        controller.selectedSleepQuality.value == index;

                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isSelected ? 1.0 : 0.4,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: option['label'] as String,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkGrey,
                            ),
                            4.verticalSpace,
                            // Hours
                            Row(
                              children: [
                                Image.asset(
                                  Assets.timerDarkIcon,
                                ),
                                6.horizontalSpace,
                                CustomText(
                                  text: option['hours'] as String,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              }).toList(),
            ),
          ),

          // Vertical slider track
          SizedBox(
            width: 60.w,
            height: double.infinity,
            child: Obx(() {
              return RotatedBox(
                quarterTurns: 3, // Rotate to make it vertical
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.lightGrey,
                    thumbColor: AppColors.primary,
                    thumbShape: CustomSliderThumbShape(thumbRadius: 26.r),
                    trackHeight: 12.h,
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 0),
                    tickMarkShape: SliderTickMarkShape.noTickMark,
                  ),
                  child: Slider(
                    value:
                        (4 - controller.selectedSleepQuality.value).toDouble(),
                    min: 0,
                    max: 4,
                    divisions: 4,
                    onChanged: (value) {
                      controller.setSleepQuality(4 - value.round());
                    },
                  ),
                ),
              );
            }),
          ),

          Expanded(
            flex: 2,
            child: Column(
              children: sleepOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setSleepQuality(index),
                    child: Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        option['icon'] as String,
                        scale: 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
