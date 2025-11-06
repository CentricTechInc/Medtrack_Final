import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/chat_inbox_controller.dart';
import 'package:medtrac/custom_widgets/custom_appbar_with_icons.dart';
import 'package:medtrac/custom_widgets/custom_text_field.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/helper_functions.dart';
 

class ChatInboxScreen extends GetView<ChatInboxController> {
   ChatInboxScreen({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: [
              CustomAppBarWithIcons(scaffoldKey: _scaffoldKey,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  16.verticalSpace,
                  CustomTextFormField(
                    hintText: "Search",
                    prefixIcon: Icons.search,
                    hasBorder: false,
                    fillColor: AppColors.lightGrey,
                  ),
                  32.verticalSpace,
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => 32.verticalSpace,
                      itemCount: 7,
                      shrinkWrap: true, // remove this
                      itemBuilder: (context, index) => InboxTileWidget(),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InboxTileWidget extends StatelessWidget {
  const InboxTileWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (HelperFunctions.shouldShowProfileCompletBottomSheet()) {
          HelperFunctions.showIncompleteProfileBottomSheet();
          return;
        }
        Get.toNamed(AppRoutes.chatScreen);
      },
      child: Row(
        children: [
          UserAvatarWidget(),
          12.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BodyTextOne(
                text: "Arjun Sharma",
                fontWeight: FontWeight.w700,
              ),
              8.verticalSpace,
              LastMessageWidget(),
            ],
          ),
          12.horizontalSpace,
          BodyTextOne(
            text: "12:18",
            color: AppColors.dark,
          )
        ],
      ),
    );
  }
}

class UserAvatarWidget extends StatelessWidget {
  const UserAvatarWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(20.r),
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(
              Assets.avatar,
            ),
          ),
        ));
  }
}

class LastMessageWidget extends StatelessWidget {
  const LastMessageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 270.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 220.w,
            child: BodyTextTwo(
              text: "Stand up for what you believe in or not or whatever",
              overflow: TextOverflow.ellipsis,
            ),
          ),
          UnreadMessageCounterWidget()
        ],
      ),
    );
  }
}

class UnreadMessageCounterWidget extends StatelessWidget {
  const UnreadMessageCounterWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondary,
      ),
      child: Center(
        child: BodyTextTwo(
          text: "9",
          color: AppColors.bright,
        ),
      ),
    );
  }
}
