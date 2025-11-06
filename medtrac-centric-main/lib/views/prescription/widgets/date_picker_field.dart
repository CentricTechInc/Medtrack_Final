import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'date_picker_bottom_sheet.dart';

class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  void _showDatePickerSheet(BuildContext context) {
    Get.bottomSheet<DateTime>(
      DatePickerBottomSheet(
        initialDate: selectedDate,
        onDateSelected: (date) {
          onDateChanged(date);
          Get.back();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDatePickerSheet(context),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.bright,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.greyBackgroundColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.year}",
              style: TextStyle(color: AppColors.secondary),
            ),
            Image.asset(
              Assets.calanderIcon,
            ),
          ],
        ),
      ),
    );
  }
}
