import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:medtrac/models/chat_models.dart';
import 'package:medtrac/services/notification_service.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'dart:convert';

/// Chat Service for Firestore integration
class ChatService extends GetxService {
  static ChatService get instance => Get.find<ChatService>();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Track current conversation ID to avoid duplicate notifications
  String? _currentConversationId;
  
  @override
  void onInit() {
    super.onInit();
    _setupMessageNotifications();
  }
  
  /// Setup listener for new messages to show notifications
  void _setupMessageNotifications() {
    try {
      final user = SharedPrefsService.getUserInfo;
      final currentUserId = user.id;
      
      // Listen to all conversations for this user
      _firestore
          .collection('conversations')
          .where('participant1Id', isEqualTo: currentUserId)
          .snapshots()
          .listen((snapshot) {
        for (var doc in snapshot.docChanges) {
          if (doc.type == DocumentChangeType.modified) {
            final conversationId = doc.doc.id;
            _checkForNewMessages(conversationId, currentUserId);
          }
        }
      });
      
      _firestore
          .collection('conversations')
          .where('participant2Id', isEqualTo: currentUserId)
          .snapshots()
          .listen((snapshot) {
        for (var doc in snapshot.docChanges) {
          if (doc.type == DocumentChangeType.modified) {
            final conversationId = doc.doc.id;
            _checkForNewMessages(conversationId, currentUserId);
          }
        }
      });
    } catch (e) {
      print('❌ Error setting up message notifications: $e');
    }
  }
  
  /// Check for new messages and show notification
  Future<void> _checkForNewMessages(String conversationId, int currentUserId) async {
    try {
      // Skip if this is the currently open conversation
      if (conversationId == _currentConversationId) {
        return;
      }
      
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();
      
      if (!conversationDoc.exists) return;
      
      final data = conversationDoc.data()!;
      final lastMessageSenderId = data['lastMessageSenderId'];
      final lastMessage = data['lastMessage'] as String?;
      
      // Only notify if message is from another user
      if (lastMessageSenderId != currentUserId && lastMessage != null && lastMessage.isNotEmpty) {
        final isParticipant1 = currentUserId == data['participant1Id'];
        final senderName = isParticipant1 ? data['participant2Name'] : data['participant1Name'];
        
        // Show local notification
        await NotificationService().showLocalNotification(
          id: conversationId.hashCode,
          title: senderName ?? 'New Message',
          body: lastMessage,
          payload: jsonEncode({
            'type': 'chat',
            'conversationId': conversationId,
            'senderId': lastMessageSenderId,
          }),
        );
      }
    } catch (e) {
      print('❌ Error checking for new messages: $e');
    }
  }
  
  /// Set current conversation ID (to avoid notifications when chat is open)
  void setCurrentConversationId(String? conversationId) {
    _currentConversationId = conversationId;
  }
  
  /// Generate conversation ID from two user IDs (sorted)
  String _generateConversationId(int userId1, int userId2) {
    final ids = [userId1, userId2]..sort();
    return 'conv_${ids[0]}_${ids[1]}';
  }

  /// Get or create a conversation between two users
  Future<String> getOrCreateConversation({
    required int userId1,
    required int userId2,
    required String userName1,
    required String userName2,
    required String userProfilePicture1,
    required String userProfilePicture2,
  }) async {
    try {
      final conversationId = _generateConversationId(userId1, userId2);
      final conversationRef = _firestore.collection('conversations').doc(conversationId);
      
      // Check if conversation exists
      final doc = await conversationRef.get();
      
      if (!doc.exists) {
        // Create new conversation
        final now = DateTime.now();
        await conversationRef.set({
          'participant1Id': userId1 < userId2 ? userId1 : userId2,
          'participant2Id': userId1 < userId2 ? userId2 : userId1,
          'participant1Name': userId1 < userId2 ? userName1 : userName2,
          'participant2Name': userId1 < userId2 ? userName2 : userName1,
          'participant1ProfilePicture': userId1 < userId2 ? userProfilePicture1 : userProfilePicture2,
          'participant2ProfilePicture': userId1 < userId2 ? userProfilePicture2 : userProfilePicture1,
          'lastMessage': null,
          'lastMessageTime': null,
          'lastMessageSenderId': null,
          'unreadCount1': 0,
          'unreadCount2': 0,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });
      }
      
      return conversationId;
    } catch (e) {
      print('❌ Error creating/getting conversation: $e');
      rethrow;
    }
  }

  /// Send a message
  Future<void> sendMessage({
    required String conversationId,
    required int senderId,
    required String senderName,
    required String senderProfilePicture,
    required String text,
  }) async {
    try {
      final conversationRef = _firestore.collection('conversations').doc(conversationId);
      final messagesRef = conversationRef.collection('messages');
      
      // Add message
      final messageData = {
        'senderId': senderId,
        'senderName': senderName,
        'senderProfilePicture': senderProfilePicture,
        'text': text,
        'timestamp': Timestamp.now(),
        'isRead': false,
        'type': 'text',
      };
      
      await messagesRef.add(messageData);
      
      // Update conversation
      final conversationDoc = await conversationRef.get();
      final conversationData = conversationDoc.data()!;
      
      final isParticipant1 = senderId == conversationData['participant1Id'];
      final currentUnreadCount1 = conversationData['unreadCount1'] ?? 0;
      final currentUnreadCount2 = conversationData['unreadCount2'] ?? 0;
      
      // Increment unread count for the other participant
      await conversationRef.update({
        'lastMessage': text,
        'lastMessageTime': Timestamp.now(),
        'lastMessageSenderId': senderId,
        'unreadCount1': isParticipant1 ? currentUnreadCount1 : currentUnreadCount1 + 1,
        'unreadCount2': isParticipant1 ? currentUnreadCount2 + 1 : currentUnreadCount2,
        'updatedAt': Timestamp.now(),
      });
      
      // Send notification to the other participant
      await _sendMessageNotification(
        conversationId: conversationId,
        senderId: senderId,
        senderName: senderName,
        receiverId: isParticipant1 ? conversationData['participant2Id'] : conversationData['participant1Id'],
        messageText: text,
      );
      
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  /// Get messages stream for a conversation
  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    try {
      return _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
      });
    } catch (e) {
      print('❌ Error getting messages stream: $e');
      return Stream.value([]);
    }
  }

  /// Get conversations stream for current user
  Stream<List<Conversation>> getConversationsStream(int currentUserId) {
    try {
      // Use a simpler approach - get all conversations and filter
      return _firestore
          .collection('conversations')
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Conversation.fromFirestore(doc))
            .where((conv) => 
                conv.participant1Id == currentUserId || 
                conv.participant2Id == currentUserId)
            .toList();
      });
    } catch (e) {
      print('❌ Error getting conversations stream: $e');
      return Stream.value([]);
    }
  }

  /// Get conversations list (single query)
  Future<List<Conversation>> getConversations(int currentUserId) async {
    try {
      final conversations1 = await _firestore
          .collection('conversations')
          .where('participant1Id', isEqualTo: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .get();
      
      final conversations2 = await _firestore
          .collection('conversations')
          .where('participant2Id', isEqualTo: currentUserId)
          .orderBy('lastMessageTime', descending: true)
          .get();
      
      final list1 = conversations1.docs.map((doc) => Conversation.fromFirestore(doc)).toList();
      final list2 = conversations2.docs.map((doc) => Conversation.fromFirestore(doc)).toList();
      
      // Combine and sort by last message time
      final allConversations = [...list1, ...list2];
      allConversations.sort((a, b) {
        final timeA = a.lastMessageTime ?? a.createdAt;
        final timeB = b.lastMessageTime ?? b.createdAt;
        return timeB.compareTo(timeA);
      });
      
      return allConversations;
    } catch (e) {
      print('❌ Error getting conversations: $e');
      return [];
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String conversationId, int currentUserId) async {
    try {
      final conversationRef = _firestore.collection('conversations').doc(conversationId);
      final messagesRef = conversationRef.collection('messages');
      
      // Get unread messages
      final unreadMessages = await messagesRef
          .where('senderId', isNotEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();
      
      // Mark all as read
      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      
      // Reset unread count in conversation
      final conversationDoc = await conversationRef.get();
      final conversationData = conversationDoc.data()!;
      final isParticipant1 = currentUserId == conversationData['participant1Id'];
      
      await conversationRef.update({
        isParticipant1 ? 'unreadCount1' : 'unreadCount2': 0,
        'updatedAt': Timestamp.now(),
      });
      
    } catch (e) {
      print('❌ Error marking messages as read: $e');
    }
  }

  /// Get unread message count for a conversation
  Future<int> getUnreadCount(String conversationId, int currentUserId) async {
    try {
      final conversationDoc = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .get();
      
      if (!conversationDoc.exists) return 0;
      
      final data = conversationDoc.data()!;
      final isParticipant1 = currentUserId == data['participant1Id'];
      return isParticipant1 
          ? (data['unreadCount1'] ?? 0) 
          : (data['unreadCount2'] ?? 0);
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  /// Send push notification for new message
  /// Note: This is a client-side notification. For production, use Cloud Functions
  Future<void> _sendMessageNotification({
    required String conversationId,
    required int senderId,
    required String senderName,
    required int receiverId,
    required String messageText,
  }) async {
    try {
      // Note: In production, notifications should be sent from backend via Cloud Functions
      // This is a placeholder for client-side notification handling
      // The backend should send FCM notifications when new messages are created
      
      print('📨 Message notification should be sent to user $receiverId');
      print('📨 From: $senderName');
      print('📨 Message: $messageText');
      
      // If you have a backend API endpoint for sending notifications:
      // await ApiManager.post('/send-chat-notification', {
      //   'receiverId': receiverId,
      //   'senderName': senderName,
      //   'message': messageText,
      //   'conversationId': conversationId,
      // });
      
    } catch (e) {
      print('❌ Error sending message notification: $e');
    }
  }
}

