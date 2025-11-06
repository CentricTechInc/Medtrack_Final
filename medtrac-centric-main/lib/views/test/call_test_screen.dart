import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/services/incoming_call_service.dart';
import 'package:medtrac/utils/assets.dart';

class CallTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call Testing'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Video Calling',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text('Use these buttons to test video calling features:'),
                    SizedBox(height: 20),
                    
                    // Test incoming call
                    ElevatedButton.icon(
                      onPressed: () {
                        final incomingCallService = Get.find<IncomingCallService>();
                        incomingCallService.simulateIncomingCall(
                          callerName: "Dr. Karan Verma",
                          callerImage: Assets.vermaImage,
                          appointmentId: 123,
                          callerId: 2,
                          receiverId: 1,
                          channelName: "test_channel_${DateTime.now().millisecondsSinceEpoch}",
                          rtcToken: "test_token_123",
                        );
                      },
                      icon: Icon(Icons.phone_in_talk),
                      label: Text('Simulate Incoming Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Test outgoing call
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed('/video-call', arguments: {
                          "fromAppointment": true,
                        });
                      },
                      icon: Icon(Icons.videocam),
                      label: Text('Start Outgoing Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Video Call Indicators',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    
                    Text('✅ Videos show by default (no photos)'),
                    Text('✅ Local video in draggable preview'),
                    Text('✅ Remote video fills background'),
                    Text('✅ Black screen when no video'),
                    Text('✅ Incoming call dialog'),
                    Text('✅ Auto-accept incoming calls'),
                    
                    SizedBox(height: 16),
                    
                    Text(
                      'How to know Agora is working:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('• You see your own video in small preview'),
                    Text('• Remote video shows when other joins'),
                    Text('• No "loading" or black screens'),
                    Text('• Console shows "Successfully joined channel"'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}