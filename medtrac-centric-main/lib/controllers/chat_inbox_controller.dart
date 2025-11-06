import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/models/chat_models.dart';
import 'package:medtrac/services/chat_service.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/utils/snackbar.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:medtrac/controllers/bottom_navigation_controller.dart';

class ChatInboxController extends GetxController {
  final ChatService _chatService = Get.find<ChatService>();
  
  final RxList<Conversation> conversations = <Conversation>[].obs;
  final RxBool isLoadingConversations = false.obs;
  final RxString searchQuery = ''.obs;
  
  // Refresh controller for pull-to-refresh
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  
  StreamSubscription<List<Conversation>>? _conversationsSubscription;
  Worker? _bottomNavWorker;
  
  // Flag to track if we're currently refreshing
  bool _isRefreshing = false;
  
  late int currentUserId;

  @override
  void onInit() {
    super.onInit();
    _initializeUserInfo();
    
    // Listen to bottom navigation changes to refresh conversations when chat tab becomes active
    try {
      final bottomNavController = Get.find<BottomNavigationController>();
      _bottomNavWorker = ever(bottomNavController.selectedNavIndex, (navIndex) {
        // Index 3 is the chat tab (after Home=0, Appointments=1, Consultant/Balance=2)
        if (navIndex == 3 && !_isRefreshing) {
          print('💬 Chat tab activated - Refreshing conversations');
          // Cancel existing subscription and reload
          _conversationsSubscription?.cancel();
          _conversationsSubscription = null;
          loadConversations(isRefresh: false);
        }
      });
    } catch (e) {
      print('⚠️ BottomNavigationController not found: $e');
    }
    
    loadConversations();
  }

  void _initializeUserInfo() {
    try {
      final user = SharedPrefsService.getUserInfo;
      currentUserId = user.id;
    } catch (e) {
      print('❌ Error initializing user info: $e');
      currentUserId = 0;
    }
  }

  /// Load conversations
  Future<void> loadConversations({bool isRefresh = false}) async {
    try {
      isLoadingConversations.value = true;
      
      print('📱 ChatInboxController: Loading conversations for user ID: $currentUserId (refresh: $isRefresh)');
      
      // Verify ChatService is available
      if (!Get.isRegistered<ChatService>()) {
        print('❌ ChatService is not registered!');
        SnackbarUtils.showError('Chat service is not available. Please restart the app.');
        isLoadingConversations.value = false;
        if (isRefresh) {
          refreshController.refreshFailed();
          _isRefreshing = false;
        }
        return;
      }
      
      // Start listening to conversations stream
      _conversationsSubscription?.cancel();
      _conversationsSubscription = _chatService
          .getConversationsStream(currentUserId)
          .listen((newConversations) {
        print('✅ ChatInboxController: Received ${newConversations.length} conversations');
        conversations.value = newConversations;
        isLoadingConversations.value = false;
        
        // Complete refresh if it's active
        if (_isRefreshing || isRefresh) {
          print('✅ Completing refresh...');
          refreshController.refreshCompleted();
          _isRefreshing = false;
        }
      }, onError: (error) {
        print('❌ Error loading conversations: $error');
        isLoadingConversations.value = false;
        
        // Fail refresh if it's active
        if (_isRefreshing || isRefresh) {
          print('❌ Failing refresh due to error...');
          refreshController.refreshFailed();
          _isRefreshing = false;
        }
        
        // Show user-friendly error message
        String errorMessage = 'Failed to load conversations';
        if (error.toString().contains('permission') || error.toString().contains('PERMISSION_DENIED')) {
          errorMessage = 'Permission denied. Please check Firestore security rules.';
        } else if (error.toString().contains('network') || error.toString().contains('UNAVAILABLE')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (error.toString().contains('UNAUTHENTICATED')) {
          errorMessage = 'Authentication error. Please log in again.';
        }
        
        SnackbarUtils.showError(errorMessage);
      });
      
    } catch (e) {
      print('❌ Error loading conversations: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      isLoadingConversations.value = false;
      
      // Fail refresh if it's active
      if (_isRefreshing || isRefresh) {
        refreshController.refreshFailed();
        _isRefreshing = false;
      }
      
      SnackbarUtils.showError('Failed to load conversations: ${e.toString()}');
    }
  }

  /// Refresh conversations (called when navigating to chat tab)
  void refreshConversationsOnTabSwitch() {
    if (!_isRefreshing) {
      print('💬 Refreshing conversations on tab switch');
      // Cancel existing subscription and reload
      _conversationsSubscription?.cancel();
      _conversationsSubscription = null;
      loadConversations(isRefresh: false);
    }
  }

  /// Refresh conversations (pull-to-refresh)
  Future<void> onRefresh() async {
    try {
      print('🔄 Refreshing conversations...');
      _isRefreshing = true;
      
      // Cancel existing subscription
      _conversationsSubscription?.cancel();
      _conversationsSubscription = null;
      
      // Small delay to ensure subscription is fully cancelled
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Reload conversations with refresh flag
      await loadConversations(isRefresh: true);
      
      // Fallback: Complete refresh after a timeout if stream doesn't emit
      Future.delayed(const Duration(seconds: 3), () {
        if (_isRefreshing) {
          print('⏰ Refresh timeout - completing manually');
          refreshController.refreshCompleted();
          _isRefreshing = false;
        }
      });
      
    } catch (e) {
      print('❌ Error refreshing conversations: $e');
      refreshController.refreshFailed();
      _isRefreshing = false;
    }
  }

  /// Get filtered conversations based on search
  List<Conversation> get filteredConversations {
    if (searchQuery.value.isEmpty) {
      return conversations;
    }
    
    final query = searchQuery.value.toLowerCase();
    return conversations.where((conv) {
      final otherUserName = conv.getOtherUserName(currentUserId).toLowerCase();
      final lastMessage = conv.lastMessage?.toLowerCase() ?? '';
      return otherUserName.contains(query) || lastMessage.contains(query);
    }).toList();
  }

  /// Open chat with a user
  void openChat(Conversation conversation) {
    try {
      final otherUserId = conversation.getOtherUserId(currentUserId);
      final otherUserName = conversation.getOtherUserName(currentUserId);
      final otherUserProfilePicture = conversation.getOtherUserProfilePicture(currentUserId);
      
      Get.toNamed(
        AppRoutes.chatScreen,
        arguments: {
          'otherUserId': otherUserId,
          'otherUserName': otherUserName,
          'otherUserProfilePicture': otherUserProfilePicture,
        },
      );
    } catch (e) {
      print('❌ Error opening chat: $e');
    }
  }

  /// Format timestamp for display
  String formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      // Today - show time
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(timestamp); // Day name
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(Conversation conversation) async {
    try {
      print('🗑️ ChatInboxController: Deleting conversation ${conversation.conversationId}');
      
      // Show confirmation dialog
      final shouldDelete = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Conversation'),
          content: Text('Are you sure you want to delete this conversation with ${conversation.getOtherUserName(currentUserId)}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      
      if (shouldDelete != true) {
        return;
      }
      
      // Delete the conversation
      await _chatService.deleteConversation(conversation.conversationId, currentUserId);
      
      // Show success message
      SnackbarUtils.showSuccess('Conversation deleted successfully');
      
      // The conversation will be automatically removed from the list via the stream
    } catch (e) {
      print('❌ Error deleting conversation: $e');
      SnackbarUtils.showError('Failed to delete conversation: ${e.toString()}');
    }
  }

  /// Get unread count for a conversation
  int getUnreadCount(Conversation conversation) {
    return conversation.getUnreadCount(currentUserId);
  }

  @override
  void onClose() {
    _bottomNavWorker?.dispose();
    _conversationsSubscription?.cancel();
    refreshController.dispose();
    super.onClose();
  }
}
