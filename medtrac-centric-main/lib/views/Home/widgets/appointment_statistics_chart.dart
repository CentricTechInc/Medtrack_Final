import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/home_controller.dart';
import 'package:medtrac/models/appointment_statistics.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class AppointmentStatisticsChart extends StatelessWidget {
  final HomeController controller;

  const AppointmentStatisticsChart({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final statistics = List<AppointmentStatistics>.from(controller.appointmentStatistics);
        final maxY = controller.maxYValue.value;
        
        print('📈 FL Chart rebuilding with ${statistics.length} items');
        print('📈 Chart data: ${statistics.map((e) => '${e.week}:${e.completed}/${e.canceled}').join(', ')}');
        print('📈 Max Y: $maxY');
        print('📈 Statistics hashCode: ${statistics.hashCode}');
        print('📈 Original list hashCode: ${controller.appointmentStatistics.hashCode}');
        
        return Column(
          children: [
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.primary.withValues(alpha: 0.8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String weekDay = statistics[group.x.toInt()].week;
                        String value = rod.toY.round().toString();
                        String type = rodIndex == 0 ? 'Completed' : 'Canceled';
                        return BarTooltipItem(
                          '$weekDay\n$type: $value',
                          TextStyle(
                            color: AppColors.bright,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value.toInt() >= 0 && value.toInt() < statistics.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                statistics[value.toInt()].week,
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 32.h,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: AppColors.darkGreyText,
                              fontWeight: FontWeight.w400,
                              fontSize: 11.sp,
                            ),
                          );
                        },
                        reservedSize: 32.w,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 10,
                    verticalInterval: 1,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.lightGrey3.withValues(alpha: 0.3),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  barGroups: _generateBarGroups(statistics),
                ),
              ),
            ),
            16.verticalSpace,
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Completed', AppColors.primary),
                24.horizontalSpace,
                _buildLegendItem('Canceled', const Color(0xFF4CD964)),
              ],
            ),
          ],
        );
      }),
    );
  }

  List<BarChartGroupData> _generateBarGroups(List<AppointmentStatistics> statistics) {
    return statistics.asMap().entries.map((entry) {
      int index = entry.key;
      AppointmentStatistics stat = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: stat.completed.toDouble(),
            color: AppColors.primary,
            width: 16.w,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4.r),
              topRight: Radius.circular(4.r),
            ),
          ),
          BarChartRodData(
            toY: stat.canceled.toDouble(),
            color: const Color(0xFF4CD964),
            width: 16.w,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4.r),
              topRight: Radius.circular(4.r),
            ),
          ),
        ],
        barsSpace: 4.w,
      );
    }).toList();
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        8.horizontalSpace,
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.darkGreyText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
