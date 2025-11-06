import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class ConsultationTypeTile extends StatelessWidget {
  final String title;
  final String description;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  const ConsultationTypeTile({
    super.key,
    required this.title,
    required this.description,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.bright,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.lightGrey,
            width: 1.2,
          ),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.dark,
                  width: selected ? 6.0 : 1.2,
                ),
                color: Colors.transparent,
              ),
            ),
            16.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyTextOne(
                    text: title,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                  4.verticalSpace,
                  BodyTextTwo(
                    text: description,
                    color: AppColors.darkGreyText,
                  ),
                ],
              ),
            ),
            16.horizontalSpace,
            BodyTextOne(
              text: price,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ],
        ),
      ),
    );
  }
}
