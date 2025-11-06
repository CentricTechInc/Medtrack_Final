import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/balance_statistics_controller.dart';
import 'package:medtrac/custom_widgets/custom_chart_widget.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/views/earnings/widgets/transaction_widget.dart';

class EarningsTabView extends GetWidget<BalanceStatisticsController> {
  const EarningsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => HeadingTextTwo(
              text: controller.currentTab.value == 0 ? "Earning Statistics" : "Withdrawal Statistics",
              fontSize: 14.sp,
            )),
            16.verticalSpace,
            Obx(() => controller.isLoadingEarnings.value
              ? const Center(child: CircularProgressIndicator())
              : RevenueChart(
                  chartData: controller.earningsChartData,
                  monthNames: controller.lastSixMonths,
                )),
            20.verticalSpace,
            TransactionWidget(index: 0),
          ],
        ),
      ),
    );
  }
}
