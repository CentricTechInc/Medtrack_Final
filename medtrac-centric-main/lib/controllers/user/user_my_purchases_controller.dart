import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/api/services/patient_service.dart';
import 'package:medtrac/api/models/my_purchases_response.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserMyPurchasesController extends GetxController {
  final PatientService _patientService = PatientService();

  final searchController = Rxn<TextEditingController>();
  final searchQuery = ''.obs;

  final isLoading = false.obs;
  final totalAppointments = 0.obs;
  final totalSpending = 0.0.obs;
  final appointments = <PurchaseAppointmentItem>[].obs;

  // Pagination
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final RefreshController refreshController = RefreshController();

  // Debouncing
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    searchController.value = TextEditingController();
    searchController.value!.addListener(_onSearchChanged);
    fetchMyPurchases(isRefresh: true);
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = searchController.value!.text;
      // Reset and fetch with new search query
      fetchMyPurchases(isRefresh: true);
    });
  }

  Future<void> fetchMyPurchases({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
        appointments.clear();
        isLoading.value = true;
      }

      final response = await _patientService.getMyPurchases(
        pageNumber: currentPage.value,
        searchQuery: searchQuery.value.isEmpty ? null : searchQuery.value,
      );

      if (response.status && response.data != null) {
        totalAppointments.value = response.data!.totalAppointments;
        totalSpending.value = response.data!.totalSpending;

        if (isRefresh) {
          appointments.value = response.data!.appointments;
        } else {
          appointments.addAll(response.data!.appointments);
        }

        // If no appointments returned or less than expected, it's the last page
        if (response.data!.appointments.isEmpty) {
          hasMoreData.value = false;
        }
      }

      if (isRefresh) {
        refreshController.refreshCompleted();
      } else {
        refreshController.loadComplete();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch purchases data',
        snackPosition: SnackPosition.BOTTOM,
      );

      if (isRefresh) {
        refreshController.refreshFailed();
      } else {
        refreshController.loadFailed();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onRefresh() {
    fetchMyPurchases(isRefresh: true);
  }

  void onLoadMore() {
    if (!hasMoreData.value) {
      refreshController.loadNoData();
      return;
    }

    currentPage.value++;
    fetchMyPurchases(isRefresh: false);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.value?.dispose();
    refreshController.dispose();
    super.onClose();
  }
}
