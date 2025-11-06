import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:medtrac/api/api_manager.dart';
import 'package:medtrac/services/agora_service.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/services/pip_service.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/views/video_call/widgets/session_ended_sheet.dart';

enum CallState {
  idle,
  initiating,
  calling,     // Outgoing call - "Calling..."
  ringing,     // Receiver is being called - "Ringing..."
  connecting,
  connected,
  disconnected,
  timeout,     // Call timed out after 1 minute
}

class VideoCallController extends GetxController {
  final AgoraService _agoraService = Get.find<AgoraService>();
  
  // Getter to expose AgoraService to views
  AgoraService get agoraService => _agoraService;
  
  // PiP service for picture-in-picture functionality
  final PipService _pipService = Get.find<PipService>();
  PipService get pipService => _pipService;
  
  // Track if we're in PiP mode
  final RxBool isInPipMode = false.obs;
  
  // Existing UI variables
  final isCameraPreviewActive = false.obs; // Default to OFF - will turn ON when connected
  final previewOffset = Offset(40, 120).obs;
  final isMicActive = true.obs; // Default to ON
  final isMoreMenuOpen = false.obs;
  final RxBool isRinging = true.obs;
  
  // User profile information
  final RxString currentUserProfilePicture = ''.obs;
  final RxString currentUserName = ''.obs;
  final RxString remoteUserProfilePicture = ''.obs;
  final RxString remoteUserName = ''.obs;
  
  // Remote camera state tracking
  final RxBool isRemoteCameraActive = false.obs; // Default to OFF - will turn ON when remote joins
  
  // New Agora video call variables
  final Rx<CallState> callState = CallState.idle.obs;
  final RxString callerName = ''.obs;
  final RxString receiverName = ''.obs;
  final RxString channelName = ''.obs;
  final RxString rtcToken = ''.obs;
  final RxBool isIncomingCall = false.obs;
  final RxInt appointmentId = 0.obs;
  final RxInt callerId = 0.obs;
  final RxInt receiverId = 0.obs;
  final RxInt callDuration = 0.obs;
  final RxInt doctorId = 0.obs; // Store doctor ID for review
  final RxInt callId = 0.obs; // Store call ID for end call API
  final RxBool hasPrescription = false.obs; // Track if doctor has written prescription
  
  Timer? _callTimer;
  Timer? _ringingTimer;
  final RxBool userAcceptedCall = false.obs;
  final RxBool wasCallEverConnected = false.obs; // Track if call was ever in connected state
  
  // Audio player for ringtone
  late AudioPlayer _audioPlayer;

  @override
  void onInit() {
    super.onInit();
    
    print('🎬 VideoCallController initializing...');
    
    // Initialize audio player with proper configuration
    _initializeAudioPlayer();
    
    // Initialize current user info from SharedPrefs
    _initializeCurrentUserInfo();
    
    // Check if this is an incoming call
    final arguments = Get.arguments;
    if (arguments != null && arguments["isReturningFromPip"] == true) {
      _handleReturningFromPip(arguments);
    } else if (arguments != null && arguments["isIncomingCall"] == true) {
      _handleIncomingCall(arguments);
    } else if (arguments != null && arguments["fromAppointment"] == true) {
      _handleAppointmentCall(arguments);
    }
    
    // Initialize Agora service with error handling
    _initializeAgoraService();
    
    // Set up onLeaveChannel callback to call end call API
    _setupOnLeaveChannelCallback();
    
    // Existing ringing logic
    Future.delayed(const Duration(seconds: 3), () {
      if (!isClosed) {
        isRinging.value = false;
        update();
      }
    });
  }
  
  Future<void> _initializeAudioPlayer() async {
    try {
      print('🎵 Initializing audio player...');
      _audioPlayer = AudioPlayer();
      
      // Configure audio player for ringtone playback
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      
      print('✅ Audio player initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize audio player: $e');
      // Fallback - create basic audio player
      _audioPlayer = AudioPlayer();
    }
  }
  
  void _initializeCurrentUserInfo() {
    try {
      final userInfo = SharedPrefsService.getUserInfo;
      currentUserName.value = userInfo.name.isNotEmpty 
          ? userInfo.name
          : "You";
      currentUserProfilePicture.value = userInfo.profilePicture;
      print('👤 Current user initialized: ${currentUserName.value}');
    } catch (e) {
      print('⚠️ Error loading current user info: $e');
      currentUserName.value = "You";
      currentUserProfilePicture.value = '';
    }
  }
  
  void _handleAppointmentCall(Map<String, dynamic> arguments) {
    print('📅 Handling appointment call...');
    // Extract appointment details for outgoing call
    if (arguments.containsKey("doctorName")) {
      remoteUserName.value = arguments["doctorName"] ?? "";
      remoteUserProfilePicture.value = arguments["doctorImage"] ?? "";
      receiverName.value = remoteUserName.value;
      channelName.value = arguments["channelName"] ?? "";
    }
    // Extract doctor ID for review
    if (arguments.containsKey("doctorId")) {
      doctorId.value = arguments["doctorId"] ?? 0;
    }
    // Extract prescription status
    if (arguments.containsKey("hasPrescription")) {
      hasPrescription.value = arguments["hasPrescription"] ?? false;
    }
    print('👨‍⚕️ Remote user (doctor) info: ${remoteUserName.value}');
    print('🆔 Doctor ID: ${doctorId.value}');
    print('💊 Has Prescription: ${hasPrescription.value}');
  }
  
  void _handleIncomingCall(Map<String, dynamic> arguments) {
    print('📞 Handling incoming call...');
    isIncomingCall.value = true;
    appointmentId.value = arguments["appointmentId"] ?? 0;
    callerId.value = arguments["callerId"] ?? 0;
    receiverId.value = arguments["receiverId"] ?? 0;
    callerName.value = arguments["callerName"] ?? "";
    channelName.value = arguments["channelName"] ?? "";
    rtcToken.value = arguments["rtcToken"] ?? "";
    callId.value = int.tryParse(arguments["callId"] ?? 0) ?? 0; // Extract call ID from notification
    
    // Extract doctor ID for review (caller is doctor in incoming call)
    if (arguments.containsKey("doctorId")) {
      doctorId.value = arguments["doctorId"] ?? 0;
    } else {
      doctorId.value = callerId.value; // Fallback: caller is doctor
    }
    
    // Extract prescription status
    if (arguments.containsKey("hasPrescription")) {
      hasPrescription.value = arguments["hasPrescription"] ?? false;
    }
    
    // Extract caller profile info from notification payload
    remoteUserName.value = arguments["callerName"] ?? "";
    remoteUserProfilePicture.value = arguments["callerProfilePicture"] ?? "";
    
    // Set receiver name as current user for incoming calls
    receiverName.value = currentUserName.value;
    
    // Show ringing state and wait for user to accept
    callState.value = CallState.ringing;
    
    // Start playing ringtone for incoming call
    _playRingtone();
    
    // Start 1-minute timeout for incoming call
    _startRingingTimeout();
    
    print('📞 Incoming call ringing, waiting for user to accept...');
    print('👤 Caller info: ${remoteUserName.value}');
    print('📞 Call ID: ${callId.value}');
    print('💊 Has Prescription: ${hasPrescription.value}');
  }
  
  void _handleReturningFromPip(Map<String, dynamic> arguments) {
    print('🖼️ Handling return from PiP mode...');
    
    // Set up call information from PiP
    isIncomingCall.value = arguments["isIncomingCall"] ?? false;
    appointmentId.value = arguments["appointmentId"] ?? 0;
    callerId.value = arguments["callerId"] ?? 0;
    receiverId.value = arguments["receiverId"] ?? 0;
    callerName.value = arguments["callerName"] ?? "";
    remoteUserName.value = arguments["remoteUserName"] ?? "";
    remoteUserProfilePicture.value = arguments["remoteUserProfilePicture"] ?? "";
    channelName.value = arguments["channelName"] ?? "";
    
    // Set as connected call since we're returning from active PiP
    callState.value = CallState.connected;
    userAcceptedCall.value = true; // Mark as accepted since we're in an ongoing call
    
    // Don't start ringing - this is an ongoing call
    print('🖼️ Returning to ongoing call: ${remoteUserName.value}');
    
    // Since we're returning from PiP, the Agora session is already active
    // We just need to restore the UI state without rejoining the channel
    _setupVideoConfigurationForOngoingCall();
  }
  
  /// Setup video configuration for returning from PiP without rejoining channel
  void _setupVideoConfigurationForOngoingCall() {
    if (!agoraService.isInitialized.value) {
      print('❌ Agora service not initialized when returning from PiP');
      return;
    }
    
    try {
      print('🔄 Refreshing video configuration for ongoing call...');
      
      // Simply refresh video without rejoining
      agoraService.refreshVideoConfiguration();
      
      // Apply audio settings
      agoraService.fixAudioIssues();
      agoraService.initializeAudioSettings();
      
      print('✅ Video configuration refreshed for ongoing call');
    } catch (e) {
      print('❌ Error refreshing video configuration: $e');
    }
  }
  
  Future<void> acceptIncomingCall() async {
    try {
      print('✅ User accepted incoming call...');
      userAcceptedCall.value = true;
      _cancelRingingTimeout();
      
      // Stop ringtone immediately when user accepts
      _stopRingtone();
      
      callState.value = CallState.connecting;
      
      // Initialize Agora if needed
      if (!agoraService.isInitialized.value) {
        await agoraService.initialize();
      }
      
      // Set up event listeners
      _setupAgoraEventListeners();
      
      // Refresh video configuration to ensure proper rendering
      await agoraService.refreshVideoConfiguration();
      
      // Fix audio issues to prevent static sound
      await agoraService.fixAudioIssues();
      
      // Initialize comprehensive audio settings
      await agoraService.initializeAudioSettings();
      
      // Ensure microphone is properly initialized (unmuted by default)
      print('🎤 Initializing microphone state for incoming call...');
      _agoraService.isMuted.value = false; // Ensure Agora service shows unmuted
      isMicActive.value = true; // Ensure UI shows active microphone
      
      // Join the channel directly using hardcoded values
      await agoraService.joinChannel(
        channelName.value,
        uid: receiverId.value, // Use receiver ID as UID for incoming calls
      );
      
      callState.value = CallState.connected;
      _startCallTimer();
      
      // Start tracking call in PiP service
      _startPipTracking();
      
      print('✅ Incoming call accepted successfully');
    } catch (e) {
      print('❌ Error accepting incoming call: $e');
      _stopRingtone(); // Stop ringtone on error (backup in case it wasn't stopped)
      callState.value = CallState.disconnected;
    }
  }

  void declineIncomingCall() async {
    print('❌ User declined incoming call');
    userAcceptedCall.value = false;
    _cancelRingingTimeout();
    _stopRingtone(); // Stop ringtone when call is declined
    callState.value = CallState.disconnected;
    
    // Notify the server that the call was declined
    try {
      await ApiManager.videoCallService.declineCall(
        appointmentId: appointmentId.value,
        callerId: callerId.value,
        receiverId: receiverId.value,
      );
      print('✅ Server notified of call decline');
    } catch (e) {
      print('⚠️ Failed to notify server of decline: $e');
    }
    
    _resetCallState();
    
    // Go back to previous screen immediately without any popup
    Get.back();
  }

  // Cancel outgoing call (when user cancels before receiver picks up)
  Future<void> cancelOutgoingCall() async {
    print('❌ User cancelled outgoing call');
    _cancelOutgoingCallTimeout();
    _stopRingtone(); // Stop ringtone when call is cancelled
    callState.value = CallState.disconnected;
    
    // Notify the server that the call was cancelled
    try {
      await ApiManager.videoCallService.declineCall(
        appointmentId: appointmentId.value,
        callerId: callerId.value,
        receiverId: receiverId.value,
      );
      print('✅ Server notified of call cancellation');
    } catch (e) {
      print('⚠️ Failed to notify server of cancellation: $e');
    }
    
    // Leave the channel and reset state
    await _agoraService.leaveChannel();
    _stopCallTimer();
    _resetCallState();
    
    // Go back to previous screen immediately without any popup
    Get.back();
  }

  void _startRingingTimeout() {
    _ringingTimer?.cancel();
    _ringingTimer = Timer(Duration(minutes: 1), () {
      if (callState.value == CallState.ringing && !userAcceptedCall.value) {
        print('⏰ Call timed out after 1 minute');
        _stopRingtone(); // Stop ringtone on timeout
        callState.value = CallState.timeout;
        _resetCallState();
        Get.back();
      }
    });
  }

  void _cancelRingingTimeout() {
    _ringingTimer?.cancel();
    _ringingTimer = null;
  }

  void _setupAgoraEventListeners() {
    // Listen to Agora events to detect when receiver joins
    agoraService.remoteUsers.listen((users) {
      print('📡 Remote users changed: $users, current state: ${callState.value}');
      
      if (users.isNotEmpty && (callState.value == CallState.calling || callState.value == CallState.ringing)) {
        print('📞 Remote user joined! Call connected');
        callState.value = CallState.connected;
        wasCallEverConnected.value = true; // Mark that call was connected
        _stopRingtone(); // Stop ringtone when remote user joins
        _cancelOutgoingCallTimeout();
        _startCallTimer();
        
        // Start PiP tracking when call connects
        _startPipTracking();
        
        // Enable video and camera now that call is connected
        Future.delayed(Duration(milliseconds: 500), () async {
          print('📹 Enabling video streams now that call is connected...');
          print('📹 Current state - UI: ${isCameraPreviewActive.value}, Agora: ${agoraService.isVideoEnabled.value}');
          
          // If video is currently disabled, toggle it on using the proper method
          if (!agoraService.isVideoEnabled.value) {
            print('📹 Video is OFF, turning it ON via toggleCamera()...');
            await toggleCamera();
            
            // Force UI update to ensure local preview shows
            isCameraPreviewActive.refresh();
            print('📹 Forced UI refresh - isCameraPreviewActive: ${isCameraPreviewActive.value}');
          } else {
            print('📹 Video already enabled, ensuring streams are unmuted...');
            isCameraPreviewActive.value = true;
            await agoraService.engine.muteLocalVideoStream(false);
          }
          
          // Enable remote video streams
          for (int uid in users) {
            await agoraService.engine.muteRemoteVideoStream(uid: uid, mute: false);
          }
          
          print('✅ Cameras enabled - local and remote');
          print('📹 Final state - UI: ${isCameraPreviewActive.value}, Agora: ${agoraService.isVideoEnabled.value}');
        });
      } else if (users.isEmpty && callState.value == CallState.connected) {
        print('📞 Remote user left the call');
        callState.value = CallState.disconnected;
        
        // Show session ended sheet before ending the call
        _showSessionEndedAfterDisconnect();
      }
    });
    
    // Listen to remote camera state changes
    agoraService.remoteUsersCameraState.listen((cameraStates) {
      print('📹 Remote camera states changed: $cameraStates');
      if (cameraStates.isNotEmpty) {
        final firstRemoteUid = agoraService.remoteUsers.isNotEmpty 
            ? agoraService.remoteUsers.first 
            : null;
        if (firstRemoteUid != null && cameraStates.containsKey(firstRemoteUid)) {
          isRemoteCameraActive.value = cameraStates[firstRemoteUid] ?? true;
          print('📹 Remote camera active: ${isRemoteCameraActive.value}');
        }
      } else if (agoraService.remoteUsers.isNotEmpty && callState.value == CallState.connected) {
        // If no camera state info yet but user just connected, assume camera is ON
        isRemoteCameraActive.value = true;
        print('📹 Remote user connected, assuming camera is ON');
      }
    });
  }

  void _startOutgoingCallTimeout() {
    _ringingTimer?.cancel();
    _ringingTimer = Timer(Duration(minutes: 1), () {
      if (callState.value == CallState.calling || callState.value == CallState.ringing) {
        print('⏰ Outgoing call timed out after 1 minute');
        _stopRingtone(); // Stop ringtone on timeout
        callState.value = CallState.timeout;
        endVideoCall();
        // Don't show snackbar - message will be displayed in UI
        
        // Auto-close screen after 2 seconds when call times out
        Future.delayed(Duration(seconds: 2), () {
          if (callState.value == CallState.timeout) {
            Get.back(); // Close the video call screen
          }
        });
      }
    });
  }

  void _cancelOutgoingCallTimeout() {
    _ringingTimer?.cancel();
    _ringingTimer = null;
  }
  
  Future<void> _initializeAgoraService() async {
    try {
      print('🔄 Initializing Agora service from VideoCallController...');
      await _agoraService.initialize();
      print('✅ Agora service initialized in VideoCallController');
    } catch (e) {
      print('❌ Failed to initialize Agora service: $e');
      // Don't block the UI, just log the error
    }
  }
  
  /// Set up callback for when leaving channel to call end call API
  void _setupOnLeaveChannelCallback() {
    _agoraService.onLeaveChannelCallback = (int duration) async {
      
      // Only call end call API if we have valid call data
      // if (callId.value > 0 && appointmentId.value > 0) {
      //   try {
      //     await ApiManager.videoCallService.endCallWithDuration(
      //       callId: callId.value,
      //       appointmentId: appointmentId.value,
      //       duration: duration,
      //     );
      //   } catch (e) {
      //     print('❌ Error calling end call API: $e');
      //   }
      // } else {
      //   print('⚠️ Skipping end call API - missing call ID or appointment ID');
      // }
    };
  }
  
  // Debug permission status
  Future<void> debugPermissionStatus() async {
    print('🔬 Debug permission status...');
    await agoraService.debugPermissionStatus();
  }
  
  // Check permission status
  Future<void> checkPermissionStatus() async {
    print('🔍 Checking permission status...');
    await agoraService.checkPermissionStatus();
  }
  
  // Test permissions method
  Future<void> testPermissions() async {
    print('🧪 Testing permissions...');
    await agoraService.requestPermissions();
  }
  
  // Start a video call with Agora
  Future<void> startVideoCall({
    required int appointmentId,
    required int callerId, 
    required int receiverId,
    required String callerName,
    required String receiverName,
  }) async {
    try {
      print('📞 Starting video call...');
      callState.value = CallState.initiating;
      this.appointmentId.value = appointmentId;
      this.callerId.value = callerId;
      this.receiverId.value = receiverId;
      this.callerName.value = callerName;
      this.receiverName.value = receiverName;
      
      // Check if Agora is properly initialized
      if (!agoraService.isInitialized.value) {
        print('⚠️ Agora not initialized, trying to initialize...');
        await agoraService.initialize();
      }
      
      if (!agoraService.isInitialized.value) {
        throw Exception('Agora initialization failed. Cannot start video call.');
      }
      
      // Set to calling state immediately - don't show camera yet
      callState.value = CallState.calling; // Start with "Calling..."
      
      // Don't play ringtone for outgoing calls - only receiver should hear ringtone
      // Caller will just see "Calling..." status
      
      // Call the API to initiate the call and get channel details
      print('🌐 Calling API to initiate call...');
      final callResponse = await ApiManager.videoCallService.initiateCall(
        appointmentId: appointmentId,
        callerId: callerId,
        receiverId: receiverId,
      );
      final data = callResponse.data;
      channelName.value = data?.channelName ?? '';
      callId.value = data?.id ?? 0; // Store call ID for end call API
      
      print('📞 Call ID: ${callId.value}');
      print('📺 Channel: ${channelName.value}');
      // Check if API call was successful
      if (!callResponse.status || callResponse.data == null) {
        throw Exception(callResponse.message.isNotEmpty 
            ? callResponse.message 
            : 'Failed to initiate call');
      }
      
      // Use hardcoded values as requested (ignoring API response)
      
      print('📺 Channel (hardcoded): ${channelName.value}');
      print('🔑 Token (hardcoded): Token provided');
      
      // DON'T start camera preview yet - wait until call is accepted
      // We'll enable video when remote user joins
      
      // Initialize audio settings only
      await agoraService.initializeAudioSettings();
      
      // Ensure microphone is properly initialized (unmuted by default)
      print('🎤 Initializing microphone state...');
      _agoraService.isMuted.value = false;
      isMicActive.value = true;
      
      print('📞 Joining Agora channel...');
      try {
        await agoraService.joinChannel(
          channelName.value,
          uid: callerId, // Use actual caller ID as UID
        );
        print('✅ Successfully joined Agora channel');
        
        // Set up Agora event listener for user join events
        _setupAgoraEventListeners();
        
        // Start 1-minute timeout for outgoing call
        _startOutgoingCallTimeout();
        
        print('📞 Waiting for remote user to accept the call...');
        
      } catch (agoraError) {
        print('❌ Failed to join Agora channel: $agoraError');
        _stopRingtone();
        throw Exception('Failed to join video channel: $agoraError');
      }
      
      // If we reach here, everything succeeded
      // Don't automatically set to connected - wait for remote user to join
      print('✅ Video call initiated successfully - waiting for answer');
    } catch (e) {
      print('❌ Error starting video call: $e');
      callState.value = CallState.disconnected;
      
      // Show user-friendly error message
      String errorMessage = 'Failed to start video call';
      if (e.toString().contains('Agora initialization')) {
        errorMessage = 'Video service initialization failed';
      } else if (e.toString().contains('Call initiation failed')) {
        errorMessage = 'Could not connect to call service';
      } else if (e.toString().contains('Failed to initiate call')) {
        errorMessage = 'Call setup failed. Please try again.';
      } else if (e.toString().contains('Failed to join video channel')) {
        errorMessage = 'Could not join video call. Please check your connection.';
      } else if (e.toString().contains('AgoraRtcException(-7')) {
        errorMessage = 'Invalid call credentials. Please try again.';
      }
      
      Get.snackbar(
        'Call Failed', 
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      // Reset call state
      _resetCallState();
    }
  }
  
  // End the video call
  Future<void> endVideoCall() async {
    try {
      _stopRingtone(); // Stop ringtone when ending call
      
      await _agoraService.leaveChannel();
      callState.value = CallState.disconnected;
      _stopCallTimer();
      // Don't reset wasCallEverConnected here - we need it to determine if session sheet should show
      _resetCallState();
      
      print('📞 Video call ended');
    } catch (e) {
      print('❌ Error ending video call: $e');
    }
  }
  
  // Toggle microphone - Fixed version
  Future<void> toggleMicrophone() async {
    print('🎤 Controller: Toggling microphone...');
    print('🎤 Before toggle - UI: ${isMicActive.value ? "ACTIVE" : "MUTED"}, Agora: ${_agoraService.isMuted.value ? "MUTED" : "ACTIVE"}');
    
    try {
      // Call the Agora service toggle method and wait for result
      final success = await _agoraService.toggleMute();
      
      if (success) {
        // Directly sync with Agora's state (isMuted means mic is muted, so isMicActive should be opposite)
        isMicActive.value = !_agoraService.isMuted.value;
        
        print('✅ Controller: Microphone toggled successfully - UI: ${isMicActive.value ? "ACTIVE" : "MUTED"}, Agora: ${_agoraService.isMuted.value ? "MUTED" : "ACTIVE"}');
        
        // Force reactive update
        isMicActive.refresh();
        
        // Additional debug
        print('🔍 Post-toggle verification - isMicActive: ${isMicActive.value}, agoraService.isMuted: ${_agoraService.isMuted.value}');
        
      } else {
        print('❌ Controller: Microphone toggle failed, keeping current state');
      }
      
    } catch (e) {
      print('❌ Controller: Error toggling microphone: $e');
    }
  }
  
  // Synchronize microphone state between UI and Agora service
  Future<void> _syncMicrophoneState() async {
    print('🔄 Syncing microphone state...');
    
    // Ensure Agora service starts with unmuted state
    _agoraService.isMuted.value = false;
    
    // Sync UI state with Agora state
    isMicActive.value = !_agoraService.isMuted.value;
    
    print('✅ Microphone state synchronized - UI: ${isMicActive.value ? "ACTIVE" : "MUTED"}, Agora: ${_agoraService.isMuted.value ? "MUTED" : "ACTIVE"}');
    
    // Force reactive update
    isMicActive.refresh();
  }
  
  // Toggle video camera
  Future<void> toggleCamera() async {
    print('📹 Controller: Toggling camera...');
    print('📹 Before toggle - UI: ${isCameraPreviewActive.value ? "ON" : "OFF"}, Agora: ${_agoraService.isVideoEnabled.value ? "ON" : "OFF"}');
    
    // Toggle Agora video state
    await _agoraService.toggleVideo();
    
    // Sync UI state with Agora state
    isCameraPreviewActive.value = _agoraService.isVideoEnabled.value;
    
    // Force reactive update
    isCameraPreviewActive.refresh();
    
    print('✅ Controller: Camera toggled - UI: ${isCameraPreviewActive.value ? "ON" : "OFF"}, Agora: ${_agoraService.isVideoEnabled.value ? "ON" : "OFF"}');
    print('✅ UI state should now show: ${isCameraPreviewActive.value ? "VIDEO PREVIEW" : "PROFILE PICTURE"}');
  }

  // Comprehensive audio debug and fix method
  Future<void> debugAndFixAudio() async {
    print('🔬 Starting comprehensive audio debug...');
    
    try {
      // Debug current audio state
      print('📊 Current Audio State:');
      print('  - UI Mic Active: ${isMicActive.value}');
      print('  - Agora Muted: ${_agoraService.isMuted.value}');
      print('  - Agora Initialized: ${_agoraService.isInitialized.value}');
      print('  - Call State: ${callState.value}');
      
      // Reinitialize audio settings
      await _agoraService.initializeAudioSettings();
      
      // Force enable audio
      await _agoraService.engine.enableAudio();
      await _agoraService.engine.enableLocalAudio(true);
      await _agoraService.engine.muteLocalAudioStream(false);
      
      // Synchronize microphone state after audio fix
      await _syncMicrophoneState();
      
      print('✅ Audio debug and fix completed');
      
    } catch (e) {
      print('❌ Error in audio debug: $e');
    }
  }
  
  // Fix audio issues - useful for static sound problems
  Future<void> fixAudio() async {
    print('🔧 Manual audio fix initiated...');
    try {
      // Call the comprehensive audio debug and fix
      await agoraService.debugAudioStatus();
      
      // Synchronize microphone state after debug
      await _syncMicrophoneState();
      
      print('✅ Manual audio fix completed');
    } catch (e) {
      print('❌ Error in manual audio fix: $e');
    }
  }

  // Test ringtone playback - for debugging
  Future<void> testRingtone() async {
    print('🧪 Testing ringtone playback...');
    print('🧪 Testing multiple asset path formats...');
    
    try {
      // Test 1: Direct asset path
      print('🧪 Test 1: Direct asset path - assets/audio/slack_ringtone.mp3');
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.play(AssetSource('audio/slack_ringtone.mp3'));
      await Future.delayed(Duration(seconds: 2));
      await _audioPlayer.stop();
      print('✅ Test 1 successful');
      
    } catch (e) {
      print('❌ Test 1 failed: $e');
      
      try {
        // Test 2: Full asset path
        print('🧪 Test 2: Full asset path - assets/audio/slack_ringtone.mp3');
        await _audioPlayer.play(AssetSource('assets/audio/slack_ringtone.mp3'));
        await Future.delayed(Duration(seconds: 2));
        await _audioPlayer.stop();
        print('✅ Test 2 successful');
        
      } catch (e2) {
        print('❌ Test 2 failed: $e2');
        
        try {
          // Test 3: Alternative path format
          print('🧪 Test 3: Alternative format');
          await _audioPlayer.play(AssetSource('slack_ringtone.mp3'));
          await Future.delayed(Duration(seconds: 2));
          await _audioPlayer.stop();
          print('✅ Test 3 successful');
          
        } catch (e3) {
          print('❌ All tests failed');
          print('❌ Test 3 error: $e3');
        }
      }
    }
    
    print('✅ Ringtone test sequence completed');
  }

  // Debug video status
  Future<void> debugVideoStatus() async {
    print('🔬 Debug video status from controller...');
    await agoraService.debugVideoStatus();
  }
  
  // Refresh video if having issues
  Future<void> refreshVideo() async {
    print('🔄 Refreshing video from controller...');
    await agoraService.refreshVideoConfiguration();
  }
  
  // Fix audio issues - useful for static sound problems
  void _startCallTimer() {
    _callTimer?.cancel();
    callDuration.value = 0;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (callState.value == CallState.connected) {
        callDuration.value++;
      } else {
        timer.cancel();
      }
    });
  }
  
  void _stopCallTimer() {
    _callTimer?.cancel();
    // Don't reset callDuration here - we want to preserve it to show after call ends
  }
  
  void _resetCallState() {
    // callerName.value = '';
    // receiverName.value = '';
    // channelName.value = '';
    // rtcToken.value = '';
    // appointmentId.value = 0;
    // callerId.value = 0;
    // receiverId.value = 0;
    // callDuration.value = 0; // Reset call duration for new calls
    // isIncomingCall.value = false;
    // isRemoteCameraActive.value = true;
    hasPrescription.value = false; // Reset prescription status
    // // Don't reset wasCallEverConnected here - it's needed to show session ended sheet
    // It will be reset when actually closing the screen in onCallPressed()
    // Note: Don't reset current user info as it's persistent
    // Note: Don't reset remote user info as it may be needed for reconnection
  }
  
  String get formattedCallDuration {
    final duration = Duration(seconds: callDuration.value);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get callStatusText {
    switch (callState.value) {
      case CallState.idle:
        return '';
      case CallState.initiating:
        return 'Initiating call...';
      case CallState.calling:
        return 'Calling ${remoteUserName.value.isNotEmpty ? remoteUserName.value : ""}...';
      case CallState.ringing:
        return isIncomingCall.value ? 'Incoming call' : 'Ringing...';
      case CallState.connecting:
        return 'Connecting...';
      case CallState.connected:
        return formattedCallDuration;
      case CallState.disconnected:
        return 'Call ended';
      case CallState.timeout:
        return 'No answer';
    }
  }

  void onCallPressed({bool fromAppointment = false}) {
    if (isRinging.value) return;
    
    // Only show session ended sheet if call was ever connected
    if (wasCallEverConnected.value) {

    } else {
      // Call was never connected (timeout, cancelled, declined)
      // Just go back without showing session ended sheet
      wasCallEverConnected.value = false; // Reset before going back
      Get.back();
    }
  }

  void showSessionEndedBottomSheet() {
    Get.bottomSheet(
      SessionEndedSheet(
        doctorId: doctorId.value,
        doctorName: remoteUserName.value,
        callDuration: _agoraService.totalCallDuration.value,
        doctorImage: remoteUserProfilePicture.value,
        appointmentId: appointmentId.value,
        hasPrescription: hasPrescription.value,
      ),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
    );
  }
  
  /// Show session ended sheet after remote user disconnects
  void _showSessionEndedAfterDisconnect() async {
    print('📞 Showing session ended sheet after disconnect...');
    
    // Stop any timers and ringtones
    _stopRingtone();
    _stopCallTimer();
    _stopPipTracking();
    
    // Leave the Agora channel
    await _agoraService.leaveChannel();
    
    // Show the session ended sheet with doctor info and call duration
    Get.bottomSheet(
      SessionEndedSheet(
        doctorId: doctorId.value,
        doctorName: remoteUserName.value,
        callDuration: _agoraService.totalCallDuration.value,
        doctorImage: remoteUserProfilePicture.value,
        appointmentId: appointmentId.value,
        hasPrescription: hasPrescription.value,
      ),
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
    ).then((_) {
      // After sheet is dismissed, reset state and go back
      _resetCallState();
    });
  }
  
  // Ringtone methods
  Future<void> _playRingtone() async {
    try {
      print('🔊 Attempting to play ringtone...');
      print('🔊 AudioPlayer state: ${_audioPlayer.state}');
      
      // Check if audio file exists first - using Assets constant
      print('🔊 Attempting to load: ${Assets.ringtone}');
      
      // Set audio player configuration for ringtone playback
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      
      // For iOS, set audio session category to allow playback during Agora session
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      
      // Set volume to ensure it's audible
      await _audioPlayer.setVolume(1.0);
      
      print('🔊 Audio player configured, starting playback...');
      
      // Play the ringtone - AssetSource expects path WITHOUT "assets/" prefix
      await _audioPlayer.play(AssetSource('audio/slack_ringtone.mp3'));
      print('🔊 Ringtone started playing successfully');
      
      // Monitor playback state
      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        print('🔊 Audio player state changed to: $state');
      });
      
    } catch (e) {
      print('❌ Failed to play ringtone: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Stack trace: ${StackTrace.current}');
      
      // Try fallback - system sound or vibration
      try {
        print('🔄 Attempting fallback ringtone with different settings...');
        await _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
        await _audioPlayer.play(AssetSource('audio/slack_ringtone.mp3'));
        print('🔄 Fallback ringtone started');
      } catch (fallbackError) {
        print('❌ Fallback ringtone also failed: $fallbackError');
        print('❌ Fallback error type: ${fallbackError.runtimeType}');
      }
    }
  }
  
  Future<void> _stopRingtone() async {
    try {
      print('🔇 Stopping ringtone...');
      print('🔇 Current audio player state: ${_audioPlayer.state}');
      await _audioPlayer.stop();
      print('🔇 Ringtone stopped successfully');
    } catch (e) {
      print('❌ Failed to stop ringtone: $e');
    }
  }

  // PiP tracking methods
  void _startPipTracking() {
    print('🖼️ Starting PiP tracking for current call');
    try {
      _pipService.startCall(
        controller: this,
        remoteUserName: remoteUserName.value,
        remoteUserProfilePicture: remoteUserProfilePicture.value,
        channelName: channelName.value,
        callerId: callerId.value.toString(),
      );
    } catch (e) {
      print('❌ Error starting PiP tracking: $e');
    }
  }
  
  void _stopPipTracking() {
    print('🖼️ Stopping PiP tracking');
    try {
      // Only stop if tracking is active
      if (isInPipMode.value || _pipService.isCallOngoing.value) {
        _pipService.endCall();
        isInPipMode.value = false;
        print('✅ PiP tracking stopped');
      } else {
        print('🖼️ PiP tracking already stopped');
      }
    } catch (e) {
      print('❌ Error stopping PiP tracking: $e');
    }
  }
  
  /// Enter Picture-in-Picture mode
  Future<void> enterPipMode() async {
    if (callState.value != CallState.connected) {
      print('⚠️ Cannot enter PiP: Call not connected');
      return;
    }
    
    try {
      print('🖼️ Entering PiP mode from video call screen');
      isInPipMode.value = true;
      
      // Transfer call ownership to PiP service before navigating away
      await _pipService.takeOverCall(this);
      
      // Now safely navigate back - the PiP service has control
      Get.back();
      
      print('✅ Successfully entered PiP mode');
    } catch (e) {
      print('❌ Error entering PiP mode: $e');
      isInPipMode.value = false;
    }
  }
  
  /// Exit Picture-in-Picture mode
  Future<void> exitPipMode() async {
    try {
      print('🖼️ Exiting PiP mode');
      isInPipMode.value = false;
      await _pipService.exitPipMode();
    } catch (e) {
      print('❌ Error exiting PiP mode: $e');
    }
  }
  
  /// Handle back button press - enter PiP instead of ending call
  Future<bool> handleBackPress() async {
    if (callState.value == CallState.connected && !isInPipMode.value) {
      // If call is connected and not already in PiP, enter PiP mode
      await enterPipMode();
      return false; // Prevent default back action
    } else {
      // Allow default back action for other states
      return true;
    }
  }

  @override
  void onClose() {
    print('🎬 VideoCallController onClose called');
    _stopRingtone();
    _audioPlayer.dispose();
    
    // Only stop PiP tracking if we're not in PiP mode
    // The PiP service will handle cleanup when the call actually ends
    if (!isInPipMode.value) {
      print('🖼️ Stopping PiP tracking (not in PiP mode)');
      _stopPipTracking(); // Stop PiP tracking when controller is disposed
      
      _stopCallTimer();
      _cancelRingingTimeout();
      _cancelOutgoingCallTimeout();
      
      // Only call endVideoCall if still connected/ongoing and not in PiP mode
      if (callState.value != CallState.disconnected && callState.value != CallState.idle) {
        endVideoCall();
      }
    } else {
      print('🖼️ In PiP mode - leaving call management to PiP service');
      // Just stop timers and cancel timeouts, but don't end the call
      _stopCallTimer();
      _cancelRingingTimeout();
      _cancelOutgoingCallTimeout();
    }
    
    super.onClose();
  }
}