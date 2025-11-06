import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_number_slider.dart';
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

class StressLevelSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const StressLevelSlider(
      {super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CustomNumberSlider(
      value: value,
      onChanged: onChanged,
      min: 1,
      max: 5,
      divisions: 4,
    );
  }
}
