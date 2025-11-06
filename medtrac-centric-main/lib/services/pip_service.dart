import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:medtrac/controllers/video_call_controller.dart';

class PipService extends GetxService {
  static PipService get instance => Get.find<PipService>();
  
  // PiP state management
  final RxBool isPipActive = false.obs;
  final RxBool isCallOngoing = false.obs;
  final RxString currentCallerId = ''.obs;
  final RxString currentChannelName = ''.obs;
  
  // PiP position management
  final RxDouble pipTopPosition = 100.0.obs;
  final RxDouble pipRightPosition = 20.0.obs;
  
  // Store call details for PiP mode
  final RxString remoteUserName = ''.obs;
  final RxString remoteUserProfilePicture = ''.obs;
  final RxString callDuration = ''.obs;
  final Rx<CallState> callState = CallState.idle.obs;
  
  VideoCallController? _currentCallController;
  OverlayEntry? _overlayEntry;
  Timer? _durationTimer;
  int _callStartTime = 0; // Store when the call started (in seconds since epoch)
  
  @override
  void onInit() {
    super.onInit();
    print('🖼️ PipService initialized');
    
    // Initialize default position
    _resetPipPosition();
  }
  
  /// Reset PiP to default position
  void _resetPipPosition() {
    pipTopPosition.value = 100.0;
    pipRightPosition.value = 20.0;
  }
  
  /// Start tracking an ongoing call
  void startCall({
    required VideoCallController controller,
    required String remoteUserName,
    required String remoteUserProfilePicture,
    required String channelName,
    required String callerId,
  }) {
    print('📱 PipService: Starting call tracking');
    _currentCallController = controller;
    isCallOngoing.value = true;
    currentCallerId.value = callerId;
    currentChannelName.value = channelName;
    this.remoteUserName.value = remoteUserName;
    this.remoteUserProfilePicture.value = remoteUserProfilePicture;
    
    // Listen to call state changes
    _listenToCallStateChanges();
  }
  
  /// Stop tracking the call
  void endCall() {
    print('📱 PipService: Ending call tracking');
    
    // Hide PiP overlay first
    if (isPipActive.value && _overlayEntry != null) {
      print('🖼️ Removing PiP overlay due to call end');
      hidePip();
    }
    
    // Stop the duration timer
    _stopDurationTimer();
    
    isCallOngoing.value = false;
    isPipActive.value = false;
    currentCallerId.value = '';
    currentChannelName.value = '';
    remoteUserName.value = '';
    remoteUserProfilePicture.value = '';
    callDuration.value = '';
    callState.value = CallState.idle;
    _currentCallController = null;
    
    print('✅ PiP service call tracking ended and overlay removed');
  }
  
  /// Start independent duration timer for PiP mode
  void _startDurationTimer() {
    _stopDurationTimer(); // Stop any existing timer
    
    _durationTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isCallOngoing.value || !isPipActive.value) {
        _stopDurationTimer();
        return;
      }
      
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final elapsed = currentTime - _callStartTime;
      final newDuration = _formatDuration(elapsed);
      
      if (callDuration.value != newDuration) {
        callDuration.value = newDuration;
        print('🖼️ PiP duration updated independently: ${callDuration.value}');
      }
    });
    
    print('⏱️ PiP duration timer started');
  }
  
  /// Stop the duration timer
  void _stopDurationTimer() {
    if (_durationTimer != null) {
      _durationTimer!.cancel();
      _durationTimer = null;
      print('⏱️ PiP duration timer stopped');
    }
  }
  
  /// Take over call management from VideoCallController during PiP transition
  Future<void> takeOverCall(VideoCallController controller) async {
    print('🖼️ PiP Service taking over call management');
    
    // Only allow PiP for connected calls
    if (controller.callState.value != CallState.connected) {
      print('⚠️ Cannot enter PiP: Call is not connected (state: ${controller.callState.value})');
      return;
    }
    
    // Store the current call controller
    _currentCallController = controller;
    
    // Update our internal state with current call information
    isCallOngoing.value = true;
    isPipActive.value = false; // Will be set to true when we enter PiP
    currentCallerId.value = controller.callerId.value.toString();
    currentChannelName.value = controller.channelName.value;
    remoteUserName.value = controller.remoteUserName.value;
    remoteUserProfilePicture.value = controller.remoteUserProfilePicture.value;
    callState.value = controller.callState.value;
    
    // Get current call duration and calculate start time
    final duration = controller.callDuration.value;
    callDuration.value = _formatDuration(duration);
    _callStartTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - duration;
    
    // Start independent duration timer
    _startDurationTimer();
    
    // Set up listeners for ongoing updates
    _listenToCallStateChanges();
    
    // Now enter PiP mode
    await enterPipMode();
    
    print('✅ PiP Service successfully took over call management');
  }
  Future<void> enterPipMode() async {
    if (!isCallOngoing.value || isPipActive.value || callState.value != CallState.connected) {
      print('⚠️ Cannot enter PiP: Call not ongoing (${isCallOngoing.value}), PiP already active (${isPipActive.value}), or call not connected (${callState.value})');
      return;
    }
    
    try {
      print('🖼️ Entering Picture-in-Picture mode');
      isPipActive.value = true;
      
      // Reset PiP position to default
      _resetPipPosition();
      
      // Show the PiP floating widget using overlay
      await showPip();
      
      print('✅ PiP mode activated successfully');
    } catch (e) {
      print('❌ Error entering PiP mode: $e');
      isPipActive.value = false;
    }
  }
  
  /// Exit Picture-in-Picture mode and return to full screen
  Future<void> exitPipMode() async {
    if (!isPipActive.value) {
      print('⚠️ PiP not active, cannot exit');
      return;
    }
    
    try {
      print('🖼️ Exiting Picture-in-Picture mode');
      isPipActive.value = false;
      
      // Hide the PiP widget first
      await hidePip();
      
      // Navigate back to video call screen only if call is still ongoing
      if (isCallOngoing.value && callState.value == CallState.connected) {
        print('🖼️ Returning to video call screen');
        // Pass call information to recreate the call state properly
        Get.toNamed('/video-call-screen', arguments: {
          'isReturningFromPip': true,
          'appointmentId': 25, // From the original call
          'callerId': int.parse(currentCallerId.value),
          'receiverId': 50, // Current user ID
          'callerName': remoteUserName.value,
          'remoteUserName': remoteUserName.value,
          'remoteUserProfilePicture': remoteUserProfilePicture.value,
          'isIncomingCall': false, // This is an ongoing call, not incoming
          'channelName': currentChannelName.value,
          'isConnected': true, // Mark as already connected
        });
      } else {
        print('🖼️ Call not ongoing, not returning to video call screen');
      }
      
      print('✅ PiP mode exited successfully');
    } catch (e) {
      print('❌ Error exiting PiP mode: $e');
    }
  }
  
  /// Show the PiP floating widget using Flutter overlay
  Future<void> showPip() async {
    if (_overlayEntry != null) {
      print('⚠️ PiP overlay already exists');
      return;
    }
    
    // Create overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildPipOverlay(),
    );
    
    // Insert overlay into the app
    Overlay.of(Get.overlayContext!).insert(_overlayEntry!);
  }
  
  /// Hide the PiP floating widget
  Future<void> hidePip() async {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
  
  /// Build the PiP overlay widget
  Widget _buildPipOverlay() {
    return Material(
      type: MaterialType.transparency,
      child: Obx(() {
        // Don't show overlay if PiP is not active or call is not ongoing
        if (!isPipActive.value || !isCallOngoing.value) {
          return SizedBox.shrink();
        }
        
        return Stack(
          children: [
            Positioned(
              top: pipTopPosition.value,
              right: pipRightPosition.value,
              child: Draggable(
                feedback: _buildPipContent(),
                childWhenDragging: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                ),
                onDragEnd: (details) {
                  _updatePipPosition(details.offset);
                },
                child: _buildPipContent(),
              ),
            ),
          ],
        );
      }),
    );
  }
  
  /// Update PiP position with bounds checking
  void _updatePipPosition(Offset newPosition) {
    // Get screen dimensions
    final screenSize = Get.size;
    const pipWidth = 120.0;
    const pipHeight = 160.0;
    const padding = 20.0;
    
    // Calculate bounds
    final maxTop = screenSize.height - pipHeight - padding;
    final maxRight = screenSize.width - pipWidth - padding;
    
    // Update position with bounds checking
    pipTopPosition.value = newPosition.dy.clamp(padding, maxTop);
    pipRightPosition.value = (screenSize.width - newPosition.dx - pipWidth).clamp(padding, maxRight);
    
    print('🖼️ PiP position updated: top=${pipTopPosition.value}, right=${pipRightPosition.value}');
  }
  
  /// Build the actual PiP content
  Widget _buildPipContent() {
    return GestureDetector(
      onTap: () {
        print('🖼️ PiP overlay tapped - attempting to return to full screen');
        if (isPipActive.value && isCallOngoing.value) {
          exitPipMode();
        } else {
          print('⚠️ Cannot exit PiP - isPipActive: ${isPipActive.value}, isCallOngoing: ${isCallOngoing.value}');
        }
      },
      child: Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // Background image or default avatar - can show video if available
              _buildPipMainContent(),
              
              // Call duration overlay
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Obx(() => Text(
                    callDuration.value.isNotEmpty ? callDuration.value : '00:00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
                ),
              ),
              
              // Status text
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Obx(() => Text(
                    _getCallStatusText(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build the main content for PiP - shows video if available, otherwise profile picture
  Widget _buildPipMainContent() {
    // Check if we have remote video available
    if (_currentCallController != null && 
        _currentCallController!.agoraService.remoteUsers.isNotEmpty &&
        _currentCallController!.isRemoteCameraActive.value &&
        callState.value == CallState.connected) {
      
      // Show remote user's video
      final remoteUid = _currentCallController!.agoraService.remoteUsers.first;
      print('🎥 PiP showing remote video for UID: $remoteUid');
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _currentCallController!.agoraService.engine,
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: _currentCallController!.channelName.value),
        ),
      );
    } else {
      // Show remote user's profile picture
      return _buildPipProfilePicture();
    }
  }
  
  /// Build profile picture for PiP widget
  Widget _buildPipProfilePicture() {
    if (remoteUserProfilePicture.value.isNotEmpty) {
      return Image.network(
        remoteUserProfilePicture.value,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildDefaultProfileIcon(),
      );
    } else {
      return _buildDefaultProfileIcon();
    }
  }
  
  /// Build default profile icon when no image is available
  Widget _buildDefaultProfileIcon() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Icon(
          Icons.person,
          color: Colors.white70,
          size: 40,
        ),
      ),
    );
  }
  
  /// Get call status text for PiP widget
  String _getCallStatusText() {
    // In PiP mode, we should only show connected state since PiP only activates for connected calls
    if (isPipActive.value && callState.value == CallState.connected) {
      return remoteUserName.value.isNotEmpty 
          ? remoteUserName.value.length > 12 
              ? '${remoteUserName.value.substring(0, 12)}...'
              : remoteUserName.value
          : 'In Call';
    }
    
    // Fallback for other states (shouldn't happen in PiP, but just in case)
    switch (callState.value) {
      case CallState.connecting:
        return 'Connecting...';
      case CallState.connected:
        return 'In Call';
      case CallState.ringing:
        return 'Ringing...';
      case CallState.calling:
        return 'Calling...';
      default:
        return 'Call';
    }
  }
  
  /// Listen to call state changes from the video call controller
  void _listenToCallStateChanges() {
    if (_currentCallController == null) return;
    
    print('🔗 Setting up PiP listeners for call state and duration');
    
    // Listen to call state changes
    _currentCallController!.callState.listen((state) {
      print('🖼️ PiP received call state change: $state');
      callState.value = state;
      
      // If call ends, automatically end PiP
      if (state == CallState.disconnected || state == CallState.idle) {
        print('🖼️ Call ended, cleaning up PiP');
        endCall();
      }
    });
    
    // Listen to call duration changes and update our display
    _currentCallController!.callDuration.listen((duration) {
      final formattedDuration = _formatDuration(duration);
      if (callDuration.value != formattedDuration) {
        callDuration.value = formattedDuration;
        print('🖼️ PiP duration updated: ${callDuration.value}');
      }
    });
    
    // Also listen to remote user state changes
    _currentCallController!.remoteUserName.listen((name) {
      if (remoteUserName.value != name && name.isNotEmpty) {
        remoteUserName.value = name;
        print('🖼️ PiP remote user name updated: $name');
      }
    });
    
    _currentCallController!.remoteUserProfilePicture.listen((picture) {
      if (remoteUserProfilePicture.value != picture && picture.isNotEmpty) {
        remoteUserProfilePicture.value = picture;
        print('🖼️ PiP remote user picture updated');
      }
    });
  }
  
  /// Format duration for display
  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  /// Check if PiP is supported on the current platform
  Future<bool> isPipSupported() async {
    try {
      // Our custom PiP implementation using overlays works on all platforms
      return true;
    } catch (e) {
      print('❌ Error checking PiP support: $e');
      return false;
    }
  }
  
  /// Get current call controller for external access
  VideoCallController? get currentCallController => _currentCallController;
  
  @override
  void onClose() {
    _stopDurationTimer();
    endCall();
    super.onClose();
  }
}