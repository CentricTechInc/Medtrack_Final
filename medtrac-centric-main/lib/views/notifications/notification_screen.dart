import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:medtrac/controllers/notification_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_notification_count_badge.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/views/notifications/widgets/notification_tile.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final NotificationController controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          Obx(() => NotificationCountBadge(
            text: controller.newNotificationsCount,
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.notifications.isEmpty) {
          return const Center(
            child: Text('No notifications found'),
          );
        }

        final groupedNotifications = controller.groupedNotifications;

        return SmartRefresher(
          controller: controller.refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: controller.onRefresh,
          onLoading: controller.onLoading,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _getTotalItemCount(groupedNotifications),
            itemBuilder: (context, index) {
              return _buildItem(context, index, groupedNotifications);
            },
          ),
        );
      }),
    );
  }

  int _getTotalItemCount(Map<String, List<dynamic>> groupedNotifications) {
    int count = 0;
    for (final entry in groupedNotifications.entries) {
      count += 1; // Section header
      count += entry.value.length; // Notifications in section
    }
    return count;
  }

  Widget _buildItem(BuildContext context, int index, Map<String, List<dynamic>> groupedNotifications) {
    int currentIndex = 0;
    
    for (final entry in groupedNotifications.entries) {
      final sectionTitle = entry.key;
      final notifications = entry.value;
      
      // Check if this index is the section header
      if (currentIndex == index) {
        return _buildSectionHeader(sectionTitle);
      }
      currentIndex++;
      
      // Check if this index is within the notifications for this section
      if (index < currentIndex + notifications.length) {
        final notificationIndex = index - currentIndex;
        final notification = notifications[notificationIndex];
        return NotificationTile(
          iconPath: notification.iconPath,
          title: notification.subject,
          body: notification.message,
          timeAgo: notification.timeAgo,
          isRead: notification.isRead,
          onTap: () => controller.onNotificationTap(notification),
        );
      }
      currentIndex += notifications.length;
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 24.h, bottom: 8.h),
      child: BodyTextTwo(
        text: title.toUpperCase(),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
