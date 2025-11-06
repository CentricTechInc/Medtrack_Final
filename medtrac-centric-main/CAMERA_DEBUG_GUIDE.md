# Camera State Debugging Guide

## 📅 Date: October 5, 2025

## 🐛 Current Issue

**Symptom:**
- Receiver accepts call → Local video preview shows "Camera is off"
- But caller sees receiver's video feed (video IS being sent)
- Receiver taps camera button → Local preview turns ON
- Receiver taps again → Local preview turns OFF AND remote feed turns OFF

**Analysis:**
This indicates that:
1. ✅ Agora engine IS sending video (caller can see it)
2. ❌ UI state `isCameraPreviewActive` is NOT being updated
3. ✅ Manual toggle works correctly (syncs state properly)

**Root Cause:**
The `toggleCamera()` method is being called in the connection handler, but the UI state update might not be persisting or triggering reactive updates properly.

---

## 🔍 Debug Steps

### **Step 1: Test Call Connection**

1. **Start a video call**
2. **Watch the console logs carefully**
3. **Look for these specific log messages when receiver accepts:**

```
📹 Enabling video streams now that call is connected...
📹 Current state - UI: false, Agora: false
📹 Video is OFF, turning it ON via toggleCamera()...
📹 Controller: Toggling camera...
📹 Before toggle - UI: OFF, Agora: OFF
📹 AgoraService: Toggling video from OFF to ON
📹 Turning video ON - starting preview and enabling capture
  ✅ Preview started
  ✅ Local video enabled
  ✅ Video stream unmuted
✅ AgoraService: Video toggled - isEnabled: true
✅ Controller: Camera toggled - UI: ON, Agora: ON
✅ UI state should now show: VIDEO PREVIEW
📹 Forced UI refresh - isCameraPreviewActive: true
✅ Cameras enabled - local and remote
📹 Final state - UI: true, Agora: true
```

### **Step 2: Check What Actually Happens**

**Expected (CORRECT):**
- Logs show: `UI: true, Agora: true`
- Receiver sees: Local video preview
- Caller sees: Receiver's video

**Actual (if BUG persists):**
- Logs show: `UI: true, Agora: true` ← States are correct!
- Receiver sees: "Camera is off" ← UI not updating!
- Caller sees: Receiver's video ← Video is working!

If this happens, it means:
- State is correct
- Agora is working
- **But the UI (Obx) isn't re-rendering**

---

## 🔧 Debugging Checklist

### **Check 1: Are the logs showing the toggle happened?**
- [ ] See "Video is OFF, turning it ON via toggleCamera()..."
- [ ] See "AgoraService: Video toggled - isEnabled: true"
- [ ] See "Controller: Camera toggled - UI: ON, Agora: ON"
- [ ] See "UI state should now show: VIDEO PREVIEW"

**If YES:** State is being updated correctly ✅  
**If NO:** Toggle isn't being called ❌

### **Check 2: Is the local preview still showing profile picture?**
- [ ] Receiver's local preview shows "Camera is off"
- [ ] But logs say "UI: ON"

**If YES:** Obx widget isn't re-rendering ❌  
**If NO:** Everything works! ✅

### **Check 3: What happens on first manual toggle?**
- [ ] Tap camera button
- [ ] Does local preview turn ON immediately?
- [ ] Do logs show `UI: OFF → ON`?

**If local preview turns ON:** Confirms Obx IS working when manually triggered ✅  
**If nothing happens:** Different issue ❌

---

## 🎯 Possible Causes & Fixes

### **Cause 1: Obx Widget Not Re-rendering**

**Problem:** Even though state updates, the Obx widget doesn't rebuild.

**Why:** `Future.delayed` might cause the state update to happen outside of GetX's reactivity context.

**Fix Option A - Remove Future.delayed:**
```dart
// Instead of Future.delayed
if (users.isNotEmpty && (callState.value == CallState.calling || callState.value == CallState.ringing)) {
  callState.value = CallState.connected;
  _stopRingtone();
  _cancelOutgoingCallTimeout();
  _startCallTimer();
  
  // Call immediately without delay
  await _enableCamerasOnConnection(users);
}

// New method
Future<void> _enableCamerasOnConnection(List<int> users) async {
  print('📹 Enabling video streams now that call is connected...');
  
  if (!agoraService.isVideoEnabled.value) {
    await toggleCamera();
  }
  
  for (int uid in users) {
    await agoraService.engine.muteRemoteVideoStream(uid: uid, mute: false);
  }
}
```

**Fix Option B - Force GetX Update:**
```dart
// After toggleCamera(), force GetX to rebuild all Obx widgets
Get.forceAppUpdate();
```

**Fix Option C - Update UI state first:**
```dart
// Update UI state BEFORE calling toggle
isCameraPreviewActive.value = true;
isCameraPreviewActive.refresh();

// Then sync with Agora
if (!agoraService.isVideoEnabled.value) {
  await agoraService.toggleVideo();
}
```

---

### **Cause 2: Race Condition with Future.delayed**

**Problem:** The 500ms delay might cause issues with state synchronization.

**Fix:** Remove the delay or make it shorter:
```dart
// Change from 500ms to 100ms
Future.delayed(Duration(milliseconds: 100), () async {
  // ...
});

// Or remove delay entirely
await _enableVideOnConnection(users);
```

---

### **Cause 3: Multiple State Sources**

**Problem:** Checking `controller.isCameraPreviewActive.value` in UI but updating through nested method calls.

**Fix:** Ensure single source of truth:
```dart
// In video_call_screen.dart
// Always use controller.agoraService.isVideoEnabled.value
if (controller.agoraService.isVideoEnabled.value && 
    controller.agoraService.isInitialized.value &&
    controller.callState.value == CallState.connected) {
  // Show video
}
```

---

## 🧪 Test Scenarios

### **Test 1: Basic Call Flow**
1. Caller initiates call
2. Receiver accepts
3. **EXPECTED:** Both see each other's video
4. **CHECK LOGS:** See all toggle messages

### **Test 2: Manual Toggle**
1. During call, tap camera button
2. **EXPECTED:** Video turns OFF immediately
3. Tap again
4. **EXPECTED:** Video turns ON immediately
5. **CHECK:** Single tap should work, no multiple taps needed

### **Test 3: State Consistency**
1. During call, check logs
2. **VERIFY:**
   - `isCameraPreviewActive.value` matches what UI shows
   - `agoraService.isVideoEnabled.value` matches Agora state
   - Both match each other

---

## 📊 Debug Output Analysis

### **Good Logs (Working):**
```
📹 Enabling video streams now that call is connected...
📹 Current state - UI: false, Agora: false
📹 Video is OFF, turning it ON via toggleCamera()...
✅ Controller: Camera toggled - UI: ON, Agora: ON
📹 Final state - UI: true, Agora: true
```
**Result:** Receiver sees video preview ✅

### **Bad Logs (Bug Present):**
```
📹 Enabling video streams now that call is connected...
📹 Current state - UI: false, Agora: false
📹 Video is OFF, turning it ON via toggleCamera()...
✅ Controller: Camera toggled - UI: ON, Agora: ON
📹 Final state - UI: true, Agora: true
```
**Result:** Receiver sees "Camera is off" ❌  
**Analysis:** State is correct but UI not updating!

---

## 🔍 What to Share

If the bug persists after current changes, please share:

1. **Console logs** from when receiver accepts call
2. **Screenshot** of what receiver sees (should show "Camera is off")
3. **Screenshot** of what caller sees (should show receiver's video)
4. **Logs from first manual toggle** (when receiver taps camera button)

This will help identify if it's:
- State update issue
- UI reactivity issue  
- Timing/race condition issue
- Agora SDK issue

---

## ✅ Expected Behavior After Fix

1. **Receiver accepts call**
   - Logs show: `UI: true, Agora: true`
   - Receiver sees: **Local video preview** ✅
   - Caller sees: Receiver's video ✅

2. **Receiver taps camera button**
   - Logs show: `UI: true → false, Agora: true → false`
   - Receiver sees: "Camera is off" ✅
   - Caller sees: Receiver's profile picture ✅

3. **Receiver taps camera button again**
   - Logs show: `UI: false → true, Agora: false → true`
   - Receiver sees: Local video preview ✅
   - Caller sees: Receiver's video ✅

---

## 🚀 Next Steps

1. **Run the app with current changes**
2. **Watch console logs carefully**
3. **Test the call flow**
4. **Share logs if issue persists**

The enhanced logging will help us pinpoint exactly where the issue is!
