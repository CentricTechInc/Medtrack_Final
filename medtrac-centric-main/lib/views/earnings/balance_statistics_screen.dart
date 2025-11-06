import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/balance_statistics_controller.dart';
import 'package:medtrac/custom_widgets/custom_appbar_with_icons.dart';
import 'package:medtrac/custom_widgets/custom_balance_card.dart';
import 'package:medtrac/custom_widgets/custom_tab_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/models/balance_staistics_model.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:medtrac/views/earnings/widgets/earnings_tab_view.dart';
import 'package:medtrac/views/earnings/widgets/withdrawal_tab_view.dart';

class BalanceStatsScreen extends GetWidget<BalanceStatisticsController> {
  final BalanceStatisticsModel model = BalanceStatisticsModel();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BalanceStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.r),
              child: Column(
                children: [
                  10.verticalSpace,
                  CustomAppBarWithIcons(
                    scaffoldKey: _scaffoldKey,
                  ),
                  24.verticalSpace,
                  Obx(() {
                    final data = controller.currentTab.value == 0 
                      ? controller.earningsData.value 
                      : controller.withdrawalsData.value;
                    
                    return BalanceCard(
                      balance: double.tryParse(data?.balance ?? '0') ?? 0,
                      earning: double.tryParse(data?.totalEarning ?? '0') ?? 0,
                      withdrawalAmount: double.tryParse(data?.withdrawal ?? '0') ?? 0,
                    );
                  }),
                  20.verticalSpace,
                  CustomTabBar(
                    tabs: const ["Earnings", "Withdrawal"],
                    currentIndex: controller.currentTab,
                    onTabChanged: controller.onTabChanged,
                  ),
                  10.verticalSpace,
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: const [
                  EarningsTabView(),
                  WithdrawalTabView(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.r),
              child: CustomElevatedButton(
                text: "Withdraw",
                onPressed: () {
                  if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
                    HelperFunctions.showIncompleteProfileBottomSheet();
                    return;
                  }
                  controller.onWithDrawButtonPressed(model);
                },
              ),
            ),
            10.verticalSpace,
          ],
        ),
      ),
    );
  }
}


// void _confrimWithDrawalModal(BuildContext context) async{
//   await showModalBottomSheet(context: context, builder: );
// }