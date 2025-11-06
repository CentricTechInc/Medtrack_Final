import 'package:fl_chart/fl_chart.dart';
import 'package:medtrac/models/transaction_histor_model.dart';
import 'package:medtrac/utils/constants.dart';

class BalanceStatisticsModel {
  int withdrawalAmount = 0;
  int earning = 0;
  List<TransactionHistoryModel> transactionHistory = [];
  final List<FlSpot> revenueSpots = dummySpots;

  int get totalAmount => withdrawalAmount + earning;

  final List<Map<String, dynamic>> dummyTransactions = List.generate(
    3,
    (index) => {
      "date": DateTime.now().subtract(Duration(days: index, hours: index * 2)),
      "amount": (index + 1) * 100,
    },
  );
}
