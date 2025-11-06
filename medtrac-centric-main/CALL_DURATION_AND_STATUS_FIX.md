# Call Duration and Status Display Improvements

## 📅 Date: October 6, 2025

## ✨ Features Implemented

### **1. Fixed "Call Not Picked Up" Message** 📞
- ✅ When a call times out (no answer), now shows **"Call not picked up"** message
- ✅ Changed from "No answer" to more user-friendly message
- ✅ Message appears in orange color below the profile picture

### **2. Added Call Duration Display** ⏱️
- ✅ Shows real-time call duration during active call
- ✅ Shows final call duration after call ends (if call was ever connected)
- ✅ Format: `MM:SS` (e.g., "02:35" for 2 minutes 35 seconds)
- ✅ Appears below profile picture and camera status

### **3. Camera Off Icon** 📹
- ✅ Replaced "Camera is off" text with camera icon
- ✅ Shows `videocam_off_rounded` icon when camera is disabled
- ✅ Works for both local and remote users
- ✅ Only shows when camera is actually off

---

## 🎨 UI Changes

### **Before:**
```
[Profile Picture]
John Doe
"Camera is off"  ← Text message
```

### **After - During Call Setup:**
```
[Profile Picture]
John Doe
"Calling..."
```

### **After - Active Call (Camera Off):**
```
[Profile Picture]
John Doe
🎥 ← Camera off icon
00:45 ← Call duration
```

### **After - Call Timeout:**
```
[Profile Picture]
John Doe
"Call not picked up"  ← Orange message
```

### **After - Call Ended (Connected):**
```
[Profile Picture]
John Doe
🎥 ← Camera off icon (if camera was off)
02:35 ← Final call duration
```

---

## 🔧 Technical Implementation

### **File: video_call_screen.dart**

**Changes to `_buildProfilePictureView()` method:**

```dart
// 1. Show call status messages during setup
if (controller.callState.value == CallState.ringing || 
    controller.callState.value == CallState.connecting ||
    controller.callState.value == CallState.calling ||
    controller.callState.value == CallState.initiating) {
  return Text(controller.callStatusText, ...);
}

// 2. Show "Call not picked up" on timeout
if (controller.callState.value == CallState.timeout) {
  return Column(
    children: [
      Text("Call not picked up", 
        style: TextStyle(color: Colors.orange, ...),
      ),
    ],
  );
}

// 3. Show camera off icon when camera is disabled
if (isRemote) {
  if (!controller.isRemoteCameraActive.value) {
    return Icon(Icons.videocam_off_rounded, ...);
  }
} else {
  if (!controller.agoraService.isVideoEnabled.value) {
    return Icon(Icons.videocam_off_rounded, ...);
  }
}

// 4. Show call duration during and after call (if connected)
if (controller.callState.value == CallState.connected ||
    (controller.callState.value == CallState.disconnected && 
     controller.wasCallEverConnected.value)) {
  return Text(controller.formattedCallDuration, ...);
}
```

### **File: video_call_controller.dart**

**Changes to timer management:**

```dart
// Modified _stopCallTimer() to preserve duration
void _stopCallTimer() {
  _callTimer?.cancel();
  // ✅ Don't reset callDuration - preserve it for display after call ends
}

// Added callDuration reset in _resetCallState()
void _resetCallState() {
  // ... other resets
  callDuration.value = 0; // ✅ Reset for new calls
  // ... 
}
```

---

## 📊 Call Duration Logic

### **When Timer Starts:**
- ✅ When call reaches `CallState.connected`
- ✅ Increments every second: `callDuration.value++`

### **When Timer Stops:**
- ✅ When call ends: `endVideoCall()` → `_stopCallTimer()`
- ✅ Duration is **preserved** (not reset to 0)
- ✅ Allows showing final duration after call ends

### **When Duration Resets:**
- ✅ Only in `_resetCallState()` when preparing for new call
- ✅ Not when call ends (so user can see final duration)

---

## 🎯 Display Conditions

| Call State | Camera Icon | Call Duration | Status Text |
|------------|-------------|---------------|-------------|
| **Initiating** | ❌ | ❌ | "Initiating call..." |
| **Calling** | ❌ | ❌ | "Calling..." |
| **Ringing** | ❌ | ❌ | "Ringing..." |
| **Connecting** | ❌ | ❌ | "Connecting..." |
| **Connected** | ✅ (if camera off) | ✅ (live timer) | - |
| **Timeout** | ❌ | ❌ | "Call not picked up" |
| **Disconnected** | ✅ (if camera was off) | ✅ (final duration)* | - |

*Only shows if `wasCallEverConnected == true`

---

## 🧪 Testing Scenarios

### **Test 1: Call Not Picked Up**
1. Make a call
2. Wait 45 seconds (timeout)
3. ✅ **Expected**: "Call not picked up" message appears in orange
4. ✅ **Expected**: Screen auto-closes after 2 seconds

### **Test 2: Active Call with Camera Off**
1. Start a video call
2. Turn camera off
3. ✅ **Expected**: Camera icon 🎥 appears
4. ✅ **Expected**: Call duration shows below (e.g., "00:15")
5. ✅ **Expected**: Duration increments every second

### **Test 3: Active Call with Camera On**
1. Start a video call
2. Keep camera on
3. ✅ **Expected**: Video feed shows (no camera icon)
4. ✅ **Expected**: Call duration shows at top of screen
5. ✅ **Expected**: Duration increments every second

### **Test 4: Call Ended - Show Final Duration**
1. Have a connected call for 30+ seconds
2. End the call
3. ✅ **Expected**: Camera icon shows (if camera was off)
4. ✅ **Expected**: Final duration shows (e.g., "00:35")
5. ✅ **Expected**: Duration doesn't reset to 00:00

### **Test 5: New Call - Duration Resets**
1. Complete a call (see final duration)
2. Close screen and start a new call
3. ✅ **Expected**: Duration starts from 00:00 for new call

---

## 🎨 Visual Hierarchy

```
┌─────────────────────────┐
│   [Profile Picture]     │  ← Always visible
│                         │
│      John Doe          │  ← Name
│                         │
│   [Status/Icon]        │  ← Status text OR camera icon
│                         │
│      00:45             │  ← Call duration (when connected)
│                         │
└─────────────────────────┘
```

---

## 📝 Files Modified

1. **`lib/views/video_call/video_call_screen.dart`**
   - Updated `_buildProfilePictureView()` method
   - Added camera off icon display logic
   - Added call duration display logic
   - Changed timeout message to "Call not picked up"

2. **`lib/controllers/video_call_controller.dart`**
   - Modified `_stopCallTimer()` to preserve duration
   - Added `callDuration.value = 0` to `_resetCallState()`
   - Ensured duration persists after call ends

---

## ✅ Summary

| Feature | Status |
|---------|--------|
| "Call not picked up" message | ✅ Fixed |
| Call duration during call | ✅ Implemented |
| Call duration after call ends | ✅ Implemented |
| Camera off icon (instead of text) | ✅ Implemented |
| Duration resets for new calls | ✅ Implemented |

**All requested features successfully implemented!** 🎉
