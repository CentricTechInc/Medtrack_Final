# Picture-in-Picture (PiP) Video Call Implementation

## Overview

This implementation provides Picture-in-Picture functionality for the MedTrac video calling system. When a user is in an ongoing video call and presses the back button, instead of disconnecting the call, the app will enter PiP mode showing a floating mini-window with the remote user's profile picture and call information.

## Architecture

### Core Components

1. **PipService** (`lib/services/pip_service.dart`)
   - Manages PiP state and tracks ongoing calls
   - Handles overlay creation and management
   - Provides methods to enter/exit PiP mode

2. **VideoCallController** (`lib/controllers/video_call_controller.dart`)
   - Enhanced with PiP support methods
   - Handles back button press to trigger PiP mode
   - Integrates with PipService for call tracking

3. **VideoCallScreen** (`lib/views/video_call/video_call_screen.dart`)
   - Wrapped with WillPopScope to intercept back button
   - Calls controller's handleBackPress method

## How It Works

### Call Flow

1. **Call Initiation**: When a video call starts (either incoming or outgoing), the VideoCallController automatically starts tracking the call in PipService
2. **PiP Trigger**: When user presses back button during a connected call, instead of ending the call, the app enters PiP mode
3. **PiP Display**: A floating overlay appears showing the remote user's profile picture, call duration, and status
4. **Navigation**: User can navigate anywhere in the app while the PiP overlay remains visible
5. **Return to Full Screen**: Tapping the PiP overlay returns to the full video call screen
6. **Call End**: When the call ends (by either party), PiP automatically closes

### Key Features

- **Smart Back Button Handling**: Back button only triggers PiP during connected calls
- **Overlay System**: Uses Flutter's native overlay system (works on all platforms)
- **Automatic Call Tracking**: Seamlessly integrates with existing video call flow
- **Real-time Updates**: PiP widget updates with call duration and status changes
- **Profile Picture Display**: Shows remote user's profile picture when video is off
- **Cross-Platform**: Works on iOS, Android, and other Flutter-supported platforms

## Implementation Details

### PiP Service Methods

```dart
// Start tracking a call for PiP
pipService.startCall(
  controller: videoCallController,
  remoteUserName: "Dr. John Doe",
  remoteUserProfilePicture: "https://...",
  channelName: "channel123",
  callerId: "user456"
);

// Enter PiP mode
await pipService.enterPipMode();

// Exit PiP mode
await pipService.exitPipMode();

// End call tracking
pipService.endCall();
```

### VideoCallController Integration

```dart
// Handle back button press
Future<bool> handleBackPress() async {
  if (callState.value == CallState.connected && !isInPipMode.value) {
    await enterPipMode();
    return false; // Prevent default back action
  }
  return true; // Allow default back action
}

// Enter PiP mode
Future<void> enterPipMode() async {
  await pipService.enterPipMode();
  Get.back(); // Return to previous screen
}
```

## Service Integration

The PipService is automatically initialized in the app's binding system and is available throughout the app lifecycle. It integrates with:

- **AgoraService**: For video call state management
- **VideoCallController**: For call tracking and UI coordination
- **GetX Navigation**: For screen transitions and overlay management

## Usage Examples

### For Developers

The PiP functionality is automatically enabled for all video calls. No additional setup is required in individual screens.

### For Users

1. **Start a video call** from any appointment or direct call
2. **During the call**, press the back button or navigate away
3. **PiP mode activates** showing a floating video preview
4. **Navigate freely** through the app while call continues
5. **Tap the floating window** to return to full-screen video call
6. **End the call** normally to close PiP automatically

## Technical Specifications

- **Overlay Size**: 120x160 pixels
- **Position**: Top-right corner by default (customizable)
- **Update Frequency**: Real-time reactive updates using GetX
- **Memory Usage**: Minimal overhead using Flutter's efficient overlay system
- **Platform Support**: iOS, Android, Web, Desktop

## Benefits

1. **Enhanced UX**: Users can access other parts of the app during calls
2. **No Call Interruption**: Calls continue seamlessly in background
3. **Professional Experience**: Similar to native video call apps
4. **Easy Integration**: Minimal code changes to existing system
5. **Cross-Platform**: Consistent behavior across all platforms

## Error Handling

The implementation includes comprehensive error handling:
- Graceful fallback if overlay creation fails
- Automatic cleanup on app lifecycle changes
- State management to prevent duplicate overlays
- Memory leak prevention with proper disposal

## Future Enhancements

Potential improvements for future versions:
- Draggable PiP window positioning
- Resizable PiP window
- Multiple call support
- Voice-only PiP mode
- Custom PiP themes
- PiP controls (mute, end call) within the floating window

## Dependencies

The implementation uses only Flutter's built-in capabilities:
- Flutter Material Design
- GetX for state management
- Native overlay system
- No external PiP packages required

This approach ensures maximum compatibility and minimal external dependencies while providing a robust PiP experience.