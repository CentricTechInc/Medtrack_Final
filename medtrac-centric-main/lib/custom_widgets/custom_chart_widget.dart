import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RevenueChart extends StatefulWidget {
  final List<FlSpot>? chartData;
  final List<String>? monthNames;
  
  const RevenueChart({super.key, this.chartData, this.monthNames});

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart> {
  int? touchedIndex;

  final List<FlSpot> defaultRevenueSpots = const [
    FlSpot(0, 600),
    FlSpot(1, 1100),
    FlSpot(2, 800),
    FlSpot(3, 700),
    FlSpot(4, 1700),
    FlSpot(5, 2100),
  ];

  List<FlSpot> get revenueSpots => widget.chartData ?? defaultRevenueSpots;
  
  List<String> get monthNames => widget.monthNames ?? ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
  
  double get maxX => revenueSpots.isNotEmpty 
    ? revenueSpots.map((spot) => spot.x).reduce((a, b) => a > b ? a : b)
    : 5;
    
  double get maxY {
    if (revenueSpots.isEmpty) return 2500;
    
    final maxValue = revenueSpots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    // Ensure maxY is never zero - use minimum of 100 for proper chart display
    return maxValue <= 0 ? 100 : (maxValue * 1.2);
  }

  // Get safe horizontal interval that's never zero
  double get horizontalInterval {
    final interval = maxY / 4;
    // Ensure interval is never zero - minimum of 25
    return interval <= 0 ? 25 : interval;
  }

  // Format currency values for Y-axis
  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '₹${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '₹${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${value.toStringAsFixed(0)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.8,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 2500,
                lineBarsData: [
                  LineChartBarData(
                    spots: revenueSpots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withValues(alpha: 0.2),
                          Colors.blue.withValues(alpha: 0.05),
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
                            strokeColor: Colors.blue,
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
                    // Only update touchedIndex if a spot is tapped; do not clear on pan end or tap outside
                    if (response != null &&
                        response.lineBarSpots != null &&
                        response.lineBarSpots!.isNotEmpty) {
                      final spot = response.lineBarSpots!.first;
                      setState(() {
                        touchedIndex = spot.spotIndex;
                      });
                    }
                    // Do not clear touchedIndex when finger is lifted or tap outside
                  },
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    // Return a list matching spotIndexes length
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
                        // No indicator for other points
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
                      // Only show tooltip for touchedIndex
                      if (touchedIndex != null && spots.isNotEmpty) {
                        final spot = spots.firstWhere(
                          (s) => s.spotIndex == touchedIndex,
                          orElse: () => spots.first,
                        );
                        return [
                          LineTooltipItem(
                            '₹${spot.y.toStringAsFixed(0)}',
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
                  horizontalInterval: horizontalInterval, // Use safe interval that's never zero
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Colors.grey.withValues(alpha: .2),
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
                        final index = value.toInt();
                        if (index >= 0 && index < monthNames.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              monthNames[index],
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 500,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            _formatCurrency(value),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
