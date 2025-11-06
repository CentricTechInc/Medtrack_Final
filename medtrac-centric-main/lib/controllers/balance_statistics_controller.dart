import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/shared_controller.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'package:medtrac/api/models/transaction_response.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/views/earnings/widgets/withdrawal_bottom_sheet.dart';
import 'package:fl_chart/fl_chart.dart';

class BalanceStatisticsController extends SharedController with GetSingleTickerProviderStateMixin {
  final DoctorService _doctorService = DoctorService();
  
  late TabController tabController;
  @override
  final RxInt currentTab = 0.obs;

  // Transaction data
  final RxBool isLoadingEarnings = false.obs;
  final RxBool isLoadingWithdrawals = false.obs;
  final Rx<TransactionData?> earningsData = Rx<TransactionData?>(null);
  final Rx<TransactionData?> withdrawalsData = Rx<TransactionData?>(null);

  // Chart data
  final RxList<FlSpot> earningsChartData = <FlSpot>[].obs;
  final RxList<FlSpot> withdrawalsChartData = <FlSpot>[].obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      currentTab.value = tabController.index;
    });
    
    // Load both earnings and withdrawals data
    loadEarningsData();
    loadWithdrawalsData();
  }

  // Load earnings transaction data
  Future<void> loadEarningsData() async {
    try {
      isLoadingEarnings.value = true;
      final response = await _doctorService.getTransactions(type: 'Earning');
      
      if (response.status && response.data != null) {
        earningsData.value = response.data;
        _updateEarningsChartData(response.data!.record);
      }
    } catch (e) {
      print("Error loading earnings data: $e");
    } finally {
      isLoadingEarnings.value = false;
    }
  }

  // Load withdrawals transaction data
  Future<void> loadWithdrawalsData() async {
    try {
      isLoadingWithdrawals.value = true;
      final response = await _doctorService.getTransactions(type: 'WithDrawal');
      
      if (response.status && response.data != null) {
        withdrawalsData.value = response.data;
        _updateWithdrawalsChartData(response.data!.record);
      }
    } catch (e) {
      print("Error loading withdrawals data: $e");
    } finally {
      isLoadingWithdrawals.value = false;
    }
  }

  // Convert monthly records to chart data
  void _updateEarningsChartData(List<MonthlyRecord> records) {
    earningsChartData.clear();
    for (int i = 0; i < records.length; i++) {
      double amount = double.tryParse(records[i].total) ?? 0.0;
      earningsChartData.add(FlSpot(i.toDouble(), amount));
    }
    
    // Ensure we always have some data points for proper chart rendering
    if (earningsChartData.isEmpty) {
      for (int i = 0; i < 6; i++) {
        earningsChartData.add(FlSpot(i.toDouble(), 0.0));
      }
    }
  }

  void _updateWithdrawalsChartData(List<MonthlyRecord> records) {
    withdrawalsChartData.clear();
    for (int i = 0; i < records.length; i++) {
      double amount = double.tryParse(records[i].total) ?? 0.0;
      withdrawalsChartData.add(FlSpot(i.toDouble(), amount));
    }
    
    // Ensure we always have some data points for proper chart rendering
    if (withdrawalsChartData.isEmpty) {
      for (int i = 0; i < 6; i++) {
        withdrawalsChartData.add(FlSpot(i.toDouble(), 0.0));
      }
    }
  }

  // Get last 6 months names
  List<String> get lastSixMonths {
    final now = DateTime.now();
    final List<String> months = [];
    
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      months.add(monthNames[monthDate.month - 1]);
    }
    
    return months;
  }

  // Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadEarningsData(),
      loadWithdrawalsData(),
    ]);
  }

  // Getters for current tab data
  TransactionData? get currentTabData => 
    currentTab.value == 0 ? earningsData.value : withdrawalsData.value;
    
  List<FlSpot> get currentChartData => 
    currentTab.value == 0 ? earningsChartData : withdrawalsChartData;
    
  bool get isCurrentTabLoading => 
    currentTab.value == 0 ? isLoadingEarnings.value : isLoadingWithdrawals.value;
    
  String get currentTabTitle => 
    currentTab.value == 0 ? 'Earning Statistics' : 'Withdrawal Statistics';

  // Submit withdrawal request
  Future<void> submitWithdrawal({
    required int bankId,
    required double amount,
  }) async {
    try {
      final response = await _doctorService.submitWithdrawal(
        bankId: bankId,
        amount: amount,
      );
      
      if (response.success) {
        // Refresh data after successful withdrawal
        await refreshData();
        
        // Use Future.delayed to avoid snackbar conflicts
        Future.delayed(Duration(milliseconds: 200), () {
          SnackbarUtils.showSuccess(
            response.message ?? 'Withdrawal request submitted successfully'
          );
        });
      } else {
        throw Exception(response.message ?? 'Failed to submit withdrawal request');
      }
    } catch (e) {
      // Re-throw the error to be handled by the calling widget
      throw e;
    }
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  @override
  void onTabChanged(int index) {
    currentTab.value = index;
    tabController.animateTo(index);
  }
  void onWithDrawButtonPressed(dynamic model) {
    Get.bottomSheet(
      WithdrawBottomSheet(
        amountController: TextEditingController(),
        onConfirm: () {
          // Optional callback for additional UI updates after successful withdrawal
          // The actual API call is handled inside the WithdrawBottomSheet widget
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

final Widget withdrawImage = Padding(
  padding: EdgeInsets.only(top: 24.h),
  child: Image.asset(
    Assets.withdrawalFund,
    width: 80.w,
    height: 80.h,
  ),
);
