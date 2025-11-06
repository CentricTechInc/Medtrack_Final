import '../http_client.dart';
import '../models/call_response.dart';

class VideoCallService {
  final HttpClient _httpClient = HttpClient();

  /// Initiate a video call
  Future<CallInitiateResponse> initiateCall({
    required int appointmentId,
    required int callerId,
    required int receiverId,
  }) async {
    try {
      final request = CallInitiateRequest(
        appointmentId: appointmentId,
        callerId: callerId,
        receiverId: receiverId,
      );

      final response = await _httpClient.post(
        'agora/call-initiate',
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CallInitiateResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to initiate call: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      throw Exception('Call initiation failed: $e');
    }
  }

  /// Decline a video call
  Future<void> declineCall({
    required int appointmentId,
    required int callerId,
    required int receiverId,
  }) async {
    try {
      final response = await _httpClient.post(
        'agora/call-decline',
        data: {
          'appointmentId': appointmentId,
          'callerId': callerId,
          'receiverId': receiverId,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to decline call: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Failed to notify server of call decline: $e');
      // Don't throw - declining locally is more important than server notification
    }
  }

  /// End a video call
  Future<void> endCall({
    required int appointmentId,
    required int callerId,
    required int receiverId,
  }) async {
    try {
      final response = await _httpClient.post(
        'agora/call-end',
        data: {
          'appointmentId': appointmentId,
          'callerId': callerId,
          'receiverId': receiverId,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to end call: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Failed to notify server of call end: $e');
      // Don't throw - ending locally is more important than server notification
    }
  }

  /// End call with duration tracking (called on leave channel)
  Future<void> endCallWithDuration({
    required int callId,
    required int appointmentId,
    required int duration,
  }) async {
    try {

      final response = await _httpClient.post(
        'agora/end-call',
        data: {
          'callId': callId,
          'appointmentId': appointmentId,
          'duration': duration,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Call ended successfully on server');
      } else {
        throw Exception('Failed to end call: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Failed to notify server of call end with duration: $e');
      // Don't throw - ending locally is more important than server notification
    }
  }
}