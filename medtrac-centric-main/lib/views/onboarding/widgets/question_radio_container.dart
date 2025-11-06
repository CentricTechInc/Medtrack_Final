import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class QuestionRadioContainer extends StatelessWidget {
  final String question;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onOptionSelected;

  const QuestionRadioContainer({
    super.key,
    required this.question,
    required this.options,
    required this.selectedValue,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
          BodyTextOne(
            text: question,
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
          16.verticalSpace,
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: options.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = selectedValue == option;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: BodyTextOne(
                  text: option,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
                leading: InkWell(
                  onTap: () => onOptionSelected(option),
                  child: Container(
                    width: 24.w,
                    height: 24.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.secondary,
                        width: isSelected ? 6.0 : 1.0,
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
