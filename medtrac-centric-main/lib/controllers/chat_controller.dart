import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/models/chat_models.dart';
import 'package:medtrac/services/chat_service.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:intl/intl.dart';

class ChatController extends GetxController {
  final ChatService _chatService = Get.find<ChatService>();
  
  // Current conversation
  final RxString conversationId = ''.obs;
  final RxString otherUserName = ''.obs;
  final RxString otherUserProfilePicture = ''.obs;
  final RxInt otherUserId = 0.obs;
  
  // Messages
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoadingMessages = false.obs;
  
  // Message input
  final TextEditingController messageController = TextEditingController();
  final RxBool isSending = false.obs;
  
  // Stream subscription
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  
  // Current user info
  late int currentUserId;
  late String currentUserName;
  late String currentUserProfilePicture;

  @override
  void onInit() {
    super.onInit();
    _initializeUserInfo();
  }

  /// Reset conversation state for new chat
  void resetConversation() {
    conversationId.value = '';
    otherUserName.value = '';
    otherUserProfilePicture.value = '';
    otherUserId.value = 0;
    messages.clear();
    isLoadingMessages.value = false;
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    messageController.clear();
  }

  void _initializeUserInfo() {
    try {
      final user = SharedPrefsService.getUserInfo;
      currentUserId = user.id;
      currentUserName = user.name;
      currentUserProfilePicture = user.profilePicture;
    } catch (e) {
      print('❌ Error initializing user info: $e');
      currentUserId = 0;
      currentUserName = '';
      currentUserProfilePicture = '';
    }
  }

  /// Initialize conversation with another user
  Future<void> initializeConversation({
    required int otherUserId,
    required String otherUserName,
    required String otherUserProfilePicture,
  }) async {
    try {
      isLoadingMessages.value = true;
      
      this.otherUserId.value = otherUserId;
      this.otherUserName.value = otherUserName;
      this.otherUserProfilePicture.value = otherUserProfilePicture;
      
      // Get or create conversation
      conversationId.value = await _chatService.getOrCreateConversation(
        userId1: currentUserId,
        userId2: otherUserId,
        userName1: currentUserName,
        userName2: otherUserName,
        userProfilePicture1: currentUserProfilePicture,
        userProfilePicture2: otherUserProfilePicture,
      );
      
      // Listen to messages
      _startListeningToMessages();
      
      // Set current conversation to avoid notifications
      _chatService.setCurrentConversationId(conversationId.value);
      
      // Mark messages as read
      await _chatService.markMessagesAsRead(conversationId.value, currentUserId);
      
    } catch (e) {
      print('❌ Error initializing conversation: $e');
      final errorMessage = e.toString().contains('Unable to establish connection') 
          ? 'Firestore is not enabled. Please enable Firestore in Firebase Console.'
          : 'Failed to load conversation: ${e.toString()}';
      SnackbarUtils.showError(errorMessage);
    } finally {
      isLoadingMessages.value = false;
    }
  }

  /// Start listening to messages stream
  void _startListeningToMessages() {
    _messagesSubscription?.cancel();
    print('📨 Starting to listen to messages for conversation: ${conversationId.value}');
    _messagesSubscription = _chatService
        .getMessagesStream(conversationId.value)
        .listen((newMessages) {
      print('📨 Received ${newMessages.length} messages in controller');
      messages.value = newMessages;
    }, onError: (error) {
      print('❌ Error listening to messages: $error');
      print('❌ Stack trace: ${StackTrace.current}');
    });
  }

  /// Send a message
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || conversationId.value.isEmpty) return;
    
    try {
      isSending.value = true;
      
      await _chatService.sendMessage(
        conversationId: conversationId.value,
        senderId: currentUserId,
        senderName: currentUserName,
        senderProfilePicture: currentUserProfilePicture,
        text: text,
      );
      
      // Clear input
      messageController.clear();
      
      // Mark messages as read for sender
      await _chatService.markMessagesAsRead(conversationId.value, currentUserId);
      
    } catch (e) {
      print('❌ Error sending message: $e');
      SnackbarUtils.showError('Failed to send message');
    } finally {
      isSending.value = false;
    }
  }

  /// Check if message is from current user
  bool isMyMessage(ChatMessage message) {
    return message.senderId == currentUserId;
  }

  /// Check if two messages are on different dates
  bool _isDifferentDate(ChatMessage message1, ChatMessage message2) {
    final date1 = DateTime(
      message1.timestamp.year,
      message1.timestamp.month,
      message1.timestamp.day,
    );
    final date2 = DateTime(
      message2.timestamp.year,
      message2.timestamp.month,
      message2.timestamp.day,
    );
    return !date1.isAtSameMomentAs(date2);
  }

  /// Format date for divider display
  String formatDateDivider(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (messageDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      // Check if it's within the last 7 days
      final difference = today.difference(messageDate).inDays;
      if (difference < 7) {
        return DateFormat('EEEE').format(date); // Day name (Monday, Tuesday, etc.)
      } else {
        return DateFormat('dd MMM yyyy').format(date); // Full date (12 Jan 2024)
      }
    }
  }

  /// Get messages with date dividers
  List<dynamic> get messagesWithDividers {
    if (messages.isEmpty) return [];
    
    final List<dynamic> items = [];
    
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      
      // Add date divider if this is the first message or if date changed
      if (i == 0 || _isDifferentDate(messages[i - 1], message)) {
        items.add({
          'type': 'date_divider',
          'date': message.timestamp,
        });
      }
      
      // Add the message
      items.add({
        'type': 'message',
        'message': message,
      });
    }
    
    return items;
  }

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    messageController.dispose();
    // Clear current conversation when leaving chat screen
    _chatService.setCurrentConversationId(null);
    super.onClose();
  }
}
