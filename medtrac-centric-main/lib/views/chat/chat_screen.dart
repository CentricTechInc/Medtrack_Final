import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/chat_controller.dart';
import 'package:medtrac/custom_widgets/custom_app_bar.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Arjun Sharma",
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  16.verticalSpace,
                  Flexible(
                    fit: FlexFit.loose,
                    child: Obx(() => ListView.builder(
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            final msg = controller.messages[index];
                            final isMe = msg.isMe;
                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 6.h),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 12.h),
                                constraints: BoxConstraints(maxWidth: 300.w),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppColors.primary
                                      : AppColors.lightGrey,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(isMe ? 16.r : 0),
                                    topRight: Radius.circular(16.r),
                                    bottomLeft: Radius.circular(16.r),
                                    bottomRight:
                                        Radius.circular(isMe ? 0 : 16.r),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BodyTextOne(
                                      text: isMe ? 'Arjun' : "Verma",
                                      color: isMe
                                          ? AppColors.primaryLight2
                                          : AppColors.darkGrey,
                                    ),
                                    BodyTextOne(
                                      text: msg.text,
                                      color: isMe
                                          ? Colors.white
                                          : AppColors.secondary,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
                  ),
                ],
              ),
            ),
          ),
          16.verticalSpace,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: AppColors.bright,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add,
                  color: AppColors.primary,
                  size: 36.sp,
                ),
                Expanded(
                  child: CustomTextFormField(
                    hintText: "Type a message...",
                    borderRadius: 24.r,
                    fillColor: AppColors.lightGrey,
                    suffixIcon: Container(
                      height: 32.h,
                      width: 32.h,
                      decoration: BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: Image.asset(
                        Assets.sendMessageIcon,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
