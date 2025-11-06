import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/chat_controller.dart';
import 'package:medtrac/models/chat_models.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  late ChatController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ChatController>();
    _initializeConversation();
  }

  void _initializeConversation() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    
    if (arguments != null) {
      // Reset controller state for new conversation
      controller.resetConversation();
      
      // Initialize conversation immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.initializeConversation(
          otherUserId: arguments['otherUserId'] ?? 0,
          otherUserName: arguments['otherUserName'] ?? '',
          otherUserProfilePicture: arguments['otherUserProfilePicture'] ?? '',
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: CustomAppBar(
        title: controller.otherUserName.value.isEmpty 
            ? "Loading..." 
            : controller.otherUserName.value,
      ),
      body: controller.isLoadingMessages.value
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: controller.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64.sp,
                                color: AppColors.lightGrey,
                              ),
                              16.verticalSpace,
                              BodyTextOne(
                                text: "No messages yet",
                                color: AppColors.darkGrey,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            final message = controller.messages[index];
                            final isMe = controller.isMyMessage(message);
                            
                            // Scroll to bottom when new messages arrive
                            if (index == controller.messages.length - 1) {
                              _scrollToBottom();
                            }
                            
                            return _buildMessageBubble(message, isMe);
                          },
                        ),
                ),
                _buildMessageInput(controller),
              ],
            ),
    ));
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        constraints: BoxConstraints(maxWidth: 300.w),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.lightGrey,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 16.r : 0),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(isMe ? 0 : 16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BodyTextOne(
              text: message.senderName,
              color: isMe
                  ? AppColors.primaryLight2
                  : AppColors.darkGrey,
              fontSize: 12.sp,
            ),
            4.verticalSpace,
            BodyTextOne(
              text: message.text,
              color: isMe ? Colors.white : AppColors.secondary,
            ),
            4.verticalSpace,
            BodyTextTwo(
              text: DateFormat('HH:mm').format(message.timestamp),
              color: isMe
                  ? AppColors.primaryLight2.withOpacity(0.7)
                  : AppColors.darkGrey.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(ChatController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.bright,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: CustomTextFormField(
              controller: controller.messageController,
              hintText: "Type a message...",
              borderRadius: 24.r,
              fillColor: AppColors.lightGrey,
              onSubmitted: (_) => controller.sendMessage(),
            ),
          ),
          12.horizontalSpace,
          Obx(() => GestureDetector(
            onTap: controller.isSending.value 
                ? null 
                : () => controller.sendMessage(),
            child: Container(
              height: 48.h,
              width: 48.w,
              decoration: BoxDecoration(
                color: controller.isSending.value 
                    ? AppColors.lightGrey 
                    : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: controller.isSending.value
                  ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Image.asset(
                        Assets.sendMessageIcon,
                        color: Colors.white,
                      ),
                    ),
            ),
          )),
        ],
      ),
    );
  }
}
