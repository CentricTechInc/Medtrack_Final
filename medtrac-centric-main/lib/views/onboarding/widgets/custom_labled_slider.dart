import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/views/onboarding/widgets/sleep_quality_slider.dart';

/// A customizable labeled slider for any value/labels use case.
///
/// Use this widget for mood, rating, or any other labeled slider scenario.
class CustomLabeledSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final List<String> labels;
  final double thumbRadius;
  final double thumbRotation;
  final double trackHeight;
  final EdgeInsetsGeometry? padding;

  const CustomLabeledSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.labels,
    this.thumbRadius = 18.0,
    this.thumbRotation = 90.0,
    this.trackHeight = 8.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SliderTheme(
          
            data: SliderTheme.of(context).copyWith(
              
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.lightGrey,
              thumbColor: AppColors.primary,
              thumbShape: CustomSliderThumbShape( thumbRadius: thumbRadius, rotationDegrees: thumbRotation),
              trackHeight: trackHeight,
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: (labels.length - 1).toDouble(),
              divisions: labels.length - 1,
              onChanged: (v) => onChanged(v.round()),
              // Add reduce/semantic actions for accessibility
              semanticFormatterCallback: (double newValue) =>
                  labels[newValue.round()],
            ),
          ),
          8.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(labels.length, (index) {
              final isActive = value == index;
              return Expanded(
                child: Center(
                  child: Text(
                    labels[index],
                    style: TextStyle(
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.lightGreyText,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
