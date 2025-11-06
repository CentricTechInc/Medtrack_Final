# 🔍 Notification Debugging Guide

## What to Look For in Logs

After adding comprehensive logging to the notification service, here's what to check when testing notifications from Firebase Console:

### 📱 **When App is in Foreground**

**Expected Log Sequence:**
```
📨 === FOREGROUND MESSAGE RECEIVED ===
📨 Message ID: [some-id]
📨 From: [firebase-project-id]
📨 Notification Title: [your-title]
📨 Notification Body: [your-body]
📨 Data payload: {...}
📨 === PROCESSING FOREGROUND MESSAGE ===
🔍 === HANDLING FOREGROUND MESSAGE ===
🔍 Converting FCM message to local notification...
🔍 Local notification details:
🔍 - Title: [your-title]
🔍 - Body: [your-body]
📧 === SHOWING LOCAL NOTIFICATION ===
📧 Calling flutter_local_notifications.show()...
✅ Local notification shown successfully: [your-title]
✅ Foreground message handled successfully
```

**❌ If you DON'T see these logs:**
- FCM is not receiving the message
- Check your FCM token is correct
- Verify Firebase project configuration

### 📱 **When App is in Background**

**Expected Log Sequence:**
```
📨 === BACKGROUND MESSAGE HANDLER ===
📨 Message ID: [some-id]
📨 From: [firebase-project-id]
📨 Background notification title: [your-title]
📨 Background notification body: [your-body]
📨 Background message processing completed
```

**❌ If you DON'T see these logs:**
- Background message handler not configured
- Check main.dart initialization

### 📱 **When Tapping Notification**

**Expected Log Sequence:**
```
👆 === NOTIFICATION TAPPED ===
👆 Notification ID: [id]
👆 Payload: {"test": "data"}
👆 Parsing payload JSON...
👆 Parsed data: {test: data}
🎯 === HANDLING NOTIFICATION TAP NAVIGATION ===
🎯 Message source: Local notification
🎯 Notification data: {test: data}
🎯 Navigation handling completed
```

## 🧪 **Testing Steps**

### Step 1: Run System Test
1. Open the app
2. Go to NotificationTestScreen  
3. Tap "🧪 Run Full System Test"
4. Check console for test results

**Expected Results:**
```
🧪 === TESTING NOTIFICATION SYSTEM ===
✅ Test 1 passed: Local notification sent
✅ Test 2 passed: FCM token is available
✅ Test 3 passed: Permissions are granted
🧪 Notification system test completed
```

### Step 2: Test Firebase Console
1. Copy FCM token from logs or test screen
2. Go to Firebase Console > Cloud Messaging
3. Send test message with:
   - **Title**: "Test from Firebase"
   - **Body**: "Testing notification delivery"
   - **Target**: Your FCM token
4. Watch console logs

### Step 3: Test Different App States
1. **Foreground**: App open and active
2. **Background**: App minimized/in background
3. **Terminated**: App completely closed

## 🔧 **Common Issues & Solutions**

### Issue 1: No Logs at All
**Problem**: No FCM logs appear when sending from Firebase Console
**Solutions**:
- Verify FCM token is correct and current
- Check internet connectivity
- Ensure Firebase project ID matches your app
- Verify `google-services.json` (Android) / `GoogleService-Info.plist` (iOS)

### Issue 2: Foreground Logs but No Notification
**Problem**: See FCM logs but no local notification appears
**Logs to check**:
```
❌ Error showing local notification: [error]
```
**Solutions**:
- Check notification permissions
- Verify local notification initialization
- Check device notification settings

### Issue 3: Background Messages Not Received
**Problem**: No background handler logs
**Solutions**:
- Verify background handler is registered in main.dart
- Check app is not in "Do Not Disturb" mode
- Ensure app has background app refresh enabled

### Issue 4: Notifications Not Tappable
**Problem**: Notifications appear but tapping doesn't work
**Solutions**:
- Check local notification initialization
- Verify tap handler registration
- Look for tap handler logs

## 🎯 **Firebase Console Testing Tips**

### Message Composition
- **Title**: Keep it short and clear
- **Body**: Descriptive message text
- **Additional Options**:
  - Add custom data under "Advanced options"
  - Set specific platform targeting if needed

### Target Selection
- Use "FCM registration token" for testing
- Paste the EXACT token from your app logs
- Don't use topics or user segments for initial testing

### Delivery Options
- Start with "Send now" for immediate testing
- Check "Test on device" option if available

## 📊 **Success Indicators**

### ✅ Everything Working
- FCM token generated successfully
- Foreground messages converted to local notifications
- Background messages logged properly
- Notification taps trigger navigation logs
- System test passes all checks

### ⚠️ Partial Issues
- Token available but no foreground notifications → Permission issue
- Background logs but no foreground logs → Handler configuration
- Notifications show but no tap response → Tap handler issue

### ❌ Complete Failure
- No FCM token → Firebase configuration issue
- No logs at all → Network or project setup issue
- System test failures → Multiple configuration problems

## 🔧 **Debug Commands**

```bash
# Check Flutter setup
flutter doctor

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Check device logs (Android)
adb logcat | grep -i flutter

# Check device logs (iOS) 
# Use Xcode Console or device logs
```

## 📝 **What to Report**

If notifications still don't work, share these logs:
1. Full console output during app startup
2. Complete system test results
3. Any error messages or stack traces
4. Firebase Console delivery status
5. Device type and OS version

---

**Use this guide to systematically debug your notification setup!** 🔍