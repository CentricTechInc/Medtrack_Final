import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medtrac/controllers/balance_statistics_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/views/earnings/widgets/transaction_item_tile.dart';

class TransactionWidget extends GetWidget<BalanceStatisticsController> {
  final int index;
  TransactionWidget({super.key, required this.index});

  // Parse the custom date format "12 Sep 2025 5PM"
  DateTime _parseCustomDate(String dateString) {
    try {
      // Try to parse with hour
      if (dateString.contains('PM') || dateString.contains('AM')) {
        final isPM = dateString.contains('PM');
        final hourMatch = RegExp(r'(\d+)(AM|PM)').firstMatch(dateString);
        
        if (hourMatch != null) {
          int hour = int.parse(hourMatch.group(1)!);
          if (isPM && hour != 12) hour += 12;
          if (!isPM && hour == 12) hour = 0;
          
          final dateOnly = dateString.replaceAll(RegExp(r'\s*\d+(AM|PM)'), '');
          final parsedDate = DateFormat('dd MMM yyyy').parse(dateOnly);
          return DateTime(parsedDate.year, parsedDate.month, parsedDate.day, hour);
        }
      }
      
      // Fallback to date only
      final dateOnly = dateString.replaceAll(RegExp(r'\s*\d+(AM|PM)'), '');
      return DateFormat('dd MMM yyyy').parse(dateOnly);
    } catch (e) {
      print("Error parsing date '$dateString': $e");
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeadingTextTwo(
          text: "${index == 0 ? 'Transaction' : 'Withdrawal'} History",
          fontSize: 20.sp,
        ),
        Obx(() {
          final data = index == 0 
            ? controller.earningsData.value 
            : controller.withdrawalsData.value;
          
          final history = data?.history ?? [];
          
          if (history.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: Center(
                child: BodyTextOne(
                  text: "No ${index == 0 ? 'transaction' : 'withdrawal'} history available",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            itemBuilder: (context, historyIndex) {
              final transaction = history[historyIndex];
              DateTime dateTime;
              
              try {
                dateTime = _parseCustomDate(transaction.createdAt);
              } catch (e) {
                print("Error parsing date: $e");
                dateTime = DateTime.now();
              }
              
              int amount = 0;
              try {
                amount = double.parse(transaction.amount).toInt();
              } catch (e) {
                amount = 0;
              }
              
              return TransactionItemTile(
                dateTime: dateTime,
                amount: amount,
                bankName: transaction.doctorBankDetail?.bankName,
              );
            },
          );
        }),
      ],
    );
  }
}
