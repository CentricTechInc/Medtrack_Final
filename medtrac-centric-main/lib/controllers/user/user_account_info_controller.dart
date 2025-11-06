import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/assets.dart';

class UserAccountInfoController extends GetxController {
  // Selected bank account index
  RxInt selectedPaymentMethodIndex = 0.obs;
  RxString selectedBank = "".obs;
  RxBool consentValue = false.obs;

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text editing controllers for form fields
  final TextEditingController accountHolderNameController =
      TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController confirmAccountNumberController =
      TextEditingController();

  // Sample bank account data (in a real app, this would come from an API)
  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: "1",
      methodName: "Stripe",
      logoUrl: Assets.stripeLogo,
    ),
    PaymentMethod(
      id: "2",
      methodName: "Stripe",
      logoUrl: Assets.stripeLogo,
    ),
  ].obs;

  // Sample saved credit cards data
  final List<SavedCreditCard> savedCreditCards = [
    SavedCreditCard(
      id: "1",
      cardNumber: "5698562546769979",
      cardHolderName: "John Doe",
      cardType: "Mastercard",
      cardLevel: "Platinum",
      isDefault: true,
    ),
    SavedCreditCard(
      id: "2",
      cardNumber: "4532123456789012",
      cardHolderName: "Jane Smith",
      cardType: "Mastercard",
      cardLevel: "Gold",
      isDefault: false,
    ),
  ].obs;

  // Change selected account
  void setSelectedPaymentMethod(int index) {
    if (index >= 0 && index < paymentMethods.length) {
      selectedPaymentMethodIndex.value = index;
    }
  }

  // Validate bank selection
  String? validateBankSelection(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a bank';
    }
    return null;
  }

  // Add a new bank account (for button in account list)
  void addNewPaymentMethod() {
    Get.toNamed(AppRoutes.userAddNewPaymentMethodScreen);
  }

  // Check if at least one bank account exists
  bool hasAtLeastOneAccount() {
    return paymentMethods.isNotEmpty;
  }
}

// Model class to represent a bank account
class PaymentMethod {
  final String id;
  final String methodName;
  final String logoUrl;

  PaymentMethod({
    required this.id,
    required this.methodName,
    required this.logoUrl,
  });
}

// Model class to represent a saved credit card
class SavedCreditCard {
  final String id;
  final String cardNumber;
  final String cardHolderName;
  final String cardType;
  final String cardLevel;
  final bool isDefault;

  SavedCreditCard({
    required this.id,
    required this.cardNumber,
    required this.cardHolderName,
    required this.cardType,
    required this.cardLevel,
    required this.isDefault,
  });
}
