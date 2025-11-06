import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/models/chat_models.dart';
import 'package:medtrac/services/chat_service.dart';
import 'package:medtrac/services/shared_preference_service.dart';

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
      Get.snackbar('Error', errorMessage, duration: const Duration(seconds: 5));
    } finally {
      isLoadingMessages.value = false;
    }
  }

  /// Start listening to messages stream
  void _startListeningToMessages() {
    _messagesSubscription?.cancel();
    _messagesSubscription = _chatService
        .getMessagesStream(conversationId.value)
        .listen((newMessages) {
      messages.value = newMessages;
    }, onError: (error) {
      print('❌ Error listening to messages: $error');
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
      Get.snackbar('Error', 'Failed to send message');
    } finally {
      isSending.value = false;
    }
  }

  /// Check if message is from current user
  bool isMyMessage(ChatMessage message) {
    return message.senderId == currentUserId;
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
