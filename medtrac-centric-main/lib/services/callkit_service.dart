import 'dart:async';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:get/get.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:uuid/uuid.dart';
import 'package:medtrac/routes/app_routes.dart';

/// CallKit Service for handling native incoming call UI
/// Provides iOS-style and Android native call notifications with accept/decline buttons
class CallKitService extends GetxService {
  static CallKitService get instance => Get.find<CallKitService>();
  
  // Track active calls to prevent duplicates
  final Set<String> _activeCalls = <String>{};
  final RxBool isCallActive = false.obs;
  
  // Store call data for navigation when app opens
  Map<String, dynamic>? _pendingCallData;
  
  // Current call UUID for tracking
  String? _currentUuid;
  
  @override
  void onInit() {
    super.onInit();
    _setupCallKitEventListeners();
    print('✅ CallKitService initialized');
  }
  
  /// Setup CallKit event listeners for accept/decline actions
  void _setupCallKitEventListeners() {
    try {
      print('📡 Setting up CallKit event listeners...');
      
      FlutterCallkitIncoming.onEvent.listen((event) {
        if (event != null) {
          print('📞 === CALLKIT EVENT RECEIVED ===');
          print('📞 Event Type: ${event.event}');
          print('📞 Event Body: ${event.body}');
          
          _handleCallKitEvent(event);
        }
      });
      
      print('✅ CallKit event listeners setup complete');
    } catch (e) {
      print('❌ Error setting up CallKit event listeners: $e');
    }
  }
  
  /// Handle CallKit events (accept, decline, timeout)
  void _handleCallKitEvent(dynamic event) {
    try {
      print('🎯 Processing CallKit event: ${event.event}');
      
      // Handle different event types based on the enum values
      switch (event.event.toString()) {
        case 'Event.actionCallAccept':
          print('✅ User ACCEPTED call via CallKit');
          _handleCallAccept(event.body);
          break;
          
        case 'Event.actionCallDecline':
          print('❌ User DECLINED call via CallKit');
          _handleCallDecline(event.body);
          break;
          
        case 'Event.actionCallEnded':
          print('📞 Call ENDED via CallKit');
          _handleCallEnd(event.body);
          break;
          
        case 'Event.actionCallTimeout':
          print('⏱️ Call TIMEOUT via CallKit');
          _handleCallTimeout(event.body);
          break;
          
        case 'Event.actionCallCallback':
          print('🔄 Call CALLBACK via CallKit');
          _handleCallCallback(event.body);
          break;
          
        default:
          print('⚠️ Unknown CallKit event: ${event.event}');
      }
    } catch (e) {
      print('❌ Error handling CallKit event: $e');
    }
  }
  
  /// Handle call accept - open app and navigate to video call screen
  void _handleCallAccept(Map<String, dynamic>? body) {
    try {
      print('📞 === HANDLING CALL ACCEPT ===');
      
      if (body == null || body.isEmpty) {
        print('❌ No call data available for accept action');
        return;
      }
      
      print('📞 Call accept data: $body');
      
      // Extract call data from body
      final callData = {
        "fromAppointment": true,
        "appointmentId": int.tryParse(body['appointmentId']?.toString() ?? '0') ?? 0,
        'doctorId' : HelperFunctions.isUser() ? int.tryParse(body['receiverId']?.toString() ?? '0') ?? 0 : SharedPrefsService.getUserInfo.id,
        "callerId": int.tryParse(body['callerId']?.toString() ?? '0') ?? 0,
        "receiverId": int.tryParse(body['receiverId']?.toString() ?? '0') ?? 0,
        "callerName": body['callerName']?.toString() ?? 'Unknown Caller',
        "callerProfilePicture": body['callerProfilePicture']?.toString() ?? '',
        "channelName": body['channelName']?.toString() ?? '',
        "rtcToken": body['rtcToken']?.toString() ?? '',
        "isIncomingCall": true,
        "callId": body['callId']?.toString() ?? '',
        "showRinging": false, // Don't show ringing since user already accepted
        "autoAccept": true, // Auto-accept since user accepted via CallKit
      };
      
      print('📞 Prepared call data for navigation: $callData');
      
      // Store call data for navigation
      _pendingCallData = callData;
      
      // End CallKit call first
      _endCallKitCall(body['callId']?.toString() ?? '');
      
      // Navigate to video call screen
      print('🚀 Navigating to video call screen...');
      
      // Use a small delay to ensure CallKit UI is dismissed
      Future.delayed(Duration(milliseconds: 500), () {
        Get.toNamed(AppRoutes.videoCallScreen, arguments: callData);
        print('✅ Navigation to video call screen initiated');
      });
      
    } catch (e) {
      print('❌ Error handling call accept: $e');
    }
  }
  
  /// Handle call decline - just end the CallKit call
  void _handleCallDecline(Map<String, dynamic>? body) {
    try {
      print('📞 === HANDLING CALL DECLINE ===');
      
      if (body != null) {
        String callId = body['callId']?.toString() ?? '';
        print('📞 Declining call with ID: $callId');
        
        // End CallKit call
        _endCallKitCall(callId);
        
        // TODO: Notify backend that call was declined
        // This would be implemented based on your API
        print('📞 Call declined - backend notification would be sent here');
      }
      
    } catch (e) {
      print('❌ Error handling call decline: $e');
    }
  }
  
  /// Handle call end
  void _handleCallEnd(Map<String, dynamic>? body) {
    try {
      print('📞 === HANDLING CALL END ===');
      
      if (body != null) {
        String callId = body['callId']?.toString() ?? '';
        print('📞 Ending call with ID: $callId');
        
        // Clean up call state
        _activeCalls.remove(callId);
        isCallActive.value = _activeCalls.isNotEmpty;
        
        print('📞 Call ended - cleanup completed');
      }
      
    } catch (e) {
      print('❌ Error handling call end: $e');
    }
  }
  
  /// Handle call timeout
  void _handleCallTimeout(Map<String, dynamic>? body) {
    try {
      print('📞 === HANDLING CALL TIMEOUT ===');
      
      if (body != null) {
        String callId = body['callId']?.toString() ?? '';
        print('⏱️ Call timeout for ID: $callId');
        
        // End CallKit call
        _endCallKitCall(callId);
        
        print('⏱️ Call timeout handled');
      }
      
    } catch (e) {
      print('❌ Error handling call timeout: $e');
    }
  }
  
  /// Handle call callback (when user taps the notification)
  void _handleCallCallback(Map<String, dynamic>? body) {
    try {
      print('📞 === HANDLING CALL CALLBACK (NOTIFICATION TAP) ===');
      
      if (body == null || body.isEmpty) {
        print('❌ No call data available for callback action');
        return;
      }
      
      print('📞 Call callback data: $body');
      
      // Extract call data for navigation (similar to accept but with ringing state)
      final callData = {
        "fromAppointment": true,
        "appointmentId": int.tryParse(body['appointmentId']?.toString() ?? '0') ?? 0,
        "callerId": int.tryParse(body['callerId']?.toString() ?? '0') ?? 0,
        "receiverId": int.tryParse(body['receiverId']?.toString() ?? '0') ?? 0,
        "callerName": body['callerName']?.toString() ?? 'Unknown Caller',
        "callerProfilePicture": body['callerProfilePicture']?.toString() ?? '',
        "channelName": body['channelName']?.toString() ?? '',
        "rtcToken": body['rtcToken']?.toString() ?? '',
        "isIncomingCall": true,
        "callId": body['callId']?.toString() ?? '',
        "showRinging": true, // Show ringing state since user just tapped notification
        "autoAccept": false, // Don't auto-accept, let user choose
      };
      
      print('📞 Prepared call data for callback navigation: $callData');
      
      // Navigate to video call screen with ringing state
      print('🚀 Navigating to video call screen from notification tap...');
      Get.toNamed(AppRoutes.videoCallScreen, arguments: callData);
      
    } catch (e) {
      print('❌ Error handling call callback: $e');
    }
  }
  
  /// Show incoming call using CallKit
  Future<void> showIncomingCall({
    required String callId,
    required String callerName,
    required String callerId,
    required String receiverId,
    required String appointmentId,
    required String channelName,
    required String rtcToken,
    String? callerProfilePicture,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      print('📞 === SHOWING CALLKIT INCOMING CALL ===');
      
      // Prevent duplicate calls
      if (_activeCalls.contains(callId)) {
        print('⚠️ Call with ID $callId is already active, skipping');
        return;
      }
      
      print('📞 CallKit Call Details:');
      print('  Call ID: $callId');
      print('  Caller Name: $callerName');
      print('  Caller ID: $callerId');
      print('  Receiver ID: $receiverId');
      print('  Appointment ID: $appointmentId');
      print('  Channel: $channelName');
      print('  Profile Picture: $callerProfilePicture');
      print('  Timeout: ${timeout.inSeconds}s');
      
      // Generate unique UUID for CallKit
      _currentUuid = Uuid().v4();
      
      // Create CallKit parameters using the proper class
      final params = CallKitParams(
        id: _currentUuid,
        nameCaller: callerName,
        appName: 'Medtrac',
        avatar: callerProfilePicture ?? '',
        handle: callerId,
        type: 1, // 0 = Audio, 1 = Video
        textAccept: 'Accept',
        textDecline: 'Decline',
        duration: timeout.inMilliseconds,
        extra: <String, dynamic>{
          'callId': callId,
          'callerId': callerId,
          'receiverId': receiverId,
          'appointmentId': appointmentId,
          'channelName': channelName,
          'rtcToken': rtcToken,
          'callerName': callerName,
          'callerProfilePicture': callerProfilePicture ?? '',
        },
        headers: <String, dynamic>{
          'platform': 'flutter',
          'version': '1.0.0'
        },
        missedCallNotification: const NotificationParams(
          showNotification: true,
          isShowCallback: true,
          subtitle: 'Missed video call',
          callbackText: 'Call back',
        ),
        android: const AndroidParams(
          isCustomNotification: true,
          isShowLogo: false,
          ringtonePath: 'system_ringtone_default',
          backgroundColor: '#0955fa',
          backgroundUrl: '',
          actionColor: '#4CAF50',
          textColor: '#ffffff',
          incomingCallNotificationChannelName: 'Incoming Video Call',
          missedCallNotificationChannelName: 'Missed Video Call',
          isShowCallID: false,
        ),
        ios: const IOSParams(
          iconName: 'CallKitLogo',
          handleType: 'generic',
          supportsVideo: true,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100.0,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: true,
          supportsHolding: true,
          supportsGrouping: false,
          supportsUngrouping: false,
          ringtonePath: 'system_ringtone_default',
        ),
      );
      
      // Show CallKit incoming call
      await FlutterCallkitIncoming.showCallkitIncoming(params);
      
      // Track active call
      _activeCalls.add(callId);
      isCallActive.value = true;
      
      print('✅ CallKit incoming call displayed successfully');
      
      // Auto-end call after timeout
      Timer(timeout, () {
        if (_activeCalls.contains(callId)) {
          print('⏱️ Auto-ending call $callId due to timeout');
          _endCallKitCall(callId);
        }
      });
      
    } catch (e) {
      print('❌ Error showing CallKit incoming call: $e');
      rethrow;
    }
  }
  
  /// End a specific CallKit call
  Future<void> _endCallKitCall(String callId) async {
    try {
      print('📞 Ending CallKit call: $callId');
      
      // End the specific call if we have the UUID
      if (_currentUuid != null) {
        await FlutterCallkitIncoming.endCall(_currentUuid!);
      } else {
        // Fallback to end all calls
        await FlutterCallkitIncoming.endAllCalls();
      }
      
      // Clean up call state
      _activeCalls.remove(callId);
      isCallActive.value = _activeCalls.isNotEmpty;
      
      print('✅ CallKit call ended successfully');
    } catch (e) {
      print('❌ Error ending CallKit call: $e');
    }
  }
  
  /// End all active CallKit calls
  Future<void> endAllCalls() async {
    try {
      print('📞 Ending all CallKit calls...');
      
      await FlutterCallkitIncoming.endAllCalls();
      
      // Clear all active calls
      _activeCalls.clear();
      isCallActive.value = false;
      _currentUuid = null;
      
      print('✅ All CallKit calls ended');
    } catch (e) {
      print('❌ Error ending all CallKit calls: $e');
    }
  }
  
  /// Check if there are active calls
  bool get hasActiveCalls => _activeCalls.isNotEmpty;
  
  /// Get count of active calls
  int get activeCallCount => _activeCalls.length;
  
  /// Get pending call data (for navigation after app opens)
  Map<String, dynamic>? get pendingCallData => _pendingCallData;
  
  /// Clear pending call data
  void clearPendingCallData() {
    _pendingCallData = null;
  }
  
  @override
  void onClose() {
    print('🔄 CallKitService closing - ending all calls');
    endAllCalls();
    super.onClose();
  }
}