import 'dart:async';
import 'package:get/get.dart';
import 'package:medtrac/models/chat_models.dart';
import 'package:medtrac/services/chat_service.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:intl/intl.dart';

class ChatInboxController extends GetxController {
  final ChatService _chatService = Get.find<ChatService>();
  
  final RxList<Conversation> conversations = <Conversation>[].obs;
  final RxBool isLoadingConversations = false.obs;
  final RxString searchQuery = ''.obs;
  
  StreamSubscription<List<Conversation>>? _conversationsSubscription;
  
  late int currentUserId;

  @override
  void onInit() {
    super.onInit();
    _initializeUserInfo();
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
  Future<void> loadConversations() async {
    try {
      isLoadingConversations.value = true;
      
      // Start listening to conversations stream
      _conversationsSubscription?.cancel();
      _conversationsSubscription = _chatService
          .getConversationsStream(currentUserId)
          .listen((newConversations) {
        conversations.value = newConversations;
        isLoadingConversations.value = false;
      }, onError: (error) {
        print('❌ Error loading conversations: $error');
        isLoadingConversations.value = false;
      });
      
    } catch (e) {
      print('❌ Error loading conversations: $e');
      isLoadingConversations.value = false;
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

  /// Get unread count for a conversation
  int getUnreadCount(Conversation conversation) {
    return conversation.getUnreadCount(currentUserId);
  }

  @override
  void onClose() {
    _conversationsSubscription?.cancel();
    super.onClose();
  }
}
