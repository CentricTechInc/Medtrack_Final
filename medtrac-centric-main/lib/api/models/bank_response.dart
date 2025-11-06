class BankListResponse {
  final bool status;
  final String message;
  final List<BankAccountData> data;

  BankListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BankListResponse.fromJson(Map<String, dynamic> json) {
    return BankListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => BankAccountData.fromJson(item))
          .toList() ?? [],
    );
  }
}

class BankAccountData {
  final int id;
  final String accountHolderName;
  final String bankName;
  final String ifscCode;
  final String accountNumber;
  final bool confirmConsent;
  final int userId;
  final bool isCurrent;

  BankAccountData({
    required this.id,
    required this.accountHolderName,
    required this.bankName,
    required this.ifscCode,
    required this.accountNumber,
    required this.confirmConsent,
    required this.userId,
    required this.isCurrent,
  });

  factory BankAccountData.fromJson(Map<String, dynamic> json) {
    return BankAccountData(
      id: json['id'] ?? 0,
      accountHolderName: json['account_holder_name'] ?? '',
      bankName: json['bank_name'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      accountNumber: json['account_number'] ?? '',
      confirmConsent: json['confirm_consent'] ?? false,
      userId: json['UserId'] ?? 0,
      isCurrent: json['isCurrent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'ifsc_code': ifscCode,
      'account_number': accountNumber,
      'confirm_consent': confirmConsent,
      'UserId': userId,
      'isCurrent': isCurrent,
    };
  }

  // Helper method to get masked account number
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    String lastFour = accountNumber.substring(accountNumber.length - 4);
    return "**** **** **** $lastFour";
  }

  // Helper method to format IFSC with spaces for display
  String get formattedIfscCode {
    if (ifscCode.length == 11) {
      return "${ifscCode.substring(0, 4)} ${ifscCode.substring(4, 5)} ${ifscCode.substring(5)}";
    }
    return ifscCode;
  }
}
