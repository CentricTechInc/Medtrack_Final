import 'package:cloud_firestore/cloud_firestore.dart';

/// Chat Message Model
class ChatMessage {
  final String messageId;
  final int senderId;
  final String senderName;
  final String senderProfilePicture;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'text', 'image', 'file'

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.senderProfilePicture,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.type = 'text',
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      messageId: doc.id,
      senderId: data['senderId'] ?? 0,
      senderName: data['senderName'] ?? '',
      senderProfilePicture: data['senderProfilePicture'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      type: data['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderProfilePicture': senderProfilePicture,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
    };
  }

  ChatMessage copyWith({
    String? messageId,
    int? senderId,
    String? senderName,
    String? senderProfilePicture,
    String? text,
    DateTime? timestamp,
    bool? isRead,
    String? type,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderProfilePicture: senderProfilePicture ?? this.senderProfilePicture,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

/// Chat Conversation Model
class Conversation {
  final String conversationId;
  final int participant1Id;
  final int participant2Id;
  final String participant1Name;
  final String participant2Name;
  final String participant1ProfilePicture;
  final String participant2ProfilePicture;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int? lastMessageSenderId;
  final int unreadCount1; // Unread count for participant1
  final int unreadCount2; // Unread count for participant2
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.conversationId,
    required this.participant1Id,
    required this.participant2Id,
    required this.participant1Name,
    required this.participant2Name,
    required this.participant1ProfilePicture,
    required this.participant2ProfilePicture,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.unreadCount1 = 0,
    this.unreadCount2 = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Conversation(
      conversationId: doc.id,
      participant1Id: data['participant1Id'] ?? 0,
      participant2Id: data['participant2Id'] ?? 0,
      participant1Name: data['participant1Name'] ?? '',
      participant2Name: data['participant2Name'] ?? '',
      participant1ProfilePicture: data['participant1ProfilePicture'] ?? '',
      participant2ProfilePicture: data['participant2ProfilePicture'] ?? '',
      lastMessage: data['lastMessage'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      lastMessageSenderId: data['lastMessageSenderId'],
      unreadCount1: data['unreadCount1'] ?? 0,
      unreadCount2: data['unreadCount2'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participant1Id': participant1Id,
      'participant2Id': participant2Id,
      'participant1Name': participant1Name,
      'participant2Name': participant2Name,
      'participant1ProfilePicture': participant1ProfilePicture,
      'participant2ProfilePicture': participant2ProfilePicture,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadCount1': unreadCount1,
      'unreadCount2': unreadCount2,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper methods
  int getOtherUserId(int currentUserId) {
    return currentUserId == participant1Id ? participant2Id : participant1Id;
  }

  String getOtherUserName(int currentUserId) {
    return currentUserId == participant1Id ? participant2Name : participant1Name;
  }

  String getOtherUserProfilePicture(int currentUserId) {
    return currentUserId == participant1Id ? participant2ProfilePicture : participant1ProfilePicture;
  }

  int getUnreadCount(int currentUserId) {
    return currentUserId == participant1Id ? unreadCount1 : unreadCount2;
  }

  Conversation copyWith({
    String? conversationId,
    int? participant1Id,
    int? participant2Id,
    String? participant1Name,
    String? participant2Name,
    String? participant1ProfilePicture,
    String? participant2ProfilePicture,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? lastMessageSenderId,
    int? unreadCount1,
    int? unreadCount2,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      conversationId: conversationId ?? this.conversationId,
      participant1Id: participant1Id ?? this.participant1Id,
      participant2Id: participant2Id ?? this.participant2Id,
      participant1Name: participant1Name ?? this.participant1Name,
      participant2Name: participant2Name ?? this.participant2Name,
      participant1ProfilePicture: participant1ProfilePicture ?? this.participant1ProfilePicture,
      participant2ProfilePicture: participant2ProfilePicture ?? this.participant2ProfilePicture,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      unreadCount1: unreadCount1 ?? this.unreadCount1,
      unreadCount2: unreadCount2 ?? this.unreadCount2,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

