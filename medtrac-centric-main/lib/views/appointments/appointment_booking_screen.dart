import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/appointment_booking_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/consultation_type_tile.dart';
import 'package:medtrac/utils/app_colors.dart';

class AppointmentBookingScreen extends GetView<AppointmentBookingController> {
  const AppointmentBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bright,
      appBar: CustomAppBar(
        titleWidget: Obx(() => Text(
          controller.isRescheduleMode.value ? "Reschedule Appointment" : "Appointment",
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        )),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScheduleSection(),
                  32.verticalSpace,
                  // Show different states based on loading and availability
                  Obx(() {
                    if (controller.isLoadingSlots.value) {
                      // Show loading state
                      return _buildLoadingState();
                    } else if (controller.slotError.isNotEmpty && controller.selectedDateId.isNotEmpty) {
                      // Show "Select another day" message when there's no availability for selected date
                      return _buildNoAvailabilityMessage();
                    } else {
                      // Show normal slot and time sections
                      return Column(
                        children: [
                          _buildSlotSection(),
                          32.verticalSpace,
                          _buildTimeSection(),
                        ],
                      );
                    }
                  }),
                  32.verticalSpace,
                  _buildConsultationTypeSection(),
                  60.verticalSpace,
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Obx(() => CustomElevatedButton(
              text: controller.isRescheduleMode.value ? "Reschedule" : "Continue",
              onPressed: (controller.slotError.isNotEmpty && controller.selectedDateId.isNotEmpty) 
                  ? () {}
                  : controller.continueToNextStep,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey, width: 1),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          16.verticalSpace,
          const BodyTextOne(
            text: "Loading availability...",
            textAlign: TextAlign.center,
            color: AppColors.darkGreyText,
            fontWeight: FontWeight.w600,
          ),
          8.verticalSpace,
          const BodyTextTwo(
            text: "Please wait while we fetch available slots for this date.",
            textAlign: TextAlign.center,
            color: AppColors.darkGreyText,
          ),
        ],
      ),
    );
  }

  Widget _buildNoAvailabilityMessage() {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.lightGrey, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48.w,
            color: AppColors.darkGreyText,
          ),
          16.verticalSpace,
          const BodyTextOne(
            text: "No availability for this date",
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
            textAlign: TextAlign.center,
          ),
          8.verticalSpace,
          const BodyTextTwo(
            text: "Please select another day to check availability",
            color: AppColors.darkGreyText,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BodyTextOne(
          text: "Consultation Type",
          fontWeight: FontWeight.bold,
          color: AppColors.dark,
        ),
        16.verticalSpace,
        Obx(() => Column(
              children: [
                ConsultationTypeTile(
                  title: "Standard Consultation",
                  description: "Regular fees based on doctor's rate.",
                  price: "₹${controller.regularFees.value.toStringAsFixed(0)}",
                  selected:
                      controller.selectedConsultationType.value == 'standard',
                  onTap: () =>
                      controller.selectedConsultationType.value = 'standard',
                ),
                ConsultationTypeTile(
                  title: "Emergency Consultation",
                  description:
                      "Higher fees apply for emergency. Session will be start in 10 to 20 minutes",
                  price: "₹${controller.emergencyFees.value.toStringAsFixed(0)}",
                  selected:
                      controller.selectedConsultationType.value == 'emergency',
                  onTap: () =>
                      controller.selectedConsultationType.value = 'emergency',
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BodyTextOne(
              text: "Schedule",
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
            GestureDetector(
              onTap: _showMonthPicker,
              child: Row(
                children: [
                  Obx(() => BodyTextOne(
                        text: controller.currentMonthName,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      )),
                  8.horizontalSpace,
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        24.verticalSpace,
        _buildHorizontalDateScroll(),
      ],
    );
  }

  Widget _buildHorizontalDateScroll() {
    return SizedBox(
      height: 80.h,
      child: Obx(() {
        return ListView.separated(
          controller: controller.dateScrollController,
          scrollDirection: Axis.horizontal,
          itemCount: controller.availableDays.length,
          separatorBuilder: (context, index) => 12.horizontalSpace,
          itemBuilder: (context, index) {
            final availableDay = controller.availableDays[index];

            return Obx(() {
              final isSelected =
                  controller.selectedDateId.value == availableDay.id;

              return GestureDetector(
                onTap: () {
                  controller.selectDate(availableDay);
                },
                child: Container(
                  width: 60.w,
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.bright,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.lightGrey,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BodyTextTwo(
                        text: availableDay.weekday,
                        color: isSelected
                            ? AppColors.bright
                            : AppColors.darkGreyText,
                        fontWeight: FontWeight.w500,
                      ),
                      4.verticalSpace,
                      BodyTextOne(
                        text: availableDay.day.toString(),
                        color: isSelected ? AppColors.bright : AppColors.dark,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      }),
    );
  }

  void _showMonthPicker() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.bright,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            16.verticalSpace,
            const BodyTextOne(
              text: "Select Month",
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
            24.verticalSpace,
            Expanded(
              child: ListView(
                children: controller.availableMonths.map(
                (month) => ListTile(
                  title: BodyTextOne(
                    text: month,
                    color: AppColors.dark,
                  ),
                  trailing: Obx(() => controller.selectedMonth.value == month
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : const SizedBox.shrink()),
                  onTap: () {
                    controller.changeMonth(month);
                    Get.back();
                  },
                ),
              ).toList()
              ),
            ),
            24.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildSlotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BodyTextOne(
          text: "Slot",
          fontWeight: FontWeight.bold,
          color: AppColors.dark,
        ),
        16.verticalSpace,
        _buildSlotSelection(),
      ],
    );
  }

  Widget _buildSlotSelection() {
    return Obx(() {
      if (controller.isLoadingSlots.value) {
        return Container(
          height: 48.h,
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.slotError.isNotEmpty) {
        return Container(
          height: 48.h,
          alignment: Alignment.center,
          child: Text(controller.slotError.value, style: TextStyle(color: AppColors.secondary)),
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
            // Disable slot if all times are booked
            final slotTimes = controller.slotTimeSlots[slot] ?? [];
            final allBooked = slotTimes.isNotEmpty && slotTimes.every((ts) => !ts.isAvailable);
            return Expanded(
              child: GestureDetector(
                onTap: allBooked ? null : () => controller.setSlot(slot),
                child: Opacity(
                  opacity: allBooked ? 0.4 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.dark : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: BodyTextTwo(
                        text: slot,
                        color: isSelected ? AppColors.bright : AppColors.dark,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
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

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BodyTextOne(
          text: "Time",
          fontWeight: FontWeight.bold,
          color: AppColors.dark,
        ),
        16.verticalSpace,
        _buildTimeSelection(),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Obx(() {
      final slotTimes = controller.currentSlotTimeSlots;
      if (controller.isLoadingSlots.value) {
        return Container(
          height: 48.h,
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.slotError.isNotEmpty) {
        return Container(
          height: 48.h,
          alignment: Alignment.center,
          child: Text(controller.slotError.value, style: TextStyle(color: AppColors.secondary)),
        );
      }
      if (slotTimes.isEmpty) {
        return Container(
          height: 48.h,
          alignment: Alignment.center,
          child: Text('No times available', style: TextStyle(color: AppColors.secondary)),
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
          children: slotTimes.map((ts) {
            final isSelected = controller.selectedTime.value == ts.time;
            final isBooked = !ts.isAvailable;
            return Expanded(
              child: GestureDetector(
                onTap: isBooked ? null : () => controller.selectTime(ts.time),
                child: Opacity(
                  opacity: isBooked ? 0.4 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.dark : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: BodyTextTwo(
                        text: ts.time,
                        color: isSelected ? AppColors.bright : AppColors.dark,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
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
}
