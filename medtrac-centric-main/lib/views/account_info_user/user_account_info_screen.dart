import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/user/user_account_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_payment_method_tile.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/horizontal_credit_cards_widget.dart';

class UserAccountInfoScreen extends GetView<UserAccountInfoController> {
  const UserAccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Account Info",
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    44.verticalSpace,

                    // Horizontal Credit Cards Widget
                    HorizontalCreditCardsWidget(controller: controller),

                    32.verticalSpace,
                    BodyTextOne(text: "More Payment Options"),
                    16.verticalSpace,
                    Obx(
                      () => Column(
                        children: List.generate(
                          controller.paymentMethods.length,
                          (index) => Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: CustomPaymentMethodTile(
                                method: controller.paymentMethods[index],
                                index: index,
                              )),
                        ),
                      ),
                    ),
                    30.verticalSpace,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
