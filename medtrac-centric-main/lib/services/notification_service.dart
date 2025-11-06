import 'dart:io';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
import 'package:medtrac/services/callkit_service.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📲 === BACKGROUND MESSAGE RECEIVED ===');
  print('📲 Message ID: ${message.messageId}');
  print('📲 From: ${message.from}');
  print('📲 Data: ${message.data}');
  
  // Check if this is a call notification
  if (message.data.containsKey('rtcToken') && message.data['rtcToken']?.isNotEmpty == true) {
    print('📞 Detected CALL notification in background');
    await _handleIncomingCallBackground(message);
  } else {
    print('📧 Regular notification in background');
  }
}

/// Handle incoming call when app is in background/terminated
@pragma('vm:entry-point')
Future<void> _handleIncomingCallBackground(RemoteMessage message) async {
  try {
    print('📞 === HANDLING INCOMING CALL (BACKGROUND) ===');
    
    final data = message.data;
    
    // Extract call data
    final callId = data['callId'] ?? '';
    final callerId = data['callerId'] ?? '';
    final receiverId = data['receiverId'] ?? '';
    final appointmentId = data['appointmentId'] ?? '';
    final channelName = data['channelName'] ?? '';
    final rtcToken = data['rtcToken'] ?? '';
    
    // Get caller name and profile picture from data
    final callerName = data['callerName'] ?? message.notification?.title ?? 'Incoming Video Call';
    final callerProfilePicture = data['profile_picture'] ?? ''; // Backend sends 'profile_picture'
    
    print('📞 Background Call Details:');
    print('  Call ID: $callId');
    print('  Caller ID: $callerId');
    print('  Receiver ID: $receiverId');
    print('  Channel: $channelName');
    print('  RTC Token: ${rtcToken.isNotEmpty ? "Present" : "Missing"}');
    print('  Caller Name: $callerName');
    print('  Caller Profile Picture: $callerProfilePicture');
    print('  Appointment ID: $appointmentId');
    
    // Use CallKit to show incoming call UI
    try {
      // Initialize CallKit service if not already done
      if (!Get.isRegistered<CallKitService>()) {
        Get.put(CallKitService());
      }
      
      final callKitService = Get.find<CallKitService>();
      await callKitService.showIncomingCall(
        callId: callId,
        callerId: callerId,
        receiverId: receiverId,
        callerName: callerName,
        channelName: channelName,
        rtcToken: rtcToken,
        appointmentId: appointmentId,
        // TODO: Add callerProfilePicture parameter to CallKitService
      );
      
      print('✅ CallKit incoming call displayed');
    } catch (e) {
      print('❌ Error showing CallKit call: $e');
    }
    
  } catch (e) {
    print('❌ Error handling incoming call in background: $e');
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  
  String? get fcmToken => _fcmToken;

  /// Initialize the notification service
  Future<void> initialize() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Request notification permissions
      await _requestPermissions();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Get FCM token
      await _getFCMToken();
      
      // Configure FCM
      await _configureFCM();
      
      print('✅ Notification Service initialized successfully');
      print('🔑 FCM Token: $_fcmToken');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request FCM permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('📋 FCM Permission status: ${settings.authorizationStatus}');

    // Request general notification permission for Android 13+
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      print('📋 Android Notification Permission: $status');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    print('📱 Initializing local notifications...');
    
    // Android initialization settings
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    // Combined initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    print('📱 Calling flutter_local_notifications.initialize()...');
    
    // Initialize the plugin
    bool? initialized = await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    print('📱 Local notifications initialization result: $initialized');
    
    // Check if we can show notifications
    if (Platform.isAndroid) {
      bool? areNotificationsEnabled = await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      print('📱 Android notifications enabled: $areNotificationsEnabled');
    }
    
    print('📱 Local notifications initialized successfully');
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      // For iOS, we need to get APNS token first
      if (Platform.isIOS) {
        await _handleIOSToken();
      }
      
      _fcmToken = await _firebaseMessaging.getToken();
      print('🔑 FCM Token retrieved: $_fcmToken');
      
      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((String token) {
        print('🔄 FCM Token refreshed: $token');
        _fcmToken = token;
        // Here you can update the token on your server
        _updateTokenOnServer(token);
      });
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      // Retry after a delay for iOS
      if (Platform.isIOS) {
        print('🔄 Retrying FCM token generation for iOS...');
        await Future.delayed(const Duration(seconds: 2));
        await _retryGetToken();
      }
    }
  }

  /// Handle iOS-specific token generation
  Future<void> _handleIOSToken() async {
    try {
      // For iOS, ensure APNS token is available
      String? apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken != null) {
        print('🍎 APNS Token available: ${apnsToken.substring(0, 20)}...');
      } else {
        print('⏳ Waiting for APNS token...');
        // Wait a bit for APNS token to be available
        await Future.delayed(const Duration(seconds: 1));
        apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken != null) {
          print('🍎 APNS Token obtained: ${apnsToken.substring(0, 20)}...');
        }
      }
    } catch (e) {
      print('⚠️ APNS Token handling error: $e');
    }
  }

  /// Retry getting FCM token for iOS
  Future<void> _retryGetToken() async {
    try {
      // Check if APNS token is now available
      String? apnsToken = await _firebaseMessaging.getAPNSToken();
      if (apnsToken != null) {
        _fcmToken = await _firebaseMessaging.getToken();
        print('🔑 FCM Token retrieved on retry: $_fcmToken');
      } else {
        print('❌ APNS token still not available, FCM token will be null');
        // Set up a listener for when APNS token becomes available
        _setupTokenListener();
      }
    } catch (e) {
      print('❌ Retry FCM token failed: $e');
      _setupTokenListener();
    }
  }

  /// Set up listener for delayed token generation
  void _setupTokenListener() {
    // Listen for token refresh which will trigger when APNS becomes available
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      print('🔄 FCM Token received via refresh: $token');
      _fcmToken = token;
      _updateTokenOnServer(token);
    });
  }

  /// Configure FCM message handling
  Future<void> _configureFCM() async {
    print('🔧 Configuring FCM message handlers...');
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 === FOREGROUND MESSAGE RECEIVED ===');
      print('📨 Message ID: ${message.messageId}');
      print('📨 From: ${message.from}');
      print('📨 Sent Time: ${message.sentTime}');
      print('📨 TTL: ${message.ttl}');
      print('📨 Category: ${message.category}');
      print('📨 Collapse Key: ${message.collapseKey}');
      
      if (message.notification != null) {
        print('📨 Notification Title: ${message.notification!.title}');
        print('📨 Notification Body: ${message.notification!.body}');
        print('📨 Notification Android Channel ID: ${message.notification!.android?.channelId}');
        print('📨 Notification iOS Badge: ${message.notification!.apple?.badge}');
      } else {
        print('📨 No notification payload (data-only message)');
      }
      
      if (message.data.isNotEmpty) {
        print('📨 === PAYLOAD DATA ===');
        print('📨 Raw data payload: ${message.data}');
        print('📨 Payload keys: ${message.data.keys.toList()}');
        print('📨 Payload values: ${message.data.values.toList()}');
        
        // Print each key-value pair individually for clarity
        message.data.forEach((key, value) {
          print('📨 Payload[$key]: $value');
        });
        
        // Pretty print JSON if possible
        try {
          final prettyPayload = const JsonEncoder.withIndent('  ').convert(message.data);
          print('📨 Pretty payload:\n$prettyPayload');
        } catch (e) {
          print('📨 Could not format payload as JSON: $e');
        }
        print('📨 === END PAYLOAD DATA ===');
      } else {
        print('📨 No data payload');
      }
      
      print('📨 === PROCESSING FOREGROUND MESSAGE ===');
      _handleForegroundMessage(message);
    });

    // Handle message when app is opened from notification (background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 === APP OPENED FROM NOTIFICATION ===');
      print('📱 Message ID: ${message.messageId}');
      print('📱 From: ${message.from}');
      print('📱 Notification Title: ${message.notification?.title}');
      print('📱 Notification Body: ${message.notification?.body}');
      
      if (message.data.isNotEmpty) {
        print('📱 === APP OPENED PAYLOAD ===');
        print('📱 Raw payload: ${message.data}');
        message.data.forEach((key, value) {
          print('📱 Payload[$key]: $value');
        });
        
        try {
          final prettyPayload = const JsonEncoder.withIndent('  ').convert(message.data);
          print('📱 Pretty payload:\n$prettyPayload');
        } catch (e) {
          print('📱 Could not format payload as JSON: $e');
        }
        print('📱 === END APP OPENED PAYLOAD ===');
      } else {
        print('📱 No payload data');
      }
      
      print('📱 === HANDLING TAP NAVIGATION ===');
      _handleNotificationTap(message);
    });

    // Handle initial message when app is opened from terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print('🚀 === APP OPENED FROM TERMINATED STATE ===');
      print('🚀 Message ID: ${initialMessage.messageId}');
      print('🚀 From: ${initialMessage.from}');
      print('🚀 Notification Title: ${initialMessage.notification?.title}');
      print('🚀 Notification Body: ${initialMessage.notification?.body}');
      
      if (initialMessage.data.isNotEmpty) {
        print('🚀 === TERMINATED STATE PAYLOAD ===');
        print('🚀 Raw payload: ${initialMessage.data}');
        initialMessage.data.forEach((key, value) {
          print('🚀 Payload[$key]: $value');
        });
        
        try {
          final prettyPayload = const JsonEncoder.withIndent('  ').convert(initialMessage.data);
          print('🚀 Pretty payload:\n$prettyPayload');
        } catch (e) {
          print('🚀 Could not format payload as JSON: $e');
        }
        print('🚀 === END TERMINATED STATE PAYLOAD ===');
      } else {
        print('🚀 No payload data');
      }
      
      print('🚀 === HANDLING INITIAL MESSAGE ===');
      _handleNotificationTap(initialMessage);
    } else {
      print('🚀 No initial message (app not opened from notification)');
    }
    
    print('🔧 FCM message handlers configured successfully');
  }

  /// Handle foreground messages by checking for call notifications first
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      print('🔍 === HANDLING FOREGROUND MESSAGE ===');
      
      // Check if this is a call notification (has rtcToken)
      if (message.data.containsKey('rtcToken') && message.data['rtcToken']?.isNotEmpty == true) {
        print('📞 Detected CALL notification in foreground');
        await _handleIncomingCallForeground(message);
        return;
      }
      
      print('🔍 Converting FCM message to local notification...');
      
      String title = message.notification?.title ?? 'New Message';
      String body = message.notification?.body ?? 'You have a new message';
      String payload = jsonEncode(message.data);
      
      print('🔍 Local notification details:');
      print('🔍 - Title: $title');
      print('🔍 - Body: $body');
      print('🔍 - Payload: $payload');
      print('🔍 - ID: ${message.hashCode}');
      
      await showLocalNotification(
        id: message.hashCode,
        title: title,
        body: body,
        payload: payload,
      );
      
      print('✅ Foreground message handled successfully');
    } catch (e) {
      print('❌ Error handling foreground message: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }
  
  /// Handle incoming call when app is in foreground
  Future<void> _handleIncomingCallForeground(RemoteMessage message) async {
    try {
      print('📞 === HANDLING INCOMING CALL (FOREGROUND) ===');
      
      final data = message.data;
      print('📧 Payload: $data');
      
      // Extract call data
      final callId = data['callId'] ?? '';
      final callerId = data['callerId'] ?? '';
      final receiverId = data['receiverId'] ?? '';
      final appointmentId = data['appointmentId'] ?? '';
      final channelName = data['channelName'] ?? '';
      final rtcToken = data['rtcToken'] ?? '';
      
      // Get caller name and profile picture from notification data
      final callerName = message.notification?.title ?? data['callerName'] ?? 'Incoming Call';
      final callerProfilePicture = data['profile_picture'] ?? ''; // Backend sends 'profile_picture'
      
      print('📞 Call Details:');
      print('  Call ID: $callId');
      print('  Caller ID: $callerId');
      print('  Receiver ID: $receiverId');
      print('  Appointment ID: $appointmentId');
      print('  Channel: $channelName');
      print('  Caller Name: $callerName');
      print('  Caller Profile Picture: $callerProfilePicture');
      
      // Navigate directly to video call screen for foreground calls
      Get.toNamed(AppRoutes.videoCallScreen, arguments: {
        "fromAppointment": true,
        "appointmentId": int.tryParse(appointmentId) ?? 0,
        "callerId": int.tryParse(callerId) ?? 0,
        "receiverId": int.tryParse(receiverId) ?? 0,
        "callerName": callerName,
        "callerProfilePicture": callerProfilePicture, // Pass caller's profile picture
        "channelName": channelName,
        "rtcToken": rtcToken,
        "isIncomingCall": true,
        "callId": callId,
        "doctorId" : HelperFunctions.isUser() ? int.tryParse(receiverId) ?? 0 : SharedPrefsService.getUserInfo.id,
        "showRinging": true, // Show ringing state for incoming calls
      });
      
      print('✅ Navigated to video call screen for incoming call');
      
    } catch (e) {
      print('❌ Error handling incoming call in foreground: $e');
    }
  }

  /// Show local notification
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      print('📧 === SHOWING LOCAL NOTIFICATION ===');
      print('📧 ID: $id');
      print('📧 Title: $title');
      print('📧 Body: $body');
      print('📧 Payload: $payload');
      
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'medtrac_channel',
        'MedTrac Notifications',
        channelDescription: 'Notifications for MedTrac app',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      print('📧 Calling flutter_local_notifications.show()...');
      await _localNotifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      
      print('✅ Local notification shown successfully: $title');
    } catch (e) {
      print('❌ Error showing local notification: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('👆 === NOTIFICATION TAPPED ===');
    print('👆 Notification ID: ${response.id}');
    print('👆 Action ID: ${response.actionId}');
    print('👆 Input: ${response.input}');
    print('👆 Notification Response Type: ${response.notificationResponseType}');
    
    if (response.payload != null) {
      print('👆 === TAP PAYLOAD ===');
      print('👆 Raw payload: ${response.payload}');
      
      try {
        print('👆 Parsing payload JSON...');
        final data = jsonDecode(response.payload!);
        print('👆 Parsed data: $data');
        
        // Print each key-value pair if it's a map
        if (data is Map<String, dynamic>) {
          data.forEach((key, value) {
            print('👆 Tap Payload[$key]: $value');
          });
          
          // Pretty print JSON
          try {
            final prettyPayload = const JsonEncoder.withIndent('  ').convert(data);
            print('👆 Pretty tap payload:\n$prettyPayload');
          } catch (e) {
            print('👆 Could not format tap payload as JSON: $e');
          }
        }
        print('👆 === END TAP PAYLOAD ===');
        
        print('👆 Calling _handleNotificationTap with parsed data...');
        _handleNotificationTap(null, data: data);
      } catch (e) {
        print('❌ Error parsing notification payload: $e');
        print('❌ Raw payload: ${response.payload}');
        print('❌ Stack trace: ${StackTrace.current}');
      }
    } else {
      print('👆 No payload, calling _handleNotificationTap without data...');
      _handleNotificationTap(null);
    }
  }

  /// Handle notification tap navigation
  void _handleNotificationTap(RemoteMessage? message, {Map<String, dynamic>? data}) {
    final notificationData = data ?? message?.data ?? {};
    print('🎯 === HANDLING NOTIFICATION TAP NAVIGATION ===');
    print('🎯 Message source: ${message != null ? 'FCM RemoteMessage' : 'Local notification'}');
    print('🎯 Notification data: $notificationData');
    print('🎯 Data keys: ${notificationData.keys.toList()}');
    print('🎯 Data values: ${notificationData.values.toList()}');
    
    // Check if this is a call notification first
    if (notificationData.containsKey('rtcToken') && notificationData['rtcToken']?.isNotEmpty == true) {
      print('📞 Detected CALL notification tap');
      _handleCallNotificationTap(notificationData, message);
      return;
    }
    
    // Log specific data fields that might be used for navigation
    if (notificationData.containsKey('type')) {
      print('🎯 Notification type: ${notificationData['type']}');
    }
    if (notificationData.containsKey('screen')) {
      print('🎯 Target screen: ${notificationData['screen']}');
    }
    if (notificationData.containsKey('id')) {
      print('🎯 Resource ID: ${notificationData['id']}');
    }
    
    // Handle chat notifications
    if (notificationData['type'] == 'chat') {
      print('💬 Handling chat notification tap...');
      final conversationId = notificationData['conversationId'];
      final senderId = notificationData['senderId'];
      
      if (conversationId != null && senderId != null) {
        // Fetch conversation details and navigate to chat
        _navigateToChat(conversationId, senderId);
      }
      return;
    }
    
    // Add your navigation logic here based on notification data
    // For example:
    // if (notificationData['type'] == 'appointment') {
    //   print('🎯 Navigating to appointment details...');
    //   Get.toNamed(AppRoutes.appointmentDetails, arguments: notificationData);
    // } else {
    //   print('🎯 No specific navigation, going to main screen...');
    //   Get.toNamed(AppRoutes.mainScreen);
    // }
    
    print('🎯 Navigation handling completed (add custom logic above)');
  }
  
  /// Navigate to chat screen when notification is tapped
  Future<void> _navigateToChat(String conversationId, int senderId) async {
    try {
      print('💬 Navigating to chat: conversationId=$conversationId, senderId=$senderId');
      
      // Get conversation document
      final conversationDoc = await FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId)
          .get();
      
      if (!conversationDoc.exists) {
        print('❌ Conversation not found');
        return;
      }
      
      final data = conversationDoc.data()!;
      final user = SharedPrefsService.getUserInfo;
      final currentUserId = user.id;
      
      // Determine other user's details
      final isParticipant1 = currentUserId == data['participant1Id'];
      final otherUserId = senderId;
      final otherUserName = isParticipant1 ? data['participant2Name'] : data['participant1Name'];
      final otherUserProfilePicture = isParticipant1 
          ? data['participant2ProfilePicture'] 
          : data['participant1ProfilePicture'];
      
      // Navigate to chat screen
      Get.toNamed(AppRoutes.chatScreen, arguments: {
        'otherUserId': otherUserId,
        'otherUserName': otherUserName ?? 'User',
        'otherUserProfilePicture': otherUserProfilePicture ?? '',
      });
      
    } catch (e) {
      print('❌ Error navigating to chat: $e');
    }
  }
  
  /// Handle call notification tap
  void _handleCallNotificationTap(Map<String, dynamic> data, RemoteMessage? message) {
    try {
      print('📞 === HANDLING CALL NOTIFICATION TAP ===');
      
      // Extract call data
      final callId = data['callId'] ?? '';
      final callerId = data['callerId'] ?? '';
      final receiverId = data['receiverId'] ?? '';
      final appointmentId = data['appointmentId'] ?? '';
      final channelName = data['channelName'] ?? '';
      final rtcToken = data['rtcToken'] ?? '';
      
      // Get caller name and profile picture from notification or data
      final callerName = message?.notification?.title ?? data['callerName'] ?? 'Incoming Call';
      final callerProfilePicture = data['profile_picture'] ?? ''; // Backend sends 'profile_picture'
      
      print('📞 Navigating to video call screen...');
      
      // Navigate to video call screen
      Get.toNamed(AppRoutes.videoCallScreen, arguments: {
        "fromAppointment": true,
        "appointmentId": int.tryParse(appointmentId) ?? 0,
        "callerId": int.tryParse(callerId) ?? 0,
        "receiverId": int.tryParse(receiverId) ?? 0,
        "callerName": callerName,
        "callerProfilePicture": callerProfilePicture, // Pass caller's profile picture
        "channelName": channelName,
        "rtcToken": rtcToken,
        "isIncomingCall": true,
        "callId": callId,
        "doctorId" : HelperFunctions.isUser() ? int.tryParse(receiverId) ?? 0 : SharedPrefsService.getUserInfo.id,
        "showRinging": false, // Don't show ringing when opened from notification
      });
      
      print('✅ Navigated to video call screen from notification tap');
      
    } catch (e) {
      print('❌ Error handling call notification tap: $e');
    }
  }

  /// Update token on server (implement based on your API)
  Future<void> _updateTokenOnServer(String token) async {
    try {
      // Implement your API call to update the token on your server
      print('🔄 Should update token on server: $token');
      // Example:
      // await ApiManager.post('/update-fcm-token', {'fcm_token': token});
    } catch (e) {
      print('❌ Error updating token on server: $e');
    }
  }

  /// Schedule a local notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'medtrac_scheduled_channel',
        'MedTrac Scheduled Notifications',
        channelDescription: 'Scheduled notifications for MedTrac app',
        importance: Importance.high,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convert DateTime to TZDateTime
      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      
      print('⏰ Scheduled notification: $title at $scheduledTime');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
    print('❌ Cancelled notification: $id');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print('❌ Cancelled all notifications');
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Manually refresh FCM token (useful for iOS)
  Future<void> refreshFCMToken() async {
    try {
      print('🔄 Manually refreshing FCM token...');
      
      if (Platform.isIOS) {
        await _handleIOSToken();
      }
      
      _fcmToken = await _firebaseMessaging.getToken();
      print('🔑 FCM Token refreshed manually: $_fcmToken');
      
      if (_fcmToken != null) {
        _updateTokenOnServer(_fcmToken!);
      }
    } catch (e) {
      print('❌ Error manually refreshing FCM token: $e');
    }
  }

  /// Check if FCM token is available
  bool get isTokenAvailable => _fcmToken != null && _fcmToken!.isNotEmpty;

  /// Test method to verify notification system is working
  Future<void> testNotificationSystem() async {
    print('🧪 === TESTING NOTIFICATION SYSTEM ===');
    
    // Test 1: Check if local notifications are initialized
    print('🧪 Test 1: Local notification system');
    try {
      await showLocalNotification(
        id: 999,
        title: 'Test Notification',
        body: 'If you see this, local notifications are working!',
        payload: '{"test": true}',
      );
      print('✅ Test 1 passed: Local notification sent');
    } catch (e) {
      print('❌ Test 1 failed: $e');
    }
    
    // Test 2: Check FCM token availability
    print('🧪 Test 2: FCM token availability');
    if (isTokenAvailable) {
      print('✅ Test 2 passed: FCM token is available');
      print('🔑 Token: $_fcmToken');
    } else {
      print('❌ Test 2 failed: FCM token not available');
    }
    
    // Test 3: Check permissions
    print('🧪 Test 3: Permission status');
    final settings = await _firebaseMessaging.getNotificationSettings();
    print('📋 Authorization status: ${settings.authorizationStatus}');
    print('📋 Alert setting: ${settings.alert}');
    print('📋 Badge setting: ${settings.badge}');
    print('📋 Sound setting: ${settings.sound}');
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Test 3 passed: Permissions are granted');
    } else {
      print('❌ Test 3 failed: Permissions not granted');
    }
    
    print('🧪 Notification system test completed');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📨 === BACKGROUND MESSAGE HANDLER ===');
  print('📨 Message ID: ${message.messageId}');
  print('📨 From: ${message.from}');
  print('📨 Sent Time: ${message.sentTime}');
  print('📨 TTL: ${message.ttl}');
  print('📨 Category: ${message.category}');
  print('📨 Collapse Key: ${message.collapseKey}');
  
  if (message.notification != null) {
    print('📨 Background notification title: ${message.notification!.title}');
    print('📨 Background notification body: ${message.notification!.body}');
    print('📨 Background notification android: ${message.notification!.android?.channelId}');
    print('📨 Background notification iOS: ${message.notification!.apple?.badge}');
  } else {
    print('📨 Background message has no notification payload (data-only)');
  }
  
  if (message.data.isNotEmpty) {
    print('📨 === BACKGROUND PAYLOAD ===');
    print('📨 Raw background data: ${message.data}');
    print('📨 Background data keys: ${message.data.keys.toList()}');
    print('📨 Background data values: ${message.data.values.toList()}');
    
    // Print each key-value pair individually
    message.data.forEach((key, value) {
      print('📨 Background Payload[$key]: $value');
    });
    
    // Pretty print JSON if possible
    try {
      final prettyPayload = const JsonEncoder.withIndent('  ').convert(message.data);
      print('📨 Pretty background payload:\n$prettyPayload');
    } catch (e) {
      print('📨 Could not format background payload as JSON: $e');
    }
    print('📨 === END BACKGROUND PAYLOAD ===');
  } else {
    print('📨 Background message has no data payload');
  }
  
  // Here you can process the background message if needed
  // For example, update local database, show custom notification, etc.
  
  print('📨 Background message processing completed');
}