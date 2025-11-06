import 'package:get/get.dart';
import 'package:medtrac/api/services/doctor_service.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../api/models/doctor_response.dart';
import '../utils/snackbar.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';

class ConsultantTabViewController extends GetxController {
  final DoctorService _doctorService = DoctorService();
  Worker? _bottomNavWorker;

  // Observable variables
  var isLoading = false.obs;
  var doctors = <Doctor>[].obs;
  var filteredDoctors = <Doctor>[].obs;
  var currentPage = 1.obs;
  var hasMoreData = true.obs;

  // Filter options
  final List<String> specialtyTabs = [
    'All',
    'Psychiatrist',
    'Psychologist',
    'Therapist'
  ];
  final RxInt selectedTabIndex = 0.obs;
  final RxString selectedSpecialty = 'All'.obs;
  final RxBool emergencyServicesOnly = false.obs; // Changed default to false
  final RxString searchQuery = ''.obs;

  @override
  onInit() {
    super.onInit();
    
    // Listen to bottom navigation changes to reset search when consultant tab becomes active
    try {
      final bottomNavController = Get.find<BottomNavigationController>();
      _bottomNavWorker = ever(bottomNavController.selectedNavIndex, (navIndex) {
        // Index 2 is consultant tab for users (check based on your app structure)
        // For users, consultant tab is typically index 2
        if (navIndex == 2) {
          print('📋 Consultant tab activated - Resetting search state');
          resetSearchState();
        }
      });
    } catch (e) {
      print('⚠️ BottomNavigationController not found: $e');
    }
    
    loadDoctors();
  }

  /// Reset search state to default (show all doctors)
  void resetSearchState() {
    searchQuery.value = '';
    selectedSpecialty.value = 'All';
    selectedTabIndex.value = 0;
    emergencyServicesOnly.value = false;
    // Reload doctors with cleared filters
    loadDoctors();
  }

  /// Load doctors (initial load)
  Future<void> loadDoctors() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    currentPage.value = 1;
    
    try {
      final response = await _doctorService.getDoctorsList(
        pageNumber: currentPage.value,
        speciality: selectedSpecialty.value == 'All' ? null : selectedSpecialty.value,
        isEmergencyFees: emergencyServicesOnly.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (response.success && response.data != null) {
        doctors.clear();
        doctors.addAll(response.data!.data);
        filteredDoctors.assignAll(response.data!.data); // Direct assignment since filtering is done server-side
        hasMoreData.value = response.data!.data.isNotEmpty;
      } else {
        SnackbarUtils.showError(
          response.message ?? 'Failed to load doctors',
          title: 'Error'
        );
      }
    } catch (e) {
      SnackbarUtils.showError(
        'Failed to load doctors: ${e.toString()}',
        title: 'Error'
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh doctors (pull to refresh)
  Future<void> onRefresh(RefreshController refreshController) async {
    currentPage.value = 1;
    hasMoreData.value = true;
    
    try {
      final response = await _doctorService.getDoctorsList(
        pageNumber: currentPage.value,
        speciality: selectedSpecialty.value == 'All' ? null : selectedSpecialty.value,
        isEmergencyFees: emergencyServicesOnly.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (response.success && response.data != null) {
        doctors.clear();
        doctors.addAll(response.data!.data);
        filteredDoctors.assignAll(response.data!.data);
        hasMoreData.value = response.data!.data.isNotEmpty;
        refreshController.refreshCompleted();
      } else {
        refreshController.refreshFailed();
        SnackbarUtils.showError(
          response.message ?? 'Failed to refresh doctors',
          title: 'Error'
        );
      }
    } catch (e) {
      refreshController.refreshFailed();
      SnackbarUtils.showError(
        'Failed to refresh doctors: ${e.toString()}',
        title: 'Error'
      );
    }
  }

  /// Load more doctors (pagination)
  Future<void> onLoading(RefreshController refreshController) async {
    if (!hasMoreData.value) {
      refreshController.loadComplete();
      return;
    }

    currentPage.value++;
    
    try {
      final response = await _doctorService.getDoctorsList(
        pageNumber: currentPage.value,
        speciality: selectedSpecialty.value == 'All' ? null : selectedSpecialty.value,
        isEmergencyFees: emergencyServicesOnly.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (response.success && response.data != null) {
        final newDoctors = response.data!.data;
        
        if (newDoctors.isEmpty) {
          // No more data
          hasMoreData.value = false;
          refreshController.loadNoData();
        } else {
          doctors.addAll(newDoctors);
          filteredDoctors.addAll(newDoctors);
          refreshController.loadComplete();
        }
      } else {
        currentPage.value--; // Revert page increment
        refreshController.loadFailed();
        SnackbarUtils.showError(
          response.message ?? 'Failed to load more doctors',
          title: 'Error'
        );
      }
    } catch (e) {
      currentPage.value--; // Revert page increment
      refreshController.loadFailed();
      SnackbarUtils.showError(
        'Failed to load more doctors: ${e.toString()}',
        title: 'Error'
      );
    }
  }

  void searchAppointments(String query) {
    searchQuery.value = query;
    loadDoctors(); // Reload with new search query
  }

  void selectSpecialty(String specialty) {
    selectedSpecialty.value = specialty;
    selectedTabIndex.value = specialtyTabs.indexOf(specialty);
    loadDoctors(); // Reload with new specialty filter
  }

  void onTabChanged(String tab) {
    selectedSpecialty.value = tab;
    selectedTabIndex.value = specialtyTabs.indexOf(tab);
    loadDoctors(); // Reload with new specialty filter
  }

  void toggleEmergencyServices(bool value) {
    emergencyServicesOnly.value = value;
    loadDoctors(); // Reload with new emergency filter
  }

  @override
  void onClose() {
    _bottomNavWorker?.dispose();
    super.onClose();
  }
}
