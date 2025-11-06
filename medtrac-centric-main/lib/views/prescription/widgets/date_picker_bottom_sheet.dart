import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';

class DatePickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onDateSelected;
  const DatePickerBottomSheet({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
  });

  @override
  State<DatePickerBottomSheet> createState() => _DatePickerBottomSheetState();
}

class _DatePickerBottomSheetState extends State<DatePickerBottomSheet> {
  late Rx<DateTime> currentCalendarDate;
  late RxInt selectedDay;
  late RxInt daysInMonth;
  late RxInt firstWeekdayOfMonth;

  @override
  void initState() {
    super.initState();
    currentCalendarDate = widget.initialDate.obs;
    selectedDay = widget.initialDate.day.obs;
    _updateCalendarData();
  }

  // Initialize calendar data
  void _updateCalendarData() {
    // Calculate days in the current month
    daysInMonth = DateTime(
      currentCalendarDate.value.year,
      currentCalendarDate.value.month + 1,
      0,
    ).day.obs;
    
    // Calculate the weekday of the first day (1 = Monday, 7 = Sunday)
    firstWeekdayOfMonth = DateTime(
      currentCalendarDate.value.year,
      currentCalendarDate.value.month,
      1,
    ).weekday.obs;
  }
  
  // Get current month name with year
  String get currentMonthName => 
      DateFormat('MMMM yyyy').format(currentCalendarDate.value);
  
  // Change month
  void changeMonth(int change) {
    // Update the current calendar date by adding or subtracting months
    currentCalendarDate.value = DateTime(
      currentCalendarDate.value.year,
      currentCalendarDate.value.month + change,
      1,
    );
    
    // Reset selected day if it's greater than days in new month
    if (selectedDay.value > DateTime(
        currentCalendarDate.value.year, 
        currentCalendarDate.value.month + 1, 
        0).day) {
      selectedDay.value = 1;
    }
    
    // Update calendar data for the new month
    _updateCalendarData();
  }
  
  // Select a day
  void selectDay(int day) {
    selectedDay.value = day;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.bright,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Date", 
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold
              )
            ),
            16.verticalSpace,
            Expanded(
              child: SingleChildScrollView(
                child: _buildCalendarView(),
              ),
            ),
            16.verticalSpace,
            CustomElevatedButton(
              text: "Select",
              onPressed: () {
                final selectedDate = DateTime(
                  currentCalendarDate.value.year,
                  currentCalendarDate.value.month,
                  selectedDay.value,
                );
                widget.onDateSelected(selectedDate);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Calendar widget
  Widget _buildCalendarView() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => changeMonth(-1),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.scaffoldBackground,
                    ),
                    child: Icon(
                      Icons.chevron_left_sharp,
                      size: 24.sp,
                      color: AppColors.lightGrey3,
                    ),
                  ),
                ),
                BodyTextOne(
                  text: currentMonthName,
                  fontWeight: FontWeight.w600,
                ),
                InkWell(
                  onTap: () => changeMonth(1),
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.scaffoldBackground,
                    ),
                    child: Icon(
                      Icons.chevron_right_sharp,
                      size: 24.sp,
                      color: AppColors.lightGrey3,
                    ),
                  ),
                ),
              ],
            )),
          ),
          Divider(height: 1.h, thickness: 1, color: AppColors.lightGrey),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _weekDayLabel('M'),
                _weekDayLabel('T'),
                _weekDayLabel('W'),
                _weekDayLabel('T'),
                _weekDayLabel('F'),
                _weekDayLabel('S'),
                _weekDayLabel('S'),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() => _buildCalendarGrid()),
          SizedBox(height: 16.h),
          // Pull up indicator
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  // Helper method for day labels
  Widget _weekDayLabel(String dayLetter) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.dark,
      ),
      child: Center(
        child: Text(
          dayLetter,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.bright,
          ),
        ),
      ),
    );
  }

  // Build the calendar grid based on the month data
  Widget _buildCalendarGrid() {
    final List<Widget> calendarRows = [];
    final int firstWeekday = firstWeekdayOfMonth.value;
    final int daysInCurrentMonth = daysInMonth.value;

    // Calculate total number of cells in the calendar (including empty ones)
    int totalCells = ((firstWeekday - 1) + daysInCurrentMonth);
    int totalRows = (totalCells / 7).ceil();

    int day = 1;

    for (int row = 0; row < totalRows; row++) {
      List<Widget> rowChildren = [];

      for (int col = 0; col < 7; col++) {
        if ((row == 0 && col < firstWeekday - 1) || day > daysInCurrentMonth) {
          rowChildren.add(SizedBox(width: 32.w));
        } else {
          final int currentDay = day;
          rowChildren.add(Obx(() {
            final isSelected = selectedDay.value == currentDay;
            return GestureDetector(
              onTap: () => selectDay(currentDay),
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.blue50 : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    currentDay.toString(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? AppColors.primary : AppColors.secondary,
                    ),
                  ),
                ),
              ),
            );
          }));
          day++;
        }
      }

      // Add the row with proper spacing
      calendarRows.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: rowChildren,
          ),
        ),
      );
    }

    return Column(children: calendarRows);
  }
}
