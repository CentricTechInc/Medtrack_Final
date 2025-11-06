class CallInitiateRequest {
  final int appointmentId;
  final int callerId;
  final int receiverId;

  CallInitiateRequest({
    required this.appointmentId,
    required this.callerId,
    required this.receiverId,
  });

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'callerId': callerId,
      'receiverId': receiverId,
    };
  }
}

class CallInitiateResponse {
  final bool status;
  final String message;
  final CallData? data;

  CallInitiateResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory CallInitiateResponse.fromJson(Map<String, dynamic> json) {
    return CallInitiateResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? CallData.fromJson(json['data']) : null,
    );
  }
}

class CallData {
  final String duration;
  final int id;
  final String channelName;
  final int callerId;
  final int receiverId;
  final String type;
  final String status;
  final int appointmentId;
  final String updatedAt;
  final String createdAt;
  final String? rtcToken;

  CallData({
    required this.duration,
    required this.id,
    required this.channelName,
    required this.callerId,
    required this.receiverId,
    required this.type,
    required this.status,
    required this.appointmentId,
    required this.updatedAt,
    required this.createdAt,
    this.rtcToken,
  });

  factory CallData.fromJson(Map<String, dynamic> json) {
    return CallData(
      duration: json['duration'] ?? 0,
      id: json['id'] ?? 0,
      channelName: json['channel_name'] ?? '',
      callerId: json['caller_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      appointmentId: json['appointment_id'] ?? 0,
      updatedAt: json['updatedAt'] ?? '',
      createdAt: json['createdAt'] ?? '',
      rtcToken: json['rtcToken'],
    );
  }
}