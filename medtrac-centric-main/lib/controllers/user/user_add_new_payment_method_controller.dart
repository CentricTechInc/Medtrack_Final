import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:medtrac/utils/assets.dart';

class UserAddNewPaymentMethodController extends GetxController {
  // Selected bank account index
  RxInt selectedAccountIndex = 0.obs;
  RxString selectedBank = "".obs;
  RxBool consentValue = true.obs;

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text editing controllers for form fields
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderNameController =
      TextEditingController();
  final TextEditingController expirationDateController =
      TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController accountHolderNameController =
      TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController confirmAccountNumberController =
      TextEditingController();

  // Validation status
  RxBool isValid = false.obs;

  // Sample bank account data (in a real app, this would come from an API)
  final List<BankAccount> bankAccounts = [
    BankAccount(
      id: "1",
      accountName: "John Doe",
      accountNumber: "1234567890",
      bankName: "Chase Bank",
    ),
    BankAccount(
      id: "2",
      accountName: "John Doe",
      accountNumber: "0987654321",
      bankName: "Bank of America",
    ),
  ].obs;

  final List<BankAccount> availableBankAccounts = [
    BankAccount(
      id: "1",
      accountName: "John Doe",
      accountNumber: "1234567890",
      bankName: "Chase Bank",
    ),
    BankAccount(
      id: "2",
      accountName: "John Doe",
      accountNumber: "0987654321",
      bankName: "Bank of America",
    ),
  ];

  @override
  void onClose() {
    // Dispose controllers when the controller is closed
    cardNumberController.dispose();
    cardHolderNameController.dispose();
    expirationDateController.dispose();
    cvvController.dispose();
    accountHolderNameController.dispose();
    ifscCodeController.dispose();
    accountNumberController.dispose();
    confirmAccountNumberController.dispose();
    super.onClose();
  }

  // Change selected account
  void setSelectedAccount(int index) {
    if (index >= 0 && index < bankAccounts.length) {
      selectedAccountIndex.value = index;
    }
  }

  // Get masked account number (e.g. **** **** **** 1234)
  String getMaskedAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;

    String lastFour = accountNumber.substring(accountNumber.length - 4);
    return "**** **** **** $lastFour";
  }

  // Validate card number
  String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter card number';
    }
    // Remove spaces and validate length
    String cleanNumber = value.replaceAll(' ', '');
    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
      return 'Please enter a valid card number';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanNumber)) {
      return 'Card number should contain only digits';
    }
    return null;
  }

  // Validate card holder name
  String? validateCardHolderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter card holder name';
    }
    if (value.length < 2) {
      return 'Name should be at least 2 characters';
    }
    return null;
  }

  // Validate expiration date
  String? validateExpirationDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter expiration date';
    }
    if (!RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$').hasMatch(value)) {
      return 'Please enter date in MM/YY format';
    }

    List<String> parts = value.split('/');
    int month = int.parse(parts[0]);
    int year = 2000 + int.parse(parts[1]);
    DateTime expiry = DateTime(year, month);
    DateTime now = DateTime.now();

    if (expiry.isBefore(DateTime(now.year, now.month))) {
      return 'Card has expired';
    }

    return null;
  }

  // Validate CVV
  String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter CVV';
    }
    if (!RegExp(r'^[0-9]{3,4}$').hasMatch(value)) {
      return 'CVV should be 3 or 4 digits';
    }
    return null;
  }

  // Format card number with spaces
  String formatCardNumber(String value) {
    String cleaned = value.replaceAll(' ', '');
    String formatted = '';
    for (int i = 0; i < cleaned.length; i += 4) {
      if (i + 4 <= cleaned.length) {
        formatted += cleaned.substring(i, i + 4) + ' ';
      } else {
        formatted += cleaned.substring(i);
      }
    }
    return formatted.trim();
  }

  // Format expiration date
  String formatExpirationDate(String value) {
    String cleaned = value.replaceAll('/', '');
    if (cleaned.length >= 2) {
      return cleaned.substring(0, 2) +
          '/' +
          cleaned.substring(2, cleaned.length > 4 ? 4 : cleaned.length);
    }
    return cleaned;
  }

  // Get card type based on card number
  CardType getCardType(String number) {
    String cleaned = number.replaceAll(RegExp(r'[^\d]'), '');

    if (cleaned.isEmpty) return CardType.unknown;

    // Visa: starts with 4
    if (cleaned.startsWith('4')) return CardType.visa;

    // MasterCard: starts with 5 or 2221-2720
    if (cleaned.startsWith('5') ||
        (cleaned.length >= 4 &&
            int.tryParse(cleaned.substring(0, 4)) != null &&
            int.parse(cleaned.substring(0, 4)) >= 2221 &&
            int.parse(cleaned.substring(0, 4)) <= 2720)) {
      return CardType.mastercard;
    }

    // American Express: starts with 34 or 37
    if (cleaned.startsWith('34') || cleaned.startsWith('37')) {
      return CardType.amex;
    }

    // Discover: starts with 6011 or 65
    if (cleaned.startsWith('6011') || cleaned.startsWith('65')) {
      return CardType.discover;
    }

    return CardType.unknown;
  }

  // Get card type icon path
  String getCardTypeIconPath(String cardNumber) {
    CardType type = getCardType(cardNumber);

    switch (type) {
      case CardType.mastercard:
        return Assets.masterCardLogo;
      case CardType.visa:
        // You can add visa icon path when you have the asset
        return Assets.masterCardLogo; // fallback to mastercard for now
      case CardType.amex:
        // You can add amex icon path when you have the asset
        return Assets.masterCardLogo; // fallback to mastercard for now
      default:
        return Assets.masterCardLogo; // default fallback
    }
  }

  // Validate account holder name
  String? validateAccountHolderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter account holder name';
    }
    return null;
  }

  // Validate IFSC code
  String? validateIFSC(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter IFSC code';
    }
    // IFSC code format validation (typically 11 characters: 4 letters + 7 alphanumeric)
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value)) {
      return 'Please enter a valid IFSC code';
    }
    return null;
  }

  // Validate account number
  String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter account number';
    }
    // Account numbers are usually between 8-17 digits
    if (value.length < 8 || value.length > 17) {
      return 'Account number should be 8-17 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Account number should contain only digits';
    }
    return null;
  }

  // Validate confirm account number
  String? validateConfirmAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm account number';
    }
    if (value != accountNumberController.text) {
      return 'Account numbers do not match';
    }
    return null;
  }

  // Validate bank selection
  String? validateBankSelection(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a bank';
    }
    return null;
  }

  // Save account info
  void saveAccountInfo() {
    if (formKey.currentState?.validate() ?? false) {
      // In a real app, you would save the credit card data to your backend/database
      // CreditCard data would be:
      // - cardNumber: cardNumberController.text
      // - cardHolderName: cardHolderNameController.text
      // - expirationDate: expirationDateController.text
      // - cvv: cvvController.text
      // - isDefault: consentValue.value

      // Clear form
      cardNumberController.clear();
      cardHolderNameController.clear();
      expirationDateController.clear();
      cvvController.clear();
      consentValue.value = false;

      Get.back(); // Go back to account info screen
      SnackbarUtils.showSuccess('Credit card added successfully');
    }
  }

  // Add a new bank account (for button in account list)
  void addNewBankAccount() {
    Get.toNamed('/add-new-account-screen');
  }

  // Check if at least one bank account exists
  bool hasAtLeastOneAccount() {
    return bankAccounts.isNotEmpty;
  }
}

// Model class to represent a bank account
class BankAccount {
  final String id;
  final String accountName;
  final String accountNumber;
  final String bankName;

  BankAccount({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
  });
}

// Model class to represent a credit card
class CreditCard {
  final String id;
  final String cardNumber;
  final String cardHolderName;
  final String expirationDate;
  final String cvv;
  final bool isDefault;

  CreditCard({
    required this.id,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expirationDate,
    required this.cvv,
    required this.isDefault,
  });
}

// Enum for card types
enum CardType {
  visa,
  mastercard,
  amex,
  discover,
  unknown,
}
