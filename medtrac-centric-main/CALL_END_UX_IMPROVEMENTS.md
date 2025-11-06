# Call End & Timeout UX Improvements

## 📅 Date: October 6, 2025

## 🐛 Problems Fixed

### **Problem 1: Call Button Behavior During Active Call**
- ❌ First click: Disconnects call immediately
- ❌ Second click: Shows session ended sheet
- ❌ No confirmation before ending active call
- ❌ Confusing double-tap behavior

### **Problem 2: Timeout Notification**
- ❌ Shows snackbar "Call timed out" when no answer
- ❌ Message disappears after a few seconds
- ❌ User might miss the notification

### **Problem 3: Session Ended Sheet Shown Inappropriately**
- ❌ Shows session ended sheet even when call was never connected
- ❌ Appears after timeout (call never answered)
- ❌ Appears after cancellation (call never started)
- ❌ Should only show if call was actually connected

---

## ✅ Solutions Implemented

### **1. End Call Confirmation Dialog**

**What Changed:**
- When user taps phone button during active call, show confirmation dialog first
- User must confirm "End Call" before disconnecting
- If confirmed, show session ended sheet immediately after

**Implementation:**
```dart
Widget _buildCallButton() {
  return Obx(() {
    final isConnected = controller.callState.value == CallState.connected;
    
    onPressed: () {
      if (isConnected) {
        // Show confirmation dialog before ending active call
        _showEndCallConfirmation();
      }
      // ... other states
    }
  });
}

void _showEndCallConfirmation() {
  Get.bottomSheet(
    InfoBottomSheet(
      heading: 'End Call',
      description: 'Are you sure you want to end this call?',
      secondaryButtonText: 'End Call',
      onSecondaryButtonPressed: () {
        Get.back(); // Close confirmation
        controller.endVideoCall(); // End call
        // Show session ended sheet
        controller.onCallPressed();
      },
      primaryButtonText: 'Cancel',
      onPrimaryButtonPressed: () {
        Get.back(); // Just close dialog
      },
    ),
  );
}
```

---

### **2. "No Answer" Message in UI**

**What Changed:**
- Removed snackbar notification for timeout
- Added "No answer" message directly in the profile picture view
- Message stays visible until user closes screen

**Implementation:**
```dart
Widget _buildProfilePictureView() {
  return Column(
    children: [
      _buildProfileAvatar(),
      Text(name),
      
      Obx(() {
        // Show "No answer" when call times out
        if (controller.callState.value == CallState.timeout) {
          return Text(
            "No answer",
            style: TextStyle(
              color: Colors.orange,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          );
        }
        // ... other states
      }),
    ],
  );
}
```

**Controller Change:**
```dart
void _startOutgoingCallTimeout() {
  _ringingTimer = Timer(Duration(minutes: 1), () {
    if (callState.value == CallState.calling || callState.value == CallState.ringing) {
      callState.value = CallState.timeout;
      endVideoCall();
      // Don't show snackbar - message will be displayed in UI
    }
  });
}
```

---

### **3. Session Ended Sheet Only for Connected Calls**

**What Changed:**
- Added `wasCallEverConnected` flag to track if call reached connected state
- Session ended sheet only shows if this flag is true
- For timeouts/cancellations, just close screen without sheet

**Implementation:**
```dart
class VideoCallController {
  final RxBool wasCallEverConnected = false.obs;
  
  void _setupAgoraEventListeners() {
    agoraService.remoteUsers.listen((users) {
      if (users.isNotEmpty && callState == calling/ringing) {
        callState.value = CallState.connected;
        wasCallEverConnected.value = true; // Mark as connected
      }
    });
  }
  
  void onCallPressed({bool fromAppointment = false}) {
    // Only show session ended sheet if call was ever connected
    if (wasCallEverConnected.value) {
      showSessionEndedBottomSheet();
    } else {
      // Call was never connected - just go back
      Get.back();
    }
  }
  
  void _resetCallState() {
    // Reset flag for next call
    wasCallEverConnected.value = false;
  }
}
```

---

## 🎯 User Experience Flow

### **Scenario 1: Active Call - User Ends Call**

**Before:**
```
1. User in active call
2. Taps phone button
3. Call disconnects immediately ❌
4. Taps button again
5. Session ended sheet appears ❌
```

**After:**
```
1. User in active call
2. Taps phone button
3. Confirmation dialog appears: "End Call?" ✅
4. User taps "End Call"
5. Call disconnects
6. Session ended sheet appears immediately ✅
7. OR user taps "Cancel" → Dialog closes, call continues ✅
```

---

### **Scenario 2: Call Timeout (No Answer)**

**Before:**
```
1. User makes call
2. Receiver doesn't answer
3. 1 minute passes
4. Snackbar: "Call timed out" ❌ (disappears)
5. Phone button inactive
6. Taps button → Session ended sheet ❌
```

**After:**
```
1. User makes call
2. Receiver doesn't answer
3. 1 minute passes
4. "No answer" message appears on screen ✅ (stays visible)
5. Phone button turns green
6. Taps button → Screen closes (no sheet) ✅
```

---

### **Scenario 3: User Cancels Outgoing Call**

**Before:**
```
1. User makes call (ringing...)
2. User cancels (taps red button)
3. Screen closes ✅
4. (Session ended sheet might appear) ❌
```

**After:**
```
1. User makes call (ringing...)
2. User cancels (taps red button)
3. Screen closes immediately ✅
4. No session ended sheet ✅ (call never connected)
```

---

## 📊 Comparison Table

| Scenario | Before | After |
|----------|--------|-------|
| **End Active Call** | Immediate disconnect, double-tap for sheet | Confirmation dialog, then sheet ✅ |
| **Call Timeout** | Snackbar notification (disappears) | "No answer" in UI (stays) ✅ |
| **Timeout Button** | Shows session ended sheet | Just closes screen ✅ |
| **Cancel Call** | Might show session ended sheet | Just closes screen ✅ |
| **Session Ended Sheet** | Shows even if never connected | Only shows if call was connected ✅ |

---

## 🔑 Key Changes Summary

### **Files Modified:**

#### **1. video_call_screen.dart**
- ✅ Added import for `InfoBottomSheet`
- ✅ Added `_showEndCallConfirmation()` method
- ✅ Updated `_buildCallButton()` to show confirmation for active calls
- ✅ Updated `_buildProfilePictureView()` to show "No answer" for timeout
- ✅ Handle timeout state in call button

#### **2. video_call_controller.dart**
- ✅ Added `wasCallEverConnected` flag
- ✅ Set flag to true when call connects
- ✅ Reset flag in `_resetCallState()`
- ✅ Removed snackbar from timeout handler
- ✅ Updated `onCallPressed()` to check connection flag

---

## 🎨 UI States

### **Profile Picture View - Message Display**

| Call State | Message | Color | Font Size |
|------------|---------|-------|-----------|
| **Calling** | "Calling..." | Primary Light | 20sp |
| **Ringing** | "Ringing..." / "Incoming call" | Primary Light | 20sp |
| **Connecting** | "Connecting..." | Primary Light | 20sp |
| **Timeout** | **"No answer"** | Orange | 18sp ✅ |
| **Connected** | "Camera is off" | White70 | 16sp |

### **Call Button States**

| Call State | Color | Action | Behavior |
|------------|-------|--------|----------|
| **Idle** | Green | Initiate | Shows session sheet (if connected before) |
| **Calling/Ringing** | Red | Cancel | Closes screen immediately |
| **Connected** | Red | End | **Shows confirmation dialog** ✅ |
| **Timeout** | Green | Close | **Just closes screen** ✅ |

---

## ✅ Benefits

### **1. Better UX:**
- ✅ Confirmation prevents accidental call disconnects
- ✅ Clear feedback for timeout (stays visible)
- ✅ No inappropriate session sheets

### **2. Logical Flow:**
- ✅ Session ended sheet only for actual sessions
- ✅ Timeout/cancel scenarios handled appropriately
- ✅ Single-tap behavior is clear and predictable

### **3. Visual Feedback:**
- ✅ "No answer" message is persistent
- ✅ Orange color draws attention
- ✅ Consistent with other status messages

---

**Status:** ✅ Complete  
**Testing:** Ready for QA  
**Expected Result:** 
- Confirmation dialog before ending active call
- "No answer" message visible on timeout
- Session ended sheet only for connected calls
