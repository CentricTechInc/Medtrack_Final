import 'package:dio/dio.dart';
import '../models/api_response.dart';
import '../models/bank_response.dart';
import '../http_client.dart';

class BankService {
  static final BankService _instance = BankService._internal();
  factory BankService() => _instance;
  BankService._internal();

  final HttpClient _http = HttpClient();

  /// Add a new bank account
  Future<ApiResponse<Map<String, dynamic>>> addBankAccount({
    required String accountHolderName,
    required String bankName,
    required String ifscCode,
    required String accountNumber,
    required bool confirmConsent,
  }) async {
    try {
      final data = {
        'account_holder_name': accountHolderName,
        'bank_name': bankName,
        'ifsc_code': ifscCode,
        'account_number': accountNumber,
        'confirm_consent': confirmConsent.toString(),
      };

      final response = await _http.post('bank', data: data);
      
      return ApiResponse<Map<String, dynamic>>(
        success: response.data['status'] ?? false,
        message: response.data['message'] ?? (response.data['errors'] as List)[0] ?? '',
        data: response.data,
      );
    } on DioException catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to add bank account',
        data: null,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Get user's bank accounts
  Future<ApiResponse<BankListResponse>> getBankAccounts() async {
    try {
      final response = await _http.get('bank/listing');
      
      final bankListResponse = BankListResponse.fromJson(response.data);
      
      return ApiResponse<BankListResponse>(
        success: bankListResponse.status,
        message: bankListResponse.message,
        data: bankListResponse,
      );
    } on DioException catch (e) {
      return ApiResponse<BankListResponse>(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to retrieve bank accounts',
        data: null,
      );
    } catch (e) {
      return ApiResponse<BankListResponse>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        data: null,
      );
    }
  }

  /// Mark a bank account as current
  Future<ApiResponse<Map<String, dynamic>>> markAccountAsCurrent(int bankAccountId) async {
    try {
      final response = await _http.patch('bank/mark-current/$bankAccountId');
      
      return ApiResponse<Map<String, dynamic>>(
        success: true,
        message: response.data['message'] ?? 'Bank details updated',
        data: response.data,
      );
    } on DioException catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: e.response?.data['message'] ?? 'Failed to mark account as current',
        data: null,
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        data: null,
      );
    }
  }
}
