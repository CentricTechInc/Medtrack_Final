import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class StatisticsColumnWidget extends StatelessWidget {
  final String title;
  final String value;
  final String? percentageChange;
  const StatisticsColumnWidget({
    super.key,
    required this.title,
    required this.value,
    this.percentageChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyTextTwo(text: title, color: AppColors.lightGreyText),
        16.verticalSpace,
        Row(
          children: [
            HeadingTextTwo(text: value),
            if (percentageChange != null) ...[
              12.horizontalSpace,
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: AppColors.green50,
                ),
                child: CustomText(
                  text: "$percentageChange%",
                  color: title == "Canceled" ? AppColors.error : AppColors.green,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ],
        )
      ],
    );
  }
}
