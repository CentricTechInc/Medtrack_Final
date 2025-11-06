import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/account_info_controller.dart';
import 'package:medtrac/controllers/user/user_account_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_radio_tile.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';

class CustomPaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final int index;

  CustomPaymentMethodTile({
    super.key,
    required this.method,
    required this.index,
  });

  final AccountInfoController  controller = Get.isRegistered<AccountInfoController>()
      ? Get.find<AccountInfoController>()
      : Get.put(AccountInfoController());


  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomRadioTile(
          isSelected: controller.selectedAccountIndex.value == index,
          onTap: () => controller.setSelectedAccount(index),
          title: Row(
            children: [
              Image.asset(
                method.logoUrl,
                width: 48.w,
                height: 48.w,
              ),
              12.horizontalSpace,
              CustomText(
                text: method.methodName,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ],
          ),
        ));
  }
}
