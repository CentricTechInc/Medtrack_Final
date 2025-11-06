import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/balance_statistics_controller.dart';
import 'package:medtrac/custom_widgets/custom_chart_widget.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/views/earnings/widgets/transaction_widget.dart';

class WithdrawalTabView extends GetWidget<BalanceStatisticsController> {
  const WithdrawalTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.r),
            child: HeadingTextTwo(
              text: "Withdrawal Statistics",
              fontSize: 20.sp,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Obx(() => controller.isLoadingWithdrawals.value
              ? const Center(child: CircularProgressIndicator())
              : 
              RevenueChart(
                  chartData: controller.withdrawalsChartData,
                  monthNames: controller.lastSixMonths,
                )),
          ),
          20.verticalSpace,
          TransactionWidget(index: 1),
        ],
      ),
    );
  }
}
