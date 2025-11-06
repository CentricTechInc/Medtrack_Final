import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/home_controller.dart';

class SleepChart extends StatefulWidget {
  const SleepChart({super.key});

  @override
  State<SleepChart> createState() => _SleepChartState();
}

class _SleepChartState extends State<SleepChart> {
  int? touchedIndex;
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BodyTextOne(text: "Sleep Chart", fontWeight: FontWeight.w900),
          16.verticalSpace,
          AspectRatio(
            aspectRatio: 1.7,
            child: Obx(() {
              final hours = homeController.sleepChartHours;
              final sleepAnalytics = homeController.sleepAnalytics;
              final List<FlSpot> spots = List.generate(
                hours.length,
                (i) => FlSpot(i.toDouble(), hours[i]),
              );
              return LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 10,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.deepPurple,
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.deepPurple.withOpacity(0.2),
                            Colors.deepPurple.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      dotData: FlDotData(
                        show: touchedIndex != null,
                        getDotPainter: (spot, index, barData, rodData) {
                          if (touchedIndex != null && index == touchedIndex) {
                            return FlDotCirclePainter(
                              radius: 6,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: Colors.deepPurple,
                            );
                          }
                          return FlDotCirclePainter(
                              radius: 0, color: Colors.transparent);
                        },
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchCallback: (event, response) {
                      if (response != null &&
                          response.lineBarSpots != null &&
                          response.lineBarSpots!.isNotEmpty) {
                        final spot = response.lineBarSpots!.first;
                        setState(() {
                          touchedIndex = spot.spotIndex;
                        });
                      }
                    },
                    getTouchedSpotIndicator: (barData, spotIndexes) {
                      return List.generate(spotIndexes.length, (i) {
                        final index = spotIndexes[i];
                        if (touchedIndex != null && index == touchedIndex) {
                          return TouchedSpotIndicatorData(
                            FlLine(color: Colors.black, strokeWidth: 0),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, _, __, ___) =>
                                  FlDotCirclePainter(
                                radius: 7,
                                color: Colors.white,
                                strokeWidth: 3,
                                strokeColor: Colors.black,
                              ),
                            ),
                          );
                        } else {
                          return TouchedSpotIndicatorData(
                            FlLine(color: Colors.transparent, strokeWidth: 0),
                            FlDotData(show: false),
                          );
                        }
                      });
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.black,
                      tooltipBorderRadius: BorderRadius.circular(12),
                      getTooltipItems: (spots) {
                        if (touchedIndex != null && spots.isNotEmpty) {
                          final spot = spots.firstWhere(
                            (s) => s.spotIndex == touchedIndex,
                            orElse: () => spots.first,
                          );
                          // Show the actual sleep range from API if available
                          String label = '';
                          const days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
                          if (touchedIndex != null && touchedIndex! < days.length) {
                            final day = days[touchedIndex!];
                            final sleepEntry = sleepAnalytics.firstWhereOrNull((e) => e.dayName == day);
                            if (sleepEntry != null && sleepEntry.sleepQuality.isNotEmpty) {
                              label = sleepEntry.sleepQuality;
                            } else {
                              label = spot.y.toStringAsFixed(1) + ' hrs';
                            }
                          } else {
                            label = spot.y.toStringAsFixed(1) + ' hrs';
                          }
                          return [
                            LineTooltipItem(
                              label,
                              const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ];
                        }
                        return [];
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.withOpacity(.2),
                      strokeWidth: 1,
                      dashArray: [6, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const days = [
                            'Sun',
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat'
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              days[value.toInt()],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
