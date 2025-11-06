import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/personal_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_fee_input_field.dart';
import 'package:medtrac/custom_widgets/custom_switch.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/step_progress_indicator.dart';
import 'package:medtrac/utils/app_colors.dart';

class AvailabilityScreen extends GetView<PersonalInfoController> {
   const AvailabilityScreen({super.key}); 

  @override
  Widget build(BuildContext context) {
    final bool fromRegisteration = Get.arguments["fromRegisteration"];
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Set Availability',),
        body: Column(
          children: [
            16.verticalSpace,
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    if (fromRegisteration) ...[
                      StepProgressIndicator(
                        currentStep: 3,
                        steps: ['01', '02', '03'],
                        labels: [
                          'Personal',
                          'Professional',
                          'Set Availability'
                        ],
                      ),
                      SizedBox(height: 32.h),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BodyTextOne(
                              text: 'Schedule',
                              fontWeight: FontWeight.w700,
                            ),
                            SizedBox(height: 16.h),
                            _buildCalendarView(),
                            SizedBox(height: 24.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const BodyTextOne(
                                  text: 'Slot',
                                  fontWeight: FontWeight.w700,
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _buildSlotSelection(),
                            SizedBox(height: 24.h),
                            const BodyTextOne(
                              text: 'Time',
                              fontWeight: FontWeight.w700,
                            ),
                            SizedBox(height: 16.h),
                            _buildTimeSelection(),
                            SizedBox(height: 24.h),
                            _buildEmergencyConsultation(),
                            SizedBox(height: 24.h),
                            const BodyTextOne(
                              text: 'Consultation Fees',
                              fontWeight: FontWeight.w700,
                            ),
                            SizedBox(height: 16.h),
                            _buildFeesSection(),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Obx(() => CustomElevatedButton(
                      text: fromRegisteration ?  'Continue' : "Update",
                      isLoading: controller.isLoading.value,
                      onPressed: () {
                        controller.handleContinue(fromRegistration: fromRegisteration);
                      },
                    )),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
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
            color: AppColors.dark.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => controller.changeMonth(-1),
                  child: Container(
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
                Obx(() => BodyTextOne(
                      text: controller.currentMonthName,
                      fontWeight: FontWeight.w600,
                    )),
                InkWell(
                  onTap: () => controller.changeMonth(1),
                  child: Container(
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
            ),
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
    final int firstWeekday = controller.firstWeekdayOfMonth.value;
    final int daysInMonth = controller.daysInMonth.value;

    // Calculate total number of cells in the calendar (including empty ones)
    int totalCells = ((firstWeekday - 1) + daysInMonth);
    int totalRows = (totalCells / 7).ceil();

    int day = 1;

    for (int row = 0; row < totalRows; row++) {
      List<Widget> rowChildren = [];

      for (int col = 0; col < 7; col++) {
        if ((row == 0 && col < firstWeekday - 1) || day > daysInMonth) {
          rowChildren.add(SizedBox(width: 32.w));
        } else {
          final int currentDay = day;
          rowChildren.add(Obx(() {
            final isSelected = controller.selectedDatesForCurrentSlot.contains(currentDay);
            // Check if this date is in the past
            final today = DateTime.now();
            final currentDate = DateTime(
              controller.currentCalendarDate.value.year,
              controller.currentCalendarDate.value.month,
              currentDay,
            );
            final isPastDate = currentDate.isBefore(DateTime(today.year, today.month, today.day));
            return GestureDetector(
              onTap: isPastDate ? null : () => controller.toggleDateSelection(currentDay),
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.blue50
                      : isPastDate
                          ? AppColors.lightGrey.withValues(alpha: 0.2)
                          : Colors.transparent,
                  border: isPastDate
                      ? Border.all(color: AppColors.lightGrey.withValues(alpha: 0.5), width: 1)
                      : null,
                ),
                child: Center(
                  child: Text(
                    currentDay.toString(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isPastDate
                          ? AppColors.lightGrey
                          : isSelected
                              ? AppColors.primary
                              : AppColors.secondary,
                      decoration: isPastDate ? TextDecoration.lineThrough : null,
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

  // Slot selection widget (Morning/Afternoon/Evening)
  Widget _buildSlotSelection() {
    return Obx(() {
      // Show loading state
      if (controller.isLoadingAvailability.value) {
        return Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: AppColors.bright,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.lightGrey, width: 1),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Show error state
      if (controller.hasAvailabilityError.value) {
        return Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: AppColors.bright,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.lightGrey, width: 1),
          ),
          child: Center(
            child: Text(
              controller.availabilityErrorMessage.value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
          ),
        );
      }

      return Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.bright,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.lightGrey, width: 1),
        ),
        child: Row(
          children: controller.slotOptions.map((slot) {
            final isSelected = controller.selectedSlot.value == slot;
            final isActive = controller.isSlotActive(slot);
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.setSlot(slot),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected || isActive ? AppColors.dark : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: Text(
                      slot,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected || isActive
                            ? AppColors.bright
                            : AppColors.secondary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  // Time selection widget
  Widget _buildTimeSelection() {
    return Obx(() {
      final timeOptions =
          controller.timeSlots[controller.selectedSlot.value] ?? [];
      final selectedTimings = controller.selectedTimingsForCurrentSlot;
      
      // Show loading state
      if (controller.isLoadingAvailability.value) {
        return SizedBox(
          height: 100.h,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      // Show error or no slots message
      if (controller.hasAvailabilityError.value || timeOptions.isEmpty) {
        return Container(
          height: 100.h,
          decoration: BoxDecoration(
            color: AppColors.bright,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.lightGrey, width: 1),
          ),
          child: Center(
            child: Text(
              controller.hasAvailabilityError.value 
                  ? controller.availabilityErrorMessage.value
                  : 'No time slots available for ${controller.selectedSlot.value}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      
      return Wrap(
        spacing: 8.w,
        runSpacing: 12.h,
        children: timeOptions.map((time) {
          final isSelected = selectedTimings.contains(time);
          return GestureDetector(
            onTap: () => controller.toggleTimeSelection(time),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.dark : Colors.transparent,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColors.dark : AppColors.lightGrey,
                ),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.bright : AppColors.secondary,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  // Emergency consultation toggle
  Widget _buildEmergencyConsultation() {
    return Row(
      children: [
        CustomSwitchWidget(
          switchValue: controller.isEmergencyConsultation,
          onToggle: controller.toggleEmergencyConsultation,
        ),
        SizedBox(width: 12.w),
        const BodyTextOne(
          text: 'Emergency Consultation',
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  // Fees section
  Widget _buildFeesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BodyTextOne(
                    text: 'Regular Fees',
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGreyText,
                  ),
                  SizedBox(height: 8.h),
                  CustomFeeInputField(
                    controller: controller.regularFeesController,
                    width: 150,
                    height: 60,
                    hintText: 'Regular Fees',
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BodyTextOne(
                    text: 'Emergency Fees',
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkGreyText,
                  ),
                  SizedBox(height: 8.h),
                  CustomFeeInputField(
                    controller: controller.emergencyFeesController,
                    width: double.infinity, // or 150 if same
                    height: 48,
                    hintText: 'Emergency Fees',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSlotCompletionIndicator() {
    final controller = Get.find<PersonalInfoController>();
    // Check how many slots are complete (have at least one timing selected)
    int completeSlots = 0;
    for (String slot in ['Morning', 'Afternoon', 'Evening']) {
      final timings = controller.selectedTimingsForSlot[slot] ?? [];
      if (timings.isNotEmpty) {
        completeSlots++;
      }
    }
    Color indicatorColor = completeSlots > 0 ? Colors.green : Colors.grey;
    String statusText = completeSlots > 0 
        ? '$completeSlots complete slot${completeSlots > 1 ? 's' : ''}' 
        : 'No complete slots';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: indicatorColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completeSlots > 0 ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16.sp,
            color: indicatorColor,
          ),
          SizedBox(width: 4.w),
          BodyTextTwo(
            text: statusText,
            color: indicatorColor,
          ),
        ],
      ),
    );
  }
}
