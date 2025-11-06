import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:medtrac/models/chat_models.dart';
import 'package:medtrac/services/notification_service.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'dart:convert';
import 'dart:async';

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
      // Validate that userIds are different
      if (userId1 == userId2) {
        throw Exception('Cannot create conversation: userId1 and userId2 are the same ($userId1)');
      }
      
      final conversationId = _generateConversationId(userId1, userId2);
      final conversationRef = _firestore.collection('conversations').doc(conversationId);
      
      // Check if conversation exists
      final doc = await conversationRef.get();
      
      // Determine which user should be participant1 (always the smaller ID)
      final smallerId = userId1 < userId2 ? userId1 : userId2;
      final largerId = userId1 < userId2 ? userId2 : userId1;
      
      // Map names and pictures correctly based on ID order
      final participant1Name = smallerId == userId1 ? userName1 : userName2;
      final participant2Name = smallerId == userId1 ? userName2 : userName1;
      final participant1ProfilePicture = smallerId == userId1 ? userProfilePicture1 : userProfilePicture2;
      final participant2ProfilePicture = smallerId == userId1 ? userProfilePicture2 : userProfilePicture1;
      
      if (!doc.exists) {
        // Create new conversation
        final now = DateTime.now();
        await conversationRef.set({
          'participant1Id': smallerId,
          'participant2Id': largerId,
          'participant1Name': participant1Name,
          'participant2Name': participant2Name,
          'participant1ProfilePicture': participant1ProfilePicture,
          'participant2ProfilePicture': participant2ProfilePicture,
          'lastMessage': null,
          'lastMessageTime': null,
          'lastMessageSenderId': null,
          'unreadCount1': 0,
          'unreadCount2': 0,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });
        print('✅ Created conversation: $conversationId');
        print('   participant1Id: $smallerId ($participant1Name)');
        print('   participant2Id: $largerId ($participant2Name)');
      } else {
        // Conversation exists - only update names/pictures if needed, NEVER change IDs
        final existingData = doc.data()!;
        final existingParticipant1Id = existingData['participant1Id'] as int?;
        final existingParticipant2Id = existingData['participant2Id'] as int?;
        
        // Validate existing IDs are different
        if (existingParticipant1Id == existingParticipant2Id) {
          print('⚠️ ERROR: Existing conversation has same IDs for both participants! Fixing...');
          // Fix corrupted conversation
          await conversationRef.update({
            'participant1Id': smallerId,
            'participant2Id': largerId,
            'participant1Name': participant1Name,
            'participant2Name': participant2Name,
            'participant1ProfilePicture': participant1ProfilePicture,
            'participant2ProfilePicture': participant2ProfilePicture,
            'updatedAt': Timestamp.now(),
          });
          print('✅ Fixed corrupted conversation: participant1Id=$smallerId, participant2Id=$largerId');
          return conversationId;
        }
        
        // Update names/pictures based on which participant each user is
        // NEVER change participant IDs - only update names and profile pictures
        final updateData = <String, dynamic>{};
        
        if (userId1 == existingParticipant1Id) {
          // userId1 is participant1, update participant1 info
          if (existingData['participant1Name'] != userName1) {
            updateData['participant1Name'] = userName1;
          }
          if (existingData['participant1ProfilePicture'] != userProfilePicture1) {
            updateData['participant1ProfilePicture'] = userProfilePicture1;
          }
        } else if (userId1 == existingParticipant2Id) {
          // userId1 is participant2, update participant2 info
          if (existingData['participant2Name'] != userName1) {
            updateData['participant2Name'] = userName1;
          }
          if (existingData['participant2ProfilePicture'] != userProfilePicture1) {
            updateData['participant2ProfilePicture'] = userProfilePicture1;
          }
        }
        
        if (userId2 == existingParticipant1Id) {
          // userId2 is participant1, update participant1 info
          if (existingData['participant1Name'] != userName2) {
            updateData['participant1Name'] = userName2;
          }
          if (existingData['participant1ProfilePicture'] != userProfilePicture2) {
            updateData['participant1ProfilePicture'] = userProfilePicture2;
          }
        } else if (userId2 == existingParticipant2Id) {
          // userId2 is participant2, update participant2 info
          if (existingData['participant2Name'] != userName2) {
            updateData['participant2Name'] = userName2;
          }
          if (existingData['participant2ProfilePicture'] != userProfilePicture2) {
            updateData['participant2ProfilePicture'] = userProfilePicture2;
          }
        }
        
        // Only update if there are changes
        if (updateData.isNotEmpty) {
          updateData['updatedAt'] = Timestamp.now();
          print('⚠️ Updating conversation participant info (names/pictures only): $conversationId');
          await conversationRef.update(updateData);
          print('✅ Updated conversation info');
        }
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
      print('📨 Getting messages stream for conversation: $conversationId');
      return _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        print('📨 Received ${snapshot.docs.length} messages for conversation: $conversationId');
        final messages = snapshot.docs.map((doc) {
          try {
            return ChatMessage.fromFirestore(doc);
          } catch (e) {
            print('❌ Error parsing message ${doc.id}: $e');
            return null;
          }
        }).whereType<ChatMessage>().toList();
        print('📨 Parsed ${messages.length} valid messages');
        return messages;
      });
    } catch (e) {
      print('❌ Error getting messages stream: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return Stream.value([]);
    }
  }

  /// Get conversations stream for current user
  Stream<List<Conversation>> getConversationsStream(int currentUserId) {
    try {
      print('📱 Loading conversations for user ID: $currentUserId');
      
      // Get conversations where user is participant1
      final stream1 = _firestore
          .collection('conversations')
          .where('participant1Id', isEqualTo: currentUserId)
          .snapshots();
      
      // Get conversations where user is participant2
      final stream2 = _firestore
          .collection('conversations')
          .where('participant2Id', isEqualTo: currentUserId)
          .snapshots();
      
      // Combine both streams using StreamController
      final controller = StreamController<List<Conversation>>.broadcast();
      final Map<String, Conversation> allConversations = {};
      
      void emitCombined() {
        if (controller.isClosed) return;
        final conversations = allConversations.values.toList();
        conversations.sort((a, b) {
          final timeA = a.lastMessageTime ?? a.createdAt;
          final timeB = b.lastMessageTime ?? b.createdAt;
          return timeB.compareTo(timeA);
        });
        controller.add(conversations);
      }
      
      StreamSubscription? sub1;
      StreamSubscription? sub2;
      
      sub1 = stream1.listen((snapshot) {
        if (controller.isClosed) return;
        for (var doc in snapshot.docs) {
          try {
            final conv = Conversation.fromFirestore(doc);
            allConversations[conv.conversationId] = conv;
          } catch (e) {
            print('❌ Error parsing conversation from stream1: $e');
          }
        }
        emitCombined();
      }, onError: (error) {
        print('❌ Error in stream1: $error');
        if (!controller.isClosed) {
          controller.addError(error);
        }
      });
      
      sub2 = stream2.listen((snapshot) {
        if (controller.isClosed) return;
        for (var doc in snapshot.docs) {
          try {
            final conv = Conversation.fromFirestore(doc);
            allConversations[conv.conversationId] = conv;
          } catch (e) {
            print('❌ Error parsing conversation from stream2: $e');
          }
        }
        emitCombined();
      }, onError: (error) {
        print('❌ Error in stream2: $error');
        if (!controller.isClosed) {
          controller.addError(error);
        }
      });
      
      controller.onCancel = () {
        sub1?.cancel();
        sub2?.cancel();
        if (!controller.isClosed) {
          controller.close();
        }
      };
      
      return controller.stream;
    } catch (e) {
      print('❌ Error getting conversations stream: $e');
      print('❌ Stack trace: ${StackTrace.current}');
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

  /// Delete a conversation (removes all messages and conversation document)
  Future<void> deleteConversation(String conversationId, int currentUserId) async {
    try {
      print('🗑️ Deleting conversation: $conversationId');
      
      final conversationRef = _firestore.collection('conversations').doc(conversationId);
      
      // Verify the user is a participant before deleting
      final conversationDoc = await conversationRef.get();
      if (!conversationDoc.exists) {
        throw Exception('Conversation not found');
      }
      
      final data = conversationDoc.data()!;
      final participant1Id = data['participant1Id'];
      final participant2Id = data['participant2Id'];
      
      // Verify current user is a participant
      if (currentUserId != participant1Id && currentUserId != participant2Id) {
        throw Exception('User is not a participant in this conversation');
      }
      
      // Delete all messages in the conversation
      final messagesRef = conversationRef.collection('messages');
      final messagesSnapshot = await messagesRef.get();
      
      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete the conversation document
      batch.delete(conversationRef);
      
      await batch.commit();
      
      print('✅ Successfully deleted conversation: $conversationId');
    } catch (e) {
      print('❌ Error deleting conversation: $e');
      rethrow;
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

