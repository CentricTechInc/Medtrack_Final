import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/home_controller.dart';

class StressBarChart extends StatelessWidget {
  StressBarChart({super.key});

  // Days order: Sun-Sat
  final List<String> days = const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Build a map of day -> stress from the API (controller.stressAnalytics)
      final stressApiList = homeController.stressAnalytics;
      final Map<String, int> stressMap = { for (var s in stressApiList) s.dayName: s.stressLevel };
      final List<double> stressLevels = List.generate(days.length, (i) {
        final day = days[i];
        return stressMap[day] != null ? stressMap[day]!.toDouble() : 0.0;
      });
      return Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stress Level',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5,
                  minY: 0,
                  groupsSpace: 12,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
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
                            child: BodyTextOne(
                              text: days[value.toInt()],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return BodyTextOne(
                            text: value.toInt().toString().padLeft(2, '0'),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          );
                        },
                        interval: 1,
                        reservedSize: 32,
                      ),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.withOpacity(.2),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: stressLevels[i],
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(6),
                          width: 18,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    });
// Add to HomeController:
// final RxList<StressAnalytics> stressAnalytics = <StressAnalytics>[].obs;
// In loadEmotionsAnalytics(): stressAnalytics.assignAll(analytics.stress);
  }
}
