import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../api/services/notification_service.dart';
import '../api/models/notification_response.dart';
import '../utils/snackbar.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  
  // Observable variables
  var isLoading = false.obs;
  var notifications = <NotificationItem>[].obs;
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  var totalCount = 0.obs;
  var unReadCount = 0.obs;

  // Use API unread count if available, else fallback to computed
  int get newNotificationsCount => unReadCount.value;

  // Group notifications by date sections
  Map<String, List<NotificationItem>> get groupedNotifications {
    final Map<String, List<NotificationItem>> grouped = {};
    
    for (final notification in notifications) {
      final section = notification.dateSection;
      if (!grouped.containsKey(section)) {
        grouped[section] = [];
      }
      grouped[section]!.add(notification);
    }
    
    // Sort sections by priority (Today, Yesterday, then by date descending)
    final sortedKeys = grouped.keys.toList()..sort((a, b) {
      if (a == 'TODAY') return -1;
      if (b == 'TODAY') return 1;
      if (a == 'YESTERDAY') return -1;
      if (b == 'YESTERDAY') return 1;
      // For other dates, sort by most recent first
      return b.compareTo(a);
    });
    
    final Map<String, List<NotificationItem>> sortedGrouped = {};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }
    
    return sortedGrouped;
  }

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    markAllAsRead(); // Mark all notifications as read when screen opens
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  /// Load notifications (initial load)
  Future<void> loadNotifications() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    currentPage.value = 1;
    
    try {
      final response = await _notificationService.getNotifications(
        pageNumber: currentPage.value,
      );

      if (response.success && response.data != null) {
        final wrapper = response.data!.data;
        unReadCount.value = wrapper?.unReadCount ?? 0;
        final notifData = wrapper?.data;
        notifications.clear();
        notifications.addAll(notifData?.rows ?? []);
        totalCount.value = notifData?.count ?? 0;
        // Check if there's more data
        hasMoreData.value = notifications.length < totalCount.value;
      } else {
        SnackbarUtils.showError(
          response.message ?? 'Failed to load notifications',
          title: 'Error'
        );
      }
    } catch (e) {
      SnackbarUtils.showError(
        'Failed to load notifications: ${e.toString()}',
        title: 'Error'
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh notifications (pull to refresh)
  Future<void> onRefresh() async {
    currentPage.value = 1;
    hasMoreData.value = true;
    
    try {
      final response = await _notificationService.getNotifications(
        pageNumber: currentPage.value,
      );

      if (response.success && response.data != null) {
        final wrapper = response.data!.data;
        unReadCount.value = wrapper?.unReadCount ?? 0;
        final notifData = wrapper?.data;
        notifications.clear();
        notifications.addAll(notifData?.rows ?? []);
        totalCount.value = notifData?.count ?? 0;
        hasMoreData.value = notifications.length < totalCount.value;
        refreshController.refreshCompleted();
      } else {
        refreshController.refreshFailed();
        SnackbarUtils.showError(
          response.message ?? 'Failed to refresh notifications',
          title: 'Error'
        );
      }
    } catch (e) {
      refreshController.refreshFailed();
      SnackbarUtils.showError(
        'Failed to refresh notifications: ${e.toString()}',
        title: 'Error'
      );
    }
  }

  /// Load more notifications (pagination)
  Future<void> onLoading() async {
    if (!hasMoreData.value) {
      refreshController.loadComplete();
      return;
    }

    currentPage.value++;
    
    try {
      final response = await _notificationService.getNotifications(
        pageNumber: currentPage.value,
      );

      if (response.success && response.data != null) {
        final wrapper = response.data!.data;
        unReadCount.value = wrapper?.unReadCount ?? 0;
        final notifData = wrapper?.data;
        final newNotifications = notifData?.rows ?? [];
        if (newNotifications.isEmpty) {
          // No more data
          hasMoreData.value = false;
          refreshController.loadNoData();
        } else {
          notifications.addAll(newNotifications);
          hasMoreData.value = notifications.length < totalCount.value;
          refreshController.loadComplete();
        }
      } else {
        currentPage.value--; // Revert page increment
        refreshController.loadFailed();
        SnackbarUtils.showError(
          response.message ?? 'Failed to load more notifications',
          title: 'Error'
        );
      }
    } catch (e) {
      currentPage.value--; // Revert page increment
      refreshController.loadFailed();
      SnackbarUtils.showError(
        'Failed to load more notifications: ${e.toString()}',
        title: 'Error'
      );
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final response = await _notificationService.markAllAsRead();
      
      if (response.success) {
        // Update local notification state - mark all as read
        for (int i = 0; i < notifications.length; i++) {
          final originalNotification = notifications[i];
          final updatedNotification = NotificationItem(
            id: originalNotification.id,
            subject: originalNotification.subject,
            message: originalNotification.message,
            modelType: originalNotification.modelType,
            modelId: originalNotification.modelId,
            notifiedTo: originalNotification.notifiedTo,
            isRead: true, // Mark as read
            createdAt: originalNotification.createdAt,
          );
          notifications[i] = updatedNotification;
        }
      }
    } catch (e) {
      SnackbarUtils.showError(
        'Failed to mark all notifications as read: ${e.toString()}',
        title: 'Error'
      );
    }
  }

  /// Handle notification tap
  void onNotificationTap(NotificationItem notification) {
    // Since all notifications are marked as read when screen opens,
    // we don't need to mark individual notifications as read
    
    // Navigate based on notification type
    switch (notification.modelType.toLowerCase()) {
      case 'appointment':
        // Navigate to appointment details
        // Get.toNamed('/appointment-details', arguments: notification.modelId);
        break;
      case 'ticket':
        // Navigate to ticket details
        // Get.toNamed('/ticket-details', arguments: notification.modelId);
        break;
    }
  }

  /// Legacy method for compatibility
  void notificationReceived() {
    // This method can be used when a new notification is received via push
    loadNotifications();
  }
}