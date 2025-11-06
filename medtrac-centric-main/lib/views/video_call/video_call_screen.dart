import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:medtrac/controllers/video_call_controller.dart';
import 'package:medtrac/custom_widgets/custom_icon_button.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/views/Home/widgets/info_bottom_sheet.dart';
import 'dart:ui';

import 'package:medtrac/utils/helper_functions.dart';

class VideoCallScreen extends GetView<VideoCallController> {
  // Constants for better maintainability
  static const Duration _initDelay = Duration(milliseconds: 500);
  static const double _localPreviewWidth = 120.0;
  static const double _localPreviewHeight = 160.0;
  
  final bool fromAppointment = Get.arguments != null ? Get.arguments["fromAppointment"] ?? false : false;
  VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto-initiate call when screen loads - but only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.callState.value == CallState.idle) {
        // Add small delay to ensure controller is fully initialized
        Future.delayed(_initDelay, () {
          if (controller.callState.value == CallState.idle) {
            // Get call parameters from route arguments or use defaults
            final args = Get.arguments as Map<String, dynamic>? ?? {};
            controller.startVideoCall(
              appointmentId: args['appointmentId'],
              callerId: args['callerId'],
              receiverId: args['receiverId'],
              callerName: controller.currentUserName.value,
              receiverName: controller.remoteUserName.value.isNotEmpty 
                  ? controller.remoteUserName.value 
                  : args['receiverName'] ?? "Dr. Karan Verma"
            );
          }
        });
      }
    });

    return WillPopScope(
      onWillPop: () async {
        // Handle back button press through controller
        return await controller.handleBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Main video view - shows remote user or profile picture
              _buildMainVideoView(),
              
              // Local video preview (small, draggable)
              _buildLocalPreview(),
                
              // Call controls
              _buildCallControls(),
            ],
          ),
        ),
      ),
    );
  }

  // Get remote user name
  String _getRemoteUserName() {
    if (controller.isIncomingCall.value) {
      return controller.remoteUserName.value.isNotEmpty 
          ? controller.remoteUserName.value 
          : "Unknown Caller";
    } else {
      return controller.remoteUserName.value.isNotEmpty 
          ? controller.remoteUserName.value 
          : "Connecting...";
    }
  }

  // Main video view - shows remote user video or profile picture
  Widget _buildMainVideoView() {
    return Obx(() {
      log('video call: Main video view debug:');
      log('video call:  Remote users: ${controller.agoraService.remoteUsers}');
      log('video call:  Remote camera active: ${controller.isRemoteCameraActive.value}');
      log('video call:  Call state: ${controller.callState.value}');
      
      // During call setup, always show remote user's profile picture (never show caller's own picture)
      if (controller.callState.value == CallState.ringing || 
          controller.callState.value == CallState.connecting ||
          controller.callState.value == CallState.calling ||
          controller.callState.value == CallState.initiating) {
        log('video call:📞 Call setup in progress, showing remote user profile picture with status');
        // Always show remote user's info during setup (caller or receiver)
        return _buildProfilePictureView(
          imageUrl: controller.remoteUserProfilePicture.value,
          name: controller.remoteUserName.value,
          isRemote: true,
        );
      }
      
      // During timeout, show remote user's profile picture
      if (controller.callState.value == CallState.timeout) {
        log('video call:⏱️ Call timeout, showing remote user profile picture');
        return _buildProfilePictureView(
          imageUrl: controller.remoteUserProfilePicture.value,
          name: controller.remoteUserName.value,
          isRemote: true,
        );
      }
      
      // If we have remote users and call is connected
      if (controller.agoraService.remoteUsers.isNotEmpty && 
          controller.callState.value == CallState.connected) {
        
        // Check if remote camera is active
        if (controller.isRemoteCameraActive.value) {
          // Show remote video
          final remoteUid = controller.agoraService.remoteUsers.first;
          log('video call:🎥 Showing remote video for UID: $remoteUid');
          return AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: controller.agoraService.engine,
              canvas: VideoCanvas(uid: remoteUid),
              connection: RtcConnection(
                channelId: controller.channelName.value
              ),
            ),
          );
        } else {
          // Show remote user's profile picture
          log('video call:📷 Remote camera off, showing profile picture');
          return _buildProfilePictureView(
            imageUrl: controller.remoteUserProfilePicture.value,
            name: controller.remoteUserName.value,
            isRemote: true,
          );
        }
      } else if (controller.callState.value == CallState.connected) {
        // Connected but no remote users yet - still show remote profile as placeholder
        log('video call:🔄 Connected but waiting for remote user, showing remote profile picture');
        return _buildProfilePictureView(
          imageUrl: controller.remoteUserProfilePicture.value,
          name: controller.remoteUserName.value,
          isRemote: true,
        );
      } else {
        // Show local video or profile picture as fallback (only for disconnected/idle states)
        return _buildLocalVideoBackground();
      }
    });
  }

  // Local video as background (fallback when disconnected/idle - never during call setup)
  Widget _buildLocalVideoBackground() {
    return Obx(() {
      // When connected, check camera status using Agora service state (single source of truth)
      if (controller.agoraService.isVideoEnabled.value && 
          controller.agoraService.isInitialized.value &&
          controller.callState.value == CallState.connected) {
        // Show local video
        return AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: controller.agoraService.engine,
            canvas: const VideoCanvas(uid: 0),
          ),
        );
      } else {
        // Show current user's profile picture (only for disconnected/idle states)
        return _buildProfilePictureView(
          imageUrl: controller.currentUserProfilePicture.value,
          name: controller.currentUserName.value,
          isRemote: false,
        );
      }
    });
  }

  // Profile picture view when camera is off or during call setup
  Widget _buildProfilePictureView({
    required String imageUrl,
    required String name,
    required bool isRemote,
  }) {
    return Stack(
      children: [
        // Full-screen background with profile picture
        Positioned.fill(
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // If image fails to load, show black background with person icon
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 120.sp,
                          color: Colors.white70,
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.black,
                  child: Center(
                    child: Icon(
                      Icons.person,
                      size: 120.sp,
                      color: Colors.white70,
                    ),
                  ),
                ),
        ),
        // Vignette effect at the bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 300.h,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
        // Content overlay (name and duration on center-left, status in center)
        // User name and duration on left side, positioned above center to avoid person icon
        Positioned(
          left: 24.w,
          top: 200.h, // Position from top instead of center to avoid person icon overlap
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User name
              Text(
                name.isNotEmpty ? name : (isRemote ? _getRemoteUserName() : "You"),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              // Show call duration when call is connected or ended (if it was ever connected)
              Obx(() {
                if (controller.callState.value == CallState.connected ||
                    (controller.callState.value == CallState.disconnected && 
                     controller.wasCallEverConnected.value)) {
                  return Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      controller.formattedCallDuration,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
        // Call status messages in center (for calling, timeout, etc.)
        Positioned.fill(
          child: Center(
            child: Obx(() {
              // During call setup (not connected yet), show status
              if (controller.callState.value == CallState.ringing || 
                  controller.callState.value == CallState.connecting ||
                  controller.callState.value == CallState.calling ||
                  controller.callState.value == CallState.initiating) {
                return Text(
                  controller.callStatusText,
                  style: TextStyle(
                    color: AppColors.primaryLight2,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                );
              }
              // When call timed out, show "Call not picked up" message
              if (controller.callState.value == CallState.timeout) {
                return Text(
                  "Call not picked up",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ),
        ),
      ],
    );
  }

  // Build small profile avatar for local preview
  Widget _buildSmallProfileAvatar(String imageUrl, double radius) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: imageUrl.isEmpty ? AppColors.lightGreyText.withOpacity(0.5) : null,
      ),
      child: imageUrl.isNotEmpty
          ? ClipOval(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.person,
                      size: radius,
                      color: Colors.white70,
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Icon(
                Icons.person,
                size: radius,
                color: Colors.white70,
              ),
            ),
    );
  }

  // Local video preview (small, positioned)
  Widget _buildLocalPreview() {
    return Obx(() {
      // Don't show local preview if call is not connected or during setup
      if (controller.callState.value != CallState.connected) {
        return SizedBox.shrink();
      }

      return Positioned(
        top: controller.previewOffset.value.dy,
        left: controller.previewOffset.value.dx,
        child: Draggable(
          feedback: _buildLocalPreviewContent(),
          childWhenDragging: Container(),
          onDragEnd: (details) {
            controller.previewOffset.value = details.offset;
          },
          child: _buildLocalPreviewContent(),
        ),
      );
    });
  }

  // Local preview content
  Widget _buildLocalPreviewContent() {
    return Container(
      width: _localPreviewWidth.w,
      height: _localPreviewHeight.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Obx(() {
          // Use Agora service state (single source of truth)
          if (controller.agoraService.isVideoEnabled.value && 
              controller.agoraService.isInitialized.value) {
            // Show local video
            return AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: controller.agoraService.engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            );
          } else {
            // Show current user's profile picture or person icon
            return Container(
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSmallProfileAvatar(
                      controller.currentUserProfilePicture.value,
                      30.r,
                    ),
                    8.verticalSpace,
                    Text(
                      "Camera Off",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }),
      ),
    );
  }

  // Call controls positioned at bottom
  Widget _buildCallControls() {
    return Positioned(
      bottom: 80.h,
      left: 0,
      right: 0,
      child: Obx(() {
        // Show more menu if open
        if (controller.isMoreMenuOpen.value) {
          return Positioned(
            bottom: 160.h,
            right: 40.w,
            child: MoreOptionsMenu(controller: controller),
          );
        }
        
        return ButtonsRow(
          controller: controller,
          fromAppointment: fromAppointment,
        );
      }),
    );
  }
}

// Reuse existing widgets from the original file
class ButtonsRow extends StatelessWidget {
  const ButtonsRow({
    super.key,
    required this.controller,
    this.fromAppointment = false
  });

  final VideoCallController controller;
  final bool fromAppointment;
  
  static const double _buttonSize = 88.0;
  static const double _buttonSpacing = 80.0;
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show accept/decline buttons for incoming calls in ringing state
      if (controller.isIncomingCall.value && 
          controller.callState.value == CallState.ringing) {
        return _buildIncomingCallButtons();
      }
      
      // Normal call controls for outgoing calls or connected calls
      return _buildActiveCallControls();
    });
  }

  // Buttons for incoming call (Accept/Decline)
  Widget _buildIncomingCallButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Decline button
        CustomIconButton(
          iconPath: Assets.crossIconWhite,
          backgroundColor: AppColors.error,
          onPressed: controller.declineIncomingCall,
          height: _buttonSize.h,
          width: _buttonSize.w,
          scale: 1,
        ),
        SizedBox(width: _buttonSpacing.w),
        // Accept button
        CustomIconButton(
          iconPath: Assets.callIcon,
          backgroundColor: AppColors.primary,
          onPressed: controller.acceptIncomingCall,
          height: _buttonSize.h,
          width: _buttonSize.w,
          scale: 1,
        ),
      ],
    );
  }

  // Active call controls (Camera, Call, Mic, More)
  Widget _buildActiveCallControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Camera toggle
        _buildCameraButton(),
        
        // Call/End call button
        _buildCallButton(),
        
        // Microphone toggle with muted indicator
        _buildMicrophoneButton(),
        
        // More options (only for doctors)
        if (!HelperFunctions.isUser())
          _buildMoreButton(),
      ],
    );
  }

  Widget _buildCameraButton() {
    return Obx(() => CustomIconButton(
      iconPath: Assets.videoIcon,
      onPressed: () {
        // Just call toggleCamera - it will handle state updates
        controller.toggleCamera();
      },
      // Use Agora service state for button color (single source of truth)
      backgroundColor: controller.agoraService.isVideoEnabled.value
          ? AppColors.primary
          : AppColors.lightGreyText,
    ));
  }

  Widget _buildCallButton() {
    return Obx(() {
      // Determine if we're in a cancellable state (calling/ringing)
      final isCalling = controller.callState.value == CallState.calling || 
                        controller.callState.value == CallState.ringing;
      final isConnected = controller.callState.value == CallState.connected;
      final isTimeout = controller.callState.value == CallState.timeout;
      
      return CustomIconButton(
        iconPath: Assets.callIcon,
        // Red when connected OR when calling/ringing (to show it can be cancelled)
        backgroundColor: (isConnected || isCalling)
            ? AppColors.error  // Red to end/cancel call
            : AppColors.primary,  // Green to initiate call
        onPressed: () {
          if (isConnected) {
            // Show confirmation dialog before ending active call
            _showEndCallConfirmation();
          } else if (isCalling) {
            // Cancel the outgoing call
            controller.cancelOutgoingCall();
          } else if (isTimeout) {
            // If call timed out, just show session ended sheet (call was never connected)
            controller.onCallPressed(fromAppointment: fromAppointment);
          } else {
            // Initiate a new call
            controller.onCallPressed(fromAppointment: fromAppointment);
          }
        },
        height: _buttonSize.h,
        width: _buttonSize.w,
        scale: 1,
      );
    });
  }

  // Show confirmation dialog before ending call
  void _showEndCallConfirmation() {
    Get.bottomSheet(
      InfoBottomSheet(
        imageAsset: Assets.callIcon,
        heading: 'End Call',
        description: 'Are you sure you want to end this call?',
        havePrimaryAndSecondartButtons: true,
        secondaryButtonText: 'End Call',
        secondaryButtonTextColor: AppColors.dark,
        onSecondaryButtonPressed: () {
          // InfoBottomSheet already calls Get.back(), so we don't need to call it again
          controller.endVideoCall(); // End the call
          // Show session ended sheet immediately
          Future.delayed(Duration(milliseconds: 100), () {
            controller.onCallPressed(fromAppointment: fromAppointment);
          });
        },
        primaryButtonText: 'Cancel',
        onPrimaryButtonPressed: () {
          // InfoBottomSheet already calls Get.back() - just do nothing else
          // This will only close the dialog, not the video call screen
        },
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget _buildMicrophoneButton() {
    return Obx(() => CustomIconButton(
      iconPath: Assets.microphoneIcon,
      onPressed: controller.toggleMicrophone,
      backgroundColor: controller.isMicActive.value
          ? AppColors.primary
          : AppColors.lightGreyText, // Grayed out when muted (like camera)
    ));
  }

  Widget _buildMoreButton() {
    return Obx(() => CustomIconButton(
      iconPath: Assets.moreIcon,
      onPressed: () {
        controller.isMoreMenuOpen.toggle();
      },
      backgroundColor: controller.isMoreMenuOpen.value
          ? AppColors.primary
          : AppColors.lightGreyText,
    ));
  }
}

class MoreOptionsMenu extends StatelessWidget {
  const MoreOptionsMenu({
    super.key,
    required this.controller,
  });

  final VideoCallController controller;
  
  // Set to false in production
  static const bool _showDebugOptions = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 160.w,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.bright,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMenuItem(
              text: 'E prescription',
              onTap: () {
                controller.isMoreMenuOpen.value = false;
                Get.toNamed(
                  AppRoutes.prescriptionScreen,
                  arguments: {
                    'appointmentId': controller.appointmentId.value,
                    'fromCall': false,
                  },
                );
              },
            ),
            _buildMenuItem(
              text: 'Add Notes',
              onTap: () {
                controller.isMoreMenuOpen.value = false;
                Get.toNamed(
                  AppRoutes.addNotesScreen,
                  arguments: {
                    'appointmentId': controller.appointmentId.value,
                    'fromCall': false,
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: textColor ?? Colors.black),
              SizedBox(width: 8.w),
            ],
            BodyTextOne(
              text: text,
              color: textColor,
              fontWeight: icon != null ? FontWeight.bold : null,
            ),
          ],
        ),
      ),
    );
  }
}