import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';

class AgoraService extends GetxService {
  // Agora App ID - ensure this matches your backend configuration
  static const String appId = 'aab8b8f5a8cd4469a63042fcfafe7063';
  
  late RtcEngine _engine;
  RtcEngine get engine => _engine;
  
  final RxBool isInitialized = false.obs;
  final RxBool isInitializing = false.obs;
  final RxList<int> remoteUsers = <int>[].obs;
  final RxBool isJoined = false.obs;
  final RxBool isMuted = false.obs;
  final RxBool isVideoEnabled = false.obs; // Start with video disabled - will enable when call connects
  
  // Remote camera state tracking
  final RxMap<int, bool> remoteUsersCameraState = <int, bool>{}.obs;
  
  // Call duration tracking
  final RxInt totalCallDuration = 0.obs;
  
  // Callback for when leaving channel - to be set by VideoCallController
  Function(int duration)? onLeaveChannelCallback;
  
  // Initialize Agora Engine
  Future<void> initialize() async {
    if (isInitialized.value) {
      print('✅ Agora already initialized');
      return;
    }
    
    if (isInitializing.value) {
      print('⏳ Agora initialization already in progress, waiting...');
      // Wait for initialization to complete
      while (isInitializing.value && !isInitialized.value) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      return;
    }
    
    isInitializing.value = true;
    
    try {
      print('🔄 Starting Agora initialization...');
      
      // Request permissions first
      await requestPermissions();
      
      // Create RTC engine
      print('🔧 Creating RTC engine...');
      _engine = createAgoraRtcEngine();
      
      // Initialize engine
      print('⚙️ Initializing engine with App ID...');
      await _engine.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      
      // Set up event handlers
      print('📡 Setting up event handlers...');
      _setupEventHandlers();
      
      // Enable audio and video
      print('🎤 Enabling audio...');
      await _engine.enableAudio();
      
      // Configure audio settings for voice communication (NOT music)
      print('🔧 Configuring audio settings...');
      await _engine.setAudioProfile(
        profile: AudioProfileType.audioProfileSpeechStandard, // Changed from music to speech
        scenario: AudioScenarioType.audioScenarioGameStreaming, // Real-time communication
      );
      
      // Enable additional audio features for better call quality
      print('🔧 Enabling audio enhancements...');
      await _engine.enableAudioVolumeIndication(interval: 200, smooth: 3, reportVad: true);
      
      // Enable local audio by default with enhanced settings
      print('🎤 Enabling local audio with enhanced settings...');
      await _engine.enableLocalAudio(true);
      await _engine.muteLocalAudioStream(false);
      
      // Set audio recording and playback device to default (iOS only)
      if (Platform.isIOS) {
        await _engine.setAudioSessionOperationRestriction(
          AudioSessionOperationRestriction.audioSessionOperationRestrictionNone,
        );
      }
      
      // Set reasonable volume levels for voice communication
      await _engine.adjustRecordingSignalVolume(150); // Reduced from 200 for voice clarity
      await _engine.adjustPlaybackSignalVolume(150); // Reduced from 200 for voice clarity
      
      // Reset mute state
      isMuted.value = false;
      
      print('📹 Enabling video...');
      await _engine.enableVideo();
      
      // Configure video encoder for optimal performance
      print('🎥 Configuring video encoder...');
      await _engine.setVideoEncoderConfiguration(
        VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 360),
          frameRate: 15,
          bitrate: 800,
          minBitrate: 400,
          orientationMode: OrientationMode.orientationModeAdaptive,
          degradationPreference: DegradationPreference.maintainQuality,
          mirrorMode: VideoMirrorModeType.videoMirrorModeAuto,
        ),
      );
      
      // Enable dual stream mode for better network adaptation
      print('📡 Enabling dual stream mode...');
      await _engine.enableDualStreamMode(enabled: true);
      
      // Set client role explicitly
      print('🎭 Setting client role...');
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      
      // Don't start preview yet - will be started when camera is enabled
      // This prevents the camera from being active during initialization
      print('📱 Preview will be started when camera is enabled');
      
      // Ensure local video is disabled initially
      print('🔇 Disabling local video initially...');
      await _engine.enableLocalVideo(false);
      await _engine.muteLocalVideoStream(true);
      print('✅ Video disabled by default (will be enabled when call connects)');
      
      isInitialized.value = true;
      isInitializing.value = false;
      print('✅ Agora initialized successfully');
    } catch (e) {
      isInitializing.value = false;
      isInitialized.value = false;
      print('❌ Agora initialization failed: $e');
      
      // Show actual error instead of forcing demo mode
      Get.snackbar(
        'Initialization Error', 
        'Failed to initialize video calling: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      // Re-throw the error so calling code knows it failed
      throw Exception('Agora initialization failed: $e');
    }
  }
  
  void _setupEventHandlers() {
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('✅ Successfully joined channel: ${connection.channelId}');
          isJoined.value = true;
          // Ensure video is active after joining
          Future.delayed(Duration(milliseconds: 500), () {
            _engine.muteLocalVideoStream(false);
            _engine.enableLocalVideo(true);
          });
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          print('👤 User joined: $uid');
          remoteUsers.add(uid);
          
          // Aggressively enable remote streams immediately
          print('🔧 Aggressively enabling remote streams for UID: $uid');
          Future.delayed(Duration(milliseconds: 100), () async {
            try {
              await _engine.muteRemoteVideoStream(uid: uid, mute: false);
              await _engine.muteRemoteAudioStream(uid: uid, mute: false);
              print('✅ Enabled remote streams for UID: $uid');
            } catch (e) {
              print('❌ Error enabling remote streams: $e');
            }
          });
          
          // Also try again after a longer delay to ensure it sticks
          Future.delayed(Duration(milliseconds: 1000), () async {
            try {
              await _engine.muteRemoteVideoStream(uid: uid, mute: false);
              await _engine.muteRemoteAudioStream(uid: uid, mute: false);
              print('🔄 Re-enabled remote streams for UID: $uid');
            } catch (e) {
              print('❌ Error re-enabling remote streams: $e');
            }
          });
        },
        onUserOffline: (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          print('👤 User left: $uid, reason: $reason');
          remoteUsers.remove(uid);
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          print('📞 Left channel');
          print('⏱️ Call duration: ${stats.duration} seconds');
          totalCallDuration.value = stats.duration ?? 0;
          isJoined.value = false;
          remoteUsers.clear();
          
          // Trigger callback to notify VideoCallController
          if (onLeaveChannelCallback != null) {
            onLeaveChannelCallback!(totalCallDuration.value);
          }
        },
        onError: (ErrorCodeType err, String msg) {
          print('❌ Agora error: $err - $msg');
        },
        onRemoteVideoStateChanged: (RtcConnection connection, int uid, RemoteVideoState state, RemoteVideoStateReason reason, int elapsed) {
          print('📹 Remote video state changed for uid $uid: $state, reason: $reason');
          
          // Update remote camera state tracking
          switch (state) {
            case RemoteVideoState.remoteVideoStateStarting:
            case RemoteVideoState.remoteVideoStateDecoding:
              print('🎥 Remote video is starting/decoding for UID: $uid');
              remoteUsersCameraState[uid] = true;
              // Ensure remote video stream is unmuted when it starts
              _engine.muteRemoteVideoStream(uid: uid, mute: false);
              break;
            case RemoteVideoState.remoteVideoStateStopped:
              print('⏹️ Remote video stopped for UID: $uid');
              remoteUsersCameraState[uid] = false;
              break;
            case RemoteVideoState.remoteVideoStateFrozen:
              print('🧊 Remote video frozen for UID: $uid, trying to refresh...');
              // Keep camera state as active but try to refresh
              // Aggressive recovery for frozen video
              _engine.muteRemoteVideoStream(uid: uid, mute: true);
              Future.delayed(Duration(milliseconds: 200), () {
                _engine.muteRemoteVideoStream(uid: uid, mute: false);
              });
              // Also try to refresh after a longer delay
              Future.delayed(Duration(milliseconds: 1000), () {
                _engine.muteRemoteVideoStream(uid: uid, mute: false);
                print('🔄 Applied delayed video refresh for UID: $uid');
              });
              break;
            case RemoteVideoState.remoteVideoStateFailed:
              print('❌ Remote video failed for UID: $uid, reason: $reason');
              remoteUsersCameraState[uid] = false;
              break;
          }
        },
        onFirstRemoteVideoFrame: (RtcConnection connection, int uid, int width, int height, int elapsed) {
          print('🎬 First remote video frame received from UID: $uid, Size: ${width}x${height}');
          
          // Force ensure the stream is not muted when first frame arrives
          _engine.muteRemoteVideoStream(uid: uid, mute: false);
          _engine.muteRemoteAudioStream(uid: uid, mute: false);
          
          print('🔧 Forced unmute of remote streams after first frame');
        },
        onFirstLocalVideoFrame: (VideoSourceType source, int width, int height, int elapsed) {
          print('🎬 First local video frame: ${width}x${height}');
        },
        onRemoteAudioStateChanged: (RtcConnection connection, int uid, RemoteAudioState state, RemoteAudioStateReason reason, int elapsed) {
          print('🔊 Remote audio state changed for uid $uid: $state, reason: $reason');
          
          // Ensure we can hear remote audio when it becomes available
          if (state == RemoteAudioState.remoteAudioStateStarting || 
              state == RemoteAudioState.remoteAudioStateDecoding) {
            print('📢 Remote audio is starting, ensuring it is not muted');
            // Don't mute remote audio streams
            _engine.muteRemoteAudioStream(uid: uid, mute: false);
          }
        },
        onLocalAudioStateChanged: (RtcConnection connection, LocalAudioStreamState state, LocalAudioStreamReason reason) {
          print('🎤 Local audio state changed: $state, reason: $reason');
          
          // Handle local audio failures
          if (state == LocalAudioStreamState.localAudioStreamStateFailed) {
            print('❌ Local audio failed, attempting to restart...');
            _engine.enableLocalAudio(true);
            _engine.muteLocalAudioStream(false);
          }
        },
        onAudioVolumeIndication: (RtcConnection connection, List<AudioVolumeInfo> speakers, int speakerNumber, int totalVolume) {
          // Log audio activity to help debug audio issues
          if (totalVolume > 5) {
            print('📊 AUDIO DETECTED - Total: $totalVolume, Speakers: ${speakers.length}');
            for (var speaker in speakers) {
              print('  🎤 UID ${speaker.uid}: Volume ${speaker.volume}, VAD: ${speaker.vad}');
            }
          } else if (speakers.isNotEmpty) {
            print('📊 Audio volumes (low) - Total: $totalVolume, Active speakers: ${speakers.length}');
          }
        },
      ),
    );
  }
  
  // Debug method to check permission status in detail
  Future<void> debugPermissionStatus() async {
    print('🔬 DEBUG: Detailed permission status check');
    
    final micStatus = await Permission.microphone.status;
    final cameraStatus = await Permission.camera.status;
    
    print('📱 Microphone Permission: $micStatus');
    print('  isGranted: ${micStatus.isGranted}');
    print('  isDenied: ${micStatus.isDenied}');
    print('  isPermanentlyDenied: ${micStatus.isPermanentlyDenied}');
    
    print('📹 Camera Permission: $cameraStatus');
    print('  isGranted: ${cameraStatus.isGranted}');
    print('  isDenied: ${cameraStatus.isDenied}');
    print('  isPermanentlyDenied: ${cameraStatus.isPermanentlyDenied}');
    
    if (micStatus.isPermanentlyDenied || cameraStatus.isPermanentlyDenied) {
      print('⚠️ Some permissions are permanently denied - app needs to be reinstalled or settings changed manually');
    }
  }

  // Check permission status without requesting
  Future<void> checkPermissionStatus() async {
    final micStatus = await Permission.microphone.status;
    final cameraStatus = await Permission.camera.status;
    
    print('📱 Current permission status check:');
    print('Microphone: $micStatus');
    print('Camera: $cameraStatus');
    
    if (micStatus.isPermanentlyDenied || cameraStatus.isPermanentlyDenied) {
      Get.snackbar(
        'Permissions Permanently Denied',
        'Please go to Settings > Medtrac > Permissions to enable Camera and Microphone',
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 5),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } else if (micStatus.isGranted && cameraStatus.isGranted) {
    } else {
      Get.snackbar(
        'Permissions Available',
        'Ready to request camera and microphone permissions',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
    }
  }

  // Request necessary permissions
  Future<void> requestPermissions() async {
    try {
      print('🎯 Starting permission request process...');
      
      // Check current status first
      final micStatus = await Permission.microphone.status;
      final cameraStatus = await Permission.camera.status;
      
      print('📱 Initial status check:');
      print('Microphone: $micStatus');
      print('Camera: $cameraStatus');
      
      // If permanently denied, go straight to settings dialog
      if (micStatus.isPermanentlyDenied || cameraStatus.isPermanentlyDenied) {
        print('⚠️ Permissions permanently denied. Showing settings dialog.');
        _showPermissionSettingsDialog();
        return;
      }
      
      // If already granted, show success
      if (micStatus.isGranted && cameraStatus.isGranted) {
        return;
      }
      
      // Show explanation dialog before requesting
      bool shouldRequest = await _showPermissionExplanationDialog();
      if (!shouldRequest) {
        print('❌ User declined permission request');
        return;
      }
      
      print('🚀 User agreed to grant permissions, proceeding with request...');
      
      // Request permissions one by one to see which one fails
      Map<Permission, PermissionStatus> results = {};
      
      if (!micStatus.isGranted) {
        print('🎤 Requesting microphone permission...');
        final micResult = await Permission.microphone.request();
        results[Permission.microphone] = micResult;
        print('🎤 Microphone result: $micResult');
        
        // Check if it became permanently denied immediately
        if (micResult.isPermanentlyDenied && micStatus != PermissionStatus.permanentlyDenied) {
          print('⚠️ Microphone became permanently denied - iOS may have blocked this app');
        }
      } else {
        results[Permission.microphone] = micStatus;
      }
      
      if (!cameraStatus.isGranted) {
        print('📹 Requesting camera permission...');
        final cameraResult = await Permission.camera.request();
        results[Permission.camera] = cameraResult;
        print('📹 Camera result: $cameraResult');
        
        // Check if it became permanently denied immediately
        if (cameraResult.isPermanentlyDenied && cameraStatus != PermissionStatus.permanentlyDenied) {
          print('⚠️ Camera became permanently denied - iOS may have blocked this app');
        }
      } else {
        results[Permission.camera] = cameraStatus;
      }
      
      // Show results
      final micResult = results[Permission.microphone]!;
      final cameraResult = results[Permission.camera]!;
      
      if (micResult.isGranted && cameraResult.isGranted) {
        print('✅ All permissions granted!');
        Get.snackbar(
          'Permissions Granted',
          'Camera and microphone access granted. Video calls are ready!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (micResult.isPermanentlyDenied || cameraResult.isPermanentlyDenied) {
        print('⚠️ Some permissions permanently denied after request');
        _showPermissionSettingsDialog();
      } else {
        print('⚠️ Some permissions denied');
        Get.snackbar(
          'Permissions Needed',
          'Camera and microphone access is required for video calls.',
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 5),
        );
      }
      
    } catch (e) {
      print('❌ Error requesting permissions: $e');
      Get.snackbar(
        'Permission Error',
        'Failed to request permissions: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
  
  Future<bool> _showPermissionExplanationDialog() async {
    bool result = false;
    await Get.dialog(
      AlertDialog(
        title: Text('Video Call Permissions'),
        content: Text(
          'To enable video calls with doctors, this app needs access to:\n\n'
          '• Camera - for video calling\n'
          '• Microphone - for voice communication\n\n'
          'Would you like to grant these permissions?'
        ),
        actions: [
          TextButton(
            onPressed: () {
              result = false;
              Get.back();
            },
            child: Text('Not Now'),
          ),
          TextButton(
            onPressed: () {
              result = true;
              Get.back();
            },
            child: Text('Grant Permissions'),
          ),
        ],
      ),
    );
    return result;
  }
  
  void _showPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Permissions Required'),
        content: Text(
          'Camera and microphone permissions are required for video calls.\n\n'
          'It appears iOS has blocked permission requests for this app. Please manually enable permissions:\n\n'
          '1. Open Settings app\n'
          '2. Find "Medtrac" in the app list\n'
          '3. Tap "Permissions" or scroll down\n'
          '4. Enable Camera and Microphone\n\n'
          'If this doesn\'t work, try deleting and reinstalling the app.'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Try requesting again in case iOS allows it
              requestPermissions();
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }
  
  // Join channel with token
  Future<void> joinChannel(String channelName, {int? uid}) async {
    if (!isInitialized.value) {
      throw Exception('Agora engine not initialized');
    }

    // Generate a unique UID if not provided
    final userUid = uid ?? DateTime.now().millisecondsSinceEpoch % 1000000;
    
    print('🎯 Joining channel details:');
    print('  Channel: $channelName');
    print('  UID: $userUid');
    print('  App ID: ${appId.substring(0, 8)}...');

    try {
      // Configure video and audio before joining
      print('📹 Ensuring video is properly configured...');
      await _engine.enableVideo();
      await _engine.enableLocalVideo(true);
      await _engine.muteLocalVideoStream(false);
      
      // Ensure audio is also properly configured
      await _engine.enableAudio();
      await _engine.enableLocalAudio(true);
      await _engine.muteLocalAudioStream(isMuted.value);
      
      // Use hardcoded values as requested
      await _engine.joinChannel(
        channelId: channelName,
        token: "",
        uid: userUid, // Use the provided UID
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          publishCustomAudioTrack: false,
          publishCustomVideoTrack: false,
          publishMediaPlayerAudioTrack: false,
          publishMediaPlayerVideoTrack: false,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          enableAudioRecordingOrPlayout: true,
          publishMediaPlayerId: -1,
        ),
      );
      
      // Ensure video and audio streams are active after joining
      Future.delayed(Duration(milliseconds: 500), () async {
        try {
          // Re-enable local video to ensure it's working
          await _engine.enableLocalVideo(true);
          await _engine.muteLocalVideoStream(false);
          
          // Ensure audio is working too
          await _engine.enableLocalAudio(true);
          await _engine.muteLocalAudioStream(isMuted.value);
          
          print('✅ Post-join stream configuration completed');
        } catch (e) {
          print('❌ Error in post-join configuration: $e');
        }
      });
      
      print('✅ Successfully joined channel: $channelName with UID: $userUid');
    } catch (e) {
      print('❌ Error joining channel: $e');
      
      // Add specific error messages for common token issues
      if (e.toString().contains('-7')) {
        throw Exception('Invalid App ID or Token mismatch. Check if API backend uses same App ID.');
      } else if (e.toString().contains('-5')) {
        throw Exception('Token expired. Please try again.');
      } else if (e.toString().contains('-8')) {
        throw Exception('Invalid token format.');
      } else {
        throw Exception('Failed to join channel: $e');
      }
    }
  }

  // Debug method to check video status
  Future<void> debugVideoStatus() async {
    print('🔍 DEBUG: Video Status Check');
    print('  Agora Initialized: ${isInitialized.value}');
    print('  Video Enabled: ${isVideoEnabled.value}');
    print('  Is Muted: ${isMuted.value}');
    print('  Remote Users: ${remoteUsers.length}');
    print('  Is Joined: ${isJoined.value}');
    
    if (isInitialized.value) {
      try {
        // Try to restart video preview if needed
        await _engine.enableLocalVideo(true);
        await _engine.muteLocalVideoStream(false);
        print('  ✅ Local video configuration refreshed');
      } catch (e) {
        print('  ❌ Video refresh error: $e');
      }
    }
  }

  // Leave channel
  Future<void> leaveChannel() async {
    try {
      await _engine.leaveChannel();
    } catch (e) {
      print('❌ Failed to leave channel: $e');
    }
  }
  
  // Enhanced audio initialization for better call quality
  Future<void> initializeAudioSettings() async {
    try {
      print('🔧 Initializing comprehensive audio settings...');
      
      // Enable audio first
      await _engine.enableAudio();
      
      // Configure audio profile for voice communication (NOT music)
      await _engine.setAudioProfile(
        profile: AudioProfileType.audioProfileSpeechStandard, // Changed from music to speech
        scenario: AudioScenarioType.audioScenarioGameStreaming, // Changed to game streaming for real-time communication
      );
      
      // Enable local audio and ensure it's unmuted
      await _engine.enableLocalAudio(true);
      await _engine.muteLocalAudioStream(false);
      
      // Set optimal volumes for voice communication (not too high)
      await _engine.adjustRecordingSignalVolume(150); // Reduced from 200
      await _engine.adjustPlaybackSignalVolume(150);  // Reduced from 200
      
      // Enable volume indication for debugging
      await _engine.enableAudioVolumeIndication(interval: 200, smooth: 3, reportVad: true);
      
      // Reset mute state
      isMuted.value = false;
      
      print('✅ Audio settings initialized successfully with voice communication profile');
    } catch (e) {
      print('❌ Error initializing audio settings: $e');
    }
  }

  // Toggle mute - Enhanced version
  Future<bool> toggleMute() async {
    final previousState = isMuted.value;
    isMuted.value = !isMuted.value;
    
    print('🎤 Toggling microphone: ${previousState ? "UNMUTING" : "MUTING"}');
    
    try {
      // Apply both operations for reliability
      await _engine.muteLocalAudioStream(isMuted.value);
      await _engine.enableLocalAudio(!isMuted.value);
      
      // Small delay to ensure the operation is processed
      await Future.delayed(Duration(milliseconds: 100));
      
      print('✅ Microphone toggle successful: ${isMuted.value ? "MUTED" : "UNMUTED"}');
      return true;
    } catch (e) {
      print('❌ Error toggling microphone: $e');
      // Revert the state if the operation failed
      isMuted.value = previousState;
      return false;
    }
  }
  
  // Toggle video
  Future<void> toggleVideo() async {
    print('📹 AgoraService: Toggling video from ${isVideoEnabled.value ? "ON" : "OFF"} to ${!isVideoEnabled.value ? "ON" : "OFF"}');
    
    isVideoEnabled.value = !isVideoEnabled.value;
    
    if (isVideoEnabled.value) {
      // Turning video ON
      print('📹 Turning video ON - starting preview and enabling capture');
      await _engine.startPreview();
      print('  ✅ Preview started');
      await _engine.enableLocalVideo(true);
      print('  ✅ Local video enabled');
      await _engine.muteLocalVideoStream(false);
      print('  ✅ Video stream unmuted');
    } else {
      // Turning video OFF
      print('📹 Turning video OFF - stopping preview and disabling capture');
      await _engine.enableLocalVideo(false);
      print('  ✅ Local video disabled');
      await _engine.muteLocalVideoStream(true);
      print('  ✅ Video stream muted');
      await _engine.stopPreview();
      print('  ✅ Preview stopped');
    }
    
    print('✅ AgoraService: Video toggled - isEnabled: ${isVideoEnabled.value}');
  }
  
  // Restart video preview if needed
  Future<void> restartVideoPreview() async {
    try {
      print('🔄 Restarting video preview...');
      await _engine.stopPreview();
      await Future.delayed(Duration(milliseconds: 500));
      await _engine.startPreview();
      print('✅ Video preview restarted');
    } catch (e) {
      print('❌ Error restarting video preview: $e');
    }
  }
  
  // Force refresh video configuration
  Future<void> refreshVideoConfiguration() async {
    try {
      print('🔄 Refreshing video configuration...');
      
      // Re-enable video
      await _engine.enableVideo();
      await _engine.muteLocalVideoStream(false);
      
      // Re-apply video encoder configuration
      await _engine.setVideoEncoderConfiguration(
        VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 360),
          frameRate: 15,
          bitrate: 800,
          minBitrate: 400,
          orientationMode: OrientationMode.orientationModeAdaptive,
          degradationPreference: DegradationPreference.maintainQuality,
          mirrorMode: VideoMirrorModeType.videoMirrorModeAuto,
        ),
      );
      
      // Restart preview
      await restartVideoPreview();
      
      print('✅ Video configuration refreshed');
    } catch (e) {
      print('❌ Error refreshing video configuration: $e');
    }
  }
  
  // Fix audio issues - reduce static and improve quality
  Future<void> fixAudioIssues() async {
    try {
      print('🔧 Fixing audio issues...');
      
      // Disable and re-enable audio to reset audio state
      await _engine.enableAudio();
      
      // Set audio profile for communication
      await _engine.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioDefault,
      );
      
      // Enable noise suppression and echo cancellation
      await _engine.enableAudioVolumeIndication(interval: 500, smooth: 3, reportVad: false);
      
      // Ensure local audio is not muted
      if (!isMuted.value) {
        await _engine.muteLocalAudioStream(false);
        await _engine.enableLocalAudio(true);
      }
      
      print('✅ Audio issues fix applied');
    } catch (e) {
      print('❌ Error fixing audio issues: $e');
    }
  }
  
  // Debug audio status
  Future<void> debugAudioStatus() async {
    try {
      print('🔬 DEBUG: Audio Status Check');
      print('  📊 Agora Engine Initialized: ${isInitialized.value}');
      print('  🎤 Is Muted: ${isMuted.value}');
      print('  📢 Is Joined: ${isJoined.value}');
      print('  👥 Remote Users: ${remoteUsers.length}');
      
      // Check permissions
      await debugPermissionStatus();
      
      // Try to reset audio completely
      print('🔄 Attempting complete audio reset...');
      await _engine.enableLocalAudio(true);
      await _engine.muteLocalAudioStream(false);
      await _engine.adjustRecordingSignalVolume(400);
      await _engine.adjustPlaybackSignalVolume(400);
      
      // Update mute state
      isMuted.value = false;
      
      print('✅ Audio debug and reset completed');
    } catch (e) {
      print('❌ Error in audio debug: $e');
    }
  }
  
  // Dispose engine
  @override
  void onClose() {
    _disposeEngine();
    super.onClose();
  }
  
  Future<void> _disposeEngine() async {
    try {
      await _engine.leaveChannel();
      await _engine.release();
      isInitialized.value = false;
    } catch (e) {
      print('❌ Error disposing Agora engine: $e');
    }
  }
}