import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/user/user_add_new_payment_method_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_switch.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/credit_card_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';

class UserAddNewPaymentMethodScreen
    extends GetView<UserAddNewPaymentMethodController> {
  const UserAddNewPaymentMethodScreen({super.key});

  void _showCVVTooltip(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppColors.primary,
                size: 20.sp,
              ),
              8.horizontalSpace,
              Text(
                'What is CVV?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CVV (Card Verification Value) is a 3 or 4-digit security code on your card.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.darkGreyText,
                ),
              ),
              16.verticalSpace,
              Text(
                '• For most cards: 3 digits on the back\n• For Amex: 4 digits on the front',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.darkGreyText,
                ),
              ),
              16.verticalSpace,
              Text(
                'This code helps verify that you physically have the card.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.lightGreyText,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Add New Card",
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Credit Card Widget
            GetBuilder<UserAddNewPaymentMethodController>(
              builder: (controller) => CreditCardWidget(
                cardNumber: controller.cardNumberController.text,
                cardHolderName: controller.cardHolderNameController.text,
                expirationDate: controller.expirationDateController.text,
                cvv: controller.cvvController.text,
              ),
            ),

            // Form Section
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: controller.formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        24.verticalSpace,
                        HeadingTextTwo(text: "Enter Information"),
                        24.verticalSpace,

                        // Card Number Field
                        const BodyTextOne(
                          text: "Card Number",
                          fontWeight: FontWeight.bold,
                        ),
                        8.verticalSpace,
                        CustomTextFormField(
                          controller: controller.cardNumberController,
                          hintText: "Enter your 16-digit card number",
                          hintTextStyle: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.lightGreyText,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                            TextInputFormatter.withFunction(
                                (oldValue, newValue) {
                              String formatted =
                                  controller.formatCardNumber(newValue.text);
                              return TextEditingValue(
                                text: formatted,
                                selection: TextSelection.collapsed(
                                    offset: formatted.length),
                              );
                            }),
                          ],
                          validator: controller.validateCardNumber,
                          onChanged: (value) => controller.update(),
                          suffixIcon:
                              GetBuilder<UserAddNewPaymentMethodController>(
                            builder: (controller) => Padding(
                              padding: EdgeInsets.all(12.r),
                              child: Image.asset(
                                controller.getCardTypeIconPath(
                                    controller.cardNumberController.text),
                                width: 24.w,
                                height: 24.h,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.credit_card,
                                    color: AppColors.lightGreyText,
                                    size: 24.sp,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        24.verticalSpace,

                        // Card Holder Name
                        const BodyTextOne(
                          text: "Card Holder",
                          fontWeight: FontWeight.bold,
                        ),
                        8.verticalSpace,
                        CustomTextFormField(
                          controller: controller.cardHolderNameController,
                          hintText: "Enter cardholder's full name",
                          hintTextStyle: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.lightGreyText,
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: controller.validateCardHolderName,
                          onChanged: (value) => controller.update(),
                        ),

                        24.verticalSpace,

                        // Expiration Date and CVC Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const BodyTextOne(
                                    text: "Expiration Date",
                                    fontWeight: FontWeight.bold,
                                  ),
                                  8.verticalSpace,
                                  CustomTextFormField(
                                    controller:
                                        controller.expirationDateController,
                                    hintText: "MM/YY",
                                    hintTextStyle: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.lightGreyText,
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        String formatted =
                                            controller.formatExpirationDate(
                                                newValue.text);
                                        return TextEditingValue(
                                          text: formatted,
                                          selection: TextSelection.collapsed(
                                              offset: formatted.length),
                                        );
                                      }),
                                    ],
                                    validator:
                                        controller.validateExpirationDate,
                                    onChanged: (value) => controller.update(),
                                  ),
                                ],
                              ),
                            ),
                            16.horizontalSpace,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const BodyTextOne(
                                    text: "CVC",
                                    fontWeight: FontWeight.bold,
                                  ),
                                  8.verticalSpace,
                                  CustomTextFormField(
                                    controller: controller.cvvController,
                                    hintText: "3-digit security code",
                                    hintTextStyle: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.lightGreyText,
                                    ),
                                    keyboardType: TextInputType.number,
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        _showCVVTooltip(context);
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(12.r),
                                        child: Icon(
                                          Icons.help_outline,
                                          color: AppColors.primary,
                                          size: 16.sp,
                                        ),
                                      ),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(4),
                                    ],
                                    validator: controller.validateCVV,
                                    onChanged: (value) => controller.update(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        24.verticalSpace,

                        // Default Card Toggle
                        Row(
                          children: [
                            CustomSwitchWidget(
                              switchValue: controller.consentValue,
                              onToggle: () => controller.consentValue.toggle(),
                            ),
                            16.horizontalSpace,
                            const BodyTextOne(
                              text: "Mark as default card",
                            ),
                          ],
                        ),

                        32.verticalSpace,

                        CustomElevatedButton(
                          onPressed: () {
                            if (controller.formKey.currentState?.validate() ??
                                false) {
                              Get.offAllNamed(AppRoutes.mainScreen);
                            }
                          },
                          text: "Update",
                        ),
                        24.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
