import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final int value;

  const CustomSliderThumbShape({
    required this.thumbRadius,
    required this.value,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
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

    final Paint thumbPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    final RRect thumbRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: center, width: thumbRadius * 2, height: thumbRadius * 2),
      Radius.circular(8.r),
    );

    canvas.drawRRect(thumbRRect, thumbPaint);

    final textSpan = TextSpan(
      text: this.value.toString(),
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final textCenter = Offset(center.dx - (textPainter.width / 2),
        center.dy - (textPainter.height / 2));
    textPainter.paint(canvas, textCenter);
  }
}

class CustomNumberSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int divisions;
  final List<String>? labels;

  const CustomNumberSlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.divisions,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final labelList =
        labels ?? List.generate(max - min + 1, (i) => (min + i).toString());
    return SizedBox(
      height: 60.h,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The background track with numbers/labels
          Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(labelList.length, (index) {
                final label = labelList[index];
                final number = min + index;
                return Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: number == value
                        ? Colors.transparent
                        : AppColors.secondary,
                  ),
                );
              }),
            ),
          ),
          // The actual slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              tickMarkShape: SliderTickMarkShape.noTickMark,
              thumbShape: CustomSliderThumbShape(
                thumbRadius: 24.r,
                value: value,
              ),
              trackHeight: 16.h,
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: divisions,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}
