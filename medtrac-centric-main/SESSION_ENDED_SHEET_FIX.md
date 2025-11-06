# Session Ended Sheet Not Showing Fix

## 📅 Date: October 6, 2025

## 🐛 Problem Fixed

### **Issue:**
- ❌ When a user ends a connected call, the session ended bottom sheet should appear
- ❌ Instead, the screen just closes immediately without showing the sheet
- ❌ Both caller and receiver should see the session ended sheet after ending a call
- ❌ This only affects calls that were actually connected (not cancelled/timeout)

### **Root Cause:**
The bug was in the order of operations when ending a call:

```dart
// Sequence of events:
1. User taps "End Call" in confirmation dialog
2. controller.endVideoCall() is called
   └─> Calls _resetCallState()
       └─> Sets wasCallEverConnected.value = false ❌
3. After 100ms delay, controller.onCallPressed() is called
   └─> Checks wasCallEverConnected.value
       └─> It's now false! ❌
       └─> Skips session ended sheet
       └─> Just calls Get.back()
```

**The Problem:** `wasCallEverConnected` was being reset to `false` in `_resetCallState()` BEFORE `onCallPressed()` checked its value to determine whether to show the session ended sheet.

---

## ✅ Solution Implemented

### **Key Changes:**

1. **Don't reset `wasCallEverConnected` in `endVideoCall()`**
   - Preserve the flag so `onCallPressed()` can check it later
   
2. **Don't reset `wasCallEverConnected` in `_resetCallState()`**
   - This method is called immediately after ending the call
   - Need to keep the flag until we're done showing the session sheet

3. **Reset `wasCallEverConnected` in `onCallPressed()`**
   - Only reset AFTER showing the session sheet
   - Reset when navigating back (for both users and doctors)

---

## 🔧 Technical Implementation

### **File: video_call_controller.dart**

#### **1. Updated `endVideoCall()` Method:**

**Before:**
```dart
Future<void> endVideoCall() async {
  try {
    _stopRingtone();
    await _agoraService.leaveChannel();
    callState.value = CallState.disconnected;
    _stopCallTimer();
    _resetCallState(); // ❌ This resets wasCallEverConnected too early!
    
    print('📞 Video call ended');
  } catch (e) {
    print('❌ Error ending video call: $e');
  }
}
```

**After:**
```dart
Future<void> endVideoCall() async {
  try {
    _stopRingtone();
    await _agoraService.leaveChannel();
    callState.value = CallState.disconnected;
    _stopCallTimer();
    // ✅ Don't reset wasCallEverConnected here - we need it to show session sheet
    _resetCallState();
    
    print('📞 Video call ended');
  } catch (e) {
    print('❌ Error ending video call: $e');
  }
}
```

#### **2. Updated `_resetCallState()` Method:**

**Before:**
```dart
void _resetCallState() {
  callerName.value = '';
  receiverName.value = '';
  channelName.value = '';
  rtcToken.value = '';
  appointmentId.value = 0;
  callerId.value = 0;
  receiverId.value = 0;
  callDuration.value = 0;
  isIncomingCall.value = false;
  isRemoteCameraActive.value = true;
  wasCallEverConnected.value = false; // ❌ Too early to reset!
  // Note: Don't reset current user info as it's persistent
  // Note: Don't reset remote user info as it may be needed for reconnection
}
```

**After:**
```dart
void _resetCallState() {
  callerName.value = '';
  receiverName.value = '';
  channelName.value = '';
  rtcToken.value = '';
  appointmentId.value = 0;
  callerId.value = 0;
  receiverId.value = 0;
  callDuration.value = 0;
  isIncomingCall.value = false;
  isRemoteCameraActive.value = true;
  // ✅ Don't reset wasCallEverConnected here - needed for session sheet
  // It will be reset when actually closing the screen in onCallPressed()
  // Note: Don't reset current user info as it's persistent
  // Note: Don't reset remote user info as it may be needed for reconnection
}
```

#### **3. Updated `onCallPressed()` Method:**

**Before:**
```dart
void onCallPressed({bool fromAppointment = false}) {
  if (isRinging.value) return;
  
  // Only show session ended sheet if call was ever connected
  if (wasCallEverConnected.value) {
    showSessionEndedBottomSheet();
    if (!HelperFunctions.isUser()) { // do not dismiss sheet if user
      Future.delayed(const Duration(seconds: 3), () {
        if (fromAppointment) {
          final appointmentController = Get.find<AppointmentsController>();
          appointmentController.currentIndex.value = 1;
        }
        Get.back();
        Get.back();
      });
    }
    // ❌ No reset of wasCallEverConnected!
  } else {
    // Call was never connected (timeout, cancelled, declined)
    // Just go back without showing session ended sheet
    Get.back();
    // ❌ No reset here either!
  }
}
```

**After:**
```dart
void onCallPressed({bool fromAppointment = false}) {
  if (isRinging.value) return;
  
  // Only show session ended sheet if call was ever connected
  if (wasCallEverConnected.value) {
    showSessionEndedBottomSheet();
    if (!HelperFunctions.isUser()) { // do not dismiss sheet if user
      Future.delayed(const Duration(seconds: 3), () {
        if (fromAppointment) {
          final appointmentController = Get.find<AppointmentsController>();
          appointmentController.currentIndex.value = 1;
        }
        // ✅ Reset wasCallEverConnected before navigating back
        wasCallEverConnected.value = false;
        Get.back();
        Get.back();
      });
    } else {
      // ✅ For users, reset after a delay (they manually close)
      Future.delayed(const Duration(seconds: 1), () {
        wasCallEverConnected.value = false;
      });
    }
  } else {
    // Call was never connected (timeout, cancelled, declined)
    // Just go back without showing session ended sheet
    wasCallEverConnected.value = false; // ✅ Reset before going back
    Get.back();
  }
}
```

---

## 📊 Flow Comparison

### **Before (Buggy Flow):**
```
User taps "End Call"
  ↓
endVideoCall() called
  ↓
_resetCallState() called
  ↓
wasCallEverConnected = false ❌
  ↓
Wait 100ms
  ↓
onCallPressed() called
  ↓
Check wasCallEverConnected → false ❌
  ↓
Skip session ended sheet
  ↓
Just call Get.back()
  ↓
Screen closes (no sheet shown) 😞
```

### **After (Fixed Flow):**
```
User taps "End Call"
  ↓
endVideoCall() called
  ↓
_resetCallState() called
  ↓
wasCallEverConnected PRESERVED ✅
  ↓
Wait 100ms
  ↓
onCallPressed() called
  ↓
Check wasCallEverConnected → true ✅
  ↓
Show session ended sheet! 🎉
  ↓
Wait 3 seconds (for doctors)
  ↓
Reset wasCallEverConnected = false ✅
  ↓
Get.back() twice
  ↓
Screen closes (after showing sheet) 😊
```

---

## 🎯 Key Insight

### **The Flag Lifecycle:**

```dart
// 1. Call Connects
wasCallEverConnected.value = true;  // Set in Agora event listener

// 2. Call Ends
endVideoCall();
  └─> _resetCallState();
      // ✅ DON'T reset wasCallEverConnected here!

// 3. Show Session Sheet
onCallPressed();
  └─> if (wasCallEverConnected.value) {  // ✅ Still true!
        showSessionEndedBottomSheet();   // ✅ Sheet shows!
        Future.delayed(..., () {
          wasCallEverConnected.value = false;  // ✅ Reset NOW
          Get.back();
        });
      }
```

**Key Principle:** Don't reset the flag until AFTER you've used it to make the decision!

---

## 🧪 Testing Checklist

### **Test 1: Caller Ends Connected Call**
1. Make a call as caller
2. Wait for receiver to answer
3. Call connects successfully
4. Tap red "End Call" button
5. Confirm "End Call" in dialog
6. ✅ **Expected:** Session ended bottom sheet appears
7. ✅ **Expected:** Sheet shows for 3 seconds (doctor) or stays (user)
8. ✅ **Expected:** Then navigates back to previous screen

### **Test 2: Receiver Ends Connected Call**
1. Receive an incoming call
2. Answer the call
3. Call connects successfully
4. Tap red "End Call" button
5. Confirm "End Call" in dialog
6. ✅ **Expected:** Session ended bottom sheet appears
7. ✅ **Expected:** Sheet shows for 3 seconds (doctor) or stays (user)
8. ✅ **Expected:** Then navigates back to previous screen

### **Test 3: End Call During Calling (Not Connected)**
1. Make a call as caller
2. Before receiver answers, tap red button
3. Confirm cancel
4. ✅ **Expected:** NO session ended sheet (call never connected)
5. ✅ **Expected:** Screen closes immediately
6. ✅ **Expected:** `wasCallEverConnected` was false, so no sheet

### **Test 4: Timeout (No Answer)**
1. Make a call
2. Wait 45 seconds (timeout)
3. ✅ **Expected:** "Call not picked up" message
4. ✅ **Expected:** Screen auto-closes after 2 seconds
5. ✅ **Expected:** NO session ended sheet (call never connected)

### **Test 5: Multiple Calls**
1. Make a call and connect
2. End call → Session sheet shows ✅
3. Make another call and connect
4. End call → Session sheet shows again ✅
5. ✅ **Expected:** `wasCallEverConnected` properly resets between calls

---

## 📋 Reset Locations Summary

| Location | Resets `wasCallEverConnected`? | Why |
|----------|-------------------------------|-----|
| **`_resetCallState()`** | ❌ NO | Too early - still need it |
| **`endVideoCall()`** | ❌ NO | Still need to check it later |
| **`onCallPressed()` - connected** | ✅ YES (after 1-3s) | After showing sheet |
| **`onCallPressed()` - not connected** | ✅ YES (immediately) | Before going back |

---

## 🎨 User Experience

### **Before Fix:**
```
User: *ends call*
Screen: *immediately closes*
User: "Wait, where's the session summary?" 🤔
```

### **After Fix:**
```
User: *ends call*
Screen: *shows session ended sheet with duration*
User: "Perfect! I can see the call summary" 😊
Sheet: *auto-closes after 3 seconds (doctor)*
Screen: *returns to previous page*
```

---

## 📝 Files Modified

1. **`lib/controllers/video_call_controller.dart`**
   - **`endVideoCall()`**: Added comment, removed implicit reset
   - **`_resetCallState()`**: Removed `wasCallEverConnected.value = false` line
   - **`onCallPressed()`**: Added explicit `wasCallEverConnected.value = false` in three places:
     - After showing sheet for doctors (before Get.back())
     - After showing sheet for users (after 1 second)
     - When call was never connected (before Get.back())

---

## ✅ Summary

| Issue | Status | Fix |
|-------|--------|-----|
| Session sheet not showing | ✅ Fixed | Don't reset flag in endVideoCall() |
| Flag reset too early | ✅ Fixed | Reset in onCallPressed() instead |
| Both users see sheet | ✅ Works | Flag preserved for both caller & receiver |
| Multiple calls work | ✅ Works | Flag properly reset after each call |

**Problem completely resolved!** 🎉

The session ended bottom sheet now appears correctly for both caller and receiver when ending a connected call, while still not showing for cancelled or timeout calls.
