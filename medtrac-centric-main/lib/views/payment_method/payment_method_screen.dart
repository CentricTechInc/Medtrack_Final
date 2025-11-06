import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/payment_method_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';

class PaymentMethodScreen extends GetView<PaymentMethodController> {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Payment Method',
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyTextOne(
                  text: "Choose your payment method",
                  fontWeight: FontWeight.bold,
                ),
                12.verticalSpace,
                ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: controller.paymentMethods.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final method = controller.paymentMethods[index];
                    return Obx(() {
                      final isSelected =
                          controller.selectedMethodIndex.value == index;
                      return GestureDetector(
                        onTap: () =>
                            controller.selectedMethodIndex.value = index,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  color: AppColors.primary,
                                ),
                                child: Image.asset(
                                  method['logo']!,
                                  width: 22.w,
                                  height: 22.w,
                                ),
                              ),
                              16.horizontalSpace,
                              BodyTextOne(
                                text: method['method']!,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: CustomElevatedButton(
                  text: "Continue",
                  onPressed: () {
                    Get.toNamed(AppRoutes.appointmentBookingSummaryScreen);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
