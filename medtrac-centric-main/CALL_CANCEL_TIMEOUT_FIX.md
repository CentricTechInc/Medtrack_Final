# Call Cancel Button & Timeout Auto-Close Fix

## 📅 Date: Recent Implementation

## 🐛 Problems Fixed

### **Problem 1: Cancel Button Disconnects Call**
- ❌ User taps "End Call" button during active call
- ❌ Confirmation dialog appears
- ❌ User taps "Cancel" to continue call
- ❌ **BUG**: Screen closes and call disconnects anyway!
- ❌ "Cancel" button doesn't work as expected

**Root Cause:**
- `InfoBottomSheet` automatically calls `Get.back()` in both button callbacks
- Our callback also called `Get.back()`
- **Double `Get.back()`** → First closes dialog, second closes video call screen

### **Problem 2: No Auto-Close After Timeout**
- ❌ Call times out (no answer)
- ❌ "No answer" message appears
- ❌ Screen stays open indefinitely
- ❌ User must manually tap button to close

---

## ✅ Solutions Implemented

### **1. Fixed Cancel Button (Double Get.back() Issue)**

**Before:**
```dart
void _showEndCallConfirmation() {
  Get.bottomSheet(
    InfoBottomSheet(
      primaryButtonText: 'Cancel',
      onPrimaryButtonPressed: () {
        Get.back(); // ❌ WRONG: Extra Get.back()
      },
      secondaryButtonText: 'End Call',
      onSecondaryButtonPressed: () {
        Get.back(); // ❌ WRONG: Extra Get.back()
        controller.endVideoCall();
        // ...
      },
    ),
  );
}
```

**After:**
```dart
void _showEndCallConfirmation() {
  Get.bottomSheet(
    InfoBottomSheet(
      primaryButtonText: 'Cancel',
      onPrimaryButtonPressed: () {
        // ✅ FIXED: No Get.back() - InfoBottomSheet handles it
        // This will only close the dialog, not the video call screen
      },
      secondaryButtonText: 'End Call',
      onSecondaryButtonPressed: () {
        // ✅ FIXED: No Get.back() - InfoBottomSheet handles it
        controller.endVideoCall();
        controller.onCallPressed(fromAppointment: fromAppointment);
      },
    ),
  );
}
```

**Why This Works:**
```dart
// InfoBottomSheet implementation (info_bottom_sheet.dart):
onTap: () {
  Get.back(); // ← InfoBottomSheet closes itself
  if (onPrimaryButtonPressed != null) {
    onPrimaryButtonPressed!(); // ← Then runs our callback
  }
}
```

### **2. Added 2-Second Auto-Close Timer**

**Before:**
```dart
void _startOutgoingCallTimeout() {
  outgoingCallTimer?.cancel();
  outgoingCallTimer = Timer(const Duration(seconds: 45), () {
    if (callState.value == CallState.calling) {
      callState.value = CallState.timeout;
      _stopRingtone();
      // ❌ No auto-close - screen stays open forever
    }
  });
}
```

**After:**
```dart
void _startOutgoingCallTimeout() {
  outgoingCallTimer?.cancel();
  outgoingCallTimer = Timer(const Duration(seconds: 45), () {
    if (callState.value == CallState.calling) {
      callState.value = CallState.timeout;
      _stopRingtone();
      
      // ✅ ADDED: Auto-close after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (callState.value == CallState.timeout) {
          Get.back(); // Close video call screen
        }
      });
    }
  });
}
```

---

## 📝 Key Learnings

### **InfoBottomSheet Pattern**
- **Always calls `Get.back()` before executing callbacks**
- Custom callbacks should **NOT** call `Get.back()` themselves
- This prevents double-closing issues

### **Pattern to Follow:**
```dart
// ❌ WRONG - Double Get.back()
InfoBottomSheet(
  onPrimaryButtonPressed: () {
    Get.back(); // Extra close
    doSomething();
  },
);

// ✅ CORRECT - Let InfoBottomSheet handle closing
InfoBottomSheet(
  onPrimaryButtonPressed: () {
    doSomething(); // Just do your action
  },
);
```

---

## 🧪 Testing Checklist

### **Test Scenario 1: Cancel Button**
1. Start a video call
2. Tap red "End Call" button
3. Confirmation dialog appears
4. Tap "Cancel"
5. ✅ **Expected**: Dialog closes, call continues
6. ❌ **Previous Bug**: Dialog + video screen both closed

### **Test Scenario 2: End Call Confirmation**
1. Start a video call
2. Tap red "End Call" button
3. Tap "End Call" in dialog
4. ✅ **Expected**: Call ends, session sheet appears

### **Test Scenario 3: Timeout Auto-Close**
1. Start a call
2. Wait 45 seconds (no answer)
3. ✅ **Expected**: "No answer" message appears
4. ✅ **Expected**: After 2 seconds, screen auto-closes
5. ❌ **Previous Bug**: Screen stayed open forever

---

## 📂 Files Modified

### **video_call_screen.dart**
- **Line 553-577**: `_showEndCallConfirmation()` method
- **Removed**: Duplicate `Get.back()` calls from both button callbacks
- **Added**: Comments explaining InfoBottomSheet behavior

### **video_call_controller.dart**
- **Line 357-373**: `_startOutgoingCallTimeout()` method
- **Added**: `Future.delayed(Duration(seconds: 2))` auto-close timer
- **Added**: State check `if (callState.value == CallState.timeout)` before closing

---

## ✅ Summary

| Issue | Root Cause | Solution | Status |
|-------|-----------|----------|--------|
| Cancel button closes call | Double `Get.back()` calls | Remove duplicate calls | ✅ Fixed |
| Timeout screen stays open | No auto-close logic | Add 2-second timer | ✅ Fixed |

**Both issues resolved!** 🎉
