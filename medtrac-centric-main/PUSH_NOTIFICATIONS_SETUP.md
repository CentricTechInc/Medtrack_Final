# Push Notifications Setup Guide for MedTrac

This guide explains how to configure and use Firebase Cloud Messaging (FCM) with Flutter Local Notifications in the MedTrac app.

## 📋 What's Already Configured

### Dependencies Added
- `firebase_messaging: ^16.0.2` - Firebase Cloud Messaging
- `flutter_local_notifications: ^18.0.1` - Local notifications
- `timezone: ^0.9.4` - For scheduled notifications

### Files Created/Modified
- ✅ `lib/services/notification_service.dart` - Main notification service
- ✅ `lib/main.dart` - Initialization code added
- ✅ `lib/controllers/auth_controllers/login_controller.dart` - Real FCM token integration
- ✅ `android/app/src/main/AndroidManifest.xml` - Android FCM configuration
- ✅ `lib/views/test/notification_test_screen.dart` - Test screen for notifications

## 🚀 Features Implemented

### NotificationService Features
- ✅ **FCM Token Management** - Automatic token generation and refresh
- ✅ **Permission Handling** - Request notification permissions for Android/iOS
- ✅ **Local Notifications** - Show notifications when app is in foreground
- ✅ **Background Notifications** - Handle notifications when app is backgrounded
- ✅ **Scheduled Notifications** - Schedule notifications for future delivery
- ✅ **Notification Tapping** - Handle user interactions with notifications
- ✅ **Token Updates** - Automatic server token updates (customizable)

### Login Integration
- ✅ **Real FCM Token** - Login API now uses actual FCM token instead of dummy
- ✅ **Token Logging** - FCM token is printed to console for debugging

## 🔧 Setup Instructions

### 1. Firebase Project Setup
Make sure your Firebase project has:
- ✅ Cloud Messaging API enabled
- ✅ `google-services.json` (Android) in `android/app/`
- ✅ `GoogleService-Info.plist` (iOS) in `ios/Runner/`

### 2. Android Configuration
The following is already configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<!-- Notification permission -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

<!-- FCM Service -->
<service
    android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
    android:exported="false">
    <intent-filter>
        <action android:name="com.google.firebase.MESSAGING_EVENT" />
    </intent-filter>
</service>
```

### 3. iOS Configuration (if needed)
For iOS, you may need to add to `ios/Runner/Info.plist`:
```xml
<!-- Add these keys if not present -->
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## 📱 Usage Examples

### Basic Notification
```dart
final notificationService = NotificationService();

// Show immediate notification
await notificationService.showLocalNotification(
  id: 1,
  title: 'New Appointment',
  body: 'You have an appointment with Dr. Smith at 3:00 PM',
);
```

### Scheduled Notification
```dart
// Schedule notification for appointment reminder
final appointmentTime = DateTime.now().add(Duration(hours: 24));
await notificationService.scheduleNotification(
  id: 2,
  title: 'Appointment Reminder',
  body: 'Your appointment is in 1 hour',
  scheduledTime: appointmentTime.subtract(Duration(hours: 1)),
);
```

### Get FCM Token
```dart
final notificationService = NotificationService();
String? fcmToken = notificationService.fcmToken;
print('FCM Token: $fcmToken');
```

## 🧪 Testing Notifications

### Option 1: Use the Test Screen
Navigate to the `NotificationTestScreen` to:
- View the current FCM token
- Test local notifications
- Test scheduled notifications
- Manage pending notifications

### Option 2: Firebase Console
1. Copy the FCM token from the app logs or test screen
2. Go to Firebase Console > Cloud Messaging
3. Click "Send your first message"
4. Enter title and message
5. In "Target" section, select "FCM registration token"
6. Paste the copied FCM token
7. Send the notification

### Option 3: Test via API/Postman
```bash
POST https://fcm.googleapis.com/fcm/send
Headers:
  Authorization: key=YOUR_SERVER_KEY
  Content-Type: application/json

Body:
{
  "to": "FCM_TOKEN_HERE",
  "notification": {
    "title": "Test Notification",
    "body": "Hello from MedTrac!"
  },
  "data": {
    "type": "test",
    "screen": "home"
  }
}
```

## 🔄 Notification Flow

### Foreground (App Active)
1. FCM receives notification
2. `FirebaseMessaging.onMessage` triggers
3. Converts to local notification
4. Shows notification banner

### Background (App Minimized)
1. FCM receives notification
2. Shows system notification
3. `FirebaseMessaging.onMessageOpenedApp` triggers when tapped

### Terminated (App Closed)
1. FCM receives notification
2. Shows system notification
3. `FirebaseMessaging.getInitialMessage()` gets notification when app opens

## 🎯 Notification Data Handling

### Custom Data Processing
Modify `_handleNotificationTap()` in `NotificationService` to add custom navigation:

```dart
void _handleNotificationTap(RemoteMessage? message, {Map<String, dynamic>? data}) {
  final notificationData = data ?? message?.data ?? {};
  
  // Custom navigation based on notification type
  switch (notificationData['type']) {
    case 'appointment':
      Get.toNamed(AppRoutes.appointmentDetails, arguments: notificationData);
      break;
    case 'message':
      Get.toNamed(AppRoutes.chat, arguments: notificationData);
      break;
    case 'reminder':
      Get.toNamed(AppRoutes.reminders);
      break;
    default:
      Get.toNamed(AppRoutes.mainScreen);
  }
}
```

## 🔧 Server Integration

### Update FCM Token on Server
Modify `_updateTokenOnServer()` in `NotificationService`:

```dart
Future<void> _updateTokenOnServer(String token) async {
  try {
    await ApiManager.post('/api/update-fcm-token', {
      'fcm_token': token,
      'platform': Platform.isIOS ? 'ios' : 'android',
    });
    print('✅ FCM token updated on server');
  } catch (e) {
    print('❌ Error updating FCM token: $e');
  }
}
```

## 🐛 Troubleshooting

### Common Issues

1. **No FCM Token Generated**
   - Check Firebase configuration
   - Ensure `google-services.json`/`GoogleService-Info.plist` are properly added
   - Verify internet connectivity

2. **Notifications Not Showing**
   - Check notification permissions
   - Test with local notifications first
   - Verify FCM token is valid

3. **Background Notifications Not Working**
   - Ensure background app refresh is enabled
   - Check if app is in power saving mode
   - Verify FCM service configuration

4. **iOS Notifications Issues**
   - Check iOS notification settings
   - Ensure proper provisioning profile
   - Test on physical device (not simulator)

### Debug Commands
```bash
# Check Flutter setup
flutter doctor

# Check dependencies
flutter pub deps

# Clean and rebuild
flutter clean && flutter pub get

# Run with verbose logging
flutter run --verbose
```

## 📊 Token Debugging

The FCM token is automatically printed when:
- App starts up
- User logs in
- Token refreshes

Look for these log messages:
```
🔑 FCM Token retrieved: [TOKEN]
🔑 Using FCM Token for login: [TOKEN]
🔄 FCM Token refreshed: [TOKEN]
```

## 🎨 Customization

### Notification Appearance
Modify notification appearance in `NotificationService`:

```dart
const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  'medtrac_channel',
  'MedTrac Notifications',
  channelDescription: 'Notifications for MedTrac app',
  importance: Importance.high,
  priority: Priority.high,
  icon: '@mipmap/ic_launcher', // Custom icon
  color: Colors.blue, // Notification color
  enableVibration: true,
  playSound: true,
);
```

### Notification Channels
Create different channels for different notification types:

```dart
// Appointment notifications
const AndroidNotificationDetails appointmentDetails = AndroidNotificationDetails(
  'appointment_channel',
  'Appointment Notifications',
  importance: Importance.high,
);

// Chat notifications  
const AndroidNotificationDetails chatDetails = AndroidNotificationDetails(
  'chat_channel',
  'Chat Messages',
  importance: Importance.max,
);
```

## 📞 Support

For issues or questions about the notification system:
1. Check the console logs for error messages
2. Use the `NotificationTestScreen` to debug
3. Verify Firebase project configuration
4. Test with different notification types

---

✅ **Push notifications are now fully configured and ready to use in your MedTrac app!**