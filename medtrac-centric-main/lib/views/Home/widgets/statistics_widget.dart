import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/home_controller.dart';
import 'package:medtrac/custom_widgets/custom_dropdown_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/views/Home/widgets/appointment_statistics_chart.dart';
import 'package:medtrac/views/Home/widgets/statistics_column_widget.dart';

class StatisticsWidget extends StatelessWidget {
  const StatisticsWidget({
    super.key,
    required this.controller,
  });

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const BodyTextOne(
              text: 'Appointment Statistics',
              fontWeight: FontWeight.w700,
            ),
            SizedBox(
              width: 120.w,
              child: Obx(() => CustomDropdownField(
                    hintText: "Month",
                    value: controller.selectedMonth.value,
                    items: controller.months,
                    onChanged:
                        controller.changeSelectedMonth,
                    isOutlined: false,
                    iconSize: 20.sp,
                    buttonPadding: EdgeInsets.zero,
                    fontWeight: FontWeight.w700,
                  )),
            )
          ],
        ),
        16.verticalSpace,
        GetBuilder<HomeController>(
          builder: (controller) => Obx(() {
            return Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.bright,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: () {
                if (controller.isLoadingStatistics.value) {
                  return const SizedBox(
                    height: 60,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                // Use API data if available, otherwise use dummy data
                final total = controller.apiStatisticsData.value?.total ?? 80;
                final completed = controller.apiStatisticsData.value?.completed ?? 65;
                final canceled = controller.apiStatisticsData.value?.canceled ?? 15;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatisticsColumnWidget(
                      title: "Total",
                      value: total.toString(),
                    ),
                    const BodyTextOne(text: "|"),
                    StatisticsColumnWidget(
                      title: "Completed",
                      value: completed.toString(),
                    ),
                    const BodyTextOne(text: "|"),
                    StatisticsColumnWidget(
                      title: "Canceled",
                      value: canceled.toString(),
                    ),
                  ],
                );
              }(),
            );
          }),
        ),
    
        // Appointment Statistics Chart
        AppointmentStatisticsChart(controller: controller),
      ],
    );
  }
}