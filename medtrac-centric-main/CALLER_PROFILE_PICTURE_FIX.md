# Caller Profile Picture Display Fix

## 📅 Date: October 6, 2025

## 🐛 Problem Fixed

### **Issue:**
- ❌ On the caller's end, for a brief period during call initiation, the caller sees **their own profile picture** instead of the person they're calling
- ❌ This happens during the call setup states (initiating, calling, connecting)
- ❌ Confusing UX - caller expects to see the receiver's picture

### **Root Cause:**
- The `_buildMainVideoView()` method had a fallback to `_buildLocalVideoBackground()` when no remote users were present
- During call setup states, if remote users hadn't joined yet, it would fall through to the else block
- `_buildLocalVideoBackground()` was showing the current user's (caller's) profile picture during setup states
- This created a brief flash of the caller's own picture before switching to remote user's picture

---

## ✅ Solution Implemented

### **Key Changes:**

1. **Main Video View Logic Enhanced:**
   - Always show **remote user's profile picture** during all call setup states
   - Added explicit handling for `timeout` state to show remote user
   - Added fallback for `connected` state when waiting for remote users
   - Only fall back to local background for `disconnected`/`idle` states

2. **Local Video Background Simplified:**
   - Removed call setup state handling (no longer needed)
   - Now only used for disconnected/idle states
   - Clearer separation of concerns

---

## 🔧 Technical Implementation

### **File: video_call_screen.dart**

#### **Before - _buildMainVideoView():**
```dart
Widget _buildMainVideoView() {
  return Obx(() {
    // During call setup
    if (controller.callState.value == CallState.ringing || ...) {
      // Show remote user for both incoming and outgoing
      if (controller.isIncomingCall.value) {
        return _buildProfilePictureView(..., isRemote: true);
      } else {
        return _buildProfilePictureView(..., isRemote: true);
      }
    }
    
    // If remote users connected
    if (remoteUsers.isNotEmpty && connected) {
      return remoteVideo or remoteProfile;
    } else {
      // ❌ PROBLEM: Falls back to local background during setup
      return _buildLocalVideoBackground(); // Shows caller's picture!
    }
  });
}
```

#### **After - _buildMainVideoView():**
```dart
Widget _buildMainVideoView() {
  return Obx(() {
    // 1. During call setup - ALWAYS show remote user's profile
    if (controller.callState.value == CallState.ringing || 
        controller.callState.value == CallState.connecting ||
        controller.callState.value == CallState.calling ||
        controller.callState.value == CallState.initiating) {
      print('📞 Call setup in progress, showing remote user profile picture');
      // ✅ FIX: Always show remote user (no conditions needed)
      return _buildProfilePictureView(
        imageUrl: controller.remoteUserProfilePicture.value,
        name: controller.remoteUserName.value,
        isRemote: true,
      );
    }
    
    // 2. During timeout - show remote user's profile
    if (controller.callState.value == CallState.timeout) {
      print('⏱️ Call timeout, showing remote user profile picture');
      return _buildProfilePictureView(
        imageUrl: controller.remoteUserProfilePicture.value,
        name: controller.remoteUserName.value,
        isRemote: true,
      );
    }
    
    // 3. If remote users connected
    if (remoteUsers.isNotEmpty && connected) {
      if (controller.isRemoteCameraActive.value) {
        return AgoraVideoView(...); // Remote video
      } else {
        return _buildProfilePictureView(..., isRemote: true); // Remote profile
      }
    } 
    // 4. Connected but waiting for remote user
    else if (controller.callState.value == CallState.connected) {
      print('🔄 Connected but waiting for remote user');
      // ✅ FIX: Still show remote profile as placeholder
      return _buildProfilePictureView(
        imageUrl: controller.remoteUserProfilePicture.value,
        name: controller.remoteUserName.value,
        isRemote: true,
      );
    } 
    // 5. Only for disconnected/idle states
    else {
      return _buildLocalVideoBackground(); // Now safe
    }
  });
}
```

#### **Before - _buildLocalVideoBackground():**
```dart
Widget _buildLocalVideoBackground() {
  return Obx(() {
    // ❌ PROBLEM: Handles call setup states
    if (controller.callState.value == CallState.ringing || 
        controller.callState.value == CallState.connecting || ...) {
      return _buildProfilePictureView(
        imageUrl: controller.currentUserProfilePicture.value, // Caller's picture!
        name: controller.currentUserName.value,
        isRemote: false,
      );
    }
    
    if (videoEnabled && connected) {
      return AgoraVideoView(...);
    } else {
      return currentUserProfile;
    }
  });
}
```

#### **After - _buildLocalVideoBackground():**
```dart
Widget _buildLocalVideoBackground() {
  return Obx(() {
    // ✅ SIMPLIFIED: No call setup handling (handled in main view)
    if (controller.agoraService.isVideoEnabled.value && 
        controller.agoraService.isInitialized.value &&
        controller.callState.value == CallState.connected) {
      return AgoraVideoView(...);
    } else {
      // Only shows for disconnected/idle states
      return _buildProfilePictureView(
        imageUrl: controller.currentUserProfilePicture.value,
        name: controller.currentUserName.value,
        isRemote: false,
      );
    }
  });
}
```

---

## 📊 State Flow Comparison

### **Before (Buggy Flow):**
```
Caller initiates call
  ↓
State: Initiating/Calling
  ↓
Main View: Check remote users → Empty ❌
  ↓
Falls back to _buildLocalVideoBackground()
  ↓
Shows CALLER'S OWN PICTURE 😵
  ↓
Remote user joins
  ↓
Shows remote user's picture ✅
```

**Problem:** Brief flash of caller's own picture

### **After (Fixed Flow):**
```
Caller initiates call
  ↓
State: Initiating/Calling
  ↓
Main View: During setup? → YES ✅
  ↓
Shows REMOTE USER'S PICTURE ✅
  ↓
Remote user joins
  ↓
Continues showing remote user's picture ✅
```

**Solution:** Always shows remote user's picture from the start

---

## 🎯 Display Logic by State

| Call State | Main View Shows | Why |
|------------|----------------|-----|
| **Idle** | Local background | Default state |
| **Initiating** | Remote profile | ✅ Caller sees who they're calling |
| **Calling** | Remote profile | ✅ Caller sees who they're calling |
| **Ringing** | Remote profile | ✅ Shows caller/receiver info |
| **Connecting** | Remote profile | ✅ Shows who you're connecting to |
| **Connected (no remote users)** | Remote profile | ✅ Placeholder until remote joins |
| **Connected (remote users)** | Remote video or profile | Based on camera state |
| **Timeout** | Remote profile | ✅ Shows who didn't answer |
| **Disconnected** | Local background | Call ended |

---

## 🔍 Key Improvements

### **1. Explicit State Handling:**
```dart
// ✅ Each state explicitly handled
if (state == calling || initiating || ...) {
  return remoteProfile;
}
if (state == timeout) {
  return remoteProfile;
}
if (remoteUsers.isNotEmpty && connected) {
  return remoteVideo or remoteProfile;
}
if (connected) {  // ← NEW: Waiting for remote
  return remoteProfile;
}
else {
  return localBackground;
}
```

### **2. Clear Separation:**
- **Main View:** Handles all call-related states → Shows remote user
- **Local Background:** Only for idle/disconnected → Shows local user

### **3. Better Debug Logging:**
```dart
print('📞 Call setup in progress, showing remote user profile picture');
print('⏱️ Call timeout, showing remote user profile picture');
print('🔄 Connected but waiting for remote user, showing remote profile picture');
```

---

## 🧪 Testing Checklist

### **Test 1: Outgoing Call - No Flash**
1. Make an outgoing call as caller
2. ✅ **Expected:** Immediately see receiver's profile picture
3. ✅ **Expected:** NO flash of your own picture
4. ✅ **Expected:** Receiver's picture remains during "Calling..." status
5. Wait for answer
6. ✅ **Expected:** Smooth transition to video or continued profile view

### **Test 2: Incoming Call**
1. Receive an incoming call
2. ✅ **Expected:** See caller's profile picture
3. ✅ **Expected:** Never see your own picture
4. Accept call
5. ✅ **Expected:** See caller's video or profile picture

### **Test 3: Call Timeout**
1. Make a call that goes unanswered
2. ✅ **Expected:** See receiver's picture throughout
3. Wait for timeout (45 seconds)
4. ✅ **Expected:** Still showing receiver's picture
5. ✅ **Expected:** "Call not picked up" message appears

### **Test 4: Connected - Waiting for Remote**
1. Call connects but remote user hasn't joined Agora yet
2. ✅ **Expected:** See remote user's profile picture as placeholder
3. Remote user joins
4. ✅ **Expected:** Smooth transition to their video
5. ✅ **Expected:** No flash of your own picture

### **Test 5: Call Ended - Local View**
1. End a connected call
2. Navigate back to idle state
3. ✅ **Expected:** Now can show local background (expected behavior)
4. ✅ **Expected:** Showing your own picture is OK here (call ended)

---

## 📝 Code Comments Added

```dart
// Main video view - shows remote user video or profile picture
Widget _buildMainVideoView() {
  // During call setup, always show remote user's profile picture 
  // (never show caller's own picture)
  if (isCallSetup) {
    print('📞 Call setup in progress, showing remote user profile picture with status');
    // Always show remote user's info during setup (caller or receiver)
    return remoteProfile;
  }
  
  // During timeout, show remote user's profile picture
  if (isTimeout) {
    print('⏱️ Call timeout, showing remote user profile picture');
    return remoteProfile;
  }
  
  // Connected but no remote users yet - still show remote profile as placeholder
  else if (connected) {
    print('🔄 Connected but waiting for remote user, showing remote profile picture');
    return remoteProfile;
  }
}

// Local video as background (fallback when disconnected/idle - never during call setup)
Widget _buildLocalVideoBackground() {
  // Only shows for disconnected/idle states
  ...
}
```

---

## ✅ Summary

| Issue | Status | Fix |
|-------|--------|-----|
| Caller sees own picture briefly | ✅ Fixed | Always show remote profile during setup |
| Fallback to local background during setup | ✅ Fixed | Explicit state handling in main view |
| Confusing UX during call initiation | ✅ Fixed | Remote user shown from the start |
| Code clarity | ✅ Improved | Clear separation of concerns |

**Problem completely resolved!** 🎉

The caller will now **always** see the person they're calling from the moment the call is initiated, with no brief flash of their own profile picture.
