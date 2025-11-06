# User Name and Duration Repositioning

## 📅 Date: October 6, 2025

## 🎯 Problem Fixed

### **Issue:**
- ❌ User name was centered and hidden behind the control buttons at the bottom
- ❌ Duration was below the name, also obscured by controls
- ❌ Poor visibility and UX during calls

### **Solution:**
- ✅ Moved user name to **center-left** of the screen
- ✅ Moved duration **below the name** on the left
- ✅ Call status messages remain **centered** on screen
- ✅ Content now visible and not hidden by controls

---

## 🎨 Layout Changes

### **Before:**
```
┌─────────────────────────┐
│                         │
│  [Full-screen profile]  │
│                         │
│                         │
│      John Doe           │  ← Center (hidden by controls)
│      Calling...         │  ← Center
│      00:45              │  ← Center (hidden by controls)
│                         │
│   [Control Buttons]     │  ← Covers name/duration
└─────────────────────────┘
```

### **After:**
```
┌─────────────────────────┐
│                         │
│  [Full-screen profile]  │
│                         │
│  John Doe               │  ← Center-left (visible!)
│  00:45                  │  ← Below name, left-aligned
│                         │
│      Calling...         │  ← Center (status only)
│                         │
│   [Control Buttons]     │  ← Doesn't cover content
└─────────────────────────┘
```

---

## 🔧 Technical Implementation

### **File: video_call_screen.dart**

**Changed Layout Structure:**

#### **Before - Single Centered Column:**
```dart
// Everything in one centered column
Positioned.fill(
  child: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Text(name, ...), // Name in center
        16.verticalSpace,
        Obx(() => Text(status, ...)), // Status in center
        Obx(() => Text(duration, ...)), // Duration in center
        80.verticalSpace,
      ],
    ),
  ),
),
```

#### **After - Separate Positioned Widgets:**

**1. Name & Duration (Center-Left):**
```dart
Positioned(
  left: 24.w,              // ← 24px from left edge
  top: 0,
  bottom: 0,
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,  // ← Vertically centered
    crossAxisAlignment: CrossAxisAlignment.start, // ← Left-aligned
    children: [
      // User name
      Text(
        name,
        style: TextStyle(
          fontSize: 28.sp,  // ← Increased from 24sp
          fontWeight: FontWeight.w600,
          shadows: [...],
        ),
      ),
      // Call duration (below name)
      Obx(() {
        if (controller.callState.value == CallState.connected ||
            (controller.callState.value == CallState.disconnected && 
             controller.wasCallEverConnected.value)) {
          return Padding(
            padding: EdgeInsets.only(top: 8.h),  // ← 8px spacing
            child: Text(
              controller.formattedCallDuration,
              style: TextStyle(
                fontSize: 18.sp,  // ← Increased from 16sp
                color: Colors.white70,
                shadows: [...],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    ],
  ),
),
```

**2. Status Messages (Centered):**
```dart
Positioned.fill(
  child: Center(
    child: Obx(() {
      // Show status during call setup
      if (controller.callState.value == CallState.ringing || 
          controller.callState.value == CallState.connecting ||
          controller.callState.value == CallState.calling ||
          controller.callState.value == CallState.initiating) {
        return Text(
          controller.callStatusText,  // "Calling...", "Connecting...", etc.
          style: TextStyle(...),
        );
      }
      // Show timeout message
      if (controller.callState.value == CallState.timeout) {
        return Text(
          "Call not picked up",
          style: TextStyle(...),
        );
      }
      return const SizedBox.shrink();
    }),
  ),
),
```

---

## 📐 Positioning Details

### **User Name & Duration:**
- **Position:** `left: 24.w` (24px from left edge)
- **Vertical Alignment:** `MainAxisAlignment.center` (vertically centered)
- **Horizontal Alignment:** `CrossAxisAlignment.start` (left-aligned)
- **Name Font Size:** `28.sp` (increased from 24sp)
- **Duration Font Size:** `18.sp` (increased from 16sp)
- **Spacing:** `8.h` between name and duration (reduced from 12.h)

### **Status Messages:**
- **Position:** `Positioned.fill` (full screen)
- **Alignment:** `Center` (horizontally and vertically centered)
- **Font Size:** `20.sp` (unchanged)
- **Only Shows During:** Calling, Ringing, Connecting, Initiating, Timeout states

---

## 🎯 Display Logic

### **Center-Left (Always Visible):**
| State | User Name | Duration |
|-------|-----------|----------|
| **Calling** | ✅ Visible | ❌ Hidden |
| **Ringing** | ✅ Visible | ❌ Hidden |
| **Connecting** | ✅ Visible | ❌ Hidden |
| **Connected** | ✅ Visible | ✅ **Shows Live Timer** |
| **Disconnected** | ✅ Visible | ✅ **Shows Final Duration*** |
| **Timeout** | ✅ Visible | ❌ Hidden |

*Only if `wasCallEverConnected == true`

### **Center (Status Messages):**
| State | Message |
|-------|---------|
| **Initiating** | "Initiating call..." |
| **Calling** | "Calling..." |
| **Ringing** | "Ringing..." / "Incoming call" |
| **Connecting** | "Connecting..." |
| **Connected** | ❌ No message |
| **Disconnected** | ❌ No message |
| **Timeout** | "Call not picked up" |

---

## 🎨 Visual Hierarchy

```
Screen Layout:

Left Side (24px from edge):
┌─────────────────
│ John Doe         ← Name (28sp, bold, white)
│ 00:45            ← Duration (18sp, white70)
│
│
│
│

Center (during setup):
                Calling...    ← Status (20sp, centered)


Bottom:
        [Camera] [Call] [Mic] [More]
```

---

## ✨ Improvements

### **Better Visibility:**
- ✅ Name and duration no longer hidden by controls
- ✅ Left positioning keeps content visible at all times
- ✅ Larger font sizes for better readability (28sp name, 18sp duration)

### **Better Organization:**
- ✅ User info (name, duration) grouped on left
- ✅ Status messages (calling, timeout) remain centered
- ✅ Clear visual separation of information types

### **Better UX:**
- ✅ Controls don't obscure important information
- ✅ Consistent positioning throughout call lifecycle
- ✅ Text shadows ensure visibility over any background

---

## 🧪 Testing Checklist

### **Test 1: Name Position**
1. Start a call
2. ✅ **Expected:** Name appears on center-left (24px from edge)
3. ✅ **Expected:** Name vertically centered on screen
4. ✅ **Expected:** Name not hidden by controls

### **Test 2: Duration Below Name**
1. Start a call and connect
2. ✅ **Expected:** Duration appears below name on left
3. ✅ **Expected:** 8px spacing between name and duration
4. ✅ **Expected:** Both left-aligned
5. ✅ **Expected:** Neither hidden by controls

### **Test 3: Status Messages Centered**
1. Start a call (before connected)
2. ✅ **Expected:** "Calling..." appears in center of screen
3. ✅ **Expected:** Name still visible on left
4. Wait for timeout
5. ✅ **Expected:** "Call not picked up" appears in center
6. ✅ **Expected:** Name still visible on left

### **Test 4: Connected Call**
1. Connect a call
2. ✅ **Expected:** Name on center-left
3. ✅ **Expected:** Duration below name, incrementing
4. ✅ **Expected:** No status message in center
5. ✅ **Expected:** Nothing hidden by controls

### **Test 5: Call Ended**
1. End a connected call
2. ✅ **Expected:** Name remains on left
3. ✅ **Expected:** Final duration shows below name
4. ✅ **Expected:** Duration frozen at final time

---

## 📊 Font Size Comparison

| Element | Before | After | Change |
|---------|--------|-------|--------|
| **User Name** | 24.sp | **28.sp** | ⬆️ +4sp |
| **Duration** | 16.sp | **18.sp** | ⬆️ +2sp |
| **Status** | 20.sp | 20.sp | No change |

Larger font sizes improve readability, especially at a distance.

---

## 🎯 Key Design Decisions

### **Why Center-Left?**
- ✅ Natural reading position (Western UIs)
- ✅ Avoids control button area at bottom
- ✅ Provides consistent anchor point
- ✅ Common pattern in video call apps

### **Why Separate Positioning?**
- ✅ Name/duration always visible (persistent info)
- ✅ Status messages only when needed (temporary info)
- ✅ Prevents layout shifts during state changes
- ✅ Better control over individual positioning

### **Why Increase Font Sizes?**
- ✅ Better readability over full-screen background
- ✅ More prominent display of important info
- ✅ Matches visual hierarchy (name > duration)

---

## 📝 Files Modified

1. **`lib/views/video_call/video_call_screen.dart`**
   - Restructured `_buildProfilePictureView()` content overlay
   - Split into two separate `Positioned` widgets:
     - Name & duration: Center-left alignment
     - Status messages: Center alignment
   - Increased font sizes for better visibility
   - Adjusted spacing between elements
   - Removed centered column layout

---

## ✅ Summary

| Feature | Status | Details |
|---------|--------|---------|
| User name position | ✅ Moved | Center-left (24px from edge) |
| Duration position | ✅ Moved | Below name, left-aligned |
| Status messages | ✅ Updated | Remain centered on screen |
| Font sizes | ✅ Increased | Name: 28sp, Duration: 18sp |
| Visibility | ✅ Improved | No longer hidden by controls |
| Layout structure | ✅ Refactored | Separate positioned widgets |

**All requested changes successfully implemented!** 🎉

The user name and duration are now clearly visible on the center-left of the screen and won't be hidden by the control buttons!
