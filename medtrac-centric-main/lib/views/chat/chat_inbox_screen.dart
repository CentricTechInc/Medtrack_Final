import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/chat_inbox_controller.dart';
import 'package:medtrac/models/chat_models.dart';
import 'package:medtrac/custom_widgets/custom_appbar_with_icons.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/helper_functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> with AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final ChatInboxController controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ChatInboxController>();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: [
          CustomAppBarWithIcons(scaffoldKey: _scaffoldKey),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  16.verticalSpace,
                  CustomTextFormField(
                    hintText: "Search",
                    prefixIcon: Icons.search,
                    hasBorder: false,
                    fillColor: AppColors.lightGrey,
                    onChanged: (value) {
                      controller.searchQuery.value = value;
                    },
                  ),
                  32.verticalSpace,
                  Expanded(
                    child: SmartRefresher(
                      key: const ValueKey('chat_inbox_refresher'),
                      controller: controller.refreshController,
                      enablePullDown: true,
                      enablePullUp: false,
                      onRefresh: controller.onRefresh,
                      header: WaterDropHeader(
                        complete: Text(
                          'Refresh Completed',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14.sp,
                          ),
                        ),
                        waterDropColor: AppColors.primary,
                      ),
                      child: Obx(() {
                        if (controller.isLoadingConversations.value && controller.conversations.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final conversations = controller.filteredConversations;

                        if (conversations.isEmpty) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
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
                                      text: controller.searchQuery.value.isEmpty
                                          ? "No conversations yet"
                                          : "No conversations found",
                                      color: AppColors.darkGrey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          separatorBuilder: (context, index) => 32.verticalSpace,
                          itemCount: conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = conversations[index];
                            return Dismissible(
                              key: Key(conversation.conversationId),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 24.w),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.delete,
                                  color: AppColors.bright,
                                  size: 28.sp,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                // The delete confirmation is handled in the controller
                                await controller.deleteConversation(conversation);
                                return false; // Don't dismiss automatically, let the stream handle it
                              },
                              child: InboxTileWidget(conversation: conversation),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InboxTileWidget extends StatelessWidget {
  final Conversation conversation;

  const InboxTileWidget({
    super.key,
    required this.conversation,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatInboxController>();
    final otherUserName = conversation.getOtherUserName(controller.currentUserId);
    final otherUserProfilePicture = conversation.getOtherUserProfilePicture(controller.currentUserId);
    final unreadCount = controller.getUnreadCount(conversation);
    final lastMessageTime = controller.formatTimestamp(conversation.lastMessageTime);

    return InkWell(
      onTap: () {
        if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
          HelperFunctions.showIncompleteProfileBottomSheet();
          return;
        }
        controller.openChat(conversation);
      },
      child: Row(
        children: [
          UserAvatarWidget(profilePictureUrl: otherUserProfilePicture),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyTextOne(
                  text: otherUserName,
                  fontWeight: FontWeight.w700,
                ),
                8.verticalSpace,
                LastMessageWidget(
                  lastMessage: conversation.lastMessage ?? 'No messages yet',
                  unreadCount: unreadCount,
                ),
              ],
            ),
          ),
          12.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BodyTextOne(
                text: lastMessageTime,
                color: AppColors.dark,
              ),
              if (unreadCount > 0) ...[
                8.verticalSpace,
                UnreadMessageCounterWidget(count: unreadCount),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class UserAvatarWidget extends StatelessWidget {
  final String profilePictureUrl;

  const UserAvatarWidget({
    super.key,
    required this.profilePictureUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightGrey,
      ),
      child: profilePictureUrl.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: profilePictureUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Image.asset(
                  Assets.avatar,
                  fit: BoxFit.cover,
                ),
                errorWidget: (context, url, error) => Image.asset(
                  Assets.avatar,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : Image.asset(
              Assets.avatar,
              fit: BoxFit.cover,
            ),
    );
  }
}

class LastMessageWidget extends StatelessWidget {
  final String lastMessage;
  final int unreadCount;

  const LastMessageWidget({
    super.key,
    required this.lastMessage,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: BodyTextTwo(
              text: lastMessage,
              overflow: TextOverflow.ellipsis,
              fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (unreadCount > 0) ...[
            8.horizontalSpace,
            UnreadMessageCounterWidget(count: unreadCount),
          ],
        ],
      ),
    );
  }
}

class UnreadMessageCounterWidget extends StatelessWidget {
  final int count;

  const UnreadMessageCounterWidget({
    super.key,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: count > 9 ? 6.w : 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: AppColors.secondary,
      ),
      child: BodyTextTwo(
        text: count > 99 ? '99+' : count.toString(),
        color: AppColors.bright,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
