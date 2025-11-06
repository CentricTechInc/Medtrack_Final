import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/app_bar_contoller.dart';
import 'package:medtrac/custom_widgets/custom_appbar_icon.dart';
import 'package:medtrac/routes/app_routes.dart';
import 'package:medtrac/services/shared_preference_service.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/utils/enums.dart';
import 'package:medtrac/utils/helper_functions.dart';
 
import 'package:medtrac/views/Home/widgets/banner_widget.dart';

class CustomAppBarWithIcons extends StatelessWidget {
    final GlobalKey<ScaffoldState> scaffoldKey;

   CustomAppBarWithIcons({
    super.key,
    required this.scaffoldKey
  });

  final AppBarContoller _controller = Get.find<AppBarContoller>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomAppBarIcon(
          iconPath: Assets.menuIcon,
          onTap: () => _controller.onTapMenuIcon(),
        ),
        Expanded(
          child: !SharedPrefsService.isProfileApproved() && SharedPrefsService.getRole() == Role.practitioner.name.toLowerCase()
              ? CustomBannerWidget(text: "Your profile is under review")
              : SizedBox.shrink(),
        ),
        CustomAppBarIcon(
          iconPath: Assets.notificationUnreadIcon,
          scale: 2,
          onTap: () {
            if (HelperFunctions.shouldShowProfileCompletBottomSheet() ) {
              HelperFunctions.showIncompleteProfileBottomSheet();
              return;
            } 
            Get.toNamed(AppRoutes.notificationScreen);
          },
        ),
      ],
    );
  }
}
