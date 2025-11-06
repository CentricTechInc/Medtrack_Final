import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/utils/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title; // Title of the AppBar
  final Widget? leading; // Custom leading widget (e.g., back button or icon)
  final List<Widget>? actions; // Optional actions in the AppBar
  final bool showBackArrow; // Whether to show a default back arrow or not
  final Color backgroundColor; // Background color of the AppBar
  final Widget? titleWidget;

  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.showBackArrow = false,
    this.backgroundColor =
        AppColors.scaffoldBackground, // Default dark background
    this.titleWidget,
  }) : assert(
          title == null || titleWidget == null,
          'Cannot provide both title and titleWidget',
        );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0, // No elevation when scrolled under
      backgroundColor: backgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false, // Prevent default leading widget
      leading: _buildLeadingWidget(context), // Pass context for navigation check
      title: Stack(
        alignment: Alignment.center,
        children: [
          if (title != null)
            Text(
              title!,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            )
          else if (titleWidget != null)
            Center(child: titleWidget!),
        ],
      ),
      centerTitle: true,
      actions: actions
          ?.map((action) => Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: action,
              ))
          .toList(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.h); // Default AppBar height

  /// **Leading Widget Logic**
  Widget? _buildLeadingWidget(BuildContext context) {
    // Store `leading` in a local variable to avoid Dart's field promotion issue
    final Widget? customLeading = leading;
    
    // Check if there's a previous route to navigate back to
    final bool canPop = Navigator.of(context).canPop();
    
    // Show back arrow if explicitly set or if there's a previous route
    if (customLeading == null && (showBackArrow || canPop)) {
      return GestureDetector(
        onTap: () => Get.back(),
        child: const Icon(
          Icons.arrow_back_ios_new,
        ),
      );
    } else {
      // Use custom leading if provided
      return customLeading;
    }
  }
}
