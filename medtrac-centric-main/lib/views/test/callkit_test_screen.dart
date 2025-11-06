import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/services/callkit_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CallKitTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CallKit Testing'),
        backgroundColor: Colors.deepPurple,
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
                      'CallKit Testing',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text('Test CallKit functionality for video calls:'),
                    SizedBox(height: 20),
                    
                    
                    SizedBox(height: 12),
                    
                    // End all CallKit calls
                    ElevatedButton.icon(
                      onPressed: () => _endAllCalls(),
                      icon: Icon(Icons.call_end),
                      label: Text('End All CallKit Calls'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Testing Instructions:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '1. "Test CallKit Incoming Call" - Shows native call UI with Accept/Decline buttons',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2. "Simulate Background Call" - Mimics how a real push notification would trigger CallKit',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '3. "Test Foreground Call" - Shows how calls are handled when app is open',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '4. Try putting the app in background and then use "Simulate Background Call"',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  

  void _endAllCalls() async {
    try {
      final callKitService = Get.find<CallKitService>();
      await callKitService.endAllCalls();
      
      Get.snackbar(
        'CallKit',
        'All calls ended',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to end calls: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
