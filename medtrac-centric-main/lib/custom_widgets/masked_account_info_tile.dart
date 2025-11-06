import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/account_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_radio_tile.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/api/models/bank_response.dart';

class MaskedAccountInfoTileWdiget extends StatelessWidget {
  final BankAccountData account;
  final int index;

  MaskedAccountInfoTileWdiget({
    super.key,
    required this.account,
    required this.index,
  });

  AccountInfoController get controller => Get.isRegistered<AccountInfoController>() ? Get.find<AccountInfoController>() : Get.put(AccountInfoController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomRadioTile(
      isSelected: controller.selectedAccountIndex.value == index,
      onTap: () => controller.setSelectedAccount(index),
      title: _buildBankAccountInfo(context, account),
    ));
  }

  Widget _buildBankAccountInfo(BuildContext context, BankAccountData account) {
    return Row(
      children: [
        Image.asset(
          Assets.bankIcon,
          width: 48.w,
          height: 48.w,
        ),
        12.horizontalSpace,
        Expanded(child: _accountDetails(context)),
      ],
    );
  }

  Widget _accountDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: account.bankName,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        4.verticalSpace,
        CustomText(
          text: controller.getMaskedAccountNumber(account.accountNumber),
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: AppColors.darkGreyText,
        ),
      ],
    );
  }
}
