import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/account_info_controller.dart';
import 'package:medtrac/controllers/balance_statistics_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/masked_account_info_tile.dart';
import 'package:medtrac/utils/app_colors.dart';

class WithdrawBottomSheet extends GetWidget<BalanceStatisticsController> {
  final TextEditingController amountController;
  final VoidCallback? onConfirm;

  const WithdrawBottomSheet({
    super.key,
    required this.amountController,
    this.onConfirm,
  });

  // Handle withdrawal API call
  Future<void> _handleWithdrawal(double amount, int bankId) async {
    try {
      // Show loading
      Get.dialog(
        PopScope(
          onPopInvokedWithResult: (didPop, result) => false,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "Processing withdrawal...",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      // Submit withdrawal
      await controller.submitWithdrawal(
        bankId: bankId,
        amount: amount,
      );
      
      // Close loading dialog
      if (Get.isDialogOpen!) {
        Get.back();
      }
      
      // Close withdrawal bottom sheet
      if (Get.isBottomSheetOpen!) {
        Get.back();
      }
      
      // Call onConfirm if provided (for additional UI updates)
      if (onConfirm != null) {
        // Use Future.delayed to avoid UI conflicts
        Future.delayed(Duration(milliseconds: 100), () {
          onConfirm!();
        });
      }
      
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen!) {
        Get.back();
      }
      
      // Show error with Future.delayed to avoid conflicts
      Future.delayed(Duration(milliseconds: 100), () {
        Get.snackbar(
          'Error',
          'Failed to submit withdrawal: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
  AccountInfoController  accountController = Get.isRegistered<AccountInfoController>() ? Get.find<AccountInfoController>() : Get.put(AccountInfoController());

    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  BodyTextOne(
                    text: "Balance",
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 4.h),
                  Obx(() {
                    final balance = double.tryParse(controller.currentTabData?.balance ?? '0') ?? 0.0;
                    return HeadingTextTwo(
                      text: "₹${balance.toStringAsFixed(2)}",
                      fontSize: 32.sp,
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 18.h),
            Divider(),
            SizedBox(height: 18.h),
            Container(
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.bright.withValues(alpha: 0.6),
                border: Border.all(
                  color: AppColors.greyBackgroundColor,
                ),
                borderRadius: BorderRadius.all(Radius.circular(6.r)),
              ),
              child: IntrinsicHeight(
                
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: TextField(
                          controller: amountController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: "Enter Amount to Withdraw",
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700
                            ),
                          ),
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                        ),

                        child: Center(
                          child: Text(
                            "INR",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            BodyTextOne(
              text: "Withdraw Money To:",
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            SizedBox(height: 12.h),
            Obx(() {
              if (accountController.isLoadingAccounts.value) {
                return Center(child: CircularProgressIndicator());
              }
              
              if (accountController.apiBankAccounts.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.greyBackgroundColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: BodyTextOne(
                      text: "No bank accounts found. Please add a bank account first.",
                      textAlign: TextAlign.center,
                      color: AppColors.lightGreyText,
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                itemBuilder: (context, index) {
                  final account = accountController.apiBankAccounts[index];
                  return MaskedAccountInfoTileWdiget(
                    account: account,
                    index: index,
                  );
                },
                itemCount: accountController.apiBankAccounts.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              );
            }),
            SizedBox(height: 24.h),
           Row(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyTextOne(
                  text: "Note: ",
                  // fontWeight: FontWeight.w700,
                ),
                Flexible(
                  child: BodyTextOne(
                    text: "Withdrawals are processed within 2-3 business days",
                    color: AppColors.lightGreyText,
                    // fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
SizedBox(height: 28.h),

            SizedBox(
              width: double.infinity,
              child: Obx(() {
                final hasAccounts = accountController.apiBankAccounts.isNotEmpty;
                return CustomElevatedButton(
                  text: "Confirm Withdraw",
                  onPressed: !hasAccounts ? () {
                    Get.snackbar(
                      'Error',
                      'No bank accounts available. Please add a bank account first.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  } : () {
                    // Validate amount is entered
                    if (amountController.text.trim().isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please enter an amount to withdraw',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    
                    // Validate amount is valid number
                    final amount = double.tryParse(amountController.text.trim());
                    if (amount == null || amount <= 0) {
                      Get.snackbar(
                        'Error',
                        'Please enter a valid amount',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    
                    // Validate sufficient balance
                    final balance = double.tryParse(controller.currentTabData?.balance ?? '0') ?? 0.0;
                    if (amount > balance) {
                      Get.snackbar(
                        'Error',
                        'Insufficient balance. Available balance: ₹${balance.toStringAsFixed(2)}',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    
                    // Validate account is selected
                    final selectedAccount = accountController.getSelectedAccount();
                    if (selectedAccount == null) {
                      Get.snackbar(
                        'Error',
                        'Please select a bank account',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    
                    // Submit withdrawal API call
                    _handleWithdrawal(amount, selectedAccount.id);
                  },
                  isSecondary: true,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

