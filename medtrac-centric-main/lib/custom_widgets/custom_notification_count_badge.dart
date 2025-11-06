import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class NotificationCountBadge extends StatelessWidget {
  final int text;

  const NotificationCountBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: BodyTextTwo(
        text: "$text New",
        color: AppColors.bright,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
