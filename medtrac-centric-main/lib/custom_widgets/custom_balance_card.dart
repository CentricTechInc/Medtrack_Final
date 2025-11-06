import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double earning;
  final double withdrawalAmount;

  const BalanceCard( {
    super.key,
    required this.balance,
    required this.earning,
    required this.withdrawalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Balance',
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.lightGrey3,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '₹${balance.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Withdraw
              Expanded(
                child: Container(
                  height: 80.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_downward, color: AppColors.primary, size: 22.r),
                      SizedBox(width: 16.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodyTextOne(
                           text:  'Withdraw',
                           fontSize: 14,
                           color: AppColors.primary,
                          
                          ),
                          Text(
                            '₹${withdrawalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // Earning
              Expanded(
                child: Container(
                  height: 80.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: AppColors.primary,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_upward, color: Colors.white, size: 22.r),
                      SizedBox(width: 16.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           BodyTextOne(
                           text:  'Earnings',
                           fontSize: 14,
                           color: AppColors.bright,
                          
                          ),
                          BodyTextOne(
                           text : '₹${earning.toStringAsFixed(2)}',
                           fontSize: 18.sp,
                           color: AppColors.bright,
                           fontWeight: FontWeight.w700,
                           
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}