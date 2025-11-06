import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/account_info_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_dropdown_field.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/custom_widgets/custom_buttons.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/snackbar.dart';

// Custom text formatter to convert input to uppercase and fix common IFSC mistakes
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.toUpperCase();
    
    // Auto-fix common mistake: Replace 'O' with '0' at position 5 (index 4)
    if (text.length >= 5 && text[4] == 'O') {
      text = text.substring(0, 4) + '0' + text.substring(5);
    }
    
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class AddNewAccountScreen extends GetView<AccountInfoController> {
  const AddNewAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Add New Account",
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: controller.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  36.verticalSpace,
                  HeadingTextTwo(text: "Enter Account Details"),
                  24.verticalSpace,
                  BodyTextOne(text: "Account Holder Name"),
                  8.verticalSpace,
                  CustomTextFormField(
                    hintText: "Full Name",
                    controller: controller.accountHolderNameController,
                    validator: controller.validateAccountHolderName,
                    textCapitalization: TextCapitalization.words,
                    keyboardType: TextInputType.name,
                  ),
                  24.verticalSpace,
                  BodyTextOne(text: "Bank Name"),
                  8.verticalSpace,
                  Obx(() => CustomDropdownField(
                        hintText: "Select Bank",
                        value: controller.selectedBank.value.isEmpty
                            ? null
                            : controller.selectedBank.value,
                        items: controller.availableBanks,
                        onChanged: (value) {
                          controller.selectedBank.value = value ?? "";
                        },
                        validator: controller.validateBankSelection,
                      )),
                  24.verticalSpace,
                  BodyTextOne(text: "IFSC Code"),
                  8.verticalSpace,
                  CustomTextFormField(
                    hintText: "IFSC Code (e.g., ABCD0123456 - note the zero)",
                    keyboardType: TextInputType.text,
                    controller: controller.ifscCodeController,
                    validator: controller.validateIFSC,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(11),
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      UpperCaseTextFormatter(),
                    ],
                  ),
                  4.verticalSpace,
                  Text(
                    "💡 IFSC format: 4 letters + 1 zero + 6 numbers/letters",
                    style: TextStyle(
                      color: AppColors.lightGreyText,
                      fontSize: 12.sp,
                    ),
                  ),
                  24.verticalSpace,
                  BodyTextOne(text: "Account Number"),
                  8.verticalSpace,
                  CustomTextFormField(
                    hintText: "Account Number",
                    keyboardType: TextInputType.number,
                    controller: controller.accountNumberController,
                    validator: controller.validateAccountNumber,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(18),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  24.verticalSpace,
                  BodyTextOne(text: "Re-enter Account Number"),
                  8.verticalSpace,
                  CustomTextFormField(
                    hintText: "Confirm Account Number",
                    keyboardType: TextInputType.number,
                    controller: controller.confirmAccountNumberController,
                    validator: controller.validateConfirmAccountNumber,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(18),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  24.verticalSpace,
                  Obx(() => Row(
                    children: [
                      Transform.scale(
                        scale: 0.9,
                        child: Checkbox(
                          value: controller.consentValue.value,
                          onChanged: (value) {
                            controller.consentValue.toggle();
                            if (controller.consentValue.value) {
                              controller.showConsentError.value = false;
                            }
                          },
                          checkColor: AppColors.bright,
                          activeColor: AppColors.secondary,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      Expanded(
                        child: BodyTextOne(
                          text: 'I confirm and consent to link this account.',
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreyText,
                        ),
                      ),
                    ],
                  )),
                  // Validation message for consent
                  Obx(() => controller.showConsentError.value
                      ? Padding(
                          padding: EdgeInsets.only(top: 8.h, left: 4.w),
                          child: Text(
                            'Please accept the consent to proceed',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
                  54.verticalSpace,
                  Obx(() => CustomElevatedButton(
                    onPressed: () {
                      if (controller.isLoading.value) return;
                      
                      if (controller.formKey.currentState?.validate() ?? false) {
                        if (controller.consentValue.isTrue) {
                          controller.saveAccountInfo();
                        } else {
                          SnackbarUtils.showError('Please accept the consent to proceed');
                        }
                      }
                    },
                    text: controller.isLoading.value 
                        ? "Adding Account..." 
                        : "Add Bank Account",
                    isLoading: controller.isLoading.value,
                  )),
                  24.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
