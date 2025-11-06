import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class TransactionItemTile extends StatelessWidget {
  final DateTime dateTime;
  final int amount;
  final String? bankName;
  
  const TransactionItemTile({
    super.key, 
    required this.dateTime, 
    required this.amount,
    this.bankName,
  });

  @override
  Widget build(BuildContext context) {
    final String date = DateFormat("dd MMM yyyy").format(dateTime);
    final String time = DateFormat("hh:mm a").format(dateTime);


    return Card(
      color: AppColors.bright,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(Assets.bankIcon , width: 0.1.sw,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BodyTextOne(text: bankName ?? "Bank Account"),
                      Row(
                        children: [
                          BodyTextTwo(
                            text: date,
                          ),
                          SizedBox(width: 8.w),
                          BodyTextTwo(text: time)
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            BodyTextTwo(text: "₹$amount")
      
          ],
        ),
      ),
    );
  }
}
