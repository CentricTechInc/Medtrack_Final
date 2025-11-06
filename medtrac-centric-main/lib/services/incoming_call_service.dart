import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:medtrac/routes/app_routes.dart';

class IncomingCallService extends GetxService {
  static IncomingCallService get to => Get.find();
  
  final RxBool hasIncomingCall = false.obs;
  final RxString callerName = ''.obs;
  final RxString callerImage = ''.obs;
  final RxInt appointmentId = 0.obs;
  final RxInt callerId = 0.obs;
  final RxInt receiverId = 0.obs;
  final RxString channelName = ''.obs;
  final RxString rtcToken = ''.obs;
  
  Timer? _callTimeout;
  
  // Simulate incoming call (replace with real push notification/websocket)
  void simulateIncomingCall({
    required String callerName,
    required String callerImage,
    required int appointmentId,
    required int callerId,
    required int receiverId,
    required String channelName,
    required String rtcToken,
  }) {
    this.callerName.value = callerName;
    this.callerImage.value = callerImage;
    this.appointmentId.value = appointmentId;
    this.callerId.value = callerId;
    this.receiverId.value = receiverId;
    this.channelName.value = channelName;
    this.rtcToken.value = rtcToken;
    
    hasIncomingCall.value = true;
    
    // Show incoming call UI
    _showIncomingCallScreen();
    
    // Auto-dismiss after 30 seconds
    _callTimeout = Timer(Duration(seconds: 30), () {
      declineCall();
    });
  }
  
  void _showIncomingCallScreen() {
    Get.dialog(
      IncomingCallDialog(
        callerName: callerName.value,
        callerImage: callerImage.value,
        onAccept: acceptCall,
        onDecline: declineCall,
      ),
      barrierDismissible: false,
    );
  }
  
  void acceptCall() {
    _callTimeout?.cancel();
    hasIncomingCall.value = false;
    Get.back(); // Close dialog
    
    // Navigate to video call screen with call details
    Get.toNamed(AppRoutes.videoCallScreen, arguments: {
      "fromAppointment": true,
      "appointmentId": appointmentId.value,
      "callerId": callerId.value,
      "receiverId": receiverId.value,
      "callerName": callerName.value,
      "channelName": channelName.value,
      "rtcToken": rtcToken.value,
      "isIncomingCall": true,
    });
  }
  
  void declineCall() {
    _callTimeout?.cancel();
    hasIncomingCall.value = false;
    if (Get.isDialogOpen == true) {
      Get.back(); // Close dialog
    }
    
    // TODO: Send decline signal to caller
    print('📞 Call declined');
  }
  
  @override
  void onClose() {
    _callTimeout?.cancel();
    super.onClose();
  }
}

class IncomingCallDialog extends StatelessWidget {
  final String callerName;
  final String callerImage;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  
  const IncomingCallDialog({
    super.key,
    required this.callerName,
    required this.callerImage,
    required this.onAccept,
    required this.onDecline,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF1E40AF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Incoming Video Call',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              
              // Caller image
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  image: DecorationImage(
                    image: AssetImage(callerImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              SizedBox(height: 30),
              
              // Caller name
              Text(
                callerName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 10),
              
              Text(
                'Video Call',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              
              SizedBox(height: 80),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline button
                  GestureDetector(
                    onTap: onDecline,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                  
                  // Accept button
                  GestureDetector(
                    onTap: onAccept,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}