import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:medtrac/controllers/drawer_controller.dart';
import 'package:medtrac/custom_widgets/custom_text_widget.dart';
import 'package:medtrac/utils/app_colors.dart';
import 'package:medtrac/utils/assets.dart';
import 'package:medtrac/views/drawer/widget/drawer_widget.dart';

class AdvancedDrawerWrapper extends StatefulWidget {
  final Widget child;

  const AdvancedDrawerWrapper({super.key, required this.child});

  @override
  State<AdvancedDrawerWrapper> createState() => _AdvancedDrawerWrapperState();
}

class _AdvancedDrawerWrapperState extends State<AdvancedDrawerWrapper>
    with TickerProviderStateMixin {
  late final CustomDrawerController _customDrawerController;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _customDrawerController = Get.find<CustomDrawerController>();

    // Create animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Slide animation for drawer
    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Scale animation for main content
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Listen to drawer state changes with safety check
    _customDrawerController.isDrawerOpen.listen((isOpen) {
      if (_animationController.isCompleted == false &&
          _animationController.isDismissed == false) {
        // Animation is in progress, wait for it to complete
        return;
      }

      if (mounted) {
        if (isOpen) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      }
    });

    // Mark controller as initialized after animations are set up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _customDrawerController.setInitialized();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background (blue gradient)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Drawer content - positioned much lower
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    _slideAnimation.value *
                        MediaQuery.of(context).size.width *
                        0.75,
                    0),
                child: Padding(
                  padding: EdgeInsets.only(top: 190.h),
                  child: const DrawerWidget(),
                ),
              );
            },
          ),

          // Profile section - positioned independently at the top
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                    _slideAnimation.value *
                        MediaQuery.of(context).size.width *
                        0.75,
                    0),
                child: Padding(
                  padding: EdgeInsets.only(top: 80.h, right: 24.w, left: 16.w),
                  child: SizedBox(
                    height: 80.h, // Constrain the height to prevent expansion
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Now this will work properly
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.bright,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: EdgeInsets.all(5.0.r),
                                child: CircleAvatar(
                                backgroundImage: _customDrawerController.userProfilePhoto.isNotEmpty 
                                  ? NetworkImage(_customDrawerController.userProfilePhoto)
                                  : AssetImage(Assets.profileImage) as ImageProvider,
                                radius: 35.r,
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                            16.horizontalSpace,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                BodyTextOne(
                                  text: _customDrawerController.userName,
                                  color: AppColors.bright,
                                  fontWeight: FontWeight.w900,
                                ),
                                4.verticalSpace,
                                BodyTextOne(
                                  text: _customDrawerController.userEmail,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.bright,
                                ),
                              ],
                            ),
                          ],
                        ),
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            if (_animationController.value > 0) {
                              return GestureDetector(
                                onTap: () {
                                  _customDrawerController.closeDrawer();
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha:0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Main content
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  (1 - _slideAnimation.value.abs()) *
                      MediaQuery.of(context).size.width *
                      0.75,
                  180 *
                      (1 -
                          _slideAnimation.value
                              .abs()), // Push content down much more (180px instead of 60px)
                ),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        (180 *
                            (1 -
                                _slideAnimation.value
                                    .abs())), // Reduce height accordingly
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20.0,
                          spreadRadius: 5.0,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: widget.child,
                    ),
                  ),
                ),
              );
            },
          ),

          // Gesture detector for closing drawer - only cover the main content area
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              if (_animationController.value > 0) {
                return Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width *
                      0.25, // Only cover the right 25% where main content is
                  child: GestureDetector(
                    onTap: () {
                      _customDrawerController.closeDrawer();
                    },
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
