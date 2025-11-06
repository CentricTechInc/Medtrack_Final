import 'package:flutter/material.dart';
import 'package:medtrac/services/notification_service.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'FCM Token',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _notificationService.isTokenAvailable ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _notificationService.isTokenAvailable ? 'Available' : 'Pending',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _notificationService.fcmToken ?? 'Token not available yet (iOS APNS pending)',
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                    if (!_notificationService.isTokenAvailable) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _notificationService.refreshFCMToken();
                            setState(() {}); // Refresh UI
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Refresh Token'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _notificationService.showLocalNotification(
                  id: 1,
                  title: 'Test Notification',
                  body: 'This is a test notification from MedTrac app!',
                  payload: '{"test": true, "screen": "home", "id": 123, "type": "appointment"}',
                );
              },
              child: const Text('Show Local Notification'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await _notificationService.showLocalNotification(
                  id: 2,
                  title: 'Test with Rich Payload',
                  body: 'Tap to see payload in console!',
                  payload: '{"user_id": 456, "appointment_id": 789, "doctor_name": "Dr. Smith", "type": "reminder", "action": "view_details", "timestamp": "${DateTime.now().toIso8601String()}"}',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('📋 Test Rich Payload'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await _notificationService.testNotificationSystem();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Check console logs for test results'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('🧪 Run Full System Test'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final future = DateTime.now().add(const Duration(seconds: 10));
                await _notificationService.scheduleNotification(
                  id: 2,
                  title: 'Scheduled Notification',
                  body: 'This notification was scheduled 10 seconds ago!',
                  scheduledTime: future,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification scheduled for 10 seconds from now'),
                  ),
                );
              },
              child: const Text('Schedule Notification (10s)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await _notificationService.cancelAllNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications cancelled'),
                  ),
                );
              },
              child: const Text('Cancel All Notifications'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final pending = await _notificationService.getPendingNotifications();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pending Notifications'),
                    content: Text('Count: ${pending.length}'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Check Pending Notifications'),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to test push notifications:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('1. Wait for FCM token to be generated (iOS may take a moment)'),
                    Text('2. Copy the FCM token from above'),
                    Text('3. Go to Firebase Console > Cloud Messaging'),
                    Text('4. Create a new campaign or send a test message'),
                    Text('5. Paste the FCM token in the target field'),
                    Text('6. Send the notification'),
                    SizedBox(height: 8),
                    Text(
                      'Note: On iOS, the FCM token depends on APNS token availability. If token shows as "Pending", tap the refresh button or wait a moment.',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}