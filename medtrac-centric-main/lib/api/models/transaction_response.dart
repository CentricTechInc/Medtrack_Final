class TransactionResponse {
  final bool status;
  final String message;
  final TransactionData? data;

  TransactionResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? TransactionData.fromJson(json['data']) : null,
    );
  }
}

class TransactionData {
  final String totalEarning;
  final String withdrawal;
  final String balance;
  final List<MonthlyRecord> record;
  final List<TransactionHistory> history;

  TransactionData({
    required this.totalEarning,
    required this.withdrawal,
    required this.balance,
    required this.record,
    required this.history,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      totalEarning: json['total_earning'] ?? '0.00',
      withdrawal: json['withdrawal'] ?? '0.00',
      balance: json['balance'] ?? '0.00',
      record: (json['record'] as List<dynamic>?)
          ?.map((item) => MonthlyRecord.fromJson(item))
          .toList() ?? [],
      history: (json['history'] as List<dynamic>?)
          ?.map((item) => TransactionHistory.fromJson(item))
          .toList() ?? [],
    );
  }
}

class MonthlyRecord {
  final String monthName;
  final String total;

  MonthlyRecord({
    required this.monthName,
    required this.total,
  });

  factory MonthlyRecord.fromJson(Map<String, dynamic> json) {
    return MonthlyRecord(
      monthName: json['month_name'] ?? '',
      total: json['total'] ?? '0',
    );
  }
}

class TransactionHistory {
  final String createdAt;
  final String amount;
  final DoctorBankDetail? doctorBankDetail;

  TransactionHistory({
    required this.createdAt,
    required this.amount,
    this.doctorBankDetail,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    return TransactionHistory(
      createdAt: json['createdAt'] ?? '',
      amount: json['amount'] ?? '0.00',
      doctorBankDetail: json['DoctorBankDetail'] != null 
          ? DoctorBankDetail.fromJson(json['DoctorBankDetail'])
          : null,
    );
  }
}

class DoctorBankDetail {
  final String bankName;
  final int id;

  DoctorBankDetail({
    required this.bankName,
    required this.id,
  });

  factory DoctorBankDetail.fromJson(Map<String, dynamic> json) {
    return DoctorBankDetail(
      bankName: json['bank_name'] ?? '',
      id: json['id'] ?? 0,
    );
  }
}
