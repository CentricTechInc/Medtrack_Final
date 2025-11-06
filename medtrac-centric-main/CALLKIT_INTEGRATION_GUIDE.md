# CallKit Integration Implementation Guide

## ✅ **What's Been Implemented**

### **1. Package Dependencies Added**
```yaml
# pubspec.yaml
flutter_callkit_incoming: ^2.0.0
uuid: ^4.5.1
```

### **2. CallKit Service Created**
- **File**: `lib/services/callkit_service.dart`
- **Features**:
  - Native iOS/Android incoming call UI
  - Call accept/decline handling
  - Auto-navigation to video call screen
  - 30-second call timeout
  - Integration with Agora video calling

### **3. Enhanced Notification Service**
- **File**: `lib/services/notification_service.dart` 
- **Features**:
  - Detects call notifications by `rtcToken` field
  - Background message handler for terminated/background app
  - Foreground call handling with direct navigation
  - CallKit integration for background calls

### **4. Android Configuration**
- **File**: `android/app/src/main/AndroidManifest.xml`
- **Added**: All necessary permissions for CallKit and video calling

### **5. iOS Configuration** 
- **File**: `ios/Runner/Info.plist`
- **Added**: VoIP background mode for CallKit

### **6. Service Registration**
- **File**: `lib/bindings/bindings.dart`
- **Added**: CallKitService to dependency injection

## 🎯 **How It Works**

### **Payload Detection**
```json
{
  "callId": "28",
  "receiverId": "28", 
  "rtcToken": "00650895ede72664...", // ← Key field for detection
  "appointmentId": "2",
  "channelName": "call_1759511086058",
  "callerId": "35"
}
```

### **App State Scenarios**

#### **1. App in Foreground**
```
Push Notification Received 
→ Detect rtcToken field
→ Navigate directly to video call screen
→ Show ringing state for 2 seconds
→ Auto-connect to call
```

#### **2. App in Background/Terminated**
```
Push Notification Received
→ Detect rtcToken field  
→ Show native CallKit incoming call UI
→ User accepts/declines via native UI
→ If accepted: Open app → Navigate to video call screen
→ Auto-connect to call
```

## 📱 **User Experience**

### **Foreground Experience**
- Instant navigation to video call screen
- Shows "Incoming call from Dr. Name"
- 2-second ringing animation
- Automatic call connection

### **Background/Terminated Experience**
- Native iOS/Android incoming call UI
- Full-screen call interface
- Accept/Decline buttons
- Ringtone plays
- 30-second timeout
- If accepted: App opens to video call

## 🔧 **Next Steps Required**

### **1. Install Dependencies**
```bash
cd /Users/muhammaduzair/Documents/personal-github/medtrac-centric
flutter pub get
```

### **2. iOS Setup (if targeting iOS)**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Enable "Push Notifications" capability
3. Enable "Background Modes" capability
4. Check "Voice over IP" in Background Modes
5. Add CallKit framework if needed

### **3. Test the Integration**

#### **Test Foreground Calls**
```dart
// Simulate a call notification in foreground
final testPayload = {
  "callId": "123",
  "callerId": "35", 
  "receiverId": "28",
  "appointmentId": "2",
  "channelName": "test_channel_123",
  "rtcToken": "test_token_123"
};

// This should navigate directly to video call screen
```

#### **Test Background Calls**
1. Put app in background
2. Send push notification with rtcToken
3. Should show native incoming call UI
4. Accept call → should open app to video screen

### **4. Backend Integration**
Your backend is already sending the correct payload format:
```json
{
  "callId": "28",
  "receiverId": "28",
  "rtcToken": "00650895ede...",
  "appointmentId": "2", 
  "channelName": "call_1759511086058",
  "callerId": "35"
}
```

This will be automatically detected and handled!

## 🚀 **Expected Behavior**

### **✅ Foreground App**
- Push received → Instant video call screen navigation
- Shows caller name and ringing state
- Auto-connects after 2 seconds

### **✅ Background/Terminated App** 
- Push received → Native incoming call UI
- User can accept/decline via native interface
- Accept → App opens to video call screen
- Decline → Call ends, app stays closed

### **✅ Call Management**
- 30-second call timeout
- Proper call state management
- Integration with existing Agora video calling
- CallKit event handling (accept/decline/end)

## 🔍 **Debug Information**

Look for these console logs:
```
📞 Detected CALL notification in foreground
📞 Detected CALL notification in background  
📞 === HANDLING INCOMING CALL (FOREGROUND) ===
📞 === HANDLING INCOMING CALL (BACKGROUND) ===
✅ CallKit incoming call displayed
📞 CallKit Event: actionCallAccept
```

The integration is now complete and ready to test! 🎉