import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final List<String> labels;
  final double spacing;

  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
    required this.labels,
    this.spacing = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: spacing,
      children: List.generate(steps.length * 2 - 1, (index) {
        // Even indices represent steps, odd indices represent dashes
        if (index.isEven) {
          final stepIndex = index ~/ 2;
          final isActive = stepIndex == currentStep - 1;
          final isCompleted = stepIndex < currentStep - 1;
          
          return _buildStepIndicator(
            steps[stepIndex], 
            labels[stepIndex], 
            isActive: isActive, 
            isCompleted: isCompleted,
          );
        } else {
          final dashIndex = index ~/ 2;
          final isActive = dashIndex < currentStep - 1;
          
          return _buildDashedLine(isActive);
        }
      }),
    );
  }

  Widget _buildStepIndicator(String step, String label, {bool isActive = false, bool isCompleted = false}) {
    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : isCompleted ? AppColors.primary : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: BodyTextTwo(text: step, color: AppColors.bright, fontWeight: FontWeight.w700,)
        ),
        SizedBox(height: 8.h),
        BodyTextTwo(text: label, 
          color: isActive || isCompleted ? Colors.black : AppColors.lightGreyText, 
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
  
  Widget _buildDashedLine(bool isActive) {
    return SizedBox(
      width: 40.w,
      child: Row(
        children: List.generate(5, (index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 2.w),
            width: 4.w,
            height: 2.h,
            color: isActive ? AppColors.primary : AppColors.lightGrey3,
          );
        }),
      ),
    );
  }
}
