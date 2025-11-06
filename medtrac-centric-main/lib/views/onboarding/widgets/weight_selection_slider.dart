import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/basic_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class WeightSelectionSlider extends GetView<BasicInfoController> {
  const WeightSelectionSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    // Initialize scroll position when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialScrollPosition(scrollController, context);
    });

    // Add scroll listener
    scrollController.addListener(() {
      _handleScrollUpdate(scrollController, context);
    });

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.borderGrey,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and unit toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BodyTextOne(
                text: "Weight",
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
              _buildUnitToggle(scrollController, context),
            ],
          ),
          32.verticalSpace,

          // Weight display
          Obx(() => Center(
                child: CustomText(
                  text: controller.selectedWeight.value.toInt().toString(),
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              )),
          24.verticalSpace,

          // Custom ruler picker
          SizedBox(
            height: 100.h,
            child: _buildCustomRulerPicker(scrollController, context),
          ),
        ],
      ),
    );
  }

  // Weight ranges based on unit
  double get minWeight => controller.isKg.value ? 45.0 : 99.0;
  double get maxWeight => controller.isKg.value ? 120.0 : 265.0;
  double get minDisplayWeight => controller.isKg.value ? 0.0 : 0.0;
  double get maxDisplayWeight => controller.isKg.value ? 200.0 : 400.0;

  void _handleScrollUpdate(
      ScrollController scrollController, BuildContext context) {
    final scrollOffset = scrollController.offset;
    final containerWidth = MediaQuery.of(context).size.width - (48.w * 2);
    final centerOffset = scrollOffset + (containerWidth / 2);
    final rulerWidth = containerWidth * 3;
    final weightRange = maxDisplayWeight - minDisplayWeight;
    final centerProgress = centerOffset / rulerWidth;
    final newWeight = minDisplayWeight + (centerProgress * weightRange);

    if (newWeight != controller.selectedWeight.value &&
        newWeight >= minDisplayWeight &&
        newWeight <= maxDisplayWeight) {
      controller.setSelectedWeight(newWeight.round().toDouble());
    }
  }

  void _setInitialScrollPosition(
      ScrollController scrollController, BuildContext context) {
    if (scrollController.hasClients) {
      final containerWidth = MediaQuery.of(context).size.width - (48.w * 2);
      final rulerWidth = containerWidth * 3;
      final weightRange = maxDisplayWeight - minDisplayWeight;
      final weightProgress =
          (controller.selectedWeight.value - minDisplayWeight) / weightRange;
      final targetCenterOffset = weightProgress * rulerWidth;
      final targetScrollOffset = targetCenterOffset - (containerWidth / 2);

      scrollController.animateTo(
        targetScrollOffset.clamp(
            0.0, scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildCustomRulerPicker(
      ScrollController scrollController, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - (48.w * 2);
    final rulerWidth = containerWidth * 3;

    return Stack(
      children: [
        // Scrollable ruler
        SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            width: rulerWidth,
            height: 100.h,
            child: Obx(() => CustomPaint(
                  painter: RulerPainter(
                    minDisplayWeight: minDisplayWeight,
                    maxDisplayWeight: maxDisplayWeight,
                    minWeight: minWeight,
                    maxWeight: maxWeight,
                    currentWeight: controller.selectedWeight.value,
                    containerWidth: containerWidth,
                    rulerWidth: rulerWidth,
                  ),
                )),
          ),
        ),

        // Center indicator (thicker bar)
        Positioned(
          left: 0,
          right: 0,
          top: 25.h,
          child: Center(
            child: Container(
              width: 3.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitToggle(
      ScrollController scrollController, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Obx(() => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUnitToggleButton(
                  "KG", controller.isKg.value, scrollController, context),
              _buildUnitToggleButton(
                  "lbs", !controller.isKg.value, scrollController, context),
            ],
          )),
    );
  }

  Widget _buildUnitToggleButton(String text, bool isSelected,
      ScrollController scrollController, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelected) return;

        final oldIsKg = controller.isKg.value;
        final newIsKg = text == "KG";

        double newWeight = controller.selectedWeight.value;

        // Convert weight when switching units
        if (oldIsKg && !newIsKg) {
          // Convert kg to lbs
          newWeight = newWeight * 2.20462;
        } else if (!oldIsKg && newIsKg) {
          // Convert lbs to kg
          newWeight = newWeight / 2.20462;
        }

        // Round to nearest whole number
        newWeight = newWeight.round().toDouble();

        controller.setWeightUnit(newIsKg);
        controller.setSelectedWeight(newWeight);

        // Update scroll position after conversion
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _setInitialScrollPosition(scrollController, context);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: CustomText(
          text: text,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.bright : AppColors.darkGrey,
        ),
      ),
    );
  }
}

class RulerPainter extends CustomPainter {
  final double minDisplayWeight;
  final double maxDisplayWeight;
  final double minWeight;
  final double maxWeight;
  final double currentWeight;
  final double containerWidth;
  final double rulerWidth;

  RulerPainter({
    required this.minDisplayWeight,
    required this.maxDisplayWeight,
    required this.minWeight,
    required this.maxWeight,
    required this.currentWeight,
    required this.containerWidth,
    required this.rulerWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final weightRange = maxDisplayWeight - minDisplayWeight;
    final tickSpacing = rulerWidth / weightRange;
    final stepSize = (maxDisplayWeight > 250) ? 5 : 1;

    for (int i = 0; i <= weightRange.toInt(); i += stepSize) {
      final weight = minDisplayWeight + i;
      final x = i * tickSpacing;

      double tickHeight;
      if (weight % 50 == 0) {
        tickHeight = 40.0;
        paint.strokeWidth = 2.0;
      } else if (weight % 25 == 0) {
        tickHeight = 25.0;
        paint.strokeWidth = 1.5;
      } else if (weight % 10 == 0) {
        tickHeight = 20.0;
        paint.strokeWidth = 1.5;
      } else if (weight % 5 == 0) {
        tickHeight = 15.0;
        paint.strokeWidth = 1.0;
      } else {
        tickHeight = 10.0;
        paint.strokeWidth = 1.0;
      }

      paint.color = AppColors.primary;

      final centerY = size.height / 2;
      final tickStartY = centerY - (tickHeight / 2);
      final tickEndY = centerY + (tickHeight / 2);

      canvas.drawLine(
        Offset(x, tickStartY),
        Offset(x, tickEndY),
        paint,
      );

      bool shouldShowLabel = false;
      if (maxDisplayWeight > 250) {
        shouldShowLabel = weight % 25 == 0;
      } else {
        shouldShowLabel = weight % 10 == 0;
      }

      if (shouldShowLabel) {
        textPainter.text = TextSpan(
          text: weight.toInt().toString(),
          style: TextStyle(
            color: AppColors.darkGrey,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();

        final textX = x - textPainter.width / 2;
        final textY = size.height - textPainter.height - 5;

        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
