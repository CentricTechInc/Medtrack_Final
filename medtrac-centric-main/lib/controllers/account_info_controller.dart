import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/utils/snackbar.dart';
import '../api/services/bank_service.dart';
import '../api/models/api_response.dart';
import '../api/models/bank_response.dart';
import '../utils/helper_functions.dart';

class AccountInfoController extends GetxController {
  final BankService _bankService = BankService();
  
  // Selected bank account index
  RxInt selectedAccountIndex = 0.obs;
  RxString selectedBank = "".obs;
  RxBool consentValue = false.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingAccounts = false.obs;
  RxBool isMarkingCurrent = false.obs;

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Text editing controllers for form fields
  final TextEditingController accountHolderNameController =
      TextEditingController();
  final TextEditingController ifscCodeController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController confirmAccountNumberController =
      TextEditingController();

  // API bank accounts data
  final RxList<BankAccountData> apiBankAccounts = <BankAccountData>[].obs;
  final List<String> availableBanks = <String>[
    "State Bank of India",
    "HDFC Bank",
    "ICICI Bank",
    "Axis Bank",
    "Kotak Mahindra Bank",
    "Punjab National Bank",
    "Bank of Baroda",
    "Canara Bank",
    "Union Bank of India",
    "IndusInd Bank",
    "Yes Bank",
    "IDFC First Bank",
    "RBL Bank",
    "Federal Bank",
    "City Union Bank",
    "Tamilnad Mercantile Bank",
  ].obs;
  RxBool showConsentError = false.obs;

  @override
  void onClose() {
    // Dispose controllers when the controller is closed
    accountHolderNameController.dispose();
    ifscCodeController.dispose();
    accountNumberController.dispose();
    confirmAccountNumberController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    loadBankAccounts(); // Load bank accounts when controller initializes
  }

  /// Load bank accounts from API
  Future<void> loadBankAccounts() async {
    isLoadingAccounts.value = true;
    
    try {
      final response = await _bankService.getBankAccounts();
      
      if (response.success && response.data != null) {
        apiBankAccounts.clear();
        apiBankAccounts.addAll(response.data!.data);
      } else {
        SnackbarUtils.showError(
          response.message ?? 'Failed to load bank accounts',
          title: 'Error'
        );
      }
    } catch (e) {
      SnackbarUtils.showError(
        'Failed to load bank accounts: ${e.toString()}',
        title: 'Error'
      );
    } finally {
      isLoadingAccounts.value = false;
    }
  }

  /// Mark a bank account as current
  Future<ApiResponse<Map<String, dynamic>>> markAccountAsCurrent(int bankAccountId, BuildContext context) async {
    isMarkingCurrent.value = true;
    
    // Show loading dialog
    HelperFunctions.showIndismissableLoader(context);
    
    try {
      final response = await _bankService.markAccountAsCurrent(bankAccountId);

      // Close loading dialog
      Get.back();

      if (response.success) {
        // Reload bank accounts to get updated isCurrent status
        await loadBankAccounts();
      }

      return response;
    } catch (e) {
      // Close loading dialog
      Get.back();

      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Failed to mark account as current: ${e.toString()}',
        data: null,
      );
    } finally {
      isMarkingCurrent.value = false;
    }
  }

  // Change selected account
  void setSelectedAccount(int index) {
    if (index >= 0 && index < apiBankAccounts.length) {
      selectedAccountIndex.value = index;
    }
  }

  // Get currently selected account
  BankAccountData? getSelectedAccount() {
    if (selectedAccountIndex.value >= 0 && selectedAccountIndex.value < apiBankAccounts.length) {
      return apiBankAccounts[selectedAccountIndex.value];
    }
    return null;
  }

  // Get selected account ID for API calls
  int? getSelectedAccountId() {
    final selectedAccount = getSelectedAccount();
    return selectedAccount?.id;
  }

  // Get masked account number (e.g. **** **** **** 1234)
  String getMaskedAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;

    String lastFour = accountNumber.substring(accountNumber.length - 4);
    return "**** **** **** $lastFour";
  }

  // Validate account holder name
  String? validateAccountHolderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter account holder name';
    }
    if (value.length < 2) {
      return 'Account holder name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Account holder name must not exceed 50 characters';
    }
    // Check for valid name format (letters, spaces, dots, apostrophes)
    if (!RegExp(r"^[a-zA-Z\s.']+$").hasMatch(value)) {
      return 'Please enter a valid name (letters, spaces, dots, apostrophes only)';
    }
    return null;
  }

  // Validate IFSC code
  String? validateIFSC(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter IFSC code';
    }
    // Convert to uppercase for validation
    value = value.toUpperCase();
    
    // IFSC code format validation (11 characters: 4 letters + 1 zero + 6 alphanumeric)
    if (value.length != 11) {
      return 'IFSC code must be exactly 11 characters';
    }
    
    // Check first 4 characters are letters
    if (!RegExp(r'^[A-Z]{4}').hasMatch(value.substring(0, 4))) {
      return 'First 4 characters must be letters (bank code)';
    }
    
    // Check 5th character is zero (not letter O)
    if (value[4] != '0') {
      return 'The 5th character must be zero (0), not letter O';
    }
    
    // Check last 6 characters are alphanumeric
    if (!RegExp(r'^[A-Z0-9]{6}$').hasMatch(value.substring(5))) {
      return 'Last 6 characters must be letters or numbers';
    }
    
    return null;
  }

  // Validate account number
  String? validateAccountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter account number';
    }
    // Remove any spaces or hyphens
    value = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Account numbers are usually between 8-18 digits
    if (value.length < 8) {
      return 'Account number must be at least 8 digits';
    }
    if (value.length > 18) {
      return 'Account number must not exceed 18 digits';
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
    // Remove any spaces or hyphens from both values for comparison
    String accountNumber = accountNumberController.text.replaceAll(RegExp(r'[\s-]'), '');
    String confirmAccountNumber = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (confirmAccountNumber != accountNumber) {
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

  // Validate consent
  String? validateConsent() {
    if (!consentValue.value) {
      return 'Please accept the consent to proceed';
    }
    return null;
  }

  // Save account info
  Future<void> saveAccountInfo() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!consentValue.value) {
      showConsentError.value = true;
      SnackbarUtils.showError('Please accept the consent to proceed');
      return;
    }

    showConsentError.value = false;
    isLoading.value = true;

    try {
      final response = await _bankService.addBankAccount(
        accountHolderName: accountHolderNameController.text.trim(),
        bankName: selectedBank.value,
        ifscCode: ifscCodeController.text.trim().toUpperCase(),
        accountNumber: accountNumberController.text.replaceAll(RegExp(r'[\s-]'), ''),
        confirmConsent: consentValue.value,
      );

      if (response.success) {
        // Reload bank accounts to get the newly added account
        await loadBankAccounts();

        // Clear form
        _clearForm();

        Get.back(); // Go back to account info screen
        SnackbarUtils.showSuccess(response.message ?? 'Bank account added successfully');
      } else {
        SnackbarUtils.showError(response.message ?? 'Failed to add bank account');
      }
    } catch (e) {
      SnackbarUtils.showError('An unexpected error occurred: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Clear form helper method
  void _clearForm() {
    accountHolderNameController.clear();
    ifscCodeController.clear();
    accountNumberController.clear();
    confirmAccountNumberController.clear();
    selectedBank.value = "";
    consentValue.value = false;
    showConsentError.value = false;
  }

  // Add a new bank account (for button in account list)
  void addNewBankAccount() {
    Get.toNamed('/add-new-account-screen');
  }

  // Check if at least one bank account exists
  bool hasAtLeastOneAccount() {
    return apiBankAccounts.isNotEmpty;
  }
}
